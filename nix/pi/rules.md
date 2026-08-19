# Agent workflow rules

## Todo ledger and compaction-region contract

The `todo` tool and the task-compaction tools serve different purposes:

- Todo items are deliverables and are the sole authority for current and remaining work: status, dependencies, and the active item.
- `begin_task`/`end_task` delimit disposable transcript regions. Their summaries are the authority for historical facts, decisions, changes, evidence, and recovery context.
- A todo item and a compaction region are not one-to-one. One item may span several regions, and a region may investigate several items without completing any.

When using both systems:

1. Before substantial work, create or reconcile the todo plan and mark the item actually being worked on `in_progress`.
2. Call `begin_task` and `end_task` alone in their assistant messages; never batch either boundary call with `todo` or another tool.
3. Keep the todo ledger accurate while working. Before `end_task`, complete only fully finished items, preserve partial work as pending or in progress, and create items for newly discovered actionable work.
4. Never complete a todo merely because a compaction region closes, and never close a region merely because a todo changes status.
5. Do not make `end_task.open_threads` a second plan. Represent actionable future work in the todo ledger and reference its todo ID from `open_threads`; use additional text only for unresolved nuance needed to resume safely.
6. After `end_task` succeeds, if unfinished todo items remain, call `todo` with action `list` before opening the next region. This restores the current plan to model-visible context after the region transcript is replaced by its summary.

## Nix for ephemeral environments

Nix is available in the execution environment. Use it when work needs a tool, runtime, or
isolated dependency set that is not already available; do not assume the missing dependency
is a blocker.

1. Prefer the repository's existing flake or development shell when it provides the needed
   environment (for example, `nix develop -c <command>`).
2. For ad hoc tools, prefer an ephemeral shell such as
   `nix shell nixpkgs#<package> -c <command>`.
3. For a one-shot packaged application, use `nix run nixpkgs#<package> -- <args>` when that
   is clearer than entering a shell.
4. Do not install tools globally or add dependencies to the repository solely to provision
   the agent's working environment. Project dependency changes must be justified by the
   project itself, not by temporary agent needs.
5. Prefer project-pinned Nix inputs when they exist, and report when an ad hoc environment
   uses an unpinned package source in a way that affects reproducibility.
