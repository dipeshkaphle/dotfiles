import type { ExtensionAPI, ExtensionCommandContext } from "@mariozechner/pi-coding-agent";
import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";

export default function reviewManager(pi: ExtensionAPI) {
	function getReviewsDir(override?: string): string {
		if (override) {
			const dir = override.replace("~", os.homedir());
			if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
			return dir;
		}

		// Fallback to default since getConfiguration is not available
		const home = os.homedir();
		const dir = path.join(home, ".review-notes");
		if (!fs.existsSync(dir)) {
			fs.mkdirSync(dir, { recursive: true });
		}
		return dir;
	}

	function listReviewFiles(dir: string): string[] {
		try {
			return fs
				.readdirSync(dir)
				.filter((f) => f.endsWith(".md"))
				.sort();
		} catch { return []; }
	}

	async function pickFile(ctx: ExtensionCommandContext, dir: string, prompt = "Pick review file"): Promise<string | undefined> {
		const files = listReviewFiles(dir);
		if (files.length === 0) {
			ctx.ui.notify("No review files found", "warning");
			return undefined;
		}

		const items = files.map((f) => {
			const full = path.join(dir, f);
			let stamp = "";
			try {
				const m = fs.statSync(full).mtime;
				stamp = m.toISOString().slice(0, 16).replace("T", " ");
			} catch {}
			return stamp ? `${f}  ·  ${stamp}` : f;
		});

		const picked = await ctx.ui.select(`${prompt} (type to filter)`, items);
		if (!picked) return undefined;
		const idx = items.indexOf(picked);
		return idx >= 0 ? files[idx] : undefined;
	}

	pi.registerCommand("review-notes", {
		description: "Manage review files (open, load prompt, delete, shortcuts)",
		parameters: {
			properties: {
				dir: { type: "string", description: "Override directory" }
			}
		},
		handler: async (args, ctx) => {
			if (!ctx.hasUI) return;
			const dir = getReviewsDir(args.dir as string);

			while (true) {
				const files = listReviewFiles(dir);
				const choice = await ctx.ui.select(`Reviews in ${dir} (${files.length} files)`, [
					"Load review into Pi prompt",
					"Editor shortcuts",
					"Delete one review file",
					"Delete ALL review files",
					"Done",
				]);

				if (!choice || choice === "Done") return;

				if (choice === "Load review into Pi prompt") {
					const file = await pickFile(ctx, dir, "Load which review?");
					if (!file) continue;
					const full = path.join(dir, file);
					const content = fs.readFileSync(full, "utf-8");
					ctx.ui.setEditorText(content.trim());
					ctx.ui.notify(`Loaded ${file} into editor`, "info");
					return;
				}

				if (choice === "Editor shortcuts") {
					const shortcuts = [
						"Neovim review workflow:",
						"  <leader>rf  Pick/create review file",
						"  <leader>ra  Add selected lines + comment",
						"  <leader>rv  Open current review file",
						"  <leader>rt  Toggle comments visibility",
						"  Config: require('review_notes').setup({ dir = '~/path' })",
						"",
						"Doom Emacs review workflow:",
						"  SPC r f     Pick/create review file",
						"  SPC r a     Add snippet + comment",
						"  SPC r v     Open current review file",
						"  SPC r t     Toggle comments visibility",
						"  SPC r r     Rotate layout",
						"  Config: (setq review-notes-dir \"~/path\")",
						"",
						"Pi:",
						"  /review-notes [path] -> Manage review notes",
						`  Current dir: ${dir}`
					].join("\n");
					await ctx.ui.editor("Editor shortcuts", shortcuts);
					continue;
				}

				if (choice === "Delete one review file") {
					const file = await pickFile(ctx, dir, "Delete which review?");
					if (!file) continue;
					const ok = await ctx.ui.confirm("Delete review file?", `This will delete ${path.join(dir, file)}`);
					if (!ok) continue;
					fs.unlinkSync(path.join(dir, file));
					ctx.ui.notify(`Deleted ${file}`, "info");
					continue;
				}

				if (choice === "Delete ALL review files") {
					const filesNow = listReviewFiles(dir);
					if (filesNow.length === 0) {
						ctx.ui.notify("No files to delete", "info");
						continue;
					}
					const ok = await ctx.ui.confirm(
						"Delete ALL review files?",
						`This will permanently delete ${filesNow.length} file(s) in ${dir}`,
					);
					if (!ok) continue;
					for (const f of filesNow) {
						try {
							fs.unlinkSync(path.join(dir, f));
						} catch {}
					}
					ctx.ui.notify("Deleted all review files", "warning");
				}
			}
		},
	});
}
