# Pi Extensions

Directory-based Pi extensions. Each extension lives in its own folder with an `index.ts` entrypoint, matching Pi's current discovery conventions.

## Extensions

- **context/** — dashboard for context usage, loaded files, extensions, and skills.
- **glimpse-preview/** — markdown preview/feedback UI using Glimpse.
- **pdf-reader/** — `read_pdf` tool that renders PDF pages as images.
- **qna/** — extracts questions from the last assistant message and lets you answer them interactively.
- **review-notes/** — manages markdown review notes and loads them into the Pi editor.
- **session-breakdown/** — interactive session history/cost/token visualizer.
- **statusline/** — lightweight custom footer/status line.
- **tui-runner/** — runs interactive commands in a TUI overlay.

## Notes

- `review-notes/` defaults to `~/.review-notes`; override with `/review-notes [dir]`, `/review-notes --dir [dir]`, or `REVIEW_NOTES_DIR`.
- Imports use the current `@earendil-works/*` Pi packages.
