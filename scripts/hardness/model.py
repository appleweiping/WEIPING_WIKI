"""Data model for the hardness causal layer.

Plain dataclasses, stdlib-only, JSON-serializable. These are the in-memory
representation of what gets written into ``.agent/``.
"""
from __future__ import annotations

import dataclasses
from dataclasses import dataclass, field
from typing import Any


def _clean(obj: Any) -> Any:
    """Recursively convert dataclasses/sets to JSON-safe structures."""
    if dataclasses.is_dataclass(obj) and not isinstance(obj, type):
        return {k: _clean(v) for k, v in dataclasses.asdict(obj).items()}
    if isinstance(obj, dict):
        return {k: _clean(v) for k, v in obj.items()}
    if isinstance(obj, (list, tuple)):
        return [_clean(v) for v in obj]
    if isinstance(obj, set):
        return sorted(_clean(v) for v in obj)
    return obj


@dataclass
class Module:
    """A cohesive unit of the project (usually a directory or salient file)."""
    name: str
    path: str                              # repo-relative
    kind: str = "code"                     # code|route|api|schema|config|test|docs
    languages: list[str] = field(default_factory=list)
    responsibility: str = ""               # inferred one-line role
    files: list[str] = field(default_factory=list)
    public_symbols: list[str] = field(default_factory=list)
    depends_on: list[str] = field(default_factory=list)   # other module names
    depended_by: list[str] = field(default_factory=list)
    external_deps: list[str] = field(default_factory=list)
    loc: int = 0
    confidence: str = "INFERRED"           # EXTRACTED|INFERRED|AMBIGUOUS|UNVERIFIED


@dataclass
class Entity:
    """A domain entity / persisted record / core data structure."""
    name: str
    source: str = ""                       # where defined (file:line)
    kind: str = "model"                    # model|table|schema|enum|config-key
    fields: list[str] = field(default_factory=list)
    lifecycle: list[str] = field(default_factory=list)  # created/read/updated/deleted at
    touched_by: list[str] = field(default_factory=list)  # module names
    confidence: str = "INFERRED"


@dataclass
class Route:
    """An API route / HTTP endpoint / CLI command surface."""
    method: str
    path: str
    handler: str = ""
    source: str = ""
    module: str = ""
    confidence: str = "EXTRACTED"


@dataclass
class Flow:
    """A business/process flow: an ordered chain of steps across modules."""
    name: str
    trigger: str = ""
    steps: list[str] = field(default_factory=list)
    modules: list[str] = field(default_factory=list)
    entities: list[str] = field(default_factory=list)
    confidence: str = "INFERRED"


@dataclass
class CausalNode:
    id: str
    kind: str                              # module|entity|route|external|test|config
    label: str = ""


@dataclass
class CausalEdge:
    src: str
    dst: str
    relation: str                          # imports|calls|reads|writes|tests|configures|routes-to
    confidence: str = "INFERRED"


@dataclass
class Constraint:
    """A do-not-modify boundary or invariant the agent must respect."""
    rule: str
    scope: str = ""                        # path or module
    reason: str = ""
    severity: str = "warn"                 # block|warn|note
    source: str = ""                       # where the rule came from


@dataclass
class Decision:
    """A historical decision worth preserving (from git, docs, or markers)."""
    title: str
    date: str = ""
    rationale: str = ""
    source: str = ""


@dataclass
class ProjectModel:
    """The complete hardened model of one project."""
    name: str
    root: str
    generated_at: str = ""
    engine_version: str = ""
    primary_languages: list[str] = field(default_factory=list)
    frameworks: list[str] = field(default_factory=list)
    summary: str = ""
    modules: list[Module] = field(default_factory=list)
    entities: list[Entity] = field(default_factory=list)
    routes: list[Route] = field(default_factory=list)
    flows: list[Flow] = field(default_factory=list)
    constraints: list[Constraint] = field(default_factory=list)
    decisions: list[Decision] = field(default_factory=list)
    nodes: list[CausalNode] = field(default_factory=list)
    edges: list[CausalEdge] = field(default_factory=list)
    glossary: dict[str, str] = field(default_factory=dict)
    stats: dict[str, Any] = field(default_factory=dict)

    def to_json(self) -> dict[str, Any]:
        return _clean(self)
