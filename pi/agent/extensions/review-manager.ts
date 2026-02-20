import type { ExtensionAPI, ExtensionCommandContext } from "@mariozechner/pi-coding-agent";
import * as fs from "node:fs";
import * as path from "node:path";

function reviewsDir(): string {
	const dir = path.join(process.env.HOME || "~", ".pi", "reviews");
	fs.mkdirSync(dir, { recursive: true });
	return dir;
}

function listReviewFiles(): string[] {
	const dir = reviewsDir();
	return fs
		.readdirSync(dir)
		.filter((f) => f.endsWith(".md"))
		.sort();
}

async function pickFile(ctx: ExtensionCommandContext, prompt = "Pick review file"): Promise<string | undefined> {
	const files = listReviewFiles();
	if (files.length === 0) {
		ctx.ui.notify("No review files found in ~/.pi/reviews", "warning");
		return undefined;
	}

	const items = files.map((f) => {
		const full = path.join(reviewsDir(), f);
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

export default function reviewManager(pi: ExtensionAPI) {
	pi.registerCommand("reviews", {
		description: "Manage ~/.pi/reviews files (open, load prompt, delete, delete all)",
		handler: async (_args, ctx) => {
			if (!ctx.hasUI) return;

			while (true) {
				const files = listReviewFiles();
				const choice = await ctx.ui.select(`Reviews (${files.length} files)`, [
					"Load review into Pi prompt",
					"Editor shortcuts",
					"Delete one review file",
					"Delete ALL review files",
					"Done",
				]);

				if (!choice || choice === "Done") return;

				if (choice === "Load review into Pi prompt") {
					const file = await pickFile(ctx, "Load which review?");
					if (!file) continue;
					const full = path.join(reviewsDir(), file);
					const content = fs.readFileSync(full, "utf-8");
					ctx.ui.setEditorText(content.trim());
					ctx.ui.notify(`Loaded ${file} into editor`, "info");
					return;
				}

				if (choice === "Editor shortcuts") {
					const shortcuts = [
						"Neovim review workflow:",
						"  <leader>rf  Pick/create review file (~/.pi/reviews)",
						"  <leader>ra  Add selected lines + comment",
						"  <leader>rv  Open current review file",
						"",
						"Doom Emacs review workflow:",
						"  M-x review-start                Pick/create review file",
						"  M-x review-add-snippet          Add snippet (prompts target)",
						"  M-x review-add-snippet-current  Add snippet to current review",
						"  M-x review-open-current         Open current review file",
						"",
						"Pi:",
						"  /reviews -> Load review into Pi prompt",
					].join("\n");
					await ctx.ui.editor("Editor shortcuts", shortcuts);
					continue;
				}

				if (choice === "Delete one review file") {
					const file = await pickFile(ctx, "Delete which review?");
					if (!file) continue;
					const ok = await ctx.ui.confirm("Delete review file?", `This will delete ~/.pi/reviews/${file}`);
					if (!ok) continue;
					fs.unlinkSync(path.join(reviewsDir(), file));
					ctx.ui.notify(`Deleted ${file}`, "info");
					continue;
				}

				if (choice === "Delete ALL review files") {
					const filesNow = listReviewFiles();
					if (filesNow.length === 0) {
						ctx.ui.notify("No files to delete", "info");
						continue;
					}
					const ok = await ctx.ui.confirm(
						"Delete ALL review files?",
						`This will permanently delete ${filesNow.length} file(s) in ~/.pi/reviews`,
					);
					if (!ok) continue;
					for (const f of filesNow) {
						try {
							fs.unlinkSync(path.join(reviewsDir(), f));
						} catch {}
					}
					ctx.ui.notify("Deleted all review files", "warning");
				}
			}
		},
	});
}
