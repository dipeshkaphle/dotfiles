import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { execFile } from "node:child_process";
import { mkdtemp, readFile, readdir, rm } from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

type PageRange = { start: number; end: number; limited: boolean };

function parsePages(pages: string | undefined, totalPages: number): PageRange {
	if (!pages) return { start: 1, end: totalPages > 0 ? Math.min(totalPages, 5) : 5, limited: totalPages > 5 };
	if (pages === "all") return { start: 1, end: totalPages || 100, limited: false };
	if (pages.includes("-")) {
		const [start, end] = pages.split("-").map((part) => Number.parseInt(part, 10));
		return { start: Math.max(1, start || 1), end: Math.max(start || 1, end || start || 1), limited: false };
	}
	const page = Math.max(1, Number.parseInt(pages, 10) || 1);
	return { start: page, end: page, limited: false };
}

async function getPageCount(filePath: string): Promise<number> {
	try {
		const { stdout } = await execFileAsync("pdfinfo", [filePath]);
		return Number.parseInt(stdout.match(/Pages:\s+(\d+)/)?.[1] ?? "0", 10) || 0;
	} catch {
		return 0;
	}
}

export default function pdfReader(pi: ExtensionAPI) {
	pi.registerTool({
		name: "read_pdf",
		label: "Read PDF (Visual)",
		description: "Read PDF pages as images. Best for math, diagrams, and complex layouts. Supports pagination.",
		parameters: Type.Object({
			path: Type.String({ description: "Path to the PDF file" }),
			pages: Type.Optional(Type.String({ description: "Page range: '1-5', '10', or 'all'. Default: first 5 pages." })),
			dpi: Type.Optional(Type.Number({ description: "Resolution in DPI", default: 150 })),
		}),
		async execute(_toolCallId, params, _signal, onUpdate, ctx) {
			const filePath = path.resolve(ctx.cwd, params.path);
			const totalPages = await getPageCount(filePath);
			const range = parsePages(params.pages, totalPages);
			const tempDir = await mkdtemp(path.join(os.tmpdir(), "pi-pdf-"));

			try {
				onUpdate?.({ content: [{ type: "text", text: `Converting pages ${range.start}-${range.end}...` }] });
				await execFileAsync("pdftoppm", [
					"-png",
					"-r",
					String(params.dpi ?? 150),
					"-f",
					String(range.start),
					"-l",
					String(range.end),
					filePath,
					path.join(tempDir, "page"),
				]);

				const images = (await readdir(tempDir))
					.filter((file) => file.endsWith(".png"))
					.sort((a, b) => Number(a.match(/page-(\d+)\.png/)?.[1] ?? 0) - Number(b.match(/page-(\d+)\.png/)?.[1] ?? 0));

				const content: any[] = [];
				if (range.limited) {
					content.push({
						type: "text",
						text: `PDF has ${totalPages} pages. Showing pages 1-5. Use pages, e.g. "6-10", for more.`,
					});
				}

				for (const image of images) {
					const page = image.match(/page-(\d+)\.png/)?.[1] ?? "?";
					const data = (await readFile(path.join(tempDir, image))).toString("base64");
					content.push({ type: "text", text: `--- Page ${page} ---` });
					content.push({ type: "image", data, mimeType: "image/png" });
				}

				return { content, details: { totalPages, pagesShown: `${range.start}-${range.end}` } };
			} catch (error: any) {
				return {
					content: [{ type: "text", text: `Error reading PDF: ${error.message}\nInstall poppler (brew install poppler).` }],
					isError: true,
				};
			} finally {
				await rm(tempDir, { recursive: true, force: true });
			}
		},
	});
}
