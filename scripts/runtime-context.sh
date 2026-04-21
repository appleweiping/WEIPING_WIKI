#!/bin/bash

resolve_platform_skill_root() {
  case "$1" in
    claude)
      printf '%s\n' "$HOME/.claude/skills"
      ;;
    codex)
      if [ -d "$HOME/.codex/skills" ] || [ ! -d "$HOME/.Codex/skills" ]; then
        printf '%s\n' "$HOME/.codex/skills"
      else
        printf '%s\n' "$HOME/.Codex/skills"
      fi
      ;;
    openclaw)
      printf '%s\n' "$HOME/.openclaw/skills"
      ;;
    *)
      echo "Unsupported platform: $1" >&2
      return 1
      ;;
  esac
}

detect_layout_mode() {
  local bundle_root="$1"
  if [ -e "$bundle_root/.git" ]; then
    printf '%s\n' "source_checkout"
  else
    printf '%s\n' "installed_skill"
  fi
}

resolve_layout_mode() {
  local bundle_root="$1"
  local override_mode="${2:-}"
  if [ -n "$override_mode" ]; then
    printf '%s\n' "$override_mode"
  else
    detect_layout_mode "$bundle_root"
  fi
}

resolve_optional_adapter_root() {
  local bundle_root="$1"
  local skill_root_override="${2:-}"
  local override_mode="${3:-}"
  local layout_mode

  if [ -n "$skill_root_override" ]; then
    printf '%s\n' "$skill_root_override"
    return 0
  fi

  layout_mode="$(resolve_layout_mode "$bundle_root" "$override_mode")"
  case "$layout_mode" in
    source_checkout)
      printf '%s\n' "$bundle_root/deps"
      ;;
    installed_skill|upgrade_target)
      printf '%s\n' "$(dirname "$bundle_root")"
      ;;
    *)
      echo "Unknown layout mode: $layout_mode" >&2
      return 1
      ;;
  esac
}
