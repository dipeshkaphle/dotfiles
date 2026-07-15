import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";

type ReviewFile = {
	name: string;
	path: string;
	label: string;
	mtimeMs: number;
};

const DEFAULT_DIR = path.join(os.homedir(), ".review-notes");
const MENU = [
	"Load review into Pi prompt",
	"Editor shortcuts",
	"Delete one review file",
	"Delete ALL review files",
	"Done",
] as const;

function parseDir(args: string): string {
	let dir = args.trim();
	if (dir.startsWith("--dir=")) dir = dir.slice("--dir=".length).trim();
	else if (dir.startsWith("--dir ")) dir = dir.slice("--dir ".length).trim();
	else if (dir.startsWith("dir=")) dir = dir.slice("dir=".length).trim();

	if ((dir.startsWith('"') && dir.endsWith('"')) || (dir.startsWith("'") && dir.endsWith("'"))) {
		dir = dir.slice(1, -1);
	}

	dir = dir || process.env.REVIEW_NOTES_DIR || DEFAULT_DIR;
	if (dir === "~") dir = os.homedir();
	else if (dir.startsWith("~/")) dir = path.join(os.homedir(), dir.slice(2));

	return path.resolve(dir);
}

function listReviews(dir: string): ReviewFile[] {
	return fs
		.readdirSync(dir, { withFileTypes: true })
		.filter((entry) => entry.isFile() && entry.name.endsWith(".md"))
		.map((entry) => {
			const filePath = path.join(dir, entry.name);
			const mtimeMs = fs.statSync(filePath).mtimeMs;
			const stamp = new Date(mtimeMs).toISOString().slice(0, 16).replace("T", " ");
			return { name: entry.name, path: filePath, mtimeMs, label: `${entry.name}  ·  ${stamp}` };
		})
		.sort((a, b) => b.mtimeMs - a.mtimeMs || a.name.localeCompare(b.name));
}

async function chooseReview(ctx: ExtensionCommandContext, files: ReviewFile[], title: string): Promise<ReviewFile | undefined> {
	if (files.length === 0) {
		ctx.ui.notify("No review files found", "warning");
		return undefined;
	}

	const picked = await ctx.ui.select(`${title} (type to filter)`, files.map((file) => file.label));
	return files.find((file) => file.label === picked);
}

async function showShortcuts(ctx: ExtensionCommandContext, dir: string): Promise<void> {
	await ctx.ui.editor(
		"Editor shortcuts",
		[
			"Neovim review workflow:",
			"  <leader>rf  Pick/create review file",
			"  <leader>ra  Add selected lines + comment",
			"  <leader>rv  Open current review file",
			"  <leader>rt  Toggle comments visibility",
			"",
			"Doom Emacs review workflow:",
			"  SPC r f     Pick/create review file",
			"  SPC r a     Add snippet + comment",
			"  SPC r v     Open current review file",
			"  SPC r t     Toggle comments visibility",
			"  SPC r r     Rotate layout",
			"",
			"Pi:",
			"  /review-notes [dir]        Manage review notes",
			"  /review-notes --dir [dir]  Manage notes in another directory",
			"  REVIEW_NOTES_DIR=/path     Default directory override",
			`  Current dir: ${dir}`,
		].join("\n"),
	);
}

export default function reviewNotes(pi: ExtensionAPI) {
	pi.registerCommand("review-notes", {
		description: "Manage review notes",
		getArgumentCompletions: (prefix) => {
			const options = ["--dir ", "--dir=", "~/", "~/.review-notes"];
			const matches = options.filter((option) => option.startsWith(prefix));
			return matches.length ? matches.map((value) => ({ value, label: value })) : null;
		},
		handler: async (args, ctx) => {
			if (!ctx.hasUI) return;

			const dir = parseDir(args);
			fs.mkdirSync(dir, { recursive: true });

			while (true) {
				const files = listReviews(dir);
				const choice = await ctx.ui.select(`Reviews in ${dir} (${files.length} files)`, [...MENU]);
				if (!choice || choice === "Done") return;

				if (choice === "Load review into Pi prompt") {
					const file = await chooseReview(ctx, files, "Load which review?");
					if (!file) continue;
					ctx.ui.setEditorText(fs.readFileSync(file.path, "utf-8").trim());
					ctx.ui.notify(`Loaded ${file.name} into editor`, "info");
					return;
				}

				if (choice === "Editor shortcuts") {
					await showShortcuts(ctx, dir);
					continue;
				}

				if (choice === "Delete one review file") {
					const file = await chooseReview(ctx, files, "Delete which review?");
					if (!file) continue;
					if (await ctx.ui.confirm("Delete review file?", `This will delete ${file.path}`)) {
						fs.unlinkSync(file.path);
						ctx.ui.notify(`Deleted ${file.name}`, "info");
					}
					continue;
				}

				if (files.length === 0) {
					ctx.ui.notify("No files to delete", "info");
					continue;
				}

				if (await ctx.ui.confirm("Delete ALL review files?", `Permanently delete ${files.length} file(s) in ${dir}?`)) {
					for (const file of files) fs.unlinkSync(file.path);
					ctx.ui.notify("Deleted all review files", "warning");
				}
			}
		},
	});
}
