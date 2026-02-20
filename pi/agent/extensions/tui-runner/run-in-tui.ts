import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { InteractiveShellOverlay } from "pi-interactive-shell/overlay-component.ts";
import { loadConfig } from "pi-interactive-shell/config.ts";
import type { InteractiveShellOptions, InteractiveShellResult } from "pi-interactive-shell/types.ts";

export default function runInTuiExtension(pi: ExtensionAPI) {
	pi.registerCommand("run-in-tui", {
		description: "Run command in interactive-shell overlay (e.g. /run-in-tui nvim README.md)",
		handler: async (args, ctx) => {
			const command = args.trim();
			if (!command) {
				ctx.ui.notify("Usage: /run-in-tui <command>", "warning");
				return;
			}
			if (!ctx.hasUI) return;

			const config = loadConfig(ctx.cwd);
			const options: InteractiveShellOptions = {
				command,
				cwd: ctx.cwd,
				mode: "interactive",
				reason: "run-in-tui",
			};

			const result = await ctx.ui.custom<InteractiveShellResult>((tui, theme, _kb, done) => {
				return new InteractiveShellOverlay(tui, theme, options, config, done);
			}, { overlay: true });

			if (result.cancelled) {
				ctx.ui.notify("Interactive run cancelled", "info");
				return;
			}
			if ((result.exitCode ?? 1) === 0) ctx.ui.notify("Interactive command finished", "info");
			else ctx.ui.notify(`Interactive command exited with code ${result.exitCode ?? 1}`, "warning");
		},
	});
}
