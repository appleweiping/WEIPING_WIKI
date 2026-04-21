#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_REGISTRY_SCRIPT="$SCRIPT_DIR/source-registry.sh"
source "$SCRIPT_DIR/shared-config.sh"
source "$SCRIPT_DIR/runtime-context.sh"

SKILL_ROOT_OVERRIDE=""
LAYOUT_MODE_OVERRIDE=""

usage() {
  cat <<'EOF'
Usage:
  bash scripts/adapter-state.sh [--skill-root <path>] [--layout-mode <source_checkout|installed_skill|upgrade_target>] check <source_id>
  bash scripts/adapter-state.sh [--skill-root <path>] [--layout-mode <source_checkout|installed_skill|upgrade_target>] summary
  bash scripts/adapter-state.sh [--skill-root <path>] [--layout-mode <source_checkout|installed_skill|upgrade_target>] summary-human
  bash scripts/adapter-state.sh [--skill-root <path>] [--layout-mode <source_checkout|installed_skill|upgrade_target>] classify-run <source_id> <exit_code> <output_path>
EOF
}

resolve_optional_root() {
  resolve_optional_adapter_root "$PROJECT_ROOT" "$SKILL_ROOT_OVERRIDE" "$LAYOUT_MODE_OVERRIDE"
}

dependency_installed() {
  local dependency_name="$1"
  local dependency_type="$2"
  local optional_root
  case "$dependency_type" in
    bundled)
      optional_root="$(resolve_optional_root)"
      [ -d "$optional_root/$dependency_name" ]
      ;;
    install_time)
      command -v "$dependency_name" >/dev/null 2>&1
      ;;
    none)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

has_uv() {
  command -v uv >/dev/null 2>&1
}

chrome_debug_ready() {
  if command -v lsof >/dev/null 2>&1; then
    lsof -i :9222 -sTCP:LISTEN >/dev/null 2>&1
    return $?
  fi
  return 1
}

print_header() {
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "source_id" "source_label" "state" "state_label" "detail" "recovery_action" "install_hint" "fallback_hint"
}

state_label() {
  case "$1" in
    available) printf '%s\n' "available" ;;
    not_installed) printf '%s\n' "not installed" ;;
    env_unavailable) printf '%s\n' "environment unavailable" ;;
    runtime_failed) printf '%s\n' "runtime failed" ;;
    unsupported) printf '%s\n' "manual only" ;;
    empty_result) printf '%s\n' "empty result" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

default_install_hint() {
  local source_id="$1"
  local adapter_name="$2"
  case "$source_id" in
    web_article|x_twitter|zhihu_article|youtube_video)
      printf '%s\n' "Install or restore the bundled adapter directory for $adapter_name"
      ;;
    wechat_article)
      printf '%s\n' "Install uv, then run: uv tool install ${WECHAT_TOOL_URL}"
      ;;
    *)
      printf '%s\n' "-"
      ;;
  esac
}

optional_hint() {
  local source_id="$1"
  case "$source_id" in
    web_article|x_twitter|zhihu_article)
      printf '%s\n' 'If you want to reuse a logged-in browser session, start Chrome with --remote-debugging-port=9222'
      ;;
    wechat_article|youtube_video)
      printf '%s\n' "Install uv if the adapter runtime requires it"
      ;;
    *)
      printf '%s\n' "-"
      ;;
  esac
}

emit_state_row() {
  local source_id="$1"
  local source_label="$2"
  local state="$3"
  local detail="$4"
  local recovery_action="$5"
  local install_hint="$6"
  local fallback_hint="$7"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$source_id" "$source_label" "$state" "$(state_label "$state")" "$detail" "$recovery_action" "$install_hint" "$fallback_hint"
}

resolve_preflight_state() {
  local source_id="$1"
  local record
  local source_label source_category input_mode match_rule raw_dir adapter_name dependency_name dependency_type fallback_hint
  local state detail recovery_action install_hint

  record="$(bash "$SOURCE_REGISTRY_SCRIPT" get "$source_id")" || {
    echo "Unknown source id: $source_id" >&2
    exit 1
  }

  IFS=$'\t' read -r source_id source_label source_category input_mode match_rule raw_dir adapter_name dependency_name dependency_type fallback_hint <<EOF
$record
EOF

  case "$source_category" in
    core_builtin)
      state="available"
      detail="Core source route is available without extra adapters"
      recovery_action="Proceed with standard ingest"
      install_hint="-"
      ;;
    manual_only)
      state="unsupported"
      detail="This source currently requires manual collection before ingest"
      recovery_action="Copy the content manually, then continue the ingest flow"
      install_hint="-"
      ;;
    optional_adapter)
      case "$source_id" in
        wechat_article)
          if ! has_uv; then
            state="env_unavailable"
            detail="uv is not installed, so the WeChat extraction runtime is unavailable"
            recovery_action="Install uv or fall back to manual copy-paste"
            install_hint="$(optional_hint "$source_id")"
          elif ! dependency_installed "$dependency_name" "$dependency_type"; then
            state="not_installed"
            detail="Adapter not found: $adapter_name"
            recovery_action="Install the adapter or fall back to manual ingest"
            install_hint="$(default_install_hint "$source_id" "$adapter_name")"
          else
            state="available"
            detail="WeChat adapter is available"
            recovery_action="Proceed with automatic extraction"
            install_hint="-"
          fi
          ;;
        web_article|x_twitter|zhihu_article)
          if ! dependency_installed "$dependency_name" "$dependency_type"; then
            state="not_installed"
            detail="Adapter not found: $adapter_name"
            recovery_action="Install the adapter or fall back to manual ingest"
            install_hint="$(default_install_hint "$source_id" "$adapter_name")"
          elif chrome_debug_ready; then
            state="available"
            detail="Adapter is available and a reusable Chrome debug session is already open"
            recovery_action="Proceed with automatic extraction"
            install_hint="-"
          else
            state="available"
            detail="Adapter is available; a temporary browser session may still be needed"
            recovery_action="Proceed with automatic extraction"
            install_hint="$(optional_hint "$source_id")"
          fi
          ;;
        youtube_video)
          if ! dependency_installed "$dependency_name" "$dependency_type"; then
            state="not_installed"
            detail="Adapter not found: $adapter_name"
            recovery_action="Install the adapter or fall back to manual transcript capture"
            install_hint="$(default_install_hint "$source_id" "$adapter_name")"
          else
            state="available"
            detail="YouTube transcript adapter is available"
            recovery_action="Proceed with transcript extraction"
            install_hint="-"
          fi
          ;;
        *)
          if ! dependency_installed "$dependency_name" "$dependency_type"; then
            state="not_installed"
            detail="Adapter not found: $adapter_name"
            recovery_action="Install the adapter or fall back to manual ingest"
            install_hint="$(default_install_hint "$source_id" "$adapter_name")"
          else
            state="available"
            detail="Optional adapter is available"
            recovery_action="Proceed with automatic extraction"
            install_hint="-"
          fi
          ;;
      esac
      ;;
    *)
      echo "Unknown source category: $source_category" >&2
      exit 1
      ;;
  esac

  emit_state_row "$source_id" "$source_label" "$state" "$detail" "$recovery_action" "$install_hint" "$fallback_hint"
}

classify_run_state() {
  local source_id="$1"
  local exit_code="$2"
  local output_path="$3"
  local row
  local source_label state state_label_value detail recovery_action install_hint fallback_hint

  case "$exit_code" in
    ''|*[!0-9-]*) echo "exit_code must be an integer" >&2; exit 1 ;;
  esac

  row="$(resolve_preflight_state "$source_id")"
  IFS=$'\t' read -r _ source_label state state_label_value detail recovery_action install_hint fallback_hint <<EOF
$row
EOF

  if [ "$state" != "available" ]; then
    emit_state_row "$source_id" "$source_label" "$state" "$detail" "$recovery_action" "$install_hint" "$fallback_hint"
    return 0
  fi

  if [ "$exit_code" -ne 0 ]; then
    emit_state_row \
      "$source_id" \
      "$source_label" \
      "runtime_failed" \
      "Automatic extraction exited with a non-zero status" \
      "Retry once, then fall back to manual ingest if needed" \
      "-" \
      "$fallback_hint"
    return 0
  fi

  if [ ! -f "$output_path" ] || ! grep -q '[^[:space:]]' "$output_path" 2>/dev/null; then
    emit_state_row \
      "$source_id" \
      "$source_label" \
      "empty_result" \
      "Automatic extraction completed but returned no usable text" \
      "Provide manual text or a transcript and continue the ingest flow" \
      "-" \
      "$fallback_hint"
    return 0
  fi

  emit_state_row \
    "$source_id" \
    "$source_label" \
    "available" \
    "Automatic extraction produced usable text" \
    "Continue with ingest" \
    "-" \
    "$fallback_hint"
}

print_summary() {
  local source_id
  print_header
  while IFS=$'\t' read -r source_id _; do
    [ -n "$source_id" ] || continue
    resolve_preflight_state "$source_id"
  done <<EOF
$(bash "$SOURCE_REGISTRY_SCRIPT" list | awk -F '\t' 'NR > 1 && ($3 == "optional_adapter" || $3 == "manual_only") { print $1 "\t" $2 }')
EOF
}

print_summary_human() {
  local row
  local source_id source_label state state_label_value detail recovery_action install_hint fallback_hint
  while IFS= read -r row; do
    [ -n "$row" ] || continue
    IFS=$'\t' read -r source_id source_label state state_label_value detail recovery_action install_hint fallback_hint <<EOF
$row
EOF
    printf '%s\n' "- ${source_label}: ${state_label_value}. ${detail}."
    printf '%s\n' "  Next step: ${recovery_action}."
    if [ "$install_hint" != "-" ]; then
      printf '%s\n' "  Install hint: ${install_hint}."
    fi
    printf '%s\n' "  Fallback: ${fallback_hint}."
  done <<EOF
$(print_summary | tail -n +2)
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --skill-root)
      [ $# -ge 2 ] || { usage; exit 1; }
      SKILL_ROOT_OVERRIDE="$2"
      shift 2
      ;;
    --layout-mode)
      [ $# -ge 2 ] || { usage; exit 1; }
      LAYOUT_MODE_OVERRIDE="$2"
      shift 2
      ;;
    *)
      break
      ;;
  esac
done

command_name="${1:-}"

case "$command_name" in
  check)
    [ "$#" -eq 2 ] || { usage; exit 1; }
    print_header
    resolve_preflight_state "$2"
    ;;
  summary)
    [ "$#" -eq 1 ] || { usage; exit 1; }
    print_summary
    ;;
  summary-human)
    [ "$#" -eq 1 ] || { usage; exit 1; }
    print_summary_human
    ;;
  classify-run)
    [ "$#" -eq 4 ] || { usage; exit 1; }
    print_header
    classify_run_state "$2" "$3" "$4"
    ;;
  *)
    usage
    exit 1
    ;;
esac
