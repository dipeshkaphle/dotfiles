import type { ExtensionCommandContext } from "@mariozechner/pi-coding-agent";
import { open, type GlimpseWindow } from "glimpseui";
import { composePreviewPrompt } from "./prompt.ts";
import { renderMarkdownBlocks } from "./render.ts";
import type { PreviewComment, PreviewSubmitPayload, PreviewWindowMessage } from "./types.ts";
import { buildPreviewHtml } from "./ui.ts";

let activeWindow: GlimpseWindow | null = null;

type IncomingPreviewComment = Partial<PreviewComment> | null | undefined;

type IncomingPreviewMessage = {
  type?: string;
  overallComment?: string;
  comments?: IncomingPreviewComment[];
} | null | undefined;

function isPreviewComment(value: IncomingPreviewComment): value is PreviewComment {
  return value != null
    && typeof value.blockId === "string"
    && typeof value.blockIndex === "number"
    && typeof value.blockKind === "string"
    && typeof value.blockLabel === "string"
    && typeof value.excerpt === "string"
    && typeof value.sourceMarkdown === "string"
    && typeof value.body === "string";
}

function isPreviewSubmitPayload(value: IncomingPreviewMessage): value is PreviewSubmitPayload {
  return value != null
    && value.type === "submit"
    && typeof value.overallComment === "string"
    && Array.isArray(value.comments)
    && value.comments.every(isPreviewComment);
}

function hasPreviewFeedback(payload: PreviewSubmitPayload): boolean {
  return payload.overallComment.trim().length > 0 || payload.comments.some((comment) => comment.body.trim().length > 0);
}

export function closePreviewWindow(): void {
  if (activeWindow == null) return;
  const windowToClose = activeWindow;
  activeWindow = null;
  try {
    windowToClose.close();
  } catch {}
}

export async function showPreviewWindow(ctx: ExtensionCommandContext, markdown: string): Promise<void> {
  const blocks = await renderMarkdownBlocks(markdown);
  const html = buildPreviewHtml(blocks);

  closePreviewWindow();

  const window = open(html, {
    width: 1420,
    height: 960,
    title: "",
    openLinks: true,
  });
  activeWindow = window;

  const clear = (): void => {
    if (activeWindow === window) activeWindow = null;
  };

  window.on("message", (data: IncomingPreviewMessage) => {
    if (activeWindow !== window || data == null) return;
    const message = data as PreviewWindowMessage;

    if (isPreviewSubmitPayload(message)) {
      if (!hasPreviewFeedback(message)) {
        ctx.ui.notify("No preview feedback to insert.", "warning");
        closePreviewWindow();
        return;
      }

      ctx.ui.setEditorText(composePreviewPrompt(message));
      ctx.ui.notify("Inserted preview comments into the editor.", "info");
      closePreviewWindow();
      return;
    }

    if (message.type === "done" || message.type === "cancel") {
      closePreviewWindow();
    }
  });

  window.on("closed", clear);
  window.on("error", (error) => {
    clear();
    const message = error instanceof Error ? error.message : String(error);
    ctx.ui.notify(`Glimpse preview failed: ${message}`, "error");
  });
}
