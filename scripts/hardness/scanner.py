"""Scanner: walk a target project and build a ProjectModel.

Stdlib-only, language-aware-ish via regex and AST (Python). Designed to be
robust against partial/odd repos rather than perfectly precise. Every claim
is tagged with a confidence label so downstream agents know what to trust.
"""
from __future__ import annotations

import ast
import json
import os
import re
from pathlib import Path

from .model import (
    CausalEdge,
    CausalNode,
    Constraint,
    Decision,
    Entity,
    Flow,
    Module,
    ProjectModel,
    Route,
)

# --- configuration -------------------------------------------------------

IGNORE_DIRS = {
    ".git", ".hg", ".svn", "node_modules", "__pycache__", ".venv", "venv",
    "env", ".mypy_cache", ".pytest_cache", ".ruff_cache", "dist", "build",
    ".next", ".nuxt", "target", "out", "coverage", ".idea", ".vscode",
    ".agent", ".wiki-tmp", ".work", "runs", "site", "deps", "vendor",
    "__MACOSX", ".cache", "logs", "tmp",
}

# Suffix-matched ignore patterns (e.g. *.egg-info build metadata).
IGNORE_DIR_SUFFIXES = (".egg-info", ".dist-info")

CODE_EXT = {
    ".py": "python", ".js": "javascript", ".jsx": "javascript",
    ".ts": "typescript", ".tsx": "typescript", ".go": "go", ".rs": "rust",
    ".java": "java", ".rb": "ruby", ".php": "php", ".cs": "csharp",
    ".c": "c", ".h": "c", ".cpp": "cpp", ".hpp": "cpp", ".sh": "shell",
    ".ps1": "powershell", ".sql": "sql",
}

CONFIG_FILES = {
    "package.json", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt",
    "Cargo.toml", "go.mod", "pom.xml", "build.gradle", "Gemfile", "composer.json",
    "Dockerfile", "docker-compose.yml", "docker-compose.yaml", "Makefile",
    ".env.example", "tsconfig.json", "vite.config.ts", "next.config.js",
}

DOC_EXT = {".md", ".rst", ".txt", ".adoc"}
SCHEMA_HINTS = ("schema", "migration", "models", "entities")
TEST_HINTS = ("test", "tests", "spec", "__tests__")

MAX_FILE_BYTES = 600_000
MAX_FILES = 6000


# --- file walking --------------------------------------------------------

def _iter_files(root: Path):
    count = 0
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames
                       if (d not in IGNORE_DIRS
                           and not d.endswith(IGNORE_DIR_SUFFIXES)
                           and (not d.startswith(".") or d in (".github",)))]
        for fn in filenames:
            count += 1
            if count > MAX_FILES:
                return
            yield Path(dirpath) / fn


def _read(path: Path) -> str:
    try:
        if path.stat().st_size > MAX_FILE_BYTES:
            return ""
        return path.read_text(encoding="utf-8", errors="replace")
    except (OSError, ValueError):
        return ""


def _rel(path: Path, root: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()


def _module_name(rel_path: str) -> str:
    """Group a file into a module.

    Goes up to 2 segments deep under common source roots so internal
    sub-packages (e.g. backend/engine, backend/providers) stay distinct and
    the dependency graph is meaningful.
    """
    parts = rel_path.split("/")
    if len(parts) == 1:
        return parts[0]
    roots = ("src", "lib", "app", "pkg", "internal", "backend", "frontend",
             "server", "client", "core", "packages")
    if parts[0] in roots and len(parts) >= 3:
        return "/".join(parts[:2])
    if len(parts) >= 2:
        return "/".join(parts[:2]) if len(parts) > 2 else parts[0]
    return parts[0]


# Files whose *contents* must never be read (secrets). Their existence is
# recorded as a module/constraint, but bytes are never opened.
SECRET_BASENAMES = {".env", ".env.local", ".env.production", ".env.dev",
                    "credentials.json", "secrets.json", "id_rsa", ".npmrc",
                    ".pypirc", ".netrc"}


def is_secret_file(rel_path: str) -> bool:
    base = os.path.basename(rel_path).lower()
    if base in SECRET_BASENAMES:
        return True
    # .env but not .env.example / .env.sample / .env.template
    if base.startswith(".env") and not base.endswith((".example", ".sample", ".template")):
        return True
    if base.endswith((".pem", ".key", ".pfx", ".p12")):
        return True
    return False


def classify_file(rel_path: str, ext: str) -> str:
    low = rel_path.lower()
    name = os.path.basename(low)
    if any(h in low.split("/") for h in TEST_HINTS) or name.startswith("test_") \
            or name.endswith(("_test.py", ".test.ts", ".test.js", ".spec.ts", ".spec.js")):
        return "test"
    if ext in DOC_EXT:
        return "docs"
    if name in {f.lower() for f in CONFIG_FILES} or ext in (".toml", ".ini", ".cfg", ".yaml", ".yml") \
            or name.startswith(".env"):
        return "config"
    if ext == ".sql" or any(h in low for h in SCHEMA_HINTS):
        return "schema"
    if ext in CODE_EXT:
        return "code"
    return "other"


# --- symbol / import extraction -----------------------------------------

_JS_IMPORT = re.compile(r"""(?:import\s+[^'"]*from\s+|require\(\s*)['"]([^'"]+)['"]""")
_JS_EXPORT = re.compile(r"export\s+(?:default\s+)?(?:async\s+)?(?:function|class|const|let|var)\s+([A-Za-z_$][\w$]*)")
_GO_IMPORT = re.compile(r'^\s*(?:import\s+)?"([^"]+)"', re.M)
_GO_FUNC = re.compile(r"^func\s+(?:\([^)]*\)\s+)?([A-Z]\w*)", re.M)


def extract_python(text: str) -> dict:
    out = {"imports": set(), "symbols": [], "calls": set()}
    try:
        tree = ast.parse(text)
    except SyntaxError:
        return out
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for n in node.names:
                out["imports"].add(n.name.split(".")[0])
                out["imports"].add(n.name)  # full dotted, for internal resolution
        elif isinstance(node, ast.ImportFrom):
            if node.module and node.level == 0:
                out["imports"].add(node.module.split(".")[0])
                out["imports"].add(node.module)
        elif isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)):
            if not node.name.startswith("_"):
                out["symbols"].append(node.name)
        elif isinstance(node, ast.Call):
            f = node.func
            if isinstance(f, ast.Attribute):
                out["calls"].add(f.attr)
            elif isinstance(f, ast.Name):
                out["calls"].add(f.id)
    return out


def extract_generic(text: str, language: str) -> dict:
    out = {"imports": set(), "symbols": [], "calls": set()}
    if language in ("javascript", "typescript"):
        out["imports"].update(m for m in _JS_IMPORT.findall(text) if not m.startswith("."))
        out["symbols"].extend(_JS_EXPORT.findall(text)[:40])
    elif language == "go":
        out["imports"].update(m for m in _GO_IMPORT.findall(text) if "/" in m or "." in m)
        out["symbols"].extend(_GO_FUNC.findall(text)[:40])
    return out


# --- route / endpoint extraction ----------------------------------------

_ROUTE_PATTERNS = [
    # FastAPI / Flask: @app.get("/x"), @router.post("/y")
    (re.compile(r"""@\w+\.(get|post|put|patch|delete|head|options)\(\s*['"]([^'"]+)['"]""", re.I), "py"),
    # Flask: @app.route("/x", methods=["POST"])
    (re.compile(r"""@\w+\.route\(\s*['"]([^'"]+)['"](?:.*?methods\s*=\s*\[([^\]]*)\])?""", re.I | re.S), "flask"),
    # Express: app.get('/x', / router.post("/y",
    (re.compile(r"""\b(?:app|router)\.(get|post|put|patch|delete|all)\(\s*['"]([^'"]+)['"]""", re.I), "express"),
    # Spring: @GetMapping("/x")
    (re.compile(r"""@(Get|Post|Put|Patch|Delete|Request)Mapping\(\s*(?:value\s*=\s*)?['"]([^'"]+)['"]""", re.I), "spring"),
]


def extract_routes(text: str, rel_path: str, module: str) -> list[Route]:
    routes: list[Route] = []
    for pat, flavor in _ROUTE_PATTERNS:
        for m in pat.finditer(text):
            groups = m.groups()
            if flavor == "flask":
                path, methods = groups[0], (groups[1] or "GET")
                for meth in re.findall(r"['\"](\w+)['\"]", methods) or ["GET"]:
                    routes.append(Route(method=meth.upper(), path=path, source=rel_path, module=module))
            else:
                method, path = groups[0], groups[1]
                routes.append(Route(method=method.upper(), path=path, source=rel_path, module=module))
    return routes


# --- entity / schema extraction -----------------------------------------

_PY_MODEL = re.compile(r"^class\s+(\w+)\s*\(([^)]*)\)\s*:", re.M)
_SQL_TABLE = re.compile(r"create\s+table\s+(?:if\s+not\s+exists\s+)?[`\"\[]?(\w+)", re.I)
_TS_INTERFACE = re.compile(r"(?:export\s+)?(?:interface|type)\s+([A-Z]\w+)")
_MODEL_BASES = ("Model", "Base", "BaseModel", "Document", "Schema", "Entity", "db.Model")


def extract_entities(text: str, rel_path: str, language: str) -> list[Entity]:
    ents: list[Entity] = []
    if language == "sql" or rel_path.lower().endswith(".sql"):
        for m in _SQL_TABLE.finditer(text):
            ents.append(Entity(name=m.group(1), source=rel_path, kind="table", confidence="EXTRACTED"))
    if language == "python":
        for m in _PY_MODEL.finditer(text):
            name, bases = m.group(1), m.group(2)
            if any(b in bases for b in _MODEL_BASES):
                ents.append(Entity(name=name, source=rel_path, kind="model", confidence="EXTRACTED"))
    if language in ("typescript", "javascript"):
        for m in _TS_INTERFACE.finditer(text):
            ents.append(Entity(name=m.group(1), source=rel_path, kind="schema", confidence="INFERRED"))
    return ents


# --- dependency manifests ------------------------------------------------

def parse_manifests(root: Path) -> tuple[list[str], list[str]]:
    """Return (external_deps, frameworks) from common manifest files."""
    deps: set[str] = set()
    frameworks: set[str] = set()
    fw_markers = {
        "fastapi": "FastAPI", "flask": "Flask", "django": "Django",
        "express": "Express", "react": "React", "next": "Next.js",
        "vue": "Vue", "svelte": "Svelte", "torch": "PyTorch",
        "tensorflow": "TensorFlow", "transformers": "HuggingFace",
        "spring-boot": "Spring Boot", "gin-gonic": "Gin", "actix": "Actix",
    }

    def note(name: str):
        deps.add(name)
        for marker, label in fw_markers.items():
            if marker in name.lower():
                frameworks.add(label)

    pj = root / "package.json"
    if pj.exists():
        try:
            data = json.loads(_read(pj) or "{}")
            for key in ("dependencies", "devDependencies"):
                for name in (data.get(key) or {}):
                    note(name)
        except json.JSONDecodeError:
            pass
    req = root / "requirements.txt"
    if req.exists():
        for line in (_read(req)).splitlines():
            line = line.strip()
            if line and not line.startswith("#"):
                note(re.split(r"[<>=!~\[]", line)[0].strip())
    pp = root / "pyproject.toml"
    if pp.exists():
        for m in re.finditer(r'^\s*["\']?([A-Za-z0-9_.\-]+)["\']?\s*[>=<~]', _read(pp), re.M):
            note(m.group(1))
    gm = root / "go.mod"
    if gm.exists():
        for m in re.finditer(r"^\s*([\w./\-]+)\s+v\d", _read(gm), re.M):
            note(m.group(1))
    return sorted(deps), sorted(frameworks)


# --- constraints & decisions --------------------------------------------

_CONSTRAINT_MARKERS = re.compile(
    r"(?:#|//|<!--)\s*(DO\s*NOT\s*(?:MODIFY|EDIT|TOUCH|CHANGE)|DONT\s*TOUCH|"
    r"FROZEN|IMMUTABLE|GENERATED\s*FILE|DO\s*NOT\s*EDIT)\b[:\s]*(.*)",
    re.I,
)


def extract_constraints(text: str, rel_path: str) -> list[Constraint]:
    out: list[Constraint] = []
    for m in _CONSTRAINT_MARKERS.finditer(text):
        out.append(Constraint(
            rule=f"Do not modify: {m.group(2).strip() or rel_path}",
            scope=rel_path, severity="block", source=f"{rel_path} (inline marker)",
            reason="Explicit do-not-modify marker in source.",
        ))
        break  # one per file is enough signal
    low = rel_path.lower()
    base = os.path.basename(low)
    if base in ("package-lock.json", "yarn.lock", "poetry.lock", "cargo.lock", "go.sum"):
        out.append(Constraint(rule=f"Lockfile — edit only via package manager: {rel_path}",
                              scope=rel_path, severity="block",
                              reason="Lockfiles are generated; manual edits break reproducibility.",
                              source=rel_path))
    if "migration" in low and low.endswith((".py", ".sql", ".js", ".ts")):
        out.append(Constraint(rule=f"Applied migration — do not rewrite history: {rel_path}",
                              scope=rel_path, severity="warn",
                              reason="Migrations may already be applied; rewriting corrupts schema state.",
                              source=rel_path))
    return out


def extract_decisions_from_git(root: Path) -> list[Decision]:
    """Pull decision-flavored commits from git log if available."""
    import subprocess
    decisions: list[Decision] = []
    try:
        res = subprocess.run(
            ["git", "-C", str(root), "log", "-n", "400", "--date=short",
             "--pretty=%ad%x1f%s%x1f%b%x1e"],
            capture_output=True, text=True, timeout=20, encoding="utf-8", errors="replace",
        )
        if res.returncode != 0:
            return decisions
    except (OSError, subprocess.SubprocessError):
        return decisions
    kw = re.compile(r"\b(decide|decision|adopt|switch to|migrate|deprecate|"
                    r"replace|refactor|breaking|redesign|rename|drop|remove support|architecture)\b", re.I)
    for chunk in res.stdout.split("\x1e"):
        chunk = chunk.strip()
        if not chunk:
            continue
        parts = chunk.split("\x1f")
        date = parts[0] if parts else ""
        subj = parts[1] if len(parts) > 1 else ""
        body = parts[2].strip() if len(parts) > 2 else ""
        if kw.search(subj) or kw.search(body[:200]):
            decisions.append(Decision(title=subj.strip(), date=date.strip(),
                                      rationale=body[:300].strip(), source="git log"))
        if len(decisions) >= 40:
            break
    return decisions


# --- orchestration -------------------------------------------------------

def _guess_responsibility(name: str, kind: str, files: list[str], symbols: list[str]) -> str:
    seg = name.split("/")[-1].lower()
    table = {
        "api": "Exposes API/HTTP endpoints", "routes": "HTTP routing layer",
        "models": "Data models / persisted entities", "schema": "Data schema definitions",
        "db": "Database access layer", "services": "Business-logic services",
        "engine": "Core processing engine", "core": "Core domain logic",
        "providers": "External provider integrations", "utils": "Shared utilities",
        "config": "Configuration", "auth": "Authentication / authorization",
        "ui": "User interface", "components": "UI components",
        "scripts": "Operational / build scripts", "cli": "Command-line interface",
        "tests": "Test suite", "handlers": "Request/event handlers",
    }
    if kind == "test":
        return "Test suite"
    if kind == "docs":
        return "Documentation"
    if kind == "config":
        return "Configuration and build setup"
    for key, val in table.items():
        if key in seg:
            return val
    if symbols:
        return f"Provides {', '.join(symbols[:3])}" + ("..." if len(symbols) > 3 else "")
    return "Project component (responsibility inferred from path)"


def scan_project(root_path: str, name: str | None = None) -> ProjectModel:
    root = Path(root_path).resolve()
    if not root.is_dir():
        raise NotADirectoryError(f"Not a directory: {root}")
    proj_name = name or root.name

    modules: dict[str, Module] = {}
    routes: list[Route] = []
    entities: dict[str, Entity] = {}
    constraints: list[Constraint] = []
    import_edges: dict[str, set[str]] = {}        # module -> module names (internal)
    lang_counts: dict[str, int] = {}
    file_total = 0

    for path in _iter_files(root):
        rel = _rel(path, root)
        ext = path.suffix.lower()
        kind = classify_file(rel, ext)
        if kind == "other" and ext not in CODE_EXT and os.path.basename(rel) not in CONFIG_FILES:
            continue
        file_total += 1
        language = CODE_EXT.get(ext, "")
        if language:
            lang_counts[language] = lang_counts.get(language, 0) + 1
        mod_name = _module_name(rel)
        mod = modules.get(mod_name)
        if mod is None:
            mod = Module(name=mod_name, path=mod_name, kind=kind)
            modules[mod_name] = mod
        mod.files.append(rel)
        if language and language not in mod.languages:
            mod.languages.append(language)
        # promote module kind toward most-specific signal
        if kind in ("route", "api", "schema") or (mod.kind == "code" and kind in ("schema",)):
            mod.kind = kind

        # NEVER read secret files — record existence as a constraint only.
        if is_secret_file(rel):
            constraints.append(Constraint(
                rule=f"Secret file — never read, log, or commit contents: {rel}",
                scope=rel, severity="block",
                reason="Contains credentials/secrets; hardness engine does not open it.",
                source=rel))
            continue

        text = _read(path)
        if not text:
            continue
        mod.loc += text.count("\n") + 1

        # symbols & imports
        if language == "python":
            ex = extract_python(text)
        else:
            ex = extract_generic(text, language)
        for sym in ex["symbols"]:
            if sym not in mod.public_symbols:
                mod.public_symbols.append(sym)
        import_edges.setdefault(mod_name, set())
        for imp in ex["imports"]:
            mod.external_deps.append(imp)

        # routes
        for r in extract_routes(text, rel, mod_name):
            routes.append(r)
            if mod.kind == "code":
                mod.kind = "api"

        # entities
        for e in extract_entities(text, rel, language):
            if e.name not in entities:
                entities[e.name] = e
            if mod_name not in entities[e.name].touched_by:
                entities[e.name].touched_by.append(mod_name)

        # constraints
        constraints.extend(extract_constraints(text, rel))

    # finalize modules: dedup external deps, responsibility, trim symbols
    internal_names = set(modules.keys())
    for mod in modules.values():
        mod.external_deps = sorted(set(mod.external_deps) - internal_names)[:25]
        mod.public_symbols = mod.public_symbols[:25]
        mod.files = mod.files[:60]
        mod.responsibility = _guess_responsibility(mod.name, mod.kind, mod.files, mod.public_symbols)

    deps, frameworks = parse_manifests(root)
    decisions = extract_decisions_from_git(root)
    primary_langs = sorted(lang_counts, key=lang_counts.get, reverse=True)[:4]

    model = ProjectModel(
        name=proj_name,
        root=str(root),
        primary_languages=primary_langs,
        frameworks=frameworks,
        modules=sorted(modules.values(), key=lambda m: m.name),
        entities=sorted(entities.values(), key=lambda e: e.name),
        routes=routes,
        constraints=constraints,
        decisions=decisions,
        stats={
            "files_scanned": file_total,
            "modules": len(modules),
            "routes": len(routes),
            "entities": len(entities),
            "external_deps": len(deps),
        },
    )
    return model
