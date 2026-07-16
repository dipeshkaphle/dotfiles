import type { ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { open, type GlimpseWindow } from "glimpseui";
import { composePreviewPrompt } from "./prompt.ts";
import { renderMarkdownBlocks } from "./render.ts";
import type { PreviewComment, PreviewSubmitPayload, PreviewWindowMessage } from "./types.ts";
import { buildPreviewHtml } from "./ui.ts";

let activeWindow: GlimpseWindow | null = null;

function isComment(value: any): value is PreviewComment {
  return value
    && ["blockId", "blockKind", "blockLabel", "excerpt", "sourceMarkdown", "body"].every((key) => typeof value[key] === "string")
    && typeof value.blockIndex === "number";
}

function isSubmit(value: any): value is PreviewSubmitPayload {
  return value?.type === "submit"
    && typeof value.overallComment === "string"
    && Array.isArray(value.comments)
    && value.comments.every(isComment);
}

function hasFeedback(payload: PreviewSubmitPayload): boolean {
  return payload.overallComment.trim() !== "" || payload.comments.some((comment) => comment.body.trim() !== "");
}

export function closePreviewWindow(): void {
  const window = activeWindow;
  activeWindow = null;
  try {
    window?.close();
  } catch {}
}

export async function showPreviewWindow(ctx: ExtensionCommandContext, markdown: string): Promise<void> {
  const html = buildPreviewHtml(await renderMarkdownBlocks(markdown));
  closePreviewWindow();

  const window = open(html, { width: 1420, height: 960, title: "", openLinks: true });
  activeWindow = window;

  const clear = () => {
    if (activeWindow === window) activeWindow = null;
  };

  window.on("message", (message: PreviewWindowMessage | any) => {
    if (activeWindow !== window || !message) return;

    if (isSubmit(message)) {
      if (!hasFeedback(message)) {
        ctx.ui.notify("No preview feedback to insert.", "warning");
      } else {
        ctx.ui.setEditorText(composePreviewPrompt(message));
        ctx.ui.notify("Inserted preview comments into the editor.", "info");
      }
      closePreviewWindow();
      return;
    }

    if (message.type === "done" || message.type === "cancel") closePreviewWindow();
  });

  window.on("closed", clear);
  window.on("error", (error) => {
    clear();
    ctx.ui.notify(`Markdown viewer failed: ${error instanceof Error ? error.message : String(error)}`, "error");
  });
}
