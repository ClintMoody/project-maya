#!/bin/bash
# Re-assert model_name=alfred in the upstream Maya configs (ALFRED 2026-10-28).
# WHY: llm-switch's switch smoke test and Hermes both post model "alfred"; the upstream
# server serves whatever model_name its config holds and 404s anything else. maya.py
# REWRITES these configs on --setup/--update/--repack paths with its own default
# (glm-5.3-flash, or deepseek-v4.1-flash for the DS4 config), silently reverting the alias.
# Run this after any ./maya.sh --setup, --repack, or in-place update. Idempotent.
# NOTE: no exe patch in this tree: it is the unmodified upstream build, so cfg exe stays
#       build/maya (GLM) and build/maya-ds4 (DeepSeek) as maya.py wrote them.
set -euo pipefail
cd "$(dirname "$0")"
for cfg in maya-*.json; do
  case "$cfg" in *.shared-settings.json) continue ;; esac
  cur=$(/usr/bin/python3 -c "import json;print(json.load(open('$cfg')).get('model_name',''))")
  if [ "$cur" = "alfred" ]; then
    echo "$cfg: model_name already alfred"
  else
    /usr/bin/python3 -c "
import json
c=json.load(open('$cfg'))
c['model_name']='alfred'
json.dump(c, open('$cfg','w'), indent=4)
print('$cfg: model_name', '$cur', '-> alfred')"
  fi
done
