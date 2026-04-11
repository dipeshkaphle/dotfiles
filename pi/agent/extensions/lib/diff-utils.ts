import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { execFileSync } from "node:child_process";

export function expandHome(p: string): string {
	if (p === "~") return os.homedir();
	if (p.startsWith("~/")) return path.join(os.homedir(), p.slice(2));
	return p;
}

export function resolveToolPath(cwd: string, p: string): string {
	return path.isAbsolute(p) ? expandHome(p) : path.resolve(cwd, expandHome(p));
}

export function readExistingFile(filePath: string): string {
	try {
		if (fs.existsSync(filePath)) return fs.readFileSync(filePath, "utf-8");
	} catch {}
	return "";
}

export function extractDiffTextsFromToolInput(input: any, cwd: string): { oldText: string; newText: string } {
	if (typeof input?.newText === "string") {
		return { oldText: String(input.oldText ?? ""), newText: input.newText };
	}

	if (typeof input?.content === "string") {
		const p = String(input.path ?? "");
		const abs = resolveToolPath(cwd, p);
		return { oldText: readExistingFile(abs), newText: input.content };
	}

	return { oldText: "", newText: "" };
}

export function makeUnifiedDiff(oldText: string, newText: string): string | null {
	if (oldText === newText) return null;

	const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), "pi-diff-"));
	const oldFile = path.join(tmpDir, "old.txt");
	const newFile = path.join(tmpDir, "new.txt");

	try {
		fs.writeFileSync(oldFile, oldText, "utf-8");
		fs.writeFileSync(newFile, newText, "utf-8");
		try {
			execFileSync("diff", ["-u", oldFile, newFile], { stdio: "pipe" });
			return null;
		} catch (e: any) {
			if (e?.status === 1 && e?.stdout) return String(e.stdout);
			return null;
		}
	} finally {
		fs.rmSync(tmpDir, { recursive: true, force: true });
	}
}

export function stripUnifiedHeaders(diff: string): string {
	return diff
		.split("\n")
		.filter((l) => !l.startsWith("---") && !l.startsWith("+++"))
		.join("\n");
}

export function countUnifiedChanges(diff: string): { additions: number; removals: number } {
	let additions = 0;
	let removals = 0;
	for (const line of diff.split("\n")) {
		if (line.startsWith("+++") || line.startsWith("---")) continue;
		if (line.startsWith("+")) additions++;
		else if (line.startsWith("-")) removals++;
	}
	return { additions, removals };
}
