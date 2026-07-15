import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

async function currentGitBranch(cwd: string): Promise<string> {
	try {
		const { stdout } = await execFileAsync("git", ["branch", "--show-current"], { cwd, timeout: 500 });
		return stdout.trim();
	} catch {
		return "";
	}
}

function formatLine(parts: string[], width: number): string {
	let line = parts.join("");
	const used = visibleWidth(line);
	if (used > width) return truncateToWidth(line, width);
	return line + " ".repeat(Math.max(0, width - used));
}

function shortCwd(cwd: string): string {
	const parts = cwd.split("/").filter(Boolean);
	return parts.length > 1 ? `${parts.at(-2)}/${parts.at(-1)}` : parts[0] || cwd;
}

function formatSubCore(usage: any): string {
	if (!usage) return "";
	const parts: string[] = [];

	for (const win of usage.windows ?? []) {
		const percent = Math.max(0, Math.min(100, Math.round(Number(win.usedPercent ?? 0))));
		const color = percent >= 80 ? "\x1b[31m" : percent >= 50 ? "\x1b[33m" : "\x1b[32m";
		parts.push(`${color}${win.label || "Win"}:${percent}%\x1b[0m`);
	}

	if (usage.requests?.limit) {
		const { remaining, limit } = usage.requests;
		parts.push(`${remaining < 5 ? "\x1b[31m" : "\x1b[33m"}Req:${remaining}/${limit}\x1b[0m`);
	}

	if (usage.tokens?.limit) {
		const { remaining, limit } = usage.tokens;
		parts.push(`\x1b[33mTok:${Math.round(remaining / 1000)}k/${Math.round(limit / 1000)}k\x1b[0m`);
	}

	return parts.length ? ` ${parts.join(" | ")}` : "";
}

export default async function statusline(pi: ExtensionAPI) {
	let subCoreUsage: any;
	let gitBranch = "";

	try {
		const subCore = await import("@marckrenn/pi-sub-core");
		if (typeof subCore.default === "function") subCore.default(pi);
	} catch {
		// Optional dependency.
	}

	pi.events.on("sub-core:update-current", (payload: any) => {
		subCoreUsage = payload?.state?.usage;
	});

	async function refreshGit(ctx: ExtensionContext): Promise<void> {
		gitBranch = await currentGitBranch(ctx.cwd);
	}

	function setupFooter(ctx: ExtensionContext): void {
		if (!ctx.hasUI) return;

		ctx.ui.setFooter(() => ({
			invalidate() {},
			render(width: number) {
				const top: string[] = [];
				const bottom: string[] = [];

				const modelName = ctx.model?.name || ctx.model?.id || "unknown";
				let modelDisplay = `\x1b[35m${modelName}\x1b[0m`;
				const thinking = pi.getThinkingLevel();
				if (thinking && thinking !== "off") modelDisplay += ` \x1b[2m(${thinking})\x1b[0m`;
				top.push(modelDisplay);

				const sessionId = ctx.sessionManager.getSessionId?.();
				if (sessionId) top.push(` \x1b[90m[${sessionId}]\x1b[0m`);

				if (gitBranch) bottom.push(` on \x1b[36m${gitBranch}\x1b[0m`);
				bottom.push(` in \x1b[34m${shortCwd(ctx.cwd)}\x1b[0m`);
				bottom.push(formatSubCore(subCoreUsage));

				const usage = ctx.getContextUsage();
				const contextWindow = ctx.model?.contextWindow || usage?.contextWindow || 0;
				if (usage) {
					const total = usage.tokens || 0;
					const fmt = (n: number) => (n >= 1000 ? `${Math.floor(n / 1000)}K` : `${n}`);
					bottom.push(` \x1b[90m[${fmt(total)}]\x1b[0m`);
					if (contextWindow > 0) {
						const percent = Math.floor((Math.max(0, contextWindow - total) / contextWindow) * 100);
						const color = percent <= 20 ? "\x1b[31m" : percent <= 50 ? "\x1b[33m" : "\x1b[32m";
						bottom.push(` ${color}[${percent}%]\x1b[0m`);
					}
				}

				return bottom.length ? [formatLine(top, width), formatLine(bottom, width)] : [formatLine(top, width)];
			},
		}));
	}

	pi.on("session_start", async (_event, ctx) => {
		await refreshGit(ctx);
		setupFooter(ctx);
		setTimeout(() => {
			try {
				pi.events.emit("sub-core:request", { type: "current", reply: () => {} });
			} catch {}
		}, 500);
	});

	pi.on("turn_end", async (_event, ctx) => {
		await refreshGit(ctx);
	});

	pi.on("model_select", (_event, ctx) => setupFooter(ctx));
}
