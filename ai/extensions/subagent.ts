/**
 * subagent - delegate tasks to parallel subagents with isolated context windows.
 *
 * Each task spawns a fresh `pi` child process (`--mode json -p --no-session`)
 * so the parent's context stays lean. Subagents run in the parent's cwd with
 * the default toolset and report findings back as plain text.
 *
 * Design (minimal):
 *   - One mode: a `tasks` array. A single delegation is a one-element array.
 *   - No personas, no agent files, no tool scoping, no per-task cwd.
 *   - `model` per task, omitted -> inherit the parent's active model.
 *   - One operational sentence is appended to each child's system prompt so
 *     models behave consistently as narrow, reporting subagents.
 *   - No usage stats, no error flags, no output caps, no concurrency limits.
 *     A failed subagent surfaces its error as that task's finding text.
 *   - Progress is reported as a single "{done}/{total} done" line.
 *   - Abort (Esc/Ctrl+C) propagates SIGTERM -> SIGKILL to in-flight children.
 */

import { spawn } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { keyHint, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { Message } from "@earendil-works/pi-ai";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";

/** Operational framing appended to every subagent's system prompt. */
const SUBAGENT_PROMPT =
	"You are a subagent with an isolated context reporting findings to a parent agent. Return only what the parent needs.";

interface TaskItem {
	task: string;
	model?: string;
}

const Params = Type.Object({
	tasks: Type.Array(
		Type.Object({
			task: Type.String({ description: "The task for the subagent to perform" }),
			model: Type.Optional(
				Type.String({
					description: "Model pattern or provider/id. Omit to inherit the parent's active model.",
				}),
			),
		}),
		{ description: "Tasks to run in parallel, each with an isolated context window." },
	),
});

/** Resolve how to re-invoke pi (handles the compiled binary, node, and bun). */
function getPiInvocation(args: string[]): { command: string; args: string[] } {
	const currentScript = process.argv[1];
	const isBunVirtualScript = currentScript?.startsWith("/$bunfs/root/");
	if (currentScript && !isBunVirtualScript && fs.existsSync(currentScript)) {
		return { command: process.execPath, args: [currentScript, ...args] };
	}
	const execName = path.basename(process.execPath).toLowerCase();
	const isGenericRuntime = /^(node|bun)(\.exe)?$/.test(execName);
	if (!isGenericRuntime) {
		return { command: process.execPath, args };
	}
	return { command: "pi", args };
}

/** Extract the last assistant text from a subagent's message stream. */
function getFinalOutput(messages: Message[]): string {
	for (let i = messages.length - 1; i >= 0; i--) {
		const msg = messages[i];
		if (msg.role === "assistant") {
			for (const part of msg.content) {
				if (part.type === "text") return part.text;
			}
		}
	}
	return "";
}

/**
 * Run one task in a fresh, isolated pi child process and resolve to its
 * final assistant text (or a failure message if the process dies).
 */
async function runTask(
	task: string,
	model: string | undefined,
	cwd: string,
	signal: AbortSignal | undefined,
): Promise<string> {
	const args: string[] = ["--mode", "json", "-p", "--no-session"];
	if (model) args.push("--model", model);

	const tmpDir = await fs.promises.mkdtemp(path.join(os.tmpdir(), "pi-subagent-"));
	const promptPath = path.join(tmpDir, "prompt.md");
	await fs.promises.writeFile(promptPath, SUBAGENT_PROMPT, { mode: 0o600 });
	args.push("--append-system-prompt", promptPath);
	args.push(`Task: ${task}`);

	return new Promise<string>((resolve, reject) => {
		const invocation = getPiInvocation(args);
		const messages: Message[] = [];
		const proc = spawn(invocation.command, invocation.args, {
			cwd,
			shell: false,
			stdio: ["ignore", "pipe", "pipe"],
		});
		let buffer = "";
		let stderr = "";

		const processLine = (line: string) => {
			if (!line.trim()) return;
			let event: any;
			try {
				event = JSON.parse(line);
			} catch {
				return;
			}
			if (event.type === "message_end" && event.message) {
				messages.push(event.message as Message);
			}
		};

		proc.stdout.on("data", (data) => {
			buffer += data.toString();
			const lines = buffer.split("\n");
			buffer = lines.pop() || "";
			for (const line of lines) processLine(line);
		});

		proc.stderr.on("data", (data) => {
			stderr += data.toString();
		});

		const cleanup = () => {
			try {
				fs.rmSync(tmpDir, { recursive: true, force: true });
			} catch {
				/* ignore */
			}
		};

		proc.on("close", (code) => {
			if (buffer.trim()) processLine(buffer);
			cleanup();
			if (code !== 0) {
				reject(new Error(stderr.trim() || `subagent exited with code ${code}`));
				return;
			}
			resolve(getFinalOutput(messages) || "(no output)");
		});

		proc.on("error", (err) => {
			cleanup();
			reject(err);
		});

		if (signal) {
			const kill = () => {
				proc.kill("SIGTERM");
				setTimeout(() => {
					if (!proc.killed) proc.kill("SIGKILL");
				}, 5000);
			};
			if (signal.aborted) kill();
			else signal.addEventListener("abort", kill, { once: true });
		}
	});
}

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "subagent",
		label: "Subagent",
		description: [
			"Delegate tasks to parallel subagents, each with an isolated context window.",
			"Pass an array of {task, model?}. Omit model to inherit the parent's active model.",
			"Subagents run in the parent's cwd with the default toolset and report findings as text.",
		].join(" "),
		parameters: Params,
		async execute(_toolCallId, params, signal, onUpdate, ctx) {
			const tasks = (params.tasks ?? []) as TaskItem[];
			if (tasks.length === 0) {
				return { content: [{ type: "text", text: "No tasks provided." }], details: {} };
			}

			// Inherit the parent's active model when a task omits its own.
			const parentModel = ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : undefined;

			// Per-task live status: one line each, [ ] running, [x] done.
			// Preview = first 80 chars of the task. Emitted at start (all [ ])
			// and re-emitted as each task settles.
			const preview = (t: string) => (t.length > 80 ? `${t.slice(0, 80)}…` : t);
			const statuses = tasks.map((t) => ({ text: preview(t.task), done: false }));
			const emitProgress = () => {
				if (!onUpdate) return;
				const lines = statuses.map((s) => `${s.done ? "[x]" : "[ ]"} ${s.text}`);
				onUpdate({
					content: [{ type: "text", text: lines.join("\n") }],
					details: {},
				});
			};
			emitProgress();

			// A failed subagent surfaces its error as that task's finding text
			// so the parent can read it and react, without an error flag or lost siblings.
			const results = await Promise.all(
				tasks.map(async (t, i) => {
					try {
						const out = await runTask(t.task, t.model ?? parentModel, ctx.cwd, signal);
						statuses[i].done = true;
						emitProgress();
						return out;
					} catch (err) {
						statuses[i].done = true;
						emitProgress();
						return `subagent failed: ${err instanceof Error ? err.message : String(err)}`;
					}
				}),
			);

			const text = results.map((r, i) => `### Task ${i + 1}\n\n${r}`).join("\n\n---\n\n");
			return { content: [{ type: "text", text }], details: {} };
		},

		// Compact TUI rendering: collapsed = one line, expanded = full findings.
		// The full content always goes to the LLM; this only affects display.
		renderCall(args, theme, _context) {
			const n = args.tasks?.length ?? 0;
			const head = theme.fg("toolTitle", theme.bold("subagent ")) + theme.fg("accent", `${n} task${n === 1 ? "" : "s"}`);
			return new Text(head, 0, 0);
		},

		renderResult(result, { expanded, isPartial }, theme, _context) {
			const content = result.content[0];
			const text = content?.type === "text" ? content.text : "";
			// While running: show the live [ ]/[x] status block from onUpdate.
			if (isPartial) return new Text(theme.fg("muted", text), 0, 0);
			// Done, collapsed: one-line summary (findings are on demand).
			if (!expanded) {
				const lines = text.split("\n");
				const tasks = lines.filter((l) => l.startsWith("### Task")).length;
				return new Text(
					theme.fg("success", `${tasks} task${tasks === 1 ? "" : "s"} done `) +
						theme.fg("muted", keyHint("app.tools.expand", "to expand")),
					0,
					0,
				);
			}
			return new Text(text, 0, 0);
		},
	});
}
