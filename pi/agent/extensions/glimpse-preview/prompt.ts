import type { PreviewComment, PreviewSubmitPayload } from "./types.ts";

function formatNodeText(comment: PreviewComment): string {
  const source = comment.sourceMarkdown.trim() || comment.excerpt.trim();
  return source.replace(/\r\n/g, "\n").trim();
}

function pushQuoted(lines: string[], value: string, prefix = "   > "): void {
  for (const line of value.split("\n")) {
    lines.push(`${prefix}${line}`.trimEnd());
  }
}

export function composePreviewPrompt(payload: PreviewSubmitPayload): string {
  const lines: string[] = [];
  const overallComment = payload.overallComment.trim();
  const comments = payload.comments
    .map((comment) => ({ ...comment, body: comment.body.trim() }))
    .filter((comment) => comment.body.length > 0)
    .sort((a, b) => a.blockIndex - b.blockIndex);

  if (overallComment.length > 0) {
    lines.push(overallComment);
    lines.push("");
  }

  comments.forEach((comment) => {
    const nodeText = formatNodeText(comment);
    if (nodeText.length > 0) {
      pushQuoted(lines, nodeText);
    }
    for (const line of comment.body.split("\n")) {
      lines.push(line.trimEnd());
    }
    lines.push("");
  });

  return lines.join("\n").trim();
}
