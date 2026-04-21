#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_REGISTRY_SCRIPT="$SCRIPT_DIR/source-registry.sh"

REQUIRED_PATHS=(
  ".wiki-schema.md"
  "WORKFLOWS.md"
  "purpose.md"
  "raw"
  "wiki"
  "wiki/home.md"
  "wiki/overview.md"
  "wiki/index.md"
  "wiki/log.md"
  "wiki/entities"
  "wiki/concepts"
  "wiki/topics"
  "wiki/sources"
  "wiki/analyses"
  "wiki/comparisons"
  "wiki/queries"
  "wiki/synthesis"
  "wiki/synthesis/sessions"
  "wiki/timelines"
  "wiki/_templates"
  "scripts"
)

usage() {
  cat <<'EOF'
Usage:
  bash scripts/wiki-compat.sh inspect <wiki_root>
  bash scripts/wiki-compat.sh validate <wiki_root>
  bash scripts/wiki-compat.sh ensure-source-dir <wiki_root> <source_id>
EOF
}

require_wiki_root() {
  local wiki_root="$1"
  [ -n "$wiki_root" ] || { usage; exit 1; }
  [ -d "$wiki_root" ] || {
    echo "Wiki root not found: $wiki_root" >&2
    exit 1
  }
}

file_presence() {
  local wiki_root="$1"
  local relative_path="$2"
  if [ -e "$wiki_root/$relative_path" ]; then
    printf 'present\n'
  else
    printf 'missing\n'
  fi
}

infer_language() {
  local wiki_root="$1"
  if [ ! -f "$wiki_root/purpose.md" ]; then
    printf 'unknown\n'
    return 0
  fi
  if grep -qi 'language:.*english' "$wiki_root/purpose.md"; then
    printf 'en\n'
  elif grep -qi 'language:.*chinese' "$wiki_root/purpose.md"; then
    printf 'zh\n'
  else
    printf 'mixed\n'
  fi
}

validate_layout() {
  local wiki_root="$1"
  local failed=0
  local path

  require_wiki_root "$wiki_root"

  for path in "${REQUIRED_PATHS[@]}"; do
    if [ ! -e "$wiki_root/$path" ]; then
      echo "Missing required path: $path" >&2
      failed=1
    fi
  done

  if [ "$failed" -ne 0 ]; then
    exit 1
  fi
}

missing_optional_raw_dirs() {
  local wiki_root="$1"
  local raw_dir
  local missing=()
  while IFS= read -r raw_dir; do
    [ -n "$raw_dir" ] || continue
    if [ ! -d "$wiki_root/$raw_dir" ]; then
      missing+=("$raw_dir")
    fi
  done < <(bash "$SOURCE_REGISTRY_SCRIPT" list | awk -F '\t' 'NR > 1 { print $6 }' | LC_ALL=C sort -u)

  if [ "${#missing[@]}" -eq 0 ]; then
    printf '%s\n' '-'
  else
    local IFS=,
    printf '%s\n' "${missing[*]}"
  fi
}

print_inspect() {
  local wiki_root="$1"
  local purpose_file cache_file optional_dirs

  validate_layout "$wiki_root"
  purpose_file="$(file_presence "$wiki_root" "purpose.md")"
  cache_file="$(file_presence "$wiki_root" ".wiki-cache.json")"
  optional_dirs="$(missing_optional_raw_dirs "$wiki_root")"

  printf 'wiki_root=%s\n' "$wiki_root"
  printf 'schema_version=%s\n' "2.0"
  printf 'language=%s\n' "$(infer_language "$wiki_root")"
  printf 'legacy_mode=%s\n' "no"
  printf 'migration_required=%s\n' "no"
  printf 'missing_optional_raw_dirs=%s\n' "$optional_dirs"
  printf 'purpose_file=%s\n' "$purpose_file"
  printf 'cache_file=%s\n' "$cache_file"
}

ensure_source_dir() {
  local wiki_root="$1"
  local source_id="$2"
  local record raw_dir

  validate_layout "$wiki_root"
  record="$(bash "$SOURCE_REGISTRY_SCRIPT" get "$source_id")" || {
    echo "Unknown source id: $source_id" >&2
    exit 1
  }

  IFS=$'\t' read -r _ _ _ _ _ raw_dir _ _ _ _ <<EOF
$record
EOF

  mkdir -p "$wiki_root/$raw_dir"
  printf '%s\n' "$wiki_root/$raw_dir"
}

command_name="${1:-}"

case "$command_name" in
  inspect)
    [ "$#" -eq 2 ] || { usage; exit 1; }
    print_inspect "$2"
    ;;
  validate)
    [ "$#" -eq 2 ] || { usage; exit 1; }
    validate_layout "$2"
    ;;
  ensure-source-dir)
    [ "$#" -eq 3 ] || { usage; exit 1; }
    ensure_source_dir "$2" "$3"
    ;;
  *)
    usage
    exit 1
    ;;
esac
