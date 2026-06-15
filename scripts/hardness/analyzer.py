"""Analyzer: derive the causal graph, dependencies, blast radius, and flows
from a scanned ProjectModel.

This is the "causal layer" step — it turns a flat inventory into a graph of
what affects what, so an agent can answer "if I change X, what breaks?".
"""
from __future__ import annotations

import re
from pathlib import Path

from .model import CausalEdge, CausalNode, Flow, ProjectModel


def _resolve_internal(dep: str, module_paths: dict[str, str], names: set[str]) -> str | None:
    """Best-effort: map an import token to an internal module name.

    Module names use '/' separators (e.g. 'backend/engine'); Python imports use
    '.' (e.g. 'backend.engine.council'). Normalize and match on prefix/leaf.
    """
    if dep in names:
        return dep
    norm = dep.replace("\\", "/").replace(".", "/")
    if norm in names:
        return norm
    candidates = [n for n in names
                  if norm == n or norm.startswith(n + "/") or n.startswith(norm + "/")]
    if candidates:
        return max(candidates, key=len)
    head = norm.split("/")[0]
    if head in names:
        return head
    for name in names:
        leaf = name.split("/")[-1]
        if leaf == head or leaf == norm:
            return name
    return None


def build_causal_graph(model: ProjectModel) -> None:
    """Populate model.nodes / model.edges / depends_on / depended_by in place."""
    names = {m.name for m in model.modules}
    module_paths = {m.name: m.path for m in model.modules}
    nodes: list[CausalNode] = []
    edges: list[CausalEdge] = []
    seen_edges: set[tuple] = set()

    for m in model.modules:
        nodes.append(CausalNode(id=f"module:{m.name}", kind="module", label=m.name))

    # module -> module dependency edges, resolved from raw imports
    for m in model.modules:
        resolved: set[str] = set()
        for dep in list(m.external_deps):
            tgt = _resolve_internal(dep, module_paths, names)
            if tgt and tgt != m.name:
                resolved.add(tgt)
        # also infer from import tokens still carrying internal hints
        for tgt in sorted(resolved):
            m.depends_on.append(tgt)
            key = (m.name, tgt, "imports")
            if key not in seen_edges:
                edges.append(CausalEdge(src=f"module:{m.name}", dst=f"module:{tgt}",
                                        relation="imports", confidence="INFERRED"))
                seen_edges.add(key)
        # keep external_deps as purely-external (strip resolved internals)
        m.external_deps = [d for d in m.external_deps
                           if _resolve_internal(d, module_paths, names) is None][:25]
        m.depends_on = sorted(set(m.depends_on))

    # reverse edges
    rev: dict[str, list[str]] = {}
    for m in model.modules:
        for tgt in m.depends_on:
            rev.setdefault(tgt, []).append(m.name)
    for m in model.modules:
        m.depended_by = sorted(set(rev.get(m.name, [])))

    # route nodes/edges
    for r in model.routes:
        nid = f"route:{r.method} {r.path}"
        nodes.append(CausalNode(id=nid, kind="route", label=f"{r.method} {r.path}"))
        if r.module:
            edges.append(CausalEdge(src=nid, dst=f"module:{r.module}",
                                    relation="routes-to", confidence="EXTRACTED"))

    # entity nodes/edges
    for e in model.entities:
        nid = f"entity:{e.name}"
        nodes.append(CausalNode(id=nid, kind="entity", label=e.name))
        for mod in e.touched_by:
            edges.append(CausalEdge(src=f"module:{mod}", dst=nid,
                                    relation="reads/writes", confidence="INFERRED"))

    model.nodes = nodes
    model.edges = edges


def blast_radius(model: ProjectModel, module_name: str, max_depth: int = 3) -> dict:
    """What is impacted if `module_name` changes — transitive dependents."""
    rev: dict[str, set[str]] = {}
    for m in model.modules:
        for tgt in m.depends_on:
            rev.setdefault(tgt, set()).add(m.name)
    impacted: dict[str, int] = {}
    frontier = {module_name}
    depth = 0
    while frontier and depth < max_depth:
        depth += 1
        nxt: set[str] = set()
        for node in frontier:
            for dep in rev.get(node, set()):
                if dep not in impacted:
                    impacted[dep] = depth
                    nxt.add(dep)
        frontier = nxt
    tests = sorted({m.name for m in model.modules if m.kind == "test"
                    and (module_name in m.depends_on or module_name in impacted)})
    return {
        "module": module_name,
        "direct_dependents": sorted([k for k, v in impacted.items() if v == 1]),
        "transitive_dependents": sorted([k for k, v in impacted.items() if v > 1]),
        "impacted_total": len(impacted),
        "related_tests": tests,
    }


def infer_flows(model: ProjectModel) -> list[Flow]:
    """Derive coarse business flows: route -> handler module -> dependencies."""
    flows: list[Flow] = []
    by_name = {m.name: m for m in model.modules}
    for r in model.routes[:30]:
        mod = by_name.get(r.module)
        chain = [r.module] + (mod.depends_on[:4] if mod else [])
        ents = sorted({e.name for e in model.entities
                       if r.module in e.touched_by})
        flows.append(Flow(
            name=f"{r.method} {r.path}",
            trigger=f"HTTP {r.method} request to {r.path}",
            steps=[f"Route {r.method} {r.path}",
                   f"Handled in module '{r.module}'"]
                  + [f"Calls into '{d}'" for d in (mod.depends_on[:4] if mod else [])]
                  + ([f"Touches entities: {', '.join(ents[:5])}"] if ents else []),
            modules=[c for c in chain if c],
            entities=ents,
            confidence="INFERRED",
        ))
    return flows


_GLOSSARY_STOP = {"the", "and", "for", "with", "test", "main", "init", "index", "utils"}


def build_glossary(model: ProjectModel) -> dict[str, str]:
    """Seed a glossary from entity names, frameworks, and recurring symbols."""
    g: dict[str, str] = {}
    for e in model.entities:
        g[e.name] = f"{e.kind.title()} defined in {e.source or 'project'} (lifecycle: {', '.join(e.touched_by[:4]) or 'unknown'})."
    for fw in model.frameworks:
        g.setdefault(fw, f"Framework/library used by the project.")
    # recurring public symbols across modules → likely domain terms
    freq: dict[str, int] = {}
    for m in model.modules:
        for s in m.public_symbols:
            if len(s) > 3 and s.lower() not in _GLOSSARY_STOP:
                freq[s] = freq.get(s, 0) + 1
    for sym, n in sorted(freq.items(), key=lambda kv: kv[1], reverse=True)[:25]:
        g.setdefault(sym, f"Symbol referenced in {n} module(s); inferred domain term (verify).")
    return dict(sorted(g.items()))


def analyze(model: ProjectModel) -> ProjectModel:
    build_causal_graph(model)
    model.flows = infer_flows(model)
    model.glossary = build_glossary(model)
    if not model.summary:
        langs = ", ".join(model.primary_languages) or "mixed"
        fw = ", ".join(model.frameworks) or "no detected framework"
        model.summary = (f"{model.name}: {model.stats.get('modules', 0)} modules, "
                         f"{model.stats.get('routes', 0)} routes, "
                         f"{model.stats.get('entities', 0)} entities. "
                         f"Primary languages: {langs}. Frameworks: {fw}.")
    return model
