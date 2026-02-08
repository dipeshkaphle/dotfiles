
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

export default function(pi: ExtensionAPI) {
    let gitBranch: string = "";
    
    // Helper to update git branch
    const updateGit = async (cwd: string) => {
        try {
            const result = await pi.exec("git", ["branch", "--show-current"], { timeout: 500 });
            if (result.code === 0) {
                gitBranch = result.stdout.trim();
            } else {
                gitBranch = "";
            }
        } catch (e) {
            gitBranch = "";
        }
    };

    // Update git branch on relevant events
    pi.on("session_start", async (event, ctx) => {
        await updateGit(ctx.cwd);
        // Force a redraw of the UI if possible, or just let the next render cycle pick it up
        // The footer render function will pick up the new gitBranch value
    });
    
    pi.on("turn_end", async (event, ctx) => {
        await updateGit(ctx.cwd);
    });

    // Setup the footer when session starts
    pi.on("session_start", (event, ctx) => {
        setupFooter(ctx);
    });

    // Also update if model changes
    pi.on("model_select", (event, ctx) => {
        // Just ensuring footer is active and has correct context
        setupFooter(ctx);
    });

    function setupFooter(ctx: ExtensionContext) {
        if (!ctx.hasUI) return;

        ctx.ui.setFooter((tui, theme) => {
            return {
                render(width: number) {
                    const parts: string[] = [];
                    
                    // 1. Model
                    // ctx.model is the current model
                    const modelName = ctx.model?.name || ctx.model?.id || "unknown";
                    // Magenta \033[35m
                    parts.push(`\x1b[35m${modelName}\x1b[0m`);
                    
                    // 2. Git Branch
                    if (gitBranch) {
                         // Cyan \033[36m
                        parts.push(` on \x1b[36m${gitBranch}\x1b[0m`);
                    }
                    
                    // 3. CWD (basename/parent)
                    const cwd = ctx.cwd;
                    const pathParts = cwd.split('/').filter(p => p.length > 0);
                    let dirDisplay = cwd;
                    if (pathParts.length > 0) {
                        if (pathParts.length > 1) {
                            dirDisplay = `${pathParts[pathParts.length-2]}/${pathParts[pathParts.length-1]}`;
                        } else {
                            dirDisplay = pathParts[0];
                        }
                    }
                    // Blue \033[34m
                    parts.push(` in \x1b[34m${dirDisplay}\x1b[0m`);
                    
                    // 4. Session/Context Usage
                    const usage = ctx.getContextUsage();
                    const contextWindow = ctx.model?.contextWindow || 0;

                    if (usage) {
                        const total = usage.tokens || 0;
                        
                        // Format K
                        const fmt = (n: number) => n >= 1000 ? `${Math.floor(n/1000)}K` : `${n}`;
                        
                        // Gray \033[90m
                        parts.push(` \x1b[90m[Tokens: ${fmt(total)}]\x1b[0m`);
                        
                        // 5. Context Remaining
                        if (contextWindow > 0) {
                            const remainingTokens = Math.max(0, contextWindow - total);
                            const remainingPercent = Math.floor((remainingTokens / contextWindow) * 100);
                            
                            let color = "\x1b[32m"; // Green
                            if (remainingPercent <= 20) color = "\x1b[31m"; // Red
                            else if (remainingPercent <= 50) color = "\x1b[33m"; // Yellow
                            
                            parts.push(` ${color}[Context: ${remainingPercent}%]\x1b[0m`);
                        }
                    }

                    // Pad with spaces to clear the line
                    const line = parts.join("");
                    // Simple ANSI stripping for length calc (approximate)
                    const textLen = line.replace(/\x1b\[[0-9;]*m/g, "").length;
                    const padding = " ".repeat(Math.max(0, width - textLen));

                    return [line + padding];
                },
                invalidate() {}
            };
        });
    }
}
