import type { PreviewBlock, PreviewPageBlock, PreviewPageData } from "./types.ts";
import { previewPageCss } from "./page-css.ts";
import { previewPageScript } from "./page-script.ts";

const KATEX_CSS_URL = "https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.css";

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/\"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function escapeForInlineScript(value: string): string {
  return value.replace(/</g, "\\u003c").replace(/>/g, "\\u003e").replace(/&/g, "\\u0026");
}

function toPageBlock(block: PreviewBlock): PreviewPageBlock {
  return {
    id: block.id,
    index: block.index,
    kind: block.kind,
    label: block.label,
    excerpt: block.excerpt,
    sourceMarkdown: block.sourceMarkdown,
  };
}

function buildBlockMarkup(block: PreviewBlock): string {
  return `
    <section class="preview-block" data-block-id="${escapeHtml(block.id)}" title="${escapeHtml(block.label)}">
      <div class="preview-block-body">${block.html}</div>
    </section>
  `;
}

export function buildPreviewHtml(blocks: PreviewBlock[]): string {
  const pageData: PreviewPageData = { blocks: blocks.map(toPageBlock) };
  const serializedData = escapeForInlineScript(JSON.stringify(pageData));
  const blocksMarkup = blocks.map(buildBlockMarkup).join("\n");

  return `<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="stylesheet" href="${KATEX_CSS_URL}" />
    <style>${previewPageCss}</style>
  </head>
  <body>
    <div class="app-shell">
      <main class="document-shell">${blocksMarkup}</main>
      <aside class="sidebar">
        <div class="sidebar-actions">
          <div class="action-row">
            <button id="close-button" type="button" class="secondary-button">Close</button>
            <button id="submit-button" type="button" class="primary-button">Insert into Pi</button>
          </div>
          <div class="sidebar-hint">Click to select • click again or press <strong>c</strong> to comment • <strong>j/k</strong> or <strong>↑/↓</strong> to move</div>
        </div>

        <section class="sidebar-card">
          <div class="sidebar-title">General note</div>
          <textarea id="overall-comment" placeholder="Anything for the whole response?"></textarea>
        </section>

        <section class="sidebar-card">
          <div class="sidebar-title-row">
            <div class="sidebar-title">Comments</div>
            <div id="comment-count" class="feedback-count">0</div>
          </div>
          <div id="feedback-count" class="sidebar-copy">0 comments ready</div>
          <div id="empty-state" class="empty-state">No block comments yet. Select a block and press <strong>c</strong>, or click the same block again.</div>
          <div id="comments-list" class="comments-list"></div>
        </section>
      </aside>
    </div>

    <script id="preview-data" type="application/json">${serializedData}</script>
    <script>${previewPageScript}</script>
  </body>
</html>`;
}
