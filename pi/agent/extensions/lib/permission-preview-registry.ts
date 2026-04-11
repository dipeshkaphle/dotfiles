import type {
	BashToolCallEvent,
	EditToolCallEvent,
	FindToolCallEvent,
	GrepToolCallEvent,
	LsToolCallEvent,
	ReadToolCallEvent,
	ToolCallEvent,
	WriteToolCallEvent,
} from "@mariozechner/pi-coding-agent";
import { isToolCallEventType } from "@mariozechner/pi-coding-agent";
import * as fs from "node:fs";
import { countUnifiedChanges, makeUnifiedDiff, resolveToolPath, stripUnifiedHeaders } from "./diff-utils";

export type BuiltinToolName = "bash" | "read" | "edit" | "write" | "grep" | "find" | "ls";

interface BuiltinEventMap {
	bash: BashToolCallEvent;
	read: ReadToolCallEvent;
	edit: EditToolCallEvent;
	write: WriteToolCallEvent;
	grep: GrepToolCallEvent;
	find: FindToolCallEvent;
	ls: LsToolCallEvent;
}

export interface PreviewContext {
	cwd: string;
}

export type PermissionPreviewEnricher<E extends ToolCallEvent = ToolCallEvent> = (
	event: E,
	ctx: PreviewContext,
) => string | undefined;

const builtinEnrichers: Partial<{ [K in BuiltinToolName]: PermissionPreviewEnricher<BuiltinEventMap[K]> }> = {};
const customEnrichers = new Map<string, PermissionPreviewEnricher>();
let defaultsRegistered = false;

const MAX_PREVIEW_CHARS = 120_000;

const ansi = {
	dim: (s: string) => `\x1b[2m${s}\x1b[0m`,
	bold: (s: string) => `\x1b[1m${s}\x1b[0m`,
	cyan: (s: string) => `\x1b[36m${s}\x1b[0m`,
	green: (s: string) => `\x1b[32m${s}\x1b[0m`,
	red: (s: string) => `\x1b[31m${s}\x1b[0m`,
};

function colorizeDiffBody(diffBody: string): string {
	return diffBody
		.split("\n")
		.map((line) => {
			if (line.startsWith("@@")) return ansi.cyan(line);
			if (line.startsWith("+")) return ansi.green(line);
			if (line.startsWith("-")) return ansi.red(line);
			return ansi.dim(line);
		})
		.join("\n");
}

function clampPreview(text: string): string {
	if (text.length <= MAX_PREVIEW_CHARS) return text;
	const omitted = text.length - MAX_PREVIEW_CHARS;
	return `${text.slice(0, MAX_PREVIEW_CHARS)}\n\n[preview truncated: omitted ${omitted} chars]`;
}

export function registerBuiltinPreviewEnricher<K extends BuiltinToolName>(
	toolName: K,
	enricher: PermissionPreviewEnricher<BuiltinEventMap[K]>,
): void {
	builtinEnrichers[toolName] = enricher;
}

export function registerPreviewEnricher(toolName: string, enricher: PermissionPreviewEnricher): void {
	customEnrichers.set(toolName, enricher);
}

function registerDefaultBuiltinEnrichers(): void {
	if (defaultsRegistered) return;
	defaultsRegistered = true;

	registerBuiltinPreviewEnricher("write", (event, ctx) => {
		const absPath = resolveToolPath(ctx.cwd, event.input.path);
		const oldText = fs.existsSync(absPath) ? fs.readFileSync(absPath, "utf-8") : "";
		const diff = makeUnifiedDiff(oldText, event.input.content);
		const lineCount = event.input.content.split("\n").length;
		let out = `${ansi.bold("write ")}${event.input.path}${ansi.dim(` (${lineCount} L)`)}${ansi.dim(" (exists)")}`;
		if (!diff) return out + ansi.dim(" (same)");
		const { additions, removals } = countUnifiedChanges(diff);
		out += `\n${ansi.green(`+${additions}`)}${ansi.dim(" / ")}${ansi.red(`-${removals}`)}`;
		out += `\n${colorizeDiffBody(stripUnifiedHeaders(diff))}`;
		return out;
	});

	registerBuiltinPreviewEnricher("edit", (event) => {
		const diff = makeUnifiedDiff(event.input.oldText, event.input.newText);
		const label = event.input.path ? `${ansi.bold("edit ")}${event.input.path}` : ansi.bold("edit");
		if (!diff) return `${label}${ansi.dim(" (same)")}`;
		const { additions, removals } = countUnifiedChanges(diff);
		return `${label}\n${ansi.green(`+${additions}`)}${ansi.dim(" / ")}${ansi.red(`-${removals}`)}\n${colorizeDiffBody(stripUnifiedHeaders(diff))}`;
	});

	registerBuiltinPreviewEnricher("bash", (event) => `${ansi.bold("$ ")}${event.input.command}`);
}

function runBuiltinEnricher(event: ToolCallEvent, ctx: PreviewContext): string | undefined {
	if (isToolCallEventType("bash", event)) return builtinEnrichers.bash?.(event, ctx);
	if (isToolCallEventType("read", event)) return builtinEnrichers.read?.(event, ctx);
	if (isToolCallEventType("edit", event)) return builtinEnrichers.edit?.(event, ctx);
	if (isToolCallEventType("write", event)) return builtinEnrichers.write?.(event, ctx);
	if (isToolCallEventType("grep", event)) return builtinEnrichers.grep?.(event, ctx);
	if (isToolCallEventType("find", event)) return builtinEnrichers.find?.(event, ctx);
	if (isToolCallEventType("ls", event)) return builtinEnrichers.ls?.(event, ctx);
	return undefined;
}

export function buildPermissionPreview(event: ToolCallEvent, ctx: PreviewContext): string {
	registerDefaultBuiltinEnrichers();

	try {
		const extra = runBuiltinEnricher(event, ctx) ?? customEnrichers.get(event.toolName)?.(event, ctx);
		if (extra) return clampPreview(extra);
	} catch {
		// Fall through to generic preview.
	}

	let generic = "[input]\n";
	try {
		generic += JSON.stringify(event.input ?? {}, null, 2);
	} catch {
		generic += String(event.input ?? "");
	}
	return clampPreview(generic);
}
