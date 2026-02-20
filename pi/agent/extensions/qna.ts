
import { complete, type Model, type Api, type UserMessage } from "@mariozechner/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { BorderedLoader } from "@mariozechner/pi-coding-agent";
import {
    type Component,
    Editor,
    type EditorTheme,
    Key,
    matchesKey,
    truncateToWidth,
    type TUI,
    visibleWidth,
    wrapTextWithAnsi,
} from "@mariozechner/pi-tui";

// Structured output format for question extraction
interface ExtractedQuestion {
    question: string;
    context?: string;
}

interface ExtractionResult {
    questions: ExtractedQuestion[];
}

const SYSTEM_PROMPT = `You are a question extractor. Given text from a conversation, extract any questions that need answering.

Output a JSON object with this structure:
{
  "questions": [
    {
      "question": "The question text",
      "context": "Optional context that helps answer the question"
    }
  ]
}

Rules:
- Extract all questions that require user input
- Keep questions in the order they appeared
- Be concise with question text
- Include context only when it provides essential information for answering
- If no questions are found, return {"questions": []}
`;

function parseExtractionResult(text: string): ExtractionResult | null {
    try {
        let jsonStr = text;
        const jsonMatch = text.match(/```(?:json)?\s*([\s\S]*?)```/);
        if (jsonMatch) {
            jsonStr = jsonMatch[1].trim();
        }
        const parsed = JSON.parse(jsonStr);
        if (parsed && Array.isArray(parsed.questions)) {
            return parsed as ExtractionResult;
        }
        return null;
    } catch {
        return null;
    }
}

/**
 * Model Selector Component with Thinking Level support
 */
class ModelSelectorComponent implements Component {
    private models: Model<Api>[];
    private filteredModels: Model<Api>[];
    private selectedIndex: number = 0;
    private searchEditor: Editor;
    private tui: TUI;
    private onSelect: (model: Model<Api> | null, thinkingLevel?: string) => void;
    private currentModelId?: string;
    
    // Thinking Level State
    private thinkingLevels = ["off", "minimal", "low", "medium", "high", "xhigh"];
    private thinkingLevelIndex = 0; // default "off"

    private cachedWidth?: number;
    private cachedLines?: string[];

    private dim = (s: string) => `\x1b[2m${s}\x1b[0m`;
    private bold = (s: string) => `\x1b[1m${s}\x1b[0m`;
    private cyan = (s: string) => `\x1b[36m${s}\x1b[0m`;
    private green = (s: string) => `\x1b[32m${s}\x1b[0m`;
    private gray = (s: string) => `\x1b[90m${s}\x1b[0m`;
    private white = (s: string) => `\x1b[37m${s}\x1b[0m`;
    private yellow = (s: string) => `\x1b[33m${s}\x1b[0m`;

    constructor(
        models: Model<Api>[], 
        currentModelId: string | undefined,
        tui: TUI, 
        onSelect: (model: Model<Api> | null, thinkingLevel?: string) => void
    ) {
        this.models = [...models].sort((a, b) => {
            const aId = `${a.provider}/${a.id}`;
            const bId = `${b.provider}/${b.id}`;
            if (currentModelId) {
                if (aId === currentModelId) return -1;
                if (bId === currentModelId) return 1;
            }
            return aId.localeCompare(bId);
        });

        this.filteredModels = this.models;
        this.currentModelId = currentModelId;
        this.tui = tui;
        this.onSelect = onSelect;
        
        const editorTheme: EditorTheme = { borderColor: this.dim };
        this.searchEditor = new Editor(tui, editorTheme);
        this.searchEditor.disableSubmit = true; 
        this.searchEditor.onChange = (text) => {
            this.filterModels(text);
            this.tui.requestRender();
        };
    }

    private filterModels(query: string) {
        if (!query) {
            this.filteredModels = this.models;
        } else {
            const lowerQuery = query.toLowerCase();
            this.filteredModels = this.models.filter(m => 
                m.id.toLowerCase().includes(lowerQuery) || 
                m.provider.toLowerCase().includes(lowerQuery)
            );
        }
        this.selectedIndex = 0;
        this.invalidate();
    }

    invalidate(): void {
        this.cachedWidth = undefined;
        this.cachedLines = undefined;
    }

    handleInput(data: string): void {
        if (matchesKey(data, Key.up)) {
            if (this.filteredModels.length > 0) {
                this.selectedIndex = Math.max(0, this.selectedIndex - 1);
                this.invalidate();
                this.tui.requestRender();
            }
            return;
        }
        if (matchesKey(data, Key.down)) {
            if (this.filteredModels.length > 0) {
                this.selectedIndex = Math.min(this.filteredModels.length - 1, this.selectedIndex + 1);
                this.invalidate();
                this.tui.requestRender();
            }
            return;
        }
        
        // Tab: Cycle Thinking Level
        if (matchesKey(data, Key.tab)) {
            this.thinkingLevelIndex = (this.thinkingLevelIndex + 1) % this.thinkingLevels.length;
            this.invalidate();
            this.tui.requestRender();
            return;
        }

        if (matchesKey(data, Key.enter)) {
            if (this.filteredModels.length > 0) {
                const level = this.thinkingLevels[this.thinkingLevelIndex];
                this.onSelect(this.filteredModels[this.selectedIndex], level === "off" ? undefined : level);
            }
            return;
        }
        if (matchesKey(data, Key.escape) || matchesKey(data, Key.ctrl("c"))) {
            this.onSelect(null);
            return;
        }

        this.searchEditor.handleInput(data);
        this.invalidate();
        this.tui.requestRender();
    }

    render(width: number): string[] {
        if (this.cachedLines && this.cachedWidth === width) {
            return this.cachedLines;
        }

        const lines: string[] = [];
        const boxWidth = Math.min(width - 4, 100); 
        const contentWidth = boxWidth - 4; 

        const horizontalLine = (count: number) => "─".repeat(count);
        const boxLine = (content: string): string => {
            const contentLen = visibleWidth(content);
            const rightPad = Math.max(0, boxWidth - contentLen - 2);
            return this.dim("│") + content + " ".repeat(rightPad) + this.dim("│");
        };
        const padToWidth = (line: string): string => {
            const len = visibleWidth(line);
            return line + " ".repeat(Math.max(0, width - len));
        };

        lines.push(padToWidth(this.dim("╭" + horizontalLine(boxWidth - 2) + "╮")));
        lines.push(padToWidth(boxLine(this.bold(this.cyan("Select Extraction Model")))));
        lines.push(padToWidth(this.dim("├" + horizontalLine(boxWidth - 2) + "┤")));

        const searchRender = this.searchEditor.render(contentWidth - 10);
        const searchText = searchRender.length > 0 ? searchRender[0] : "";
        lines.push(padToWidth(boxLine(this.bold("Search: ") + searchText)));
        lines.push(padToWidth(this.dim("├" + horizontalLine(boxWidth - 2) + "┤")));

        const maxVisible = 10;
        let start = 0;
        let end = 0;
        
        if (this.filteredModels.length > 0) {
            start = Math.max(0, Math.min(this.selectedIndex - Math.floor(maxVisible / 2), this.filteredModels.length - maxVisible));
            start = Math.max(0, start);
            end = Math.min(start + maxVisible, this.filteredModels.length);

            for (let i = start; i < end; i++) {
                const m = this.filteredModels[i];
                const modelIdStr = `${m.provider}/${m.id}`;
                const isSelected = i === this.selectedIndex;
                const isCurrent = this.currentModelId === modelIdStr;

                let lineContent = "";
                if (isSelected) {
                    lineContent += this.cyan("→ ");
                    lineContent += this.bold(this.white(m.id));
                    lineContent += " " + this.gray(`[${m.provider}]`);
                } else {
                    lineContent += "  ";
                    lineContent += m.id;
                    lineContent += " " + this.gray(`[${m.provider}]`);
                }

                if (isCurrent) {
                    lineContent += this.green(" ✓");
                }

                lines.push(padToWidth(boxLine(lineContent)));
            }
        } else {
            lines.push(padToWidth(boxLine(this.gray("No matching models"))));
        }

        const renderedCount = end - start;
        for (let i = renderedCount; i < maxVisible; i++) {
            lines.push(padToWidth(boxLine("")));
        }

        // Footer: Thinking Level + Hints
        lines.push(padToWidth(this.dim("├" + horizontalLine(boxWidth - 2) + "┤")));
        
        const level = this.thinkingLevels[this.thinkingLevelIndex];
        const levelColor = level === "off" ? this.dim : level === "high" ? this.yellow : this.cyan;
        const thinkingStr = `Thinking: ${levelColor(level.toUpperCase())}`;
        
        const hints = this.dim("Tab: Cycle Thinking · Enter: Select");
        lines.push(padToWidth(boxLine(`${thinkingStr}  ${hints}`)));

        lines.push(padToWidth(this.dim("╰" + horizontalLine(boxWidth - 2) + "╯")));

        this.cachedWidth = width;
        this.cachedLines = lines;
        return lines;
    }
}

class QnAComponent implements Component {
    private questions: ExtractedQuestion[];
    private answers: string[];
    private currentIndex: number = 0;
    private editor: Editor;
    private tui: TUI;
    private onDone: (result: string | null) => void;
    private showingConfirmation: boolean = false;
    private cachedWidth?: number;
    private cachedLines?: string[];

    private dim = (s: string) => `\x1b[2m${s}\x1b[0m`;
    private bold = (s: string) => `\x1b[1m${s}\x1b[0m`;
    private cyan = (s: string) => `\x1b[36m${s}\x1b[0m`;
    private green = (s: string) => `\x1b[32m${s}\x1b[0m`;
    private yellow = (s: string) => `\x1b[33m${s}\x1b[0m`;
    private gray = (s: string) => `\x1b[90m${s}\x1b[0m`;

    constructor(questions: ExtractedQuestion[], tui: TUI, onDone: (result: string | null) => void) {
        this.questions = questions;
        this.answers = questions.map(() => "");
        this.tui = tui;
        this.onDone = onDone;
        const editorTheme: EditorTheme = {
            borderColor: this.dim,
            selectList: { selectedBg: (s) => `\x1b[44m${s}\x1b[0m`, matchHighlight: this.cyan, itemSecondary: this.gray },
        };
        this.editor = new Editor(tui, editorTheme);
        this.editor.disableSubmit = true;
        this.editor.onChange = () => { this.invalidate(); this.tui.requestRender(); };
    }

    private saveCurrentAnswer(): void { this.answers[this.currentIndex] = this.editor.getText(); }

    private navigateTo(index: number): void {
        if (index < 0 || index >= this.questions.length) return;
        this.saveCurrentAnswer();
        this.currentIndex = index;
        this.editor.setText(this.answers[index] || "");
        this.invalidate();
    }

    private submit(): void {
        this.saveCurrentAnswer();
        const parts: string[] = [];
        for (let i = 0; i < this.questions.length; i++) {
            const q = this.questions[i];
            const a = this.answers[i]?.trim() || "(no answer)";
            parts.push(`Q: ${q.question}`);
            if (q.context) parts.push(`> ${q.context}`);
            parts.push(`A: ${a}`);
            parts.push("");
        }
        this.onDone(parts.join("\n").trim());
    }

    invalidate(): void { this.cachedWidth = undefined; this.cachedLines = undefined; }

    handleInput(data: string): void {
        if (this.showingConfirmation) {
            if (matchesKey(data, Key.enter) || data.toLowerCase() === "y") { this.submit(); return; }
            if (matchesKey(data, Key.escape) || matchesKey(data, Key.ctrl("c")) || data.toLowerCase() === "n") {
                this.showingConfirmation = false; this.invalidate(); this.tui.requestRender(); return;
            }
            return;
        }
        if (matchesKey(data, Key.escape) || matchesKey(data, Key.ctrl("c"))) { this.onDone(null); return; }
        if (matchesKey(data, Key.tab)) {
            if (this.currentIndex < this.questions.length - 1) { this.navigateTo(this.currentIndex + 1); this.tui.requestRender(); }
            return;
        }
        if (matchesKey(data, Key.shift("tab"))) {
            if (this.currentIndex > 0) { this.navigateTo(this.currentIndex - 1); this.tui.requestRender(); }
            return;
        }
        if (matchesKey(data, Key.up) && this.editor.getText() === "") { if (this.currentIndex > 0) this.navigateTo(this.currentIndex - 1); this.tui.requestRender(); return; }
        if (matchesKey(data, Key.down) && this.editor.getText() === "") { if (this.currentIndex < this.questions.length - 1) this.navigateTo(this.currentIndex + 1); this.tui.requestRender(); return; }
        if (matchesKey(data, Key.enter) && !matchesKey(data, Key.shift("enter"))) {
            this.saveCurrentAnswer();
            if (this.currentIndex < this.questions.length - 1) { this.navigateTo(this.currentIndex + 1); } else { this.showingConfirmation = true; }
            this.invalidate(); this.tui.requestRender(); return;
        }
        this.editor.handleInput(data); this.invalidate(); this.tui.requestRender();
    }

    render(width: number): string[] {
        if (this.cachedLines && this.cachedWidth === width) return this.cachedLines;
        const lines: string[] = [];
        const boxWidth = Math.min(width - 4, 120);
        const contentWidth = boxWidth - 4;
        const horizontalLine = (count: number) => "─".repeat(count);
        const boxLine = (content: string, leftPad: number = 2): string => {
            const paddedContent = " ".repeat(leftPad) + content;
            const contentLen = visibleWidth(paddedContent);
            const rightPad = Math.max(0, boxWidth - contentLen - 2);
            return this.dim("│") + paddedContent + " ".repeat(rightPad) + this.dim("│");
        };
        const emptyBoxLine = (): string => this.dim("│") + " ".repeat(boxWidth - 2) + this.dim("│");
        const padToWidth = (line: string): string => line + " ".repeat(Math.max(0, width - visibleWidth(line)));

        lines.push(padToWidth(this.dim("╭" + horizontalLine(boxWidth - 2) + "╮")));
        const title = `${this.bold(this.cyan("Questions"))} ${this.dim(`(${this.currentIndex + 1}/${this.questions.length})`)}`;
        lines.push(padToWidth(boxLine(title)));
        lines.push(padToWidth(this.dim("├" + horizontalLine(boxWidth - 2) + "┤")));

        const progressParts: string[] = [];
        for (let i = 0; i < this.questions.length; i++) {
            const answered = (this.answers[i]?.trim() || "").length > 0;
            const current = i === this.currentIndex;
            if (current) progressParts.push(this.cyan("●"));
            else if (answered) progressParts.push(this.green("●"));
            else progressParts.push(this.dim("○"));
        }
        lines.push(padToWidth(boxLine(progressParts.join(" "))));
        lines.push(padToWidth(emptyBoxLine()));

        const q = this.questions[this.currentIndex];
        const questionText = `${this.bold("Q:")} ${q.question}`;
        const wrappedQuestion = wrapTextWithAnsi(questionText, contentWidth);
        for (const line of wrappedQuestion) lines.push(padToWidth(boxLine(line)));

        if (q.context) {
            lines.push(padToWidth(emptyBoxLine()));
            const contextText = this.gray(`> ${q.context}`);
            const wrappedContext = wrapTextWithAnsi(contextText, contentWidth - 2);
            for (const line of wrappedContext) lines.push(padToWidth(boxLine(line)));
        }

        lines.push(padToWidth(emptyBoxLine()));
        const answerPrefix = this.bold("A: ");
        const editorWidth = contentWidth - 4 - 3;
        const editorLines = this.editor.render(editorWidth);
        for (let i = 1; i < editorLines.length - 1; i++) {
            if (i === 1) lines.push(padToWidth(boxLine(answerPrefix + editorLines[i])));
            else lines.push(padToWidth(boxLine("   " + editorLines[i])));
        }
        lines.push(padToWidth(emptyBoxLine()));

        if (this.showingConfirmation) {
            lines.push(padToWidth(this.dim("├" + horizontalLine(boxWidth - 2) + "┤")));
            const confirmMsg = `${this.yellow("Submit all answers?")} ${this.dim("(Enter/y to confirm, Esc/n to cancel)")}`;
            lines.push(padToWidth(boxLine(truncateToWidth(confirmMsg, contentWidth))));
        } else {
            lines.push(padToWidth(this.dim("├" + horizontalLine(boxWidth - 2) + "┤")));
            const controls = `${this.dim("Tab/Enter")} next · ${this.dim("Shift+Tab")} prev · ${this.dim("Shift+Enter")} newline · ${this.dim("Esc")} cancel`;
            lines.push(padToWidth(boxLine(truncateToWidth(controls, contentWidth))));
        }
        lines.push(padToWidth(this.dim("╰" + horizontalLine(boxWidth - 2) + "╯")));
        this.cachedWidth = width;
        this.cachedLines = lines;
        return lines;
    }
}

export default function (pi: ExtensionAPI) {
    const answerHandler = async (ctx: ExtensionContext) => {
            if (!ctx.hasUI) return;
            const branch = ctx.sessionManager.getBranch();
            let lastAssistantText: string | undefined;
            for (let i = branch.length - 1; i >= 0; i--) {
                const entry = branch[i];
                if (entry.type === "message" && entry.message.role === "assistant") {
                    const textParts = entry.message.content.filter((c): c is { type: "text"; text: string } => c.type === "text").map((c) => c.text);
                    if (textParts.length > 0) { lastAssistantText = textParts.join("\n"); break; }
                }
            }
            if (!lastAssistantText) { ctx.ui.notify("No assistant messages found", "error"); return; }

            const models = ctx.modelRegistry.getAvailable();
            if (models.length === 0) { ctx.ui.notify("No models available", "error"); return; }
            const currentModelId = ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : undefined;

            interface SelectedModel { model: Model<Api>, thinking?: string }
            const selection = await ctx.ui.custom<SelectedModel | null>((tui, _theme, _kb, done) => {
                return new ModelSelectorComponent(models, currentModelId, tui, (model, thinking) => {
                    done(model ? { model, thinking } : null);
                });
            });
            
            if (!selection) return;

            const extractionResult = await ctx.ui.custom<ExtractionResult | null>((tui, theme, _kb, done) => {
                const loader = new BorderedLoader(tui, theme, `Extracting questions using ${selection.model.id}...`);
                loader.onAbort = () => done(null);
                const doExtract = async () => {
                    const apiKey = await ctx.modelRegistry.getApiKey(selection.model);
                    const userMessage: UserMessage = { role: "user", content: [{ type: "text", text: lastAssistantText! }], timestamp: Date.now() };
                    
                    // Note: pi-ai complete() options don't natively expose 'thinking', 
                    // but we pass it anyway in case custom models/adapters support it.
                    // If not, it's ignored.
                    const options: any = { apiKey, signal: loader.signal };
                    if (selection.thinking) options.thinking = selection.thinking;

                    const response = await complete(
                        selection.model,
                        { systemPrompt: SYSTEM_PROMPT, messages: [userMessage] },
                        options
                    );
                    if (response.stopReason === "aborted") return null;
                    const responseText = response.content.filter((c): c is { type: "text"; text: string } => c.type === "text").map((c) => c.text).join("\n");
                    return parseExtractionResult(responseText);
                };
                doExtract().then(done).catch(() => done(null));
                return loader;
            });

            if (!extractionResult) { ctx.ui.notify("Cancelled", "info"); return; }
            if (extractionResult.questions.length === 0) { ctx.ui.notify("No questions found", "info"); return; }

            const answersResult = await ctx.ui.custom<string | null>((tui, _theme, _kb, done) => {
                return new QnAComponent(extractionResult.questions, tui, done);
            });

            if (answersResult === null) { ctx.ui.notify("Cancelled", "info"); return; }

            pi.sendMessage({
                customType: "answers",
                content: "I answered your questions in the following way:\n\n" + answersResult,
                display: true,
            }, { triggerTurn: true });
    };

    pi.registerCommand("answer", { description: "Extract questions from last assistant message", handler: (_args, ctx) => answerHandler(ctx) });
    pi.registerShortcut("ctrl+.", { description: "Extract and answer questions", handler: answerHandler });
}
