export const previewPageCss = `
  :root {
    color-scheme: light;
    --bg: #f6f8fb;
    --panel: #ffffff;
    --panel-alt: #f8fafc;
    --text: #1f2328;
    --muted: #667281;
    --border: #d7dee7;
    --border-strong: #bcc7d3;
    --accent: #2563eb;
    --accent-soft: rgba(37, 99, 235, 0.12);
    --draft: #d97706;
    --draft-soft: rgba(217, 119, 6, 0.12);
    --shadow: 0 14px 40px rgba(15, 23, 42, 0.08);
    --code: #f6f8fa;
    --danger: #dc2626;
    --danger-soft: rgba(220, 38, 38, 0.08);
  }
  * { box-sizing: border-box; }
  html, body {
    margin: 0;
    padding: 0;
    min-height: 100%;
    background: var(--bg);
    color: var(--text);
  }
  body {
    font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    line-height: 1.6;
    padding: 16px;
  }
  button, textarea, input { font: inherit; }
  button {
    cursor: pointer;
    border: 1px solid var(--border);
    border-radius: 10px;
    background: var(--panel);
    color: var(--text);
    transition: background 120ms ease, border-color 120ms ease;
  }
  button:hover {
    border-color: var(--border-strong);
    background: var(--panel-alt);
  }
  button:disabled {
    cursor: default;
    opacity: 0.65;
    background: var(--panel);
    border-color: var(--border);
    color: var(--muted);
  }
  textarea {
    width: 100%;
    min-height: 110px;
    resize: vertical;
    border: 1px solid var(--border);
    border-radius: 12px;
    background: var(--panel);
    color: var(--text);
    padding: 12px 14px;
    line-height: 1.55;
    outline: none;
  }
  textarea:focus {
    border-color: var(--accent);
    box-shadow: 0 0 0 3px var(--accent-soft);
  }
  .app-shell {
    display: grid;
    grid-template-columns: minmax(0, 1fr) 320px;
    gap: 14px;
    min-height: calc(100vh - 32px);
  }
  .document-shell {
    background: var(--panel);
    border: 1px solid var(--border);
    border-radius: 18px;
    box-shadow: var(--shadow);
    padding: 20px 26px;
    min-height: 100%;
  }
  .preview-block {
    cursor: pointer;
    padding: 6px 8px 6px 14px;
    margin: 0;
    border-left: 2px solid transparent;
    border-radius: 8px;
    transition: background 120ms ease, border-color 120ms ease;
  }
  .preview-block + .preview-block { margin-top: 2px; }
  .preview-block:hover { background: rgba(37, 99, 235, 0.03); }
  .preview-block.has-comment {
    border-left-color: var(--draft);
    background: var(--draft-soft);
  }
  .preview-block.comment-filled {
    border-left-color: var(--accent);
    background: rgba(37, 99, 235, 0.08);
  }
  .preview-block.is-selected {
    border-left-color: var(--accent);
    background: rgba(37, 99, 235, 0.12);
  }
  .preview-block.is-active { background: rgba(37, 99, 235, 0.16); }
  .preview-block-body > :first-child { margin-top: 0; }
  .preview-block-body > :last-child { margin-bottom: 0; }
  a { color: var(--accent); }
  pre, code, kbd, samp { font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; }
  code { background: var(--code); padding: 0.15em 0.35em; border-radius: 6px; }
  pre {
    background: var(--code);
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 16px;
    overflow: auto;
  }
  pre code { background: transparent; padding: 0; }
  blockquote {
    margin: 1.25em 0;
    padding: 0.1em 1em;
    border-left: 4px solid var(--border);
    background: var(--panel-alt);
    color: var(--muted);
    border-radius: 0 10px 10px 0;
  }
  table { width: 100%; border-collapse: collapse; display: block; overflow-x: auto; }
  th, td { border: 1px solid var(--border); padding: 10px 12px; }
  th { background: var(--panel-alt); }
  img, svg { max-width: 100%; height: auto; }
  hr { border: 0; border-top: 1px solid var(--border); margin: 2em 0; }
  .sidebar {
    display: flex;
    flex-direction: column;
    gap: 12px;
    position: sticky;
    top: 16px;
    align-self: start;
  }
  .sidebar-actions {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  .action-row {
    display: flex;
    justify-content: flex-end;
    gap: 8px;
    flex-wrap: wrap;
  }
  .secondary-button,
  .primary-button {
    padding: 9px 13px;
    font-weight: 600;
  }
  .primary-button {
    background: var(--accent);
    border-color: var(--accent);
    color: white;
  }
  .primary-button:hover:not(:disabled) {
    background: #1d4ed8;
    border-color: #1d4ed8;
  }
  .primary-button:disabled {
    background: #9db7f5;
    border-color: #9db7f5;
    color: white;
    opacity: 1;
  }
  .sidebar-hint,
  .sidebar-copy,
  .empty-state,
  .comment-excerpt {
    color: var(--muted);
    font-size: 12px;
  }
  .sidebar-card {
    background: var(--panel);
    border: 1px solid var(--border);
    border-radius: 16px;
    padding: 14px;
    box-shadow: var(--shadow);
    display: flex;
    flex-direction: column;
    gap: 10px;
  }
  .sidebar-title-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
  }
  .sidebar-title {
    font-size: 14px;
    font-weight: 700;
  }
  .feedback-count {
    font-size: 11px;
    font-weight: 700;
    color: var(--accent);
    background: rgba(37, 99, 235, 0.08);
    border-radius: 999px;
    padding: 4px 9px;
  }
  .comments-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
    min-height: 0;
    max-height: 34vh;
    overflow: auto;
    padding-right: 2px;
  }
  .empty-state {
    border: 1px dashed var(--border);
    border-radius: 12px;
    padding: 14px;
    background: var(--panel-alt);
  }
  .comment-card {
    border: 1px solid var(--border);
    border-radius: 14px;
    background: var(--panel-alt);
    padding: 12px;
    display: flex;
    flex-direction: column;
    gap: 10px;
  }
  .comment-card-title {
    font-size: 13px;
    font-weight: 700;
    line-height: 1.35;
  }
  .comment-excerpt {
    border-left: 3px solid var(--border);
    padding-left: 10px;
    margin: 0;
    white-space: pre-wrap;
  }
  .comment-actions {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
  }
  .comment-actions button {
    padding: 8px 10px;
    font-size: 12px;
    font-weight: 600;
  }
  .danger-button {
    color: var(--danger);
    background: white;
  }
  .danger-button:hover {
    background: var(--danger-soft);
    border-color: rgba(220, 38, 38, 0.3);
  }
  @media (max-width: 1180px) {
    .app-shell { grid-template-columns: minmax(0, 1fr); }
    .sidebar { position: static; }
    .comments-list { max-height: none; }
  }
`;
