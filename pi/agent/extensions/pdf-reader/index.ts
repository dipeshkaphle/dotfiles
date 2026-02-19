import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { exec } from "node:child_process";
import { readFile, mkdtemp, rm, readdir } from "node:fs/promises";
import { promisify } from "node:util";
import path from "node:path";
import os from "node:os";

const execAsync = promisify(exec);

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "read_pdf",
    label: "Read PDF (Visual)",
    description: "Read PDF pages as images. Best for math, diagrams, and complex layouts. Supports pagination.",
    parameters: Type.Object({
      path: Type.String({ description: "Path to the PDF file" }),
      pages: Type.Optional(Type.String({ description: "Page range (e.g. '1-5', '10', 'all'). Default: first 5 pages." })),
      dpi: Type.Optional(Type.Number({ description: "Resolution in DPI (default: 150)", default: 150 })),
    }),

    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const filePath = path.resolve(ctx.cwd, params.path);
      const dpi = params.dpi ?? 150;

      try {
        // 1. Get total page count using pdfinfo
        let totalPages = 0;
        try {
          const { stdout: infoOutput } = await execAsync(`pdfinfo "${filePath}"`);
          const pagesMatch = infoOutput.match(/Pages:\s+(\d+)/);
          totalPages = pagesMatch ? parseInt(pagesMatch[1], 10) : 0;
        } catch (e) {
          onUpdate?.({ content: [{ type: "text", text: "Could not get page count, trying conversion..." }] });
        }

        // 2. Determine page range
        let startPage = 1;
        let endPage = totalPages || 5;
        let isLimited = false;

        if (params.pages) {
          if (params.pages === "all") {
            endPage = totalPages || 100;
          } else if (params.pages.includes("-")) {
            const parts = params.pages.split("-");
            startPage = parseInt(parts[0], 10);
            endPage = parseInt(parts[1], 10);
          } else {
            startPage = parseInt(params.pages, 10);
            endPage = startPage;
          }
        } else {
          // Default: first 5 pages
          if (totalPages > 5) {
            endPage = 5;
            isLimited = true;
          } else if (totalPages > 0) {
            endPage = totalPages;
          }
        }

        if (startPage < 1) startPage = 1;

        onUpdate?.({ content: [{ type: "text", text: `Converting pages ${startPage}-${endPage}...` }] });

        // 3. Convert pages to images using pdftoppm
        const tempDir = await mkdtemp(path.join(os.tmpdir(), "pi-pdf-"));
        const outputPrefix = path.join(tempDir, "page");

        await execAsync(`pdftoppm -png -r ${dpi} -f ${startPage} -l ${endPage} "${filePath}" "${outputPrefix}"`);

        // 4. Read generated images (sorted by page number)
        const files = await readdir(tempDir);
        const imageFiles = files
          .filter(f => f.endsWith(".png"))
          .sort((a, b) => {
            const numA = parseInt(a.match(/page-(\d+)\.png/)?.[1] || "0", 10);
            const numB = parseInt(b.match(/page-(\d+)\.png/)?.[1] || "0", 10);
            return numA - numB;
          });

        // 5. Build content array with interleaved text labels and images
        const content: any[] = [];

        if (isLimited) {
          content.push({
            type: "text",
            text: `PDF has ${totalPages} pages. Showing pages ${startPage}-${endPage}. Use pages param (e.g. "6-10") for more.`
          });
        }

        for (const file of imageFiles) {
          const match = file.match(/page-(\d+)\.png/);
          const pageLabel = match ? parseInt(match[1], 10) : "?";

          const imgPath = path.join(tempDir, file);
          const buffer = await readFile(imgPath);

          content.push({ type: "text", text: `--- Page ${pageLabel} ---` });
          content.push({
            type: "image",
            data: buffer.toString("base64"),
            mimeType: "image/png"
          });
        }

        // 6. Cleanup temp files
        await rm(tempDir, { recursive: true, force: true });

        return {
          content,
          details: { totalPages, pagesShown: `${startPage}-${endPage}` }
        };

      } catch (err: any) {
        return {
          content: [{ type: "text", text: `Error reading PDF: ${err.message}\nMake sure 'poppler' is installed (brew install poppler / nix-env -iA nixpkgs.poppler_utils).` }],
          isError: true
        };
      }
    },
  });
}
