/**
 * Custom Write Tool Renderer
 * 
 * Based on the built-in tool renderer example by badlogic:
 * https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/examples/extensions/built-in-tool-renderer.ts
 *
 * Adds diff support for file overwrites using system diff.
 */
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Text } from "@mariozechner/pi-tui";
import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";
import { execSync } from "node:child_process";

export default function(pi: ExtensionAPI) {
    const cwd = process.cwd();
    const resolve = (p: string) => path.resolve(cwd, p.startsWith("~") ? path.join(os.homedir(), p.slice(1)) : p);
    
    const getDiff = (oldT: string, newT: string) => {
        if (oldT === newT) return null;
        const [t1, t2] = [path.join(os.tmpdir(), `o${Date.now()}`), path.join(os.tmpdir(), `n${Date.now()}`)];
        try {
            fs.writeFileSync(t1, oldT); fs.writeFileSync(t2, newT);
            execSync(`diff -u "${t1}" "${t2}"`, { stdio: 'pipe' });
        } catch (e: any) { if (e.status === 1 && e.stdout) return e.stdout.toString(); }
        finally { if(fs.existsSync(t1)) fs.unlinkSync(t1); if(fs.existsSync(t2)) fs.unlinkSync(t2); }
        return null;
    };

    const fmtDiff = (diff: string, t: any, exp: boolean) => {
        const lines = diff.split("\n").filter(l => !l.startsWith("---") && !l.startsWith("+++"));
        let adds = 0, rems = 0;
        lines.forEach(l => l.startsWith("+") ? adds++ : l.startsWith("-") ? rems++ : 0);
        let txt = `${t.fg("success", "+" + adds)}${t.fg("dim", " / ")}${t.fg("error", "-" + rems)}`;
        
        const content = exp ? lines : lines.slice(0, 20);
        if (content.length) txt += "\n" + content.map(l => {
            if (l.startsWith("@@")) return t.fg("accent", l);
            if (l.startsWith("+")) return t.fg("success", l);
            if (l.startsWith("-")) return t.fg("error", l);
            return t.fg("dim", l);
        }).join("\n");
        if (!exp && lines.length > 20) txt += "\n" + t.fg("dim", "...");
        return txt;
    };

    pi.registerTool({
        name: "write", label: "write", description: "Write file (overwrites)",
        parameters: { type: "object", properties: { path: { type: "string" }, content: { type: "string" } }, required: ["path", "content"] },

        async execute(id, { path: p, content }, s) {
            const f = resolve(p), old = fs.existsSync(f) ? fs.readFileSync(f, "utf-8") : null;
            try {
                fs.mkdirSync(path.dirname(f), { recursive: true });
                fs.writeFileSync(f, content, "utf-8");
            } catch (e: any) { return { content: [{ type: "text", text: `Error: ${e.message}` }], isError: true }; }
            
            const res: any = { content: [{ type: "text", text: `Written to ${p}` }], isError: false, details: {} };
            if (old !== null) res.details.diff = getDiff(old, content);
            else if (old === content) res.details.same = true;
            return res;
        },

        renderCall({ path: p, content }, t) {
            let txt = `${t.fg("toolTitle", t.bold("write "))}${t.fg("accent", p)}${t.fg("dim", ` (${content.split("\n").length} L)`)}`;
            const f = resolve(p);
            if (!fs.existsSync(f)) return new Text(txt + t.fg("success", " (new)"), 0, 0);
            
            const old = fs.readFileSync(f, "utf-8");
            const diff = getDiff(old, content);
            return new Text(txt + (diff ? t.fg("dim", " • ") + fmtDiff(diff, t, false) : t.fg("dim", " (same)")), 0, 0);
        },

        renderResult(res, { expanded }, t) {
            const d = res.details as any;
            if (res.isError) return new Text(t.fg("error", res.content[0].text), 0, 0);
            if (d?.diff) return new Text(fmtDiff(d.diff, t, expanded), 0, 0);
            return new Text(t.fg("success", d?.same ? "Written (no changes)" : "Written (new)"), 0, 0);
        }
    });
}
