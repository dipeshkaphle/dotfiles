
import type { ExtensionAPI, ExtensionContext, ToolCallEvent } from "@mariozechner/pi-coding-agent";
import { type Component, Key, matchesKey, TUI, visibleWidth, truncateToWidth, Editor, type EditorTheme } from "@mariozechner/pi-tui";
import * as fs from "fs";
import * as path from "path";
import * as os from "os";
import { spawnSync } from "child_process";
import { resolveToolPath } from "./lib/diff-utils";

type PermissionLevel = "allow" | "ask" | "block";
interface PermissionsConfig { [toolName: string]: PermissionLevel; }

const DEFAULT_POLICY: PermissionsConfig = {
    edit: "ask",
    write: "ask",
    bash: "ask",
    read: "allow",
    ls: "allow",
    find: "allow",
    grep: "allow",
};

// ----------------------------------------------------------------------------
// Custom Permission UI Component
// ----------------------------------------------------------------------------

interface PermissionResult {
    action: "allow" | "allow-session" | "block" | "block-session" | "review";
    comment?: string;
}

class PermissionPrompt implements Component {
    private tui: TUI;
    private onDone: (result: PermissionResult | null) => void;
    private theme: any;

    private items: { label: string, action: PermissionResult["action"] }[];
    private selectedIndex: number = 0;
    private mode: "menu" | "comment" = "menu";
    private commentEditor: Editor;
    private filterQuery: string = "";

    private dim = (s: string) => this.theme?.fg ? this.theme.fg("dim", s) : s;
    private bold = (s: string) => this.theme?.bold ? this.theme.bold(s) : s;
    private accent = (s: string) => this.theme?.fg ? this.theme.fg("accent", s) : s;
    private warning = (s: string) => this.theme?.fg ? this.theme.fg("warning", s) : s;

    private getReviewItem() {
        return this.items.find((item) => item.action === "review");
    }

    private getVisibleItems() {
        const q = this.filterQuery.trim().toLowerCase();
        if (!q) return this.items;
        return this.items.filter((item) => item.label.toLowerCase().includes(q) || item.action.toLowerCase().includes(q));
    }

    private clampSelected() {
        const visible = this.getVisibleItems();
        if (visible.length === 0) {
            this.selectedIndex = 0;
            return;
        }
        if (this.selectedIndex >= visible.length) this.selectedIndex = visible.length - 1;
        if (this.selectedIndex < 0) this.selectedIndex = 0;
    }

    constructor(
        _description: string,
        _showReview: boolean,
        _previewText: string | undefined,
        tui: TUI,
        theme: any,
        onDone: (result: PermissionResult | null) => void
    ) {
        this.tui = tui;
        this.theme = theme;
        this.onDone = onDone;

        this.items = [
            { label: "Allow", action: "allow" },
            { label: "Allow (Session)", action: "allow-session" },
            { label: "Block", action: "block" },
            { label: "Block (Session)", action: "block-session" },
        ];

        if (_showReview) {
            this.items.push({ label: "Review with nvim", action: "review" });
        }

        const editorTheme: EditorTheme = { borderColor: this.dim };
        this.commentEditor = new Editor(tui, editorTheme);
        this.commentEditor.disableSubmit = true;
    }

    handleInput(data: string): void {
        if (this.mode === "comment") {
            if (matchesKey(data, Key.escape)) {
                this.mode = "menu";
                this.tui.requestRender();
                return;
            }
            if (matchesKey(data, Key.enter) && !matchesKey(data, Key.shift("enter"))) {
                this.onDone({ action: this.items[this.selectedIndex].action, comment: this.commentEditor.getText() });
                return;
            }
            this.commentEditor.handleInput(data);
            this.tui.requestRender();
            return;
        }

        const visible = this.getVisibleItems();
        this.clampSelected();

        if (matchesKey(data, Key.up)) {
            this.selectedIndex = Math.max(0, this.selectedIndex - 1);
            this.tui.requestRender();
            return;
        }
        if (matchesKey(data, Key.down)) {
            this.selectedIndex = Math.min(Math.max(0, visible.length - 1), this.selectedIndex + 1);
            this.tui.requestRender();
            return;
        }

        if (matchesKey(data, Key.backspace)) {
            if (this.filterQuery.length > 0) {
                this.filterQuery = this.filterQuery.slice(0, -1);
                this.selectedIndex = 0;
                this.tui.requestRender();
                return;
            }
        }

        if (/^[a-zA-Z0-9 _\-]$/.test(data)) {
            this.filterQuery += data;
            this.selectedIndex = 0;
            this.tui.requestRender();
            return;
        }

        if (matchesKey(data, Key.tab)) {
            const item = visible[this.selectedIndex];
            if (item && item.action !== "review") {
                this.mode = "comment";
                this.commentEditor.setText("");
                this.tui.requestRender();
            }
            return;
        }

        if (matchesKey(data, Key.enter)) {
            const item = visible[this.selectedIndex];
            if (item) this.onDone({ action: item.action });
            return;
        }

        if (matchesKey(data, Key.ctrl("o"))) {
            const review = this.getReviewItem();
            if (review) {
                this.onDone({ action: review.action });
                return;
            }
        }

        if (matchesKey(data, Key.escape)) {
            if (this.filterQuery.length > 0) {
                this.filterQuery = "";
                this.selectedIndex = 0;
                this.tui.requestRender();
                return;
            }
            this.onDone(null);
            return;
        }
    }

    render(width: number): string[] {
        const lines: string[] = [];
        const maxWidth = Math.max(20, width - 2);
        const visible = this.getVisibleItems();
        this.clampSelected();

        lines.push(this.bold(this.accent("Permission")));
        lines.push(this.dim(`Filter: ${this.filterQuery || "(type to search)"}`));
        lines.push("");

        if (visible.length === 0) {
            lines.push(this.dim("No matching options"));
        } else {
            visible.forEach((item, i) => {
                const isSel = i === this.selectedIndex;
                const text = `${isSel ? "→" : " "} ${item.label}`;
                const clipped = truncateToWidth(text, maxWidth);
                if (isSel && this.theme?.bg) {
                    lines.push(this.theme.bg("selectedBg", this.bold(this.accent(clipped))));
                } else {
                    lines.push(isSel ? this.bold(this.accent(clipped)) : clipped);
                }

                if (isSel && this.mode === "comment") {
                    lines.push(this.warning("  Comment:"));
                    for (const l of this.commentEditor.render(Math.max(16, maxWidth - 2))) {
                        lines.push(`  ${l}`);
                    }
                }
            });
        }

        lines.push("");
        const hint = this.mode === "comment"
            ? "Enter: Submit · Esc: Back"
            : this.getReviewItem()
                ? "Type: Filter · Enter: Select · Tab: Comment · Ctrl+O: Review · Esc: Clear/Cancel"
                : "Type: Filter · Enter: Select · Tab: Comment · Esc: Clear/Cancel";
        lines.push(this.dim(truncateToWidth(hint, maxWidth)));

        return lines;
    }
}

// ----------------------------------------------------------------------------
// Manager Component (for /permissions)
// ----------------------------------------------------------------------------

class PermissionManager implements Component {
    private tui: TUI;
    private tools: string[];
    private projectPermissions: PermissionsConfig;
    private sessionPermissions: Map<string, PermissionLevel>;
    private saveCallback: () => void;
    private resetCallback: () => void;
    private onDone: () => void;
    
    private selectedIndex: number = 0;

    private dim = (s: string) => `\x1b[2m${s}\x1b[0m`;
    private bold = (s: string) => `\x1b[1m${s}\x1b[0m`;
    private cyan = (s: string) => `\x1b[36m${s}\x1b[0m`;
    private green = (s: string) => `\x1b[32m${s}\x1b[0m`;
    private red = (s: string) => `\x1b[31m${s}\x1b[0m`;
    private yellow = (s: string) => `\x1b[33m${s}\x1b[0m`;

    constructor(
        tools: string[],
        projectPermissions: PermissionsConfig,
        sessionPermissions: Map<string, PermissionLevel>,
        saveCallback: () => void,
        resetCallback: () => void,
        tui: TUI,
        onDone: () => void
    ) {
        this.tools = tools.sort();
        this.projectPermissions = projectPermissions;
        this.sessionPermissions = sessionPermissions;
        this.saveCallback = saveCallback;
        this.resetCallback = resetCallback;
        this.tui = tui;
        this.onDone = onDone;
    }

    handleInput(data: string): void {
        if (matchesKey(data, Key.escape) || matchesKey(data, "q")) {
            this.onDone();
            return;
        }
        
        const totalItems = this.tools.length + 1; // +1 for Reset option

        if (matchesKey(data, Key.up)) {
            this.selectedIndex = Math.max(0, this.selectedIndex - 1);
            this.tui.requestRender();
            return;
        }
        if (matchesKey(data, Key.down)) {
            this.selectedIndex = Math.min(totalItems - 1, this.selectedIndex + 1);
            this.tui.requestRender();
            return;
        }

        // Handle Selection
        if (matchesKey(data, Key.enter)) {
            if (this.selectedIndex === this.tools.length) {
                // Reset Session Logic
                this.resetCallback();
                this.onDone();
                return;
            }

            // Project Toggle
            const tool = this.tools[this.selectedIndex];
            const cur = this.projectPermissions[tool] ?? DEFAULT_POLICY[tool] ?? "ask";
            let next: PermissionLevel = "allow";
            if (cur === "ask") next = "allow";
            else if (cur === "allow") next = "block";
            else if (cur === "block") next = "ask";
            
            this.projectPermissions[tool] = next;
            this.saveCallback();
            this.tui.requestRender();
            return;
        }

        // Tab: Toggle Session Override
        if (matchesKey(data, Key.tab)) {
            if (this.selectedIndex === this.tools.length) return; // Ignore on reset button

            const tool = this.tools[this.selectedIndex];
            const cur = this.sessionPermissions.get(tool);
            let next: PermissionLevel | undefined = "allow";
            if (cur === "allow") next = "block";
            else if (cur === "block") next = undefined;
            else if (cur === undefined) next = "allow";

            if (next) this.sessionPermissions.set(tool, next);
            else this.sessionPermissions.delete(tool);
            
            this.tui.requestRender();
            return;
        }
    }

    render(width: number): string[] {
        const lines: string[] = [];
        const boxWidth = Math.min(width - 4, 100);
        const hLine = (c: number) => "─".repeat(c);
        const box = (s: string) => {
            const innerWidth = boxWidth - 2;
            const fitted = truncateToWidth(s, innerWidth);
            const pad = Math.max(0, innerWidth - visibleWidth(fitted));
            return this.dim("│") + fitted + " ".repeat(pad) + this.dim("│");
        };
        const padW = (s: string) => s + " ".repeat(Math.max(0, width - visibleWidth(s)));

        lines.push(padW(this.dim("╭" + hLine(boxWidth - 2) + "╮")));
        lines.push(padW(box(this.bold("Permission Manager"))));
        lines.push(padW(this.dim("├" + hLine(boxWidth - 2) + "┤")));
        
        lines.push(padW(box(this.dim("Tool".padEnd(15) + "Project (Enter)".padEnd(20) + "Session (Tab)"))));
        lines.push(padW(this.dim("├" + hLine(boxWidth - 2) + "┤")));

        const formatLevel = (l: string | undefined, def: boolean) => {
            if (!l) return this.dim("Inherit");
            const c = l==="allow" ? this.green : l==="block" ? this.red : this.yellow;
            return c(l.toUpperCase()) + (def ? this.dim(" (default)") : "");
        };

        // Tools List
        this.tools.forEach((tool, i) => {
            const isSel = i === this.selectedIndex;
            let marker = isSel ? this.cyan("→ ") : "  ";
            let toolName = isSel ? this.bold(this.cyan(tool)) : tool;
            
            const proj = this.projectPermissions[tool] ?? DEFAULT_POLICY[tool] ?? "ask";
            const sess = this.sessionPermissions.get(tool);
            
            const projStr = formatLevel(proj, false).padEnd(20 + (visibleWidth(formatLevel(proj, false)) - 5));
            const sessStr = formatLevel(sess, false);

            let row = `${marker}${toolName.padEnd(15 + (isSel?9:0))} ${projStr} ${sessStr}`;
            lines.push(padW(box(row)));
        });

        // Reset Option
        lines.push(padW(this.dim("├" + hLine(boxWidth - 2) + "┤")));
        const isResetSel = this.selectedIndex === this.tools.length;
        const resetLabel = isResetSel ? this.bold(this.red("→ Reset Session Overrides & YOLO")) : "  Reset Session Overrides & YOLO";
        lines.push(padW(box(resetLabel)));

        lines.push(padW(this.dim("├" + hLine(boxWidth - 2) + "┤")));
        lines.push(padW(box(this.dim("Enter: Toggle Project · Tab: Toggle Session · Esc: Exit"))));
        lines.push(padW(this.dim("╰" + hLine(boxWidth - 2) + "╯")));

        return lines;
    }
}

// ----------------------------------------------------------------------------
// Main Logic
// ----------------------------------------------------------------------------

export default function (pi: ExtensionAPI) {
    let projectPermissions: PermissionsConfig = { ...DEFAULT_POLICY };
    const sessionPermissions = new Map<string, PermissionLevel>();
    let yoloMode = false;
    let configPath: string | undefined;

    const getDiffTool = () => {
        if (process.env.PI_DIFF_TOOL) return process.env.PI_DIFF_TOOL.split(" ");
        if (spawnSync("which", ["nvim"]).status === 0) return ["nvim", "-d"];
        if (spawnSync("which", ["vim"]).status === 0) return ["vim", "-d"];
        return ["diff", "--color", "-u"];
    };

    function prepareReviewFiles(input: any, cwd: string): { oldFile: string; newFile: string } {
        const tmpDir = os.tmpdir();
        const oldFile = path.join(tmpDir, "pi-diff-old.txt");
        const newFile = path.join(tmpDir, "pi-diff-new.txt");

        let oldText = "";
        let newText = "";

        try {
            if (typeof input?.path === "string") {
                const fullPath = resolveToolPath(cwd, input.path);
                if (fs.existsSync(fullPath)) oldText = fs.readFileSync(fullPath, "utf-8");
            }
        } catch {}

        if (typeof input?.content === "string") newText = input.content;
        else if (typeof input?.newText === "string") {
            oldText = String(input.oldText ?? "");
            newText = input.newText;
        }

        fs.writeFileSync(oldFile, oldText);
        fs.writeFileSync(newFile, newText);
        return { oldFile, newFile };
    }

    function getPermission(toolName: string): PermissionLevel {
        if (yoloMode) return "allow";
        if (sessionPermissions.has(toolName)) return sessionPermissions.get(toolName)!;
        return projectPermissions[toolName] ?? DEFAULT_POLICY[toolName] ?? "ask";
    }

    function loadPermissions(cwd: string) {
        configPath = path.join(cwd, ".pi", "permissions.json");
        try {
            if (fs.existsSync(configPath)) {
                const data = fs.readFileSync(configPath, "utf-8");
                projectPermissions = { ...DEFAULT_POLICY, ...JSON.parse(data) };
            }
        } catch { projectPermissions = { ...DEFAULT_POLICY }; }
    }

    function savePermissions() {
        if (!configPath) return;
        try {
            const dir = path.dirname(configPath);
            if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
            fs.writeFileSync(configPath, JSON.stringify(projectPermissions, null, 2));
        } catch {}
    }


    pi.on("session_start", (_event, ctx) => { loadPermissions(ctx.cwd); });
    loadPermissions(process.cwd());

    pi.on("tool_call", async (event: ToolCallEvent, ctx: ExtensionContext) => {
        if (!configPath) loadPermissions(ctx.cwd);
        const level = getPermission(event.toolName);

        if (level === "allow") return;
        if (level === "block") return { block: true, reason: "Policy: Block" };

        if (level === "ask") {
            if (!ctx.hasUI) return { block: true, reason: "No UI" };

            const promptBits = [`tool: ${event.toolName}`];
            if (typeof event.input?.path === "string") promptBits.push(`path: ${event.input.path}`);
            if (typeof event.input?.command === "string") promptBits.push(`cmd: ${event.input.command}`);
            const promptLabel = promptBits.join(" · ");

            while (true) {
                let result = await ctx.ui.custom<PermissionResult | null | undefined>((tui, theme, _kb, done) => {
                    return new PermissionPrompt(
                        "",
                        (event.toolName === "edit" || event.toolName === "write"),
                        undefined,
                        tui,
                        theme,
                        done
                    );
                });

                // RPC mode: ctx.ui.custom() returns undefined. Fall back to select/confirm.
                if (result === undefined) {
                    const choice = await ctx.ui.select(`Permission: ${promptLabel}`, [
                        "Allow",
                        "Allow (Session)",
                        "Block",
                        "Block (Session)",
                    ]);

                    if (!choice) return { block: true, reason: "User cancelled" };

                    const actionMap: Record<string, PermissionResult["action"]> = {
                        "Allow": "allow",
                        "Allow (Session)": "allow-session",
                        "Block": "block",
                        "Block (Session)": "block-session",
                    };
                    const action = actionMap[choice];
                    if (!action) return { block: true, reason: "User cancelled" };

                    result = { action };
                }

                if (!result) return { block: true, reason: "User cancelled" };

                if (result.action === "review") {
                    const { oldFile, newFile } = prepareReviewFiles(event.input, ctx.cwd);

                    await ctx.ui.custom<void>((tui, _theme, _kb, done) => {
                        tui.stop();
                        try {
                            const [cmd, ...args] = getDiffTool();
                            spawnSync(cmd, [...args, oldFile, newFile], { stdio: "inherit" });
                        } catch (e) {
                            console.error(e);
                        } finally {
                            tui.start();
                            tui.requestRender();
                            done();
                        }

                        return { render: () => [], invalidate: () => {} };
                    });

                    continue;
                }

                if (result.comment && result.comment.trim().length > 0) {
                    pi.sendMessage({
                        customType: "user-feedback",
                        content: `User feedback on ${event.toolName}: ${result.comment}`,
                        display: true
                    }, { triggerTurn: false });
                }

                switch (result.action) {
                    case "allow": return;
                    case "allow-session":
                        sessionPermissions.set(event.toolName, "allow");
                        return;
                    case "block": return { block: true, reason: "User blocked" };
                    case "block-session":
                        sessionPermissions.set(event.toolName, "block");
                        return { block: true, reason: "User blocked session" };
                }
            }
        }
    });

    pi.registerCommand("yolo", {
        description: "Toggle YOLO mode",
        handler: async (_args, ctx) => {
            if (yoloMode) {
                yoloMode = false;
                ctx.ui.notify("YOLO MODE DISABLED", "info");
            } else {
                if (await ctx.ui.confirm("Enable YOLO Mode?", "Allow ALL tools?")) {
                    yoloMode = true;
                    ctx.ui.notify("YOLO ENABLED", "warning");
                }
            }
        }
    });

    pi.registerCommand("permissions", {
        description: "Manage permissions",
        handler: async (_args, ctx) => {
            if (!ctx.hasUI) return;
            loadPermissions(ctx.cwd);
            const tools = pi.getAllTools();
            
            await ctx.ui.custom<void>((tui, _theme, _kb, done) => {
                return new PermissionManager(
                    tools.map(t => t.name),
                    projectPermissions,
                    sessionPermissions,
                    () => savePermissions(),
                    () => {
                        sessionPermissions.clear();
                        yoloMode = false;
                        ctx.ui.notify("Session reset", "info");
                    },
                    tui,
                    done
                );
            });
        }
    });
}
