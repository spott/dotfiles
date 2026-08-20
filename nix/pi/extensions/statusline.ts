/**
 * Statusline footer for Pi — mirrors the Claude Code statusline:
 *
 *   <model> <think> │ ctx <pct>% │ <repo>:<branch> │ PR#<n> │ wt:<name>    ↑in ↓out $cost
 *
 * Claude model ids are shortened to Op/So/Fa/Ha + version (e.g. Op5·1m,
 * So3.5); other ids are shown as-is. Segments with no data (no PR, not in
 * a worktree, no git repo) are omitted. There is no 5h rate-limit segment:
 * pi does not surface provider rate-limit windows.
 *
 * The right side keeps the default footer's token/cost stats and any
 * extension statuses so nothing is lost by replacing the built-in footer.
 */

import { execFile } from "node:child_process";
import { resolve } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const PR_REFRESH_MS = 5 * 60 * 1000;

/** claude-opus-5[1m] -> Op5·1m, anthropic.claude-3-5-sonnet-20241022-v2:0 -> So3.5. */
export function shortModel(id: string): string {
	const match = id.match(/claude[-.](.+)$/i);
	if (!match) return id;
	const oneM = id.includes("[1m]") ? "·1m" : "";
	const families: Record<string, string> = { opus: "Op", sonnet: "So", fable: "Fa", haiku: "Ha" };
	let family = "";
	const nums: string[] = [];
	for (const tok of match[1]!.replace(/\[.*$/, "").split(/[-.]/)) {
		if (families[tok]) family = families[tok]!;
		else if (/^\d{1,2}$/.test(tok)) nums.push(tok); // skip 8-digit dates, v2:0, etc.
	}
	if (!family) return id;
	return `${family}${nums.join(".")}${oneM}`;
}

const THINKING_SHORT: Record<string, string> = {
	off: "",
	minimal: "min",
	low: "lo",
	medium: "md",
	high: "hi",
	xhigh: "xh",
	max: "max",
};

function formatTokens(count: number): string {
	if (count < 1000) return `${count}`;
	if (count < 1000000) return `${(count / 1000).toFixed(1)}k`;
	return `${(count / 1000000).toFixed(1)}M`;
}

function git(cwd: string, args: string[]): Promise<string | null> {
	return new Promise((resolve) => {
		execFile("git", args, { cwd, timeout: 2000 }, (err, stdout) => {
			resolve(err ? null : stdout.trim());
		});
	});
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx: ExtensionContext) => {
		if (ctx.mode !== "tui") return;

		ctx.ui.setFooter((tui, theme, footerData) => {
			let repoName: string | null = null;
			let worktree: string | null = null;
			let pr: { number: number; decision: string } | null = null;
			let prFetchedAt = 0;
			let disposed = false;

			// Repo identity and worktree name change at most per-session.
			void (async () => {
				const origin = await git(ctx.cwd, ["remote", "get-url", "origin"]);
				if (origin) {
					repoName = origin.replace(/\/+$/, "").split("/").pop()?.replace(/\.git$/, "") ?? null;
				}
				const top = await git(ctx.cwd, ["rev-parse", "--show-toplevel"]);
				if (!repoName && top) repoName = top.split("/").pop() ?? null;

				// Worktree: the <name> in .claude/worktrees/<name>/ or .pi/worktrees/<name>/,
				// else the toplevel dir name when this is a linked git worktree.
				const pathMatch = ctx.cwd.match(/\/\.(?:claude|pi)\/worktrees\/([^/]+)/);
				if (pathMatch) {
					worktree = pathMatch[1]!;
				} else if (top) {
					// git prints these with inconsistent absolute/relative forms
					// depending on cwd, so resolve both before comparing.
					const gitDir = await git(ctx.cwd, ["rev-parse", "--git-dir"]);
					const commonDir = await git(ctx.cwd, ["rev-parse", "--git-common-dir"]);
					if (gitDir && commonDir && resolve(ctx.cwd, gitDir) !== resolve(ctx.cwd, commonDir)) {
						worktree = top.split("/").pop() ?? null;
					}
				}
				if (!disposed) tui.requestRender();
			})();

			const refreshPr = () => {
				prFetchedAt = Date.now();
				execFile(
					"gh",
					["pr", "view", "--json", "number,reviewDecision"],
					{ cwd: ctx.cwd, timeout: 10000 },
					(err, stdout) => {
						if (disposed) return;
						let next: typeof pr = null;
						if (!err) {
							try {
								const parsed = JSON.parse(stdout) as { number: number; reviewDecision?: string };
								next = { number: parsed.number, decision: parsed.reviewDecision ?? "" };
							} catch {
								// leave next = null
							}
						}
						if (JSON.stringify(next) !== JSON.stringify(pr)) {
							pr = next;
							tui.requestRender();
						}
					},
				);
			};
			refreshPr();
			const unsubBranch = footerData.onBranchChange(() => {
				refreshPr();
				tui.requestRender();
			});

			return {
				dispose() {
					disposed = true;
					unsubBranch();
				},
				invalidate() {},
				render(width: number): string[] {
					const segs: string[] = [];

					// Model + thinking level
					const modelId = ctx.model?.id;
					if (modelId) {
						const think = THINKING_SHORT[ctx.thinkingLevel ?? ""] ?? ctx.thinkingLevel ?? "";
						segs.push(
							theme.fg("accent", shortModel(modelId)) + (think ? ` ${theme.fg("dim", think)}` : ""),
						);
					}

					// Context percent
					const pct = ctx.getContextUsage()?.percent;
					if (pct != null) {
						const color = pct >= 90 ? "error" : pct >= 70 ? "warning" : "success";
						segs.push(`ctx ${theme.fg(color, `${Math.round(pct)}%`)}`);
					}

					// repo:branch
					const branch = footerData.getGitBranch();
					if (repoName) {
						segs.push(`${theme.fg("accent", repoName)}${branch ? `:${branch}` : ""}`);
					} else if (branch) {
						segs.push(branch);
					}

					// PR (via gh, refreshed on branch change and every 5 minutes)
					if (Date.now() - prFetchedAt > PR_REFRESH_MS) refreshPr();
					if (pr) {
						const color =
							pr.decision === "APPROVED" ? "success" : pr.decision === "CHANGES_REQUESTED" ? "error" : "warning";
						segs.push(theme.fg(color, `PR#${pr.number}`));
					}

					// Worktree
					if (worktree) segs.push(theme.fg("muted", `wt:${worktree}`));

					// Right side: token/cost totals plus extension statuses, like the
					// default footer, so replacing it loses nothing.
					let input = 0;
					let output = 0;
					let cost = 0;
					for (const entry of ctx.sessionManager.getBranch()) {
						if (entry.type === "message" && entry.message.role === "assistant") {
							const usage = (entry.message as { usage: { input: number; output: number; cost: { total: number } } })
								.usage;
							input += usage.input;
							output += usage.output;
							cost += usage.cost.total;
						}
					}
					const statuses = [...footerData.getExtensionStatuses().values()].join(" ");
					const right = theme.fg(
						"dim",
						`${statuses ? `${statuses} ` : ""}↑${formatTokens(input)} ↓${formatTokens(output)} $${cost.toFixed(2)}`,
					);

					const left = segs.join(theme.fg("dim", " │ "));
					const pad = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(right)));
					return [truncateToWidth(left + pad + right, width)];
				},
			};
		});
	});
}
