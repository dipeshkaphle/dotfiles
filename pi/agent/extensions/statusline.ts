
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import * as fs from "fs";

let visibleWidth: (s: string) => number;
let truncateToWidth: (s: string, w: number) => string;
try {
    const tui = require("@mariozechner/pi-tui");
    visibleWidth = tui.visibleWidth;
    truncateToWidth = tui.truncateToWidth;
} catch (e) {
    visibleWidth = (s: string) => s.replace(/\x1b\[[0-9;]*m/g, "").length;
    truncateToWidth = (s: string, w: number) => {
        const stripped = s.replace(/\x1b\[[0-9;]*m/g, "");
        return stripped.length <= w ? s : stripped.slice(0, w - 3) + "...";
    };
}

export default async function(pi: ExtensionAPI) {
    let subCoreUsage: any = undefined;
    let gitBranch: string = "";

    try {
        const subCore = await import("@marckrenn/pi-sub-core");
        if (typeof subCore.default === "function") subCore.default(pi);
    } catch (e) {}

    pi.events.on("sub-core:update-current", (payload: any) => {
        subCoreUsage = payload?.state?.usage;
    });
    
    const updateGit = async (cwd: string) => {
        try {
            const result = await pi.exec("git", ["branch", "--show-current"], { timeout: 500 });
            if (result.code === 0) gitBranch = result.stdout.trim();
            else gitBranch = "";
        } catch (e) { gitBranch = ""; }
    };

    function formatSubCore(usage: any): string {
        if (!usage) return "";
        const parts: string[] = [];
        
        if (Array.isArray(usage.windows)) {
            for (const win of usage.windows) {
                const raw = Number(win.usedPercent ?? 0);
                const percent = Math.max(0, Math.min(100, Math.round(raw)));
                const label = win.label || "Win";
                let color = "\x1b[32m";
                if (percent >= 80) color = "\x1b[31m";
                else if (percent >= 50) color = "\x1b[33m";
                parts.push(`${color}${label}:${percent}%\x1b[0m`);
            }
        }

        if (usage.requests?.limit) {
            const { remaining, limit } = usage.requests;
            const color = remaining < 5 ? "\x1b[31m" : "\x1b[33m";
            parts.push(`${color}Req:${remaining}/${limit}\x1b[0m`);
        }
        
        if (usage.tokens?.limit) {
            const { remaining, limit } = usage.tokens;
            const r = (remaining / 1000).toFixed(0) + "k";
            const l = (limit / 1000).toFixed(0) + "k";
            parts.push(`\x1b[33mTok:${r}/${l}\x1b[0m`);
        }

        return parts.length > 0 ? " " + parts.join(" | ") : "";
    }

    pi.on("session_start", async (event, ctx) => {
        await updateGit(ctx.cwd);
        setTimeout(() => {
            try { pi.events.emit("sub-core:request", { type: "current", reply: () => {} }); } catch {}
        }, 500);
    });
    
    pi.on("turn_end", async (event, ctx) => {
        await updateGit(ctx.cwd);
    });

    pi.on("session_start", (event, ctx) => { setupFooter(ctx); });
    pi.on("model_select", (event, ctx) => { setupFooter(ctx); });

    function setupFooter(ctx: ExtensionContext) {
        if (!ctx.hasUI) return;

        ctx.ui.setFooter((tui, theme) => {
            const formatLine = (parts: string[], width: number): string => {
                let line = parts.join("");
                const vw = visibleWidth(line);
                if (vw > width) line = truncateToWidth(line, width);
                else line = line + " ".repeat(Math.max(0, width - vw));
                return line;
            };

            return {
                render(width: number) {
                    const topParts: string[] = [];
                    const bottomParts: string[] = [];
                    
                    // 1. Model + Thinking
                    const modelName = ctx.model?.name || ctx.model?.id || "unknown";
                    let modelDisplay = `\x1b[35m${modelName}\x1b[0m`;
                    
                    const thinking = pi.getThinkingLevel();
                    if (thinking && thinking !== "off") {
                        modelDisplay += ` \x1b[2m(${thinking})\x1b[0m`;
                    }
                    topParts.push(modelDisplay);

                    // 2. Session ID
                    const sessionId = ctx.sessionManager.getSessionId();
                    if (sessionId) {
                        topParts.push(` \x1b[90m[${sessionId}]\x1b[0m`);
                    }
                    
                    // 3. Git
                    if (gitBranch) {
                        bottomParts.push(` on \x1b[36m${gitBranch}\x1b[0m`);
                    }
                    
                    // 4. CWD
                    const cwd = ctx.cwd;
                    const pathParts = cwd.split('/').filter(p => p.length > 0);
                    let dirDisplay = cwd;
                    if (pathParts.length > 0) dirDisplay = pathParts.length > 1 ? `${pathParts[pathParts.length-2]}/${pathParts[pathParts.length-1]}` : pathParts[0];
                    bottomParts.push(` in \x1b[34m${dirDisplay}\x1b[0m`);

                    // 5. Sub-Core Usage
                    if (subCoreUsage) {
                        bottomParts.push(formatSubCore(subCoreUsage));
                    }
                    
                    // 6. Context
                    const usage = ctx.getContextUsage();
                    const contextWindow = ctx.model?.contextWindow || 0;
                    if (usage) {
                        const total = usage.tokens || 0;
                        const fmt = (n: number) => n >= 1000 ? `${Math.floor(n/1000)}K` : `${n}`;
                        bottomParts.push(` \x1b[90m[${fmt(total)}]\x1b[0m`);
                        if (contextWindow > 0) {
                            const remainingTokens = Math.max(0, contextWindow - total);
                            const percent = Math.floor((remainingTokens / contextWindow) * 100);
                            let color = "\x1b[32m";
                            if (percent <= 20) color = "\x1b[31m";
                            else if (percent <= 50) color = "\x1b[33m";
                            bottomParts.push(` ${color}[${percent}%]\x1b[0m`);
                        }
                    }

                    const topLine = formatLine(topParts, width);
                    const bottomLine = formatLine(bottomParts, width);
                    return bottomParts.length > 0 ? [topLine, bottomLine] : [topLine];
                },
                invalidate() {}
            };
        });
    }
}
