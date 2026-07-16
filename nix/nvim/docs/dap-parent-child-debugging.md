# DAP parent/child debugging (`<leader>dF`) — shortcomings & fix plan

Status: **known-broken**, deferred. This documents why `<leader>dF` does not
currently let you debug into a subprocess, and a rough plan to fix it.

## What `<leader>dF` is supposed to do

Debug a Python program that launches a **separate** Python process, and stop at
breakpoints in *both*:

- the **parent** — the script you launch (e.g. an emode test script), and
- the **child** — the subprocess it spawns (e.g. the `emode` engine).

The implementation lives in `nvim/lua/dap_config.lua` (`<leader>dF`, ~line 231).
It (1) launches the parent with `request = "launch"`, then (2) on the parent's
`event_initialized`, runs a second `request = "attach"` config that connects to
`127.0.0.1:5679` — the intended child debugpy server.

## Concrete case that exposed it

- Script: `~/code/work/emode/emode-linux/tests/wip/transformation_optics/script_general_coupler.py`
- Line 43: `em = emc.EMode(emode_cmd=sys.argv[1:], verbose=False)`
- `emodeconnection` launches the engine via `subprocess.Popen(build_cmd_list(emode_cmd), …)`.
- `build_cmd_list` (`emodeconnection/emodeconnection/emodeconnection.py:170`):
  `cmd = emode_cmd or ["emode"]`, then appends `["run", <port_file>, …]`.

Symptom: the parent session works, but breakpoints in emode's own source
(`src/emode/**`) never bind or hit — the child is not being debugged.

## Root cause: three independent blockers

1. **The child is launched with no debugger.**
   Under `<leader>dF` the launch config passes **no `args`**, so `sys.argv[1:]`
   is empty, so `build_cmd_list([])` falls back to `["emode"]` — the plain
   console script, no debugpy. Nothing listens on `5679`, so the attach connects
   to nothing and no child session is ever created. Breakpoints in emode source
   therefore have no session to bind to.

   The intended launch is documented (commented out) in
   `emode-linux/tests/laser_taper/test1.py:63`:
   ```python
   emode_cmd=[sys.executable, "-m", "debugpy",
              "--listen", "127.0.0.1:5679", "--wait-for-client",
              ".../src/emode/__main__.py"]
   ```
   which `build_cmd_list` expands to
   `python -m debugpy --listen 127.0.0.1:5679 --wait-for-client __main__.py run <port> …`.

2. **debugpy is not installed in the emode `.venv`.**
   `~/code/work/emode/emode-linux/.venv/bin/python -c "import debugpy"` →
   `ModuleNotFoundError`. So even with the command from #1, `python -m debugpy`
   cannot run. debugpy must be added to that venv (or the project's dev deps).

3. **The auto-attach timing is wrong (a race).**
   `<leader>dF` fires the child attach on the *parent's* `event_initialized`,
   which happens at parent **startup** — before the script reaches `EMode(...)`
   and spawns the child. So nvim-dap connects to `5679` before the child's
   listener exists → connection refused. `--wait-for-client` does not help: it
   makes the child wait for *us*, but it does not let us connect before the
   child has opened its socket.

Note: the earlier `FileNotFoundError: 'emode'` (venv not on `PATH`) is a
*separate* issue, already fixed by activating the venv into nvim's env at
startup (see `nvim/lua/worktree.lua`, `ensure_python_env` / the
`VimEnter`/`DirChanged` autocmd).

## Rough fix plan

Split into a generic dotfiles change and a project-side change.

### A. dotfiles / `<leader>dF` (generic) — fixes blocker #3

Replace "attach on parent `event_initialized`" with **poll-then-attach**: after
launching the parent, poll `127.0.0.1:5679` (e.g. `vim.uv.tcp_connect` on a
short timer) and call `dap.run(child_cfg)` only once the port accepts. Add a
timeout (~10s) with a `vim.notify` so a never-listening child fails loudly
instead of hanging. This is reusable for any "child opens a debugpy listener"
setup, not just emode.

### B. project side — fixes blockers #1 and #2

1. Install debugpy into the emode venv (dev dependency), e.g.
   `.venv/bin/python -m pip install debugpy` or add it to the project's dev deps.
2. Make emode actually launch under debugpy on `5679 --wait-for-client`. Options
   (decision deferred):
   - **DAP args in dF** — bake the `python -m debugpy … __main__.py` args into
     `<leader>dF`'s launch config (`args = {...}`). No script edits, but ties the
     keybind to emode's venv/paths.
   - **Env flag (keeps dF generic)** — dF sets `env = { EMODE_DEBUG = "1" }`; the
     script (or `emodeconnection`) builds the debugpy `emode_cmd` when that env is
     set, else uses `sys.argv[1:]`.
   - **Edit the one script** — uncomment/adapt the `emode_cmd=[…debugpy…]` line
     directly; dF stays generic and only does parent-launch + poll-attach.

### Expected result

With A + B, `<leader>dF`:
1. launches the parent (breakpoints in the script work, as today),
2. the parent spawns emode as a debugpy server on `5679` that blocks on
   `--wait-for-client`,
3. dF polls `5679`, attaches as soon as it's up, emode unblocks and runs, and
4. breakpoints in `src/emode/**` bind and hit in the child session.

## Verification (once implemented)

- Set a breakpoint in the parent script and one in `src/emode/__main__.py` (or
  another emode source file that runs during `run`).
- Run `<leader>dF`. Confirm two sessions exist (`:lua =#require('dap').sessions()`
  or the dap-ui sessions view).
- In the child (attach) session's REPL, `import sys; sys.executable` should be
  the emode `.venv` python, and `shutil.which("emode")` should resolve.
- Both breakpoints should hit.

## Relevant files

- `nvim/lua/dap_config.lua` — `<leader>dF` (~231), `<leader>da` (~271), child
  attach config (~62).
- `nvim/lua/worktree.lua` — venv activation into nvim's env (the `PATH`/`emode`
  fix, separate from the above).
- Project: `emodeconnection/emodeconnection/emodeconnection.py`
  (`build_cmd_list`, ~170), `emode-linux/src/emode/__main__.py`,
  `emode-linux/tests/laser_taper/test1.py:63` (the commented recipe).
