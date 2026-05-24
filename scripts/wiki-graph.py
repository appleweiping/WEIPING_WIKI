"""
wiki-graph.py — Knowledge graph query interface for Vipin's Knowledgebase.

Loads graphify-out/graph.json and provides rich query capabilities:
  - Node search by label, concept, or file
  - Neighborhood traversal (what connects to X?)
  - Path finding between two concepts
  - Community/cluster listing
  - God-node detection (highest-degree nodes)
  - Cross-domain bridge detection
  - Export subgraphs as Markdown or JSON

Usage:
    python scripts/wiki-graph.py search "conformal prediction"
    python scripts/wiki-graph.py neighbors "conformal prediction" --depth 2
    python scripts/wiki-graph.py path "conformal prediction" "LLM4Rec"
    python scripts/wiki-graph.py communities
    python scripts/wiki-graph.py gods --top 20
    python scripts/wiki-graph.py bridges
    python scripts/wiki-graph.py stats
    python scripts/wiki-graph.py export "conformal prediction" --depth 2 --format md
"""
from __future__ import annotations

import argparse
import json
import sys
from collections import defaultdict, deque
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

REPO_ROOT = Path(__file__).resolve().parent.parent
GRAPH_FILE = REPO_ROOT / "graphify-out" / "graph.json"

# ── Data model ─────────────────────────────────────────────────────────────────

@dataclass
class Node:
    id: str
    label: str
    file_type: str = ""
    source_file: str = ""
    source_location: str = ""
    community: int = -1
    degree: int = 0
    metadata: dict = field(default_factory=dict)

    def display(self) -> str:
        parts = [self.label]
        if self.source_file:
            parts.append(f"← {self.source_file}")
        if self.community >= 0:
            parts.append(f"[cluster {self.community}]")
        return "  ".join(parts)


@dataclass
class Edge:
    source: str
    target: str
    relation: str = ""
    weight: float = 1.0


@dataclass
class Graph:
    nodes: dict[str, Node]
    edges: list[Edge]
    adj: dict[str, list[str]]       # node_id → [neighbor_ids]
    radj: dict[str, list[str]]      # reverse adjacency
    communities: dict[int, list[str]]  # community_id → [node_ids]
    meta: dict

    @classmethod
    def load(cls, path: Path) -> "Graph":
        if not path.exists():
            print(f"Graph file not found: {path}", file=sys.stderr)
            print("Run: python scripts/graphify-extract.py --update", file=sys.stderr)
            sys.exit(1)

        raw = json.loads(path.read_text(encoding="utf-8"))
        nodes: dict[str, Node] = {}
        edges: list[Edge] = []
        adj: dict[str, list[str]] = defaultdict(list)
        radj: dict[str, list[str]] = defaultdict(list)
        communities: dict[int, list[str]] = defaultdict(list)

        for n in raw.get("nodes", []):
            node = Node(
                id=n["id"],
                label=n.get("label", n["id"]),
                file_type=n.get("file_type", ""),
                source_file=n.get("source_file", ""),
                source_location=n.get("source_location", ""),
                community=n.get("community", -1),
                metadata={k: v for k, v in n.items()
                          if k not in ("id", "label", "file_type", "source_file",
                                       "source_location", "community")},
            )
            nodes[node.id] = node
            if node.community >= 0:
                communities[node.community].append(node.id)

        for e in raw.get("edges", []):
            edge = Edge(
                source=e.get("source", e.get("from", "")),
                target=e.get("target", e.get("to", "")),
                relation=e.get("relation", e.get("type", "")),
                weight=float(e.get("weight", 1.0)),
            )
            if edge.source and edge.target:
                edges.append(edge)
                adj[edge.source].append(edge.target)
                radj[edge.target].append(edge.source)

        # Compute degree
        for node_id, node in nodes.items():
            node.degree = len(adj[node_id]) + len(radj[node_id])

        meta = {k: v for k, v in raw.items() if k not in ("nodes", "edges")}
        return cls(nodes=nodes, edges=edges, adj=dict(adj), radj=dict(radj),
                   communities=dict(communities), meta=meta)

    def search_nodes(self, query: str, top: int = 20) -> list[Node]:
        """Find nodes matching query by label, source_file, or id."""
        q = query.lower()
        scored: list[tuple[float, Node]] = []
        for node in self.nodes.values():
            score = 0.0
            label_lower = node.label.lower()
            if q == label_lower:
                score = 10.0
            elif label_lower.startswith(q):
                score = 7.0
            elif q in label_lower:
                score = 5.0
            elif q in node.source_file.lower():
                score = 3.0
            elif q in node.id.lower():
                score = 2.0
            if score > 0:
                scored.append((score, node))
        scored.sort(key=lambda x: (-x[0], x[1].label))
        return [n for _, n in scored[:top]]

    def neighbors(self, node_id: str, depth: int = 1) -> dict[str, set[str]]:
        """BFS neighborhood. Returns {node_id: set_of_relation_labels}."""
        if node_id not in self.nodes:
            return {}
        visited: dict[str, int] = {node_id: 0}
        queue = deque([(node_id, 0)])
        result: dict[str, set[str]] = defaultdict(set)

        # Build edge lookup
        edge_map: dict[tuple[str, str], list[str]] = defaultdict(list)
        for e in self.edges:
            edge_map[(e.source, e.target)].append(e.relation or "→")
            edge_map[(e.target, e.source)].append(f"←{e.relation or ''}")

        while queue:
            current, d = queue.popleft()
            if d >= depth:
                continue
            for neighbor in (self.adj.get(current, []) + self.radj.get(current, [])):
                rels = edge_map.get((current, neighbor), []) + edge_map.get((neighbor, current), [])
                result[neighbor].update(rels)
                if neighbor not in visited:
                    visited[neighbor] = d + 1
                    queue.append((neighbor, d + 1))

        result.pop(node_id, None)
        return dict(result)

    def find_path(self, src_id: str, dst_id: str, max_depth: int = 6) -> Optional[list[str]]:
        """BFS shortest path between two nodes. Returns list of node IDs or None."""
        if src_id not in self.nodes or dst_id not in self.nodes:
            return None
        if src_id == dst_id:
            return [src_id]
        visited = {src_id: None}
        queue = deque([src_id])
        while queue:
            current = queue.popleft()
            depth = 0
            n = current
            while visited[n] is not None:
                n = visited[n]
                depth += 1
            if depth >= max_depth:
                continue
            for neighbor in (self.adj.get(current, []) + self.radj.get(current, [])):
                if neighbor not in visited:
                    visited[neighbor] = current
                    if neighbor == dst_id:
                        # Reconstruct path
                        path = [dst_id]
                        node = current
                        while node is not None:
                            path.append(node)
                            node = visited[node]
                        return list(reversed(path))
                    queue.append(neighbor)
        return None

    def god_nodes(self, top: int = 20) -> list[Node]:
        """Highest-degree nodes (hubs)."""
        return sorted(self.nodes.values(), key=lambda n: -n.degree)[:top]

    def bridge_nodes(self) -> list[Node]:
        """Nodes that connect different communities (cross-domain bridges)."""
        bridges = []
        for node in self.nodes.values():
            if node.community < 0:
                continue
            neighbor_communities = set()
            for nb_id in (self.adj.get(node.id, []) + self.radj.get(node.id, [])):
                nb = self.nodes.get(nb_id)
                if nb and nb.community >= 0 and nb.community != node.community:
                    neighbor_communities.add(nb.community)
            if len(neighbor_communities) >= 2:
                node.metadata["bridge_communities"] = sorted(neighbor_communities)
                bridges.append(node)
        return sorted(bridges, key=lambda n: -len(n.metadata.get("bridge_communities", [])))


# ── Formatting ─────────────────────────────────────────────────────────────────

RESET = "\033[0m"; BOLD = "\033[1m"; DIM = "\033[2m"
CYAN = "\033[36m"; YELLOW = "\033[33m"; GREEN = "\033[32m"; MAGENTA = "\033[35m"

def c(text, *codes): return "".join(codes) + str(text) + RESET
def hr(w=72): return c("─" * w, DIM)


def print_node(node: Node, indent: str = "  "):
    print(f"{indent}{c(node.label, BOLD, CYAN)}")
    if node.source_file:
        print(f"{indent}  {c(node.source_file, DIM)}")
    if node.community >= 0:
        print(f"{indent}  cluster {node.community}  degree {node.degree}")


def format_node_md(node: Node) -> str:
    parts = [f"**{node.label}**"]
    if node.source_file:
        parts.append(f"`{node.source_file}`")
    return " — ".join(parts)


# ── Commands ───────────────────────────────────────────────────────────────────

def cmd_search(args, graph: Graph):
    results = graph.search_nodes(args.query, top=args.top)
    if not results:
        print(f"No nodes found for: {args.query}")
        return
    print(f"\n{c('Search results', BOLD)} for {c(args.query, CYAN)} ({len(results)} found)\n{hr()}")
    for node in results:
        print_node(node)
    print()


def cmd_neighbors(args, graph: Graph):
    matches = graph.search_nodes(args.query, top=5)
    if not matches:
        print(f"No node found for: {args.query}")
        return
    node = matches[0]
    print(f"\n{c('Neighbors of', BOLD)} {c(node.label, CYAN)} (depth={args.depth})\n{hr()}")

    nbrs = graph.neighbors(node.id, depth=args.depth)
    if not nbrs:
        print("  No neighbors found.")
        return

    # Group by community
    by_community: dict[int, list[tuple[str, set[str]]]] = defaultdict(list)
    for nb_id, rels in nbrs.items():
        nb = graph.nodes.get(nb_id)
        if nb:
            by_community[nb.community].append((nb_id, rels))

    for comm_id, items in sorted(by_community.items()):
        print(f"\n  {c(f'Cluster {comm_id}', YELLOW)} ({len(items)} nodes)")
        for nb_id, rels in sorted(items, key=lambda x: graph.nodes[x[0]].label):
            nb = graph.nodes[nb_id]
            rel_str = ", ".join(sorted(rels)[:3])
            print(f"    {c(nb.label, BOLD)}  {c(rel_str, DIM)}")
    print()


def cmd_path(args, graph: Graph):
    src_matches = graph.search_nodes(args.source, top=3)
    dst_matches = graph.search_nodes(args.target, top=3)
    if not src_matches:
        print(f"Source not found: {args.source}")
        return
    if not dst_matches:
        print(f"Target not found: {args.target}")
        return

    src, dst = src_matches[0], dst_matches[0]
    print(f"\n{c('Path', BOLD)}: {c(src.label, CYAN)} → {c(dst.label, CYAN)}\n{hr()}")

    path = graph.find_path(src.id, dst.id, max_depth=args.max_depth)
    if path is None:
        print(f"  No path found within depth {args.max_depth}.")
        return

    print(f"  Length: {len(path) - 1} hops\n")
    for i, node_id in enumerate(path):
        node = graph.nodes.get(node_id)
        if node:
            prefix = "  " + "  " * i
            arrow = "→ " if i > 0 else "  "
            print(f"{prefix}{arrow}{c(node.label, BOLD)}  {c(node.source_file, DIM)}")
    print()


def cmd_communities(args, graph: Graph):
    print(f"\n{c('Communities / Clusters', BOLD)}\n{hr()}")
    for comm_id, node_ids in sorted(graph.communities.items()):
        nodes = [graph.nodes[nid] for nid in node_ids if nid in graph.nodes]
        if not nodes:
            continue
        # Find representative (highest degree)
        rep = max(nodes, key=lambda n: n.degree)
        # Sample labels
        sample = sorted(nodes, key=lambda n: -n.degree)[:5]
        sample_str = ", ".join(c(n.label, CYAN) for n in sample)
        print(f"\n  {c(f'Cluster {comm_id}', BOLD, YELLOW)} ({len(nodes)} nodes)")
        print(f"  Representative: {c(rep.label, BOLD)}")
        print(f"  Top nodes: {sample_str}")
    print()


def cmd_gods(args, graph: Graph):
    gods = graph.god_nodes(top=args.top)
    print(f"\n{c('God Nodes', BOLD)} (highest degree)\n{hr()}")
    print(f"  {'Label':<40} {'Degree':<8} {'Cluster':<10} Source")
    print(f"  {'─'*40} {'─'*8} {'─'*10} {'─'*30}")
    for node in gods:
        comm = str(node.community) if node.community >= 0 else "—"
        src = node.source_file[:35] if node.source_file else "—"
        print(f"  {c(node.label[:40], BOLD):<50} {node.degree:<8} {comm:<10} {c(src, DIM)}")
    print()


def cmd_bridges(args, graph: Graph):
    bridges = graph.bridge_nodes()[:args.top]
    print(f"\n{c('Bridge Nodes', BOLD)} (cross-domain connectors)\n{hr()}")
    for node in bridges:
        comms = node.metadata.get("bridge_communities", [])
        print(f"\n  {c(node.label, BOLD, MAGENTA)}")
        print(f"  Connects clusters: {', '.join(str(c) for c in comms)}")
        print(f"  Source: {c(node.source_file, DIM)}")
    if not bridges:
        print("  No bridge nodes found.")
    print()


def cmd_stats(args, graph: Graph):
    n_nodes = len(graph.nodes)
    n_edges = len(graph.edges)
    n_communities = len(graph.communities)
    avg_degree = sum(n.degree for n in graph.nodes.values()) / max(n_nodes, 1)
    max_degree = max((n.degree for n in graph.nodes.values()), default=0)
    file_types = defaultdict(int)
    for node in graph.nodes.values():
        file_types[node.file_type or "unknown"] += 1

    print(f"\n{c('Knowledge Graph Statistics', BOLD)}\n{hr()}")
    print(f"  Nodes:       {c(str(n_nodes), CYAN)}")
    print(f"  Edges:       {c(str(n_edges), CYAN)}")
    print(f"  Communities: {c(str(n_communities), CYAN)}")
    print(f"  Avg degree:  {c(f'{avg_degree:.1f}', CYAN)}")
    print(f"  Max degree:  {c(str(max_degree), CYAN)}")
    print(f"\n  Node types:")
    for ft, count in sorted(file_types.items(), key=lambda x: -x[1]):
        print(f"    {ft:<20} {count}")
    print()


def cmd_export(args, graph: Graph):
    matches = graph.search_nodes(args.query, top=3)
    if not matches:
        print(f"No node found for: {args.query}")
        return
    node = matches[0]
    nbrs = graph.neighbors(node.id, depth=args.depth)

    if args.format == "json":
        subgraph = {
            "center": {"id": node.id, "label": node.label, "source": node.source_file},
            "neighbors": [
                {"id": nb_id, "label": graph.nodes[nb_id].label,
                 "source": graph.nodes[nb_id].source_file,
                 "relations": sorted(rels)}
                for nb_id, rels in nbrs.items() if nb_id in graph.nodes
            ],
        }
        print(json.dumps(subgraph, indent=2, ensure_ascii=False))
    else:
        # Markdown
        lines = [
            f"# Subgraph: {node.label}",
            "",
            f"**Source**: `{node.source_file}`  ",
            f"**Cluster**: {node.community}  ",
            f"**Degree**: {node.degree}",
            "",
            f"## Neighbors (depth={args.depth})",
            "",
        ]
        by_community: dict[int, list] = defaultdict(list)
        for nb_id, rels in nbrs.items():
            nb = graph.nodes.get(nb_id)
            if nb:
                by_community[nb.community].append((nb, rels))
        for comm_id, items in sorted(by_community.items()):
            lines.append(f"### Cluster {comm_id}")
            for nb, rels in sorted(items, key=lambda x: x[0].label):
                rel_str = ", ".join(sorted(rels)[:3])
                lines.append(f"- **{nb.label}** ({rel_str}) — `{nb.source_file}`")
            lines.append("")
        print("\n".join(lines))


# ── Entry point ────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        prog="wiki-graph",
        description="Knowledge graph query interface",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("search", help="Search nodes by label/concept")
    p.add_argument("query")
    p.add_argument("--top", type=int, default=20)
    p.set_defaults(func=cmd_search)

    p = sub.add_parser("neighbors", help="Show neighborhood of a node")
    p.add_argument("query")
    p.add_argument("--depth", type=int, default=1)
    p.set_defaults(func=cmd_neighbors)

    p = sub.add_parser("path", help="Find shortest path between two concepts")
    p.add_argument("source")
    p.add_argument("target")
    p.add_argument("--max-depth", type=int, default=6)
    p.set_defaults(func=cmd_path)

    p = sub.add_parser("communities", help="List all communities/clusters")
    p.set_defaults(func=cmd_communities)

    p = sub.add_parser("gods", help="Show highest-degree hub nodes")
    p.add_argument("--top", type=int, default=20)
    p.set_defaults(func=cmd_gods)

    p = sub.add_parser("bridges", help="Show cross-domain bridge nodes")
    p.add_argument("--top", type=int, default=20)
    p.set_defaults(func=cmd_bridges)

    p = sub.add_parser("stats", help="Graph statistics")
    p.set_defaults(func=cmd_stats)

    p = sub.add_parser("export", help="Export subgraph as Markdown or JSON")
    p.add_argument("query")
    p.add_argument("--depth", type=int, default=2)
    p.add_argument("--format", choices=["md", "json"], default="md")
    p.set_defaults(func=cmd_export)

    args = parser.parse_args()
    graph = Graph.load(GRAPH_FILE)
    args.func(args, graph)


if __name__ == "__main__":
    main()
