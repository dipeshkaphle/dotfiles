import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { getLastAssistantMarkdown, pickAssistantMessage } from "./assistant-messages.ts";
import { closePreviewWindow, showPreviewWindow } from "./preview-window.ts";

async function preview(ctx: ExtensionCommandContext, pick: boolean): Promise<void> {
  await ctx.waitForIdle();
  const markdown = pick ? await pickAssistantMessage(ctx) : getLastAssistantMarkdown(ctx);
  if (!markdown) {
    ctx.ui.notify("No assistant message found to preview.", "warning");
    return;
  }

  await showPreviewWindow(ctx, markdown);
  ctx.ui.notify("Opened Glimpse preview.", "info");
}

async function safely(ctx: ExtensionCommandContext, pick: boolean): Promise<void> {
  try {
    await preview(ctx, pick);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    ctx.ui.notify(`Glimpse preview failed: ${message}`, "error");
  }
}

export default function glimpsePreview(pi: ExtensionAPI) {
  pi.registerCommand("glimpse-preview", {
    description: "Open the last assistant message in Glimpse",
    handler: (_args, ctx) => safely(ctx, false),
  });

  pi.registerCommand("glimpse-preview-select", {
    description: "Select an assistant message and preview it in Glimpse",
    handler: (_args, ctx) => safely(ctx, true),
  });

  pi.on("session_shutdown", () => closePreviewWindow());
}
