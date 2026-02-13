import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import fs from "node:fs/promises";
import path from "node:path";

// We use require for pdf-parse as it is a CommonJS module
const pdf = require("pdf-parse");

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "read_pdf",
    label: "Read PDF",
    description: "Read text content from a PDF file",
    parameters: Type.Object({
      path: Type.String({ description: "Path to the PDF file" }),
    }),
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      try {
        const absolutePath = path.resolve(ctx.cwd, params.path);
        const dataBuffer = await fs.readFile(absolutePath);
        
        // pdf-parse returns a promise
        const data = await pdf(dataBuffer);
        
        return {
          content: [{ type: "text", text: data.text }],
          details: {
             numpages: data.numpages,
             info: data.info,
          }
        };
      } catch (err: any) {
        return {
          content: [{ type: "text", text: `Error reading PDF: ${err.message}` }],
          details: { error: err.message },
          isError: true
        };
      }
    },
  });
}
