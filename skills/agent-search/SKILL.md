---
name: agent-search
description: Web search via Gemini CLI or OpenAI Codex CLI. Prints a structured response (query, raw results, answer per search) and saves full output and stderr to temp files for debugging. Use when built-in web_search is unavailable. Ask the user which provider to use, or default to gemini.
---

# Web Search (Gemini / Codex)

```bash
./search.sh "your query"             # defaults to gemini
./search.sh --gemini "your query"    # explicit gemini
./search.sh --codex  "your query"    # explicit codex (gpt-5.1-codex-mini)
```

Response is structured as (repeated per search query made):

```
## Search Query: <query>
### Raw Results
### Answer
```

## Choosing a provider

- **gemini** — uses `gemini --model auto`, auth via Gemini CLI login
- **codex** — uses `codex --search -m gpt-5.1-codex-mini`, auth via OpenAI Codex CLI login

If one fails, try the other. Ask the user which they prefer if unsure.

## Debug files

Both saved to `/tmp/web-search-<id>.*`:
- `.json` — full output (gemini: single JSON; codex: NDJSON)
- `.stderr` — stderr from the CLI

```bash
# gemini
cat /tmp/web-search-<id>.json | jq '.stats'

# codex - extract all web search queries made
cat /tmp/web-search-<id>.json | jq -r 'select(.item.type == "web_search") | .item.action.query'
```
