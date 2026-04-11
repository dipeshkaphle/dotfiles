import { DynamicBorder, type ExtensionCommandContext } from "@mariozechner/pi-coding-agent";
import { Container, SelectList, Text, type SelectItem } from "@mariozechner/pi-tui";
import type { AssistantMessage } from "./types.ts";

type TimestampValue = string | number | undefined;

type TimestampCarrier = {
  timestamp?: TimestampValue;
  createdAt?: TimestampValue;
  date?: TimestampValue;
};

type AssistantTextPart = {
  type: "text";
  text: string;
};

type AssistantContentPart = {
  type: string;
  text?: string;
};

type AssistantBranchMessage = TimestampCarrier & {
  role?: string;
  content: AssistantContentPart[];
};

type AssistantBranchEntry = TimestampCarrier & {
  type: "message";
  message: AssistantBranchMessage;
};

function isAssistantTextPart(value: AssistantContentPart): value is AssistantTextPart {
  return value.type === "text" && typeof value.text === "string" && value.text.trim().length > 0;
}

function formatTimestamp(value: TimestampValue): string | undefined {
  if (typeof value !== "string" && typeof value !== "number") return undefined;
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return undefined;
  const day = date.toLocaleDateString(undefined, { month: "short", day: "numeric" });
  const time = date.toLocaleTimeString(undefined, { hour: "numeric", minute: "2-digit" });
  return `${day} ${time}`;
}

function getTimestamp(entry: TimestampCarrier, message: TimestampCarrier): string | undefined {
  return formatTimestamp(
    entry.timestamp
      ?? entry.createdAt
      ?? entry.date
      ?? message.timestamp
      ?? message.createdAt
      ?? message.date,
  );
}

function buildPreviewSnippet(markdown: string): string {
  return (markdown.split("\n").find((line) => line.trim().length > 0) ?? "")
    .replace(/^#+\s*/, "")
    .replace(/`+/g, "")
    .slice(0, 120);
}

export function getAssistantMessages(ctx: ExtensionCommandContext): AssistantMessage[] {
  const messages: AssistantMessage[] = [];
  let index = 0;

  for (const entry of ctx.sessionManager.getBranch()) {
    if (entry.type !== "message") continue;
    const message = (entry as AssistantBranchEntry).message;
    if (message.role !== "assistant") continue;

    const textParts = message.content.filter(isAssistantTextPart).map((part) => part.text);
    if (textParts.length === 0) continue;

    const markdown = textParts.join("\n\n");
    messages.push({
      index,
      markdown,
      preview: buildPreviewSnippet(markdown),
      timestamp: getTimestamp(entry, message),
    });
    index += 1;
  }

  return messages;
}

export function getLastAssistantMarkdown(ctx: ExtensionCommandContext): string | undefined {
  return getAssistantMessages(ctx).at(-1)?.markdown;
}

export async function pickAssistantMessage(ctx: ExtensionCommandContext): Promise<string | null> {
  const messages = getAssistantMessages(ctx);

  if (messages.length === 0) {
    ctx.ui.notify("No assistant message found to preview.", "warning");
    return null;
  }
  if (messages.length === 1) return messages[0]!.markdown;

  const items: SelectItem[] = messages.map((message, index) => ({
    value: String(index),
    label: message.timestamp ? `assistant · ${message.timestamp}` : `assistant · #${message.index + 1}`,
    description: message.preview || "(no text preview)",
  }));

  const selected = await ctx.ui.custom<string | null>((tui, theme, _kb, done) => {
    const container = new Container();
    container.addChild(new DynamicBorder((text) => theme.fg("border", text)));
    container.addChild(new Text(theme.fg("accent", theme.bold("Select assistant message to preview")), 1, 0));

    const list = new SelectList(items, Math.min(12, items.length), {
      selectedPrefix: (text) => theme.fg("accent", text),
      selectedText: (text) => theme.fg("accent", text),
      description: (text) => theme.fg("muted", text),
      scrollInfo: (text) => theme.fg("dim", text),
      noMatch: (text) => theme.fg("warning", text),
    });

    for (let i = 0; i < items.length - 1; i++) list.handleInput("\x1b[B");
    list.onSelect = (item) => done(item.value);
    list.onCancel = () => done(null);

    container.addChild(list);
    container.addChild(new Text(theme.fg("dim", "type to filter • ↑↓ navigate • enter select • esc cancel"), 1, 0));
    container.addChild(new DynamicBorder((text) => theme.fg("border", text)));

    return {
      render(width: number) {
        return container.render(width);
      },
      invalidate() {
        container.invalidate();
      },
      handleInput(data: string) {
        list.handleInput(data);
        tui.requestRender();
      },
    };
  });

  return selected == null ? null : messages[Number(selected)]?.markdown ?? null;
}
