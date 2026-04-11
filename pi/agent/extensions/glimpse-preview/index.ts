import type { ExtensionAPI, ExtensionCommandContext } from "@mariozechner/pi-coding-agent";
import { getLastAssistantMarkdown, pickAssistantMessage } from "./assistant-messages.ts";
import { closePreviewWindow, showPreviewWindow } from "./preview-window.ts";

async function openLastPreview(ctx: ExtensionCommandContext): Promise<void> {
  await ctx.waitForIdle();
  const markdown = getLastAssistantMarkdown(ctx);
  if (!markdown) {
    ctx.ui.notify("No assistant message found to preview.", "warning");
    return;
  }

  await showPreviewWindow(ctx, markdown);
  ctx.ui.notify("Opened Glimpse preview.", "info");
}

async function openSelectedPreview(ctx: ExtensionCommandContext): Promise<void> {
  await ctx.waitForIdle();
  const markdown = await pickAssistantMessage(ctx);
  if (!markdown) return;

  await showPreviewWindow(ctx, markdown);
  ctx.ui.notify("Opened selected Glimpse preview.", "info");
}

export default function glimpsePreview(pi: ExtensionAPI) {
  pi.registerCommand("glimpse-preview", {
    description: "Open the last assistant message in Glimpse",
    handler: async (_args, ctx) => {
      try {
        await openLastPreview(ctx);
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        ctx.ui.notify(`Glimpse preview failed: ${message}`, "error");
      }
    },
  });

  pi.registerCommand("glimpse-preview-select", {
    description: "Select an assistant message and preview it in Glimpse",
    handler: async (_args, ctx) => {
      try {
        await openSelectedPreview(ctx);
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        ctx.ui.notify(`Glimpse preview failed: ${message}`, "error");
      }
    },
  });

  pi.on("session_shutdown", async () => {
    closePreviewWindow();
  });
}
