import { spawn } from "node:child_process";

interface ClipboardCommand {
  command: string;
  args: string[];
}

function clipboardCommands(): ClipboardCommand[] {
  if (process.platform === "darwin") return [{ command: "pbcopy", args: [] }];
  if (process.platform === "win32") return [{ command: "clip.exe", args: [] }];

  if (process.platform === "linux") {
    return [
      { command: "wl-copy", args: [] },
      { command: "xclip", args: ["-selection", "clipboard"] },
      { command: "xsel", args: ["--clipboard", "--input"] },
    ];
  }

  return [];
}

function copyWith(command: ClipboardCommand, markdown: string): Promise<void> {
  return new Promise((resolve, reject) => {
    const child = spawn(command.command, command.args, { stdio: ["pipe", "ignore", "pipe"] });
    let stderr = "";
    let settled = false;

    const finish = (error?: Error) => {
      if (settled) return;
      settled = true;
      if (error) reject(error);
      else resolve();
    };

    child.stderr?.setEncoding("utf8");
    child.stderr?.on("data", (chunk) => {
      stderr += chunk;
    });
    child.stdin.on("error", () => {});
    child.on("error", (error) => finish(error));
    child.on("close", (code) => {
      if (code === 0) finish();
      else finish(new Error(stderr.trim() || `${command.command} exited with code ${code}`));
    });

    child.stdin.end(markdown);
  });
}

export async function copyMarkdownToClipboard(markdown: string): Promise<void> {
  const commands = clipboardCommands();
  if (commands.length === 0) throw new Error(`Clipboard copy is not supported on ${process.platform}.`);

  let lastError: unknown;
  for (const command of commands) {
    try {
      await copyWith(command, markdown);
      return;
    } catch (error) {
      lastError = error;
    }
  }

  const detail = lastError instanceof Error ? ` ${lastError.message}` : "";
  throw new Error(`No supported clipboard command is available.${detail}`);
}
