import type { ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { mkdir, stat, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { dirname, join, resolve } from "node:path";

function stripWrappingQuotes(value: string): string {
  if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
    return value.slice(1, -1);
  }
  return value;
}

export function resolveSavePath(cwd: string, input: string): string {
  let destination = stripWrappingQuotes(input.trim());
  if (destination === "~") destination = homedir();
  else if (destination.startsWith("~/")) destination = join(homedir(), destination.slice(2));
  return resolve(cwd, destination);
}

export async function saveMarkdownResponse(
  ctx: ExtensionCommandContext,
  markdown: string,
  destinationArg: string,
): Promise<void> {
  const enteredPath = destinationArg.trim();
  if (!enteredPath) throw new Error("A destination path is required to save markdown.");

  const filePath = resolveSavePath(ctx.cwd, enteredPath);
  const existing = await stat(filePath).catch((error: NodeJS.ErrnoException) => {
    if (error.code === "ENOENT") return null;
    throw error;
  });

  if (existing?.isDirectory()) throw new Error(`Destination is a directory: ${filePath}`);
  if (existing && !await ctx.ui.confirm("Overwrite markdown file?", filePath)) return;

  await mkdir(dirname(filePath), { recursive: true });
  await writeFile(filePath, markdown, "utf8");
  ctx.ui.notify(`Saved markdown response to ${filePath}`, "info");
}
