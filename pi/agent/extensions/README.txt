# Pi Extensions

This directory contains extensions for the Pi Coding Agent.

## Installed Extensions

- **context.ts**
  - Description: Dashboard showing token usage, loaded files, and active skills.
  - Source: https://github.com/mitsuhiko/agent-stuff (Mitsuhiko)

- **todos.ts**
  - Description: specialized TODO manager with file-based storage and TUI.
  - Source: https://github.com/mitsuhiko/agent-stuff (Mitsuhiko)

- **session-breakdown.ts**
  - Description: Interactive visualizer for session history (cost, tokens, messages).
  - Source: https://github.com/mitsuhiko/agent-stuff (Mitsuhiko)

- **statusline.ts**
  - Description: Custom status line configuration.
  - Source: Local / Custom

- **permissions.ts**
  - Description: Tool permission gate (allow/ask/block), permission modal UI, and pre-approval preview panel.
  - Source: Local / Custom

- **custom-write-renderer.ts**
  - Description: Custom renderer for write tool call/result with diff and content previews.
  - Source: Local / Custom

## Architecture Notes: Permission Preview + Write Rendering

### Separation of concerns

- `permissions.ts`
  - Owns policy decisions (`allow` / `ask` / `block`).
  - Owns permission modal interactions and preview UI behavior.
  - Consumes preview text from the registry module.
  - Supports preview expand/collapse in modal (`Ctrl+O`, `o`).

- `custom-write-renderer.ts`
  - Owns write tool call/result rendering in the main timeline.
  - Shows write previews before execution in tool call rendering.
  - Shows compact summary by default and expanded details via normal tool expansion.

- `lib/diff-utils.ts`
  - Shared low-level diff/path helpers used by both modules.
  - Keeps diff logic consistent and avoids duplication.

### Permission preview model

`lib/permission-preview-registry.ts` builds preview in two layers:

1. **Generic preview** (all tools): pretty-printed `event.input`.
2. **Optional enrichment** (per-tool): extra sections from typed enricher registries.

Default enrichers currently include:
- `write`: unified diff section (when diff exists)
- `edit`: unified diff section
- `bash`: command section

### Extending enrichers

Use the registry API in `lib/permission-preview-registry.ts`:

- `registerBuiltinPreviewEnricher(toolName, enricher)` for built-ins
- `registerPreviewEnricher(toolName, enricher)` for custom tools

Enricher signature:
- `(event, { cwd }) => string | undefined`

`permissions.ts` remains generic and only renders what `buildPermissionPreview(...)` returns.

Preview styling (colors/headers/diff emphasis) should be produced in `permission-preview-registry.ts`, not in `permissions.ts`.

### Future plugin hook (not implemented yet)

If we want extension-to-extension enrichment (instead of editing `permissions.ts`), add an event-bus contract such as:

- emit: `permissions:preview-request`
- payload: tool event + preview collector

That would let other extensions register enrichments without modifying core permission code.
