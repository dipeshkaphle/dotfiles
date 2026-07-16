import type { ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import type { AssistantMessage } from "./types.ts";

function textFromAssistantEntry(entry: any): string | null {
  if (entry?.type !== "message" || entry.message?.role !== "assistant") return null;
  const parts = Array.isArray(entry.message.content) ? entry.message.content : [];
  const text = parts
    .filter((part: any) => part?.type === "text" && typeof part.text === "string" && part.text.trim())
    .map((part: any) => part.text)
    .join("\n\n")
    .trim();
  return text || null;
}

function formatTimestamp(entry: any): string | undefined {
  const raw = entry?.timestamp ?? entry?.createdAt ?? entry?.message?.timestamp ?? entry?.message?.createdAt;
  if (raw == null) return undefined;
  const date = new Date(raw);
  if (Number.isNaN(date.getTime())) return undefined;
  return `${date.toLocaleDateString(undefined, { month: "short", day: "numeric" })} ${date.toLocaleTimeString(undefined, { hour: "numeric", minute: "2-digit" })}`;
}

function preview(markdown: string): string {
  return (markdown.split("\n").find((line) => line.trim()) ?? "")
    .replace(/^#+\s*/, "")
    .replace(/`+/g, "")
    .slice(0, 120);
}

export function getAssistantMessages(ctx: ExtensionCommandContext): AssistantMessage[] {
  return ctx.sessionManager
    .getBranch()
    .map((entry: any, branchIndex) => {
      const markdown = textFromAssistantEntry(entry);
      return markdown ? { branchIndex, markdown, preview: preview(markdown), timestamp: formatTimestamp(entry) } : null;
    })
    .filter((message): message is AssistantMessage => message != null);
}

export function getLastAssistantMarkdown(ctx: ExtensionCommandContext): string | undefined {
  return getAssistantMessages(ctx).at(-1)?.markdown;
}

export async function pickAssistantMessage(
  ctx: ExtensionCommandContext,
  action: "view" | "save" | "copy" = "view",
): Promise<string | null> {
  const messages = getAssistantMessages(ctx);
  if (messages.length === 0) {
    ctx.ui.notify(`No assistant message found to ${action}.`, "warning");
    return null;
  }
  if (messages.length === 1) return messages[0]!.markdown;

  const labels = messages.map((message, index) => {
    const title = message.timestamp ? `assistant · ${message.timestamp}` : `assistant · #${index + 1}`;
    return `${title}${message.preview ? ` — ${message.preview}` : ""}`;
  });
  const picked = await ctx.ui.select(`Select assistant message to ${action}`, labels);
  return picked ? messages[labels.indexOf(picked)]?.markdown ?? null : null;
}
