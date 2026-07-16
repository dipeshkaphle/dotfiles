import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { getLastAssistantMarkdown, pickAssistantMessage } from "./assistant-messages.ts";
import { copyMarkdownToClipboard } from "./copy-response.ts";
import { closePreviewWindow, showPreviewWindow } from "./preview-window.ts";
import { saveMarkdownResponse } from "./save-response.ts";

async function preview(ctx: ExtensionCommandContext, pick: boolean): Promise<void> {
  await ctx.waitForIdle();
  const markdown = pick ? await pickAssistantMessage(ctx, "view") : getLastAssistantMarkdown(ctx);
  if (!markdown) {
    ctx.ui.notify("No assistant message found to view.", "warning");
    return;
  }

  await showPreviewWindow(ctx, markdown);
  ctx.ui.notify("Opened Markdown viewer.", "info");
}

async function saveOrCopy(ctx: ExtensionCommandContext, destination: string): Promise<void> {
  await ctx.waitForIdle();
  const shouldCopy = destination.trim() === "";
  const markdown = await pickAssistantMessage(ctx, shouldCopy ? "copy" : "save");
  if (!markdown) return;

  if (shouldCopy) {
    await copyMarkdownToClipboard(markdown);
    ctx.ui.notify("Copied markdown response to the clipboard.", "info");
    return;
  }

  await saveMarkdownResponse(ctx, markdown, destination);
}

async function safely(ctx: ExtensionCommandContext, action: () => Promise<void>): Promise<void> {
  try {
    await action();
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    ctx.ui.notify(`Markdown viewer failed: ${message}`, "error");
  }
}

export default function mdViewer(pi: ExtensionAPI) {
  pi.registerCommand("md-preview", {
    description: "Open the last assistant message in the Markdown viewer",
    handler: (_args, ctx) => safely(ctx, () => preview(ctx, false)),
  });

  pi.registerCommand("md-preview-select", {
    description: "Select an assistant message and open it in the Markdown viewer",
    handler: (_args, ctx) => safely(ctx, () => preview(ctx, true)),
  });

  pi.registerCommand("md-save", {
    description: "Select an assistant message; save it to a path or copy it when no path is given",
    handler: (args, ctx) => safely(ctx, () => saveOrCopy(ctx, args)),
  });

  pi.on("session_shutdown", () => closePreviewWindow());
}
