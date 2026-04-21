#!/bin/bash

set -euo pipefail

[ "$#" -eq 1 ] || {
  echo "Usage: bash scripts/validate-step1.sh <json_file>" >&2
  exit 1
}

JSON_FILE="$1"
[ -f "$JSON_FILE" ] || {
  echo "File not found: $JSON_FILE" >&2
  exit 1
}

python - "$JSON_FILE" <<'PY'
import json
import sys

path = sys.argv[1]
valid_conf = {"EXTRACTED", "INFERRED", "AMBIGUOUS", "UNVERIFIED"}

with open(path, "r", encoding="utf-8") as fh:
    data = json.load(fh)

checks = {
    "entities": list,
    "topics": list,
    "connections": list,
    "contradictions": list,
    "new_vs_existing": dict,
}

for key, expected in checks.items():
    value = data.get(key)
    if not isinstance(value, expected):
        raise SystemExit(f"ERROR: '{key}' must be a {expected.__name__}")

invalid = []
for entity in data.get("entities", []):
    confidence = entity.get("confidence", "MISSING")
    if confidence not in valid_conf:
        invalid.append(confidence)
        if len(invalid) >= 3:
            break

if invalid:
    raise SystemExit("ERROR: invalid confidence value(s): " + ", ".join(invalid))

print("OK: Step 1 JSON validation passed")
PY
