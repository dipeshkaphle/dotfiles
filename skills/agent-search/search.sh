#!/usr/bin/env bash
set -euo pipefail

provider=gemini
while [[ "${1:-}" == --* ]]; do
  case "$1" in
    --gemini)   provider=gemini; shift ;;
    --codex)    provider=codex;  shift ;;
    *) echo "unknown flag: $1" >&2; exit 1 ;;
  esac
done

[[ $# -gt 0 ]] || { echo 'usage: ./search.sh [--gemini|--codex] "query"' >&2; exit 1; }

tmpfile=$(mktemp /tmp/web-search-XXXXXX.json)
errfile="${tmpfile%.json}.stderr"

prompt="Do a websearch for: $*. You may perform multiple searches. For each query you make, structure the output in markdown as follows:\n\n## Search Query: <the exact query you used>\n\n### Raw Results\n<the raw search results you got back>\n\n### Answer\n<your answer based on those results>\n\nRepeat this structure for every query you make."

if [[ "$provider" == gemini ]]; then
  gemini --model auto --output-format json -p "$prompt" 2>"$errfile" > "$tmpfile" \
    || { echo "Search failed. Check $tmpfile and $errfile for details."; exit 1; }
  jq -r '.response // "Search failed: no response in output."' "$tmpfile"
else
  codex --search -m gpt-5.1-codex-mini exec --skip-git-repo-check --json "$prompt" 2>"$errfile" > "$tmpfile" \
    || { echo "Search failed. Check $tmpfile and $errfile for details."; exit 1; }
  jq -rj 'select(.type == "item.completed" and .item.type == "agent_message") | .item.text' "$tmpfile" \
    || echo "Search failed: no response in output."
fi

echo ""
echo "[Provider: $provider | Output: $tmpfile | Stderr: $errfile]"
