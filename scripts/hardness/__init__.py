"""project-hardness engine.

Turns any target project into an AI-readable, maintainable, verifiable
causal layer, written to ``<project>/.agent/``.

This is *not* grep, an index, or chat memory. It is a static, source-backed
model of a project: module responsibilities, business flows, entity/variable
lifecycles, call chains, dependencies, blast radius, do-not-modify boundaries,
and historical decisions.

Boundary contract (see wiki/concepts/project-hardness-system.md):
  - The engine lives in WEIPING_WIKI.
  - Generated facts live in the target project's ``.agent/`` (project-local).
  - Only cross-project *reusable lessons* are synced to agentmemory.
  - Project facts must never pollute global memory.
"""

__version__ = "0.1.0"
