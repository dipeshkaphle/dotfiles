# Pi Extensions

This directory contains extensions for the Pi Coding Agent.

## Installed Extensions

- **context.ts**
  - Description: Dashboard showing token usage, loaded files, and active skills.
  - Source: https://github.com/mitsuhiko/agent-stuff (Mitsuhiko)

- **session-breakdown.ts**
  - Description: Interactive visualizer for session history (cost, tokens, messages).
  - Source: https://github.com/mitsuhiko/agent-stuff (Mitsuhiko)

- **statusline.ts**
  - Description: Custom status line configuration.
  - Source: Local / Custom

- **permissions.ts**
  - Description: Tool permission gate (allow/ask/block) with a lightweight approval prompt.
  - Source: Local / Custom

## Notes

- `permissions.ts` only handles permission policy and the approval prompt.
- Standard Pi tool call rendering is left alone.
- Project-level permission defaults are stored in `.pi/permissions.json`.
