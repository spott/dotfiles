# Plan: replace runtime zimfw with a Nix-owned Zsh plugin set

Status: implemented and verified in this branch, but not activated. The user's live `$ZDOTDIR/.zim` remains untouched.

## Recommendation

Do this if the goal is reproducibility and rollback. Do **not** do it merely to make the configuration shorter: the module list still has to live somewhere, and Nix/`flake.lock` will effectively replace zimfw as the plugin manager.

The recommended design is a narrowly scoped, local Home Manager module that implements a thin, explicit plugin loader:

- keep the current `zshrc_personal` behavior and plugin order;
- pin plugin source repositories as non-flake inputs in `flake.lock`;
- describe the current plugin set to the local module as ordered sources, `fpath` additions, autoloads, and init files/snippets;
- have the module link the immutable sources and generate a loader under `$ZDOTDIR`;
- remove all runtime download, update, build, and self-install behavior from shell startup;
- make plugin updates an explicit lock-file update followed by a normal Home Manager or nix-darwin build.

This is intentionally not a general reimplementation of zimfw. It supports the small set of declarative operations this configuration actually needs and does not parse `.zimrc`, resolve repositories, run `zimfw`, or promise compatibility with arbitrary zim modules.

This is a moderate one-time migration, not a large ongoing maintenance burden. I would avoid vendoring copies of upstream plugin code into this repository: that creates more code ownership while making updates harder.

## Implementation result

The branch now contains the local `spott.zsh.pluginSet` module, all 18 source inputs locked to the previously installed revisions, the ordered plugin policy, build-time `zcompile` preparation, the immutable fzf adaptation, and the focused update/smoke tools. Runtime zimfw bootstrap/update code and the managed `.zimrc` have been removed.

Verification completed before activation:

- the nix-darwin system and standalone Normandy Home Manager generation build on `aarch64-darwin`;
- the non-native `x86_64-linux` devbox Home Manager generation and exported devbox module evaluate successfully;
- generated source links, `fpath`, autoloads, and plugin source order match the old zim-generated loader;
- generated Zsh files pass `zsh -n` and contain no runtime `.zim`/zimfw references;
- a temporary-`HOME`, PTY-backed interactive startup loaded the generated configuration and found the required autoloaded functions, fzf/history widgets, syntax highlighters, completion state, fpath head, and autosuggestions state;
- build-time wordcode plus a Home Manager-created local highlighter index avoids immutable-store startup regressions; repeated PTY startup is about 0.13 seconds, matching the old setup on the same test harness;
- `zsh/update-plugins --check` passes, building native targets, evaluating non-native targets, and running the PTY test without activation.

The only remaining validation is deliberate activation followed by the manual interactive checklist below.

## Important update semantics

A reproducible `darwin-rebuild switch` should **not** silently contact GitHub and install whatever is newest that day. It should install exactly what `flake.lock` records.

The workflow should therefore be:

```sh
# Applies the already-locked Zsh configuration and plugin revisions.
sudo darwin-rebuild switch --flake .#Normandy

# Deliberately advance only the Zsh inputs, review flake.lock, build, then switch.
./zsh/update-plugins
nix build .#darwinConfigurations.Normandy.system
sudo darwin-rebuild switch --flake .#Normandy
```

Running `nix flake update` with no input names will also update all plugin inputs, so `zsh/update-plugins` is not required to keep them current when the whole flake is updated. Keep the helper anyway: it provides a focused update that leaves `nixpkgs`, Home Manager, and other unrelated inputs alone, and then builds/tests the Zsh-bearing configurations in isolation. It should hold the complete plugin-input list, accept an optional validated subset, show the lock-file diff, build the Darwin and Home Manager targets, and run the noninteractive Zsh smoke test. It should not activate or switch a generation. If a check fails, it should leave the lock-file change visible for inspection or reversal.

A standalone Home Manager build will consume the same lock file. Making activation itself run `zimfw update` would be simpler, but it would be network-dependent, non-reproducible, and not truly rollbackable; that option is not recommended.

## Current-state findings

The active startup path is:

1. Home Manager's generated `.zshrc` sources `.zshrc_personal` on its first line.
2. `.zshrc_personal` downloads zimfw if missing, runs `zimfw init` if `.zimrc` is newer, and sources `.zim/init.zsh`.
3. The generated zimfw loader sets plugin `fpath` entries and sources 19 modules.
4. Home Manager then applies its history, fzf, direnv, VTE, alias, and directory-hash configuration.

That order matters. In particular:

- Home Manager intentionally overrides some earlier environment/history and utility aliases.
- The custom prompt depends on `prompt-pwd` and `git-info` functions being on `fpath` before the theme is sourced.
- completion is initialized after completion definitions are put on `fpath`.
- syntax highlighting, history substring search, and autosuggestions are intentionally last.
- `zshrc_personal` adds history-search key bindings and overrides the theme's `RPS1` with the linked-worktree indicator after plugin initialization.
- `zsh-vi-mode` and the Ctrl-R fzf binding need careful interactive testing.

There is already duplication: zimfw's `fzf` module invokes `fzf --zsh`, and Home Manager's `programs.fzf.enableZshIntegration` invokes it again later. The zimfw fzf module also adds useful `fd`/`rg`, preview, and `FZF_*` customization, so it cannot simply be deleted without porting that tail of the module.

The live `.zim` tree is about 16 MiB. Its apparent dirty files are only generated `.zwc` files; no local source modifications were found. Most installed modules are behind their upstream heads. That is useful for migration: the first declarative version should lock the currently installed commits rather than mixing migration and upgrades.

The untracked files in the original worktree (`nix/zsh/plugins/`, `minimal.zsh-theme`, and `zsh_commands.zsh`) appear to be an older, inactive migration experiment from January 2025. They are not in this worktree and should not be treated as the source of current behavior. For example, the untracked minimal theme differs from the currently sourced zimfw theme.

## Proposed file layout

```text
nix/
  flake.nix                  # non-flake Zsh source inputs
  flake.lock                 # exact plugin revisions
  zsh/
    default.nix              # existing HM settings; configures the local module
    module.nix               # narrow declarative Zsh plugin-set HM module
    plugins.nix              # ordered source/fpath/autoload/init descriptors
    fzf.zsh                  # only the useful zim fzf customizations
    pty-smoke.zsh            # safe temporary-HOME interactive verification
    zprofile
    zshrc_personal           # personal config, no zim bootstrap
    update-plugins           # focused update-and-verification helper
```

The module should link every source under `$ZDOTDIR/plugins/<name>` and generate an ordinary, readable loader that uses those stable relative paths. The ordered declarations belong in `plugins.nix`; the generated loader should remain close enough to today's `.zim/init.zsh` to inspect and compare directly.

## Home Manager module boundary

Use a repository-local module with a project-specific namespace such as `spott.zsh.pluginSet`, rather than claiming to provide a general `programs.zimfw` implementation. Its configuration should be an ordered list of records that can express only what the current setup needs:

- plugin name and immutable `src`;
- zero or more relative directories to prepend to `fpath`;
- function names to autoload;
- relative init files plus small before/after snippets for adapted components such as fzf;
- an optional, explicit preload list for the syntax-highlighting files that upstream discovers dynamically.

The module owns the `$ZDOTDIR/plugins/<name>` links and generated loader. It copies source inputs only inside Nix derivations, runs a fixed `zcompile` step for declared init files, and creates a small local support index for syntax highlighting; it never builds or mutates plugins at shell startup. `zshrc_personal` sources the loader where its zimfw bootstrap currently runs, preserving the existing early startup position. The generated loader adds all required `fpath` entries and autoload declarations before sourcing the ordered init entries, matching the current zim-generated behavior.

The module must not:

- parse `.zimrc` or the full `zmodule` syntax;
- fetch repositories or choose revisions;
- run `zimfw install`, `zimfw update`, or arbitrary plugin build commands;
- write into immutable plugin sources;
- attempt to support every upstream zimfw option.

This keeps the reusable mechanism small while leaving policy—the exact plugins, order, and source inputs—in this repository. A true zimfw-compatible Home Manager module would have to reproduce repository resolution, revisions, generated init files, compilation, and mutable-cache behavior; that would be substantially more machinery than this migration warrants.

## Source policy

For the parity migration, declare the 18 source repositories that remain after the fzf adaptation as `flake = false` inputs and initialize their lock entries to the commits listed below. The fzf executable and its generated shell integration already come from the locked nixpkgs input; only the useful customization from zimfw's fzf module is retained in-tree. This avoids accidentally downgrading other plugins to older nixpkgs releases or upgrading them during the migration.

After parity is established, common plugins can optionally move to nixpkgs packages (`zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-history-substring-search`, `zsh-completions`, and `zsh-vi-mode`). That reduces flake inputs but ties their update cadence to nixpkgs and currently changes several revisions. It should be a separate change.

| Module | Revision to use for first migration |
|---|---|
| `completion` | `efc94ced311dd181835ccfd3f08ecb422c8465b2` |
| `duration-info` | `c887236aa21e2b070e128d2182c9576972697ba0` |
| `environment` | `d4bceaa3da89cd819843334dba1a5bf7dc137e14` |
| `git-info` | `3dcd29c4eaea882a8768194458287fe7fbf321e4` |
| `input` | `9f6dae94e40e0cf17333d02661490144def17276` |
| `magic-enter` | `18f6754b151d7326d54be23cbd1070ddc6e39bab` |
| `minimal` | `9fd929303e60ac8c3b2f8d4cc00b0b0f4f0c4f6b` |
| `per-directory-history` | `4117b0683bfd72e32dbbf2e73f477535e966c841` |
| `prompt-pwd` | `acdec4beeb97926b2cf19599131d7e7daa9402d2` |
| `termtitle` | `1a932f4df2dc2dcee54e2c5f5449646287ed9855` |
| `utility` | `fec84342585d61dff448c786ad4eeb082c450c54` |
| `walltime` | `285dd54fd39d814f44549622ce2b572e6381603d` |
| `zimfw-eza` | `fe12d87dc28fdc977a71804105323ad5a88dd6e5` |
| `zsh-autosuggestions` | `85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5` |
| `zsh-completions` | `8d5a945c93a6069f3f305219f373b61d2f05472c` |
| `zsh-history-substring-search` | `87ce96b1862928d84b1afe7c173316614b30e301` |
| `zsh-syntax-highlighting` | `5eb677bb0fa9a3e60f0eff031dc13926e093df92` |
| `zsh-vi-mode` | `808579b101943bc25860255334624dcb899fe3cd` |

The inputs should be declared against movable upstream repositories in `flake.nix`; only `flake.lock` should pin the revisions. The initial lock can be constructed with per-input `--override-input` values so a later `nix flake update <input>` can still advance it normally.

## Loader behavior to preserve

The new loader should reproduce the meaningful part of `.zim/init.zsh`:

1. prepend function/completion paths for `utility`, `prompt-pwd`, `duration-info`, `git-info`, `zsh-completions/src`, and `completion/functions`;
2. autoload `mkcd`, `mkpw`, `prompt-pwd`, duration helpers, and git-info helpers;
3. source, in order:
   - `environment`
   - `input`
   - `termtitle`
   - `utility`
   - `zimfw-eza`
   - `magic-enter`
   - `per-directory-history`
   - `zsh-vi-mode`
   - adapted fzf initialization/customization
   - `walltime`
   - `duration-info`
   - `minimal`
   - `completion`
   - `zsh-syntax-highlighting`
   - `zsh-history-substring-search`
   - `zsh-autosuggestions`

Do not source the zimfw `fzf/init.zsh` unchanged from the Nix store. It regenerates and compiles a file beside itself when mtimes change, which assumes a writable plugin checkout. Instead, source `fzf --zsh` once and keep the module's useful command/preview environment setup in `zsh/fzf.zsh`. Disable Home Manager's second fzf Zsh initialization after this is in place, while retaining its package and color options.

Keep `programs.zsh.enableCompletion = false` in Home Manager and `programs.zsh.enableCompletion = false` in nix-darwin during the parity phase, because the zimfw completion module remains the single `compinit` owner. A later cleanup can port its completion styles/cache behavior to native Home Manager configuration, but that is a behavior change and should not be part of the manager-removal commit.

## Implementation sequence

### 1. Capture parity fixtures

Before editing, save machine-readable observations from the current shell:

- enabled/disabled Zsh options relevant to the environment module;
- aliases from utility/eza and Home Manager after full startup;
- `fpath` order;
- existence of required functions/widgets;
- prompt variables and relevant zstyles;
- startup stderr and a rough startup-time baseline.

Do not copy the mutable `.zim` tree into Git.

### 2. Add declarative sources and the local module

- Add the 18 `flake = false` source inputs; continue taking the fzf executable from nixpkgs.
- Pass a narrowly scoped `zshSources` argument to all Home Manager entry points: embedded nix-darwin, standalone Normandy, and standalone devbox.
- Initialize lock entries to the installed commits above.
- Add/import `zsh/module.nix` in each Home Manager entry point and define the current ordered plugin declarations in `zsh/plugins.nix`.
- Have the module link source trees under `$ZDOTDIR/plugins` and generate the loader from those declarations.

### 3. Replace only the manager/bootstrap layer

- Configure the local module to generate the explicit loader with the existing order.
- Adapt the fzf module as described above, represented as an explicit local init entry rather than a writable third-party module.
- Replace the zimfw download/init/source block in `zshrc_personal` with one loader source line.
- Remove the managed `.zimrc` link and the obsolete `zimrc` file.
- Update the nix-darwin comment that currently says completion is disabled specifically for zimfw.
- Leave personal functions, history settings, prompt worktree indicator, aliases, and `zprofile` otherwise unchanged.

This commit should not update plugin revisions or redesign the shell.

### 4. Build and smoke-test before activation

Run at least:

```sh
nix build .#darwinConfigurations.Normandy.system
nix build '.#homeConfigurations."spott@Normandy.local".activationPackage'
nix build '.#homeConfigurations."spott@devbox.sc.spott.us".activationPackage'
```

If the Linux package cannot be built locally, it must at least evaluate successfully.

Run a temporary-`HOME`/`ZDOTDIR` interactive-shell smoke test against the generated files and compare it with the parity fixtures. Assert that startup output contains no errors and that generated config contains no references to `.zim`, `zimfw`, `curl`, or `wget`.

### 5. Activate and manually test

After a successful build, switch once and open a fresh terminal. Check:

- prompt colors, git state, and linked-worktree indicator;
- insert/normal vi cursor and keymap behavior;
- Up/Down and `j`/`k` history substring search;
- Ctrl-R fzf history;
- tab completion, menu selection, completion colors, and Nix command completions;
- per-directory/global history switching;
- `ls`/`ll`/eza aliases, magic Enter, terminal title, walltime commands, and 1Password plugin loading;
- a shell on the Linux Home Manager target when practical.

Keep `$ZDOTDIR/.zim` untouched for at least one successful generation. Rollback is a normal nix-darwin/Home Manager generation rollback. Once satisfied, the old `.zim`, `.zimrc` backups, and stale completion dumps can be removed manually; they should not be deleted automatically by activation.

### 6. Add and use the focused updater

Only after parity is confirmed, add `zsh/update-plugins`. With no arguments it should update the complete plugin-input whitelist; with arguments it should reject unknown names and update only the requested plugin inputs. It should then:

- show the resulting `flake.lock` diff;
- build the Darwin system and both standalone Home Manager configurations (evaluation-only where the host platform cannot build locally);
- run the same generated-shell smoke checks used during migration;
- stop without switching or activating anything.

A no-argument `nix flake update` remains valid and will update these inputs along with the rest of the flake. The helper exists to isolate plugin upgrades and their verification, not to introduce a second update mechanism.

For subsequent plugin upgrades:

- run the helper;
- inspect the lock diff and upstream changelogs;
- switch only after its checks pass;
- optionally replace well-packaged plugins with nixpkgs versions one at a time.

## Alternatives considered

### Keep zimfw but install `pkgs.zimfw`

Smallest change and removes the self-downloading `zimfw.zsh`, but modules remain mutable, independently updated, and outside Nix rollback. This is a reasonable low-effort compromise, but it does not meet the declarative-plugin goal.

### Wrap real zimfw in a Home Manager module

A module that installs zimfw, writes `.zimrc`, and runs `zimfw install`/`update` during activation is rejected. It makes rebuilds depend on network and mutable Git state, lets two identical lock files produce different shells, and prevents generation rollback from restoring plugin revisions.

A fully compatible build-time zimfw module is also not recommended: Nix builders cannot simply let zimfw clone from the network, so it would still need separately fetched sources while reproducing zimfw's resolution, generation, compilation, and writable-cache semantics. The recommended local plugin-set module captures the useful Home Manager abstraction without taking on that compatibility burden.

### Vendor all plugin source in this repository

Rejected as the default. It would add a sizeable body of third-party code and manual update work. Vendoring a small adapted fzf customization is reasonable because the original module assumes a writable checkout.

### Replace each zim module with native Home Manager/Zsh configuration immediately

Potentially cleaner eventually, but too many behavior changes at once. The completion module alone contains substantial cache and style behavior; the environment, input, utility, term-title, magic-enter, prompt, and custom history modules all contribute observable behavior. Manager removal should be mechanical first, cleanup second.

## Effort/value assessment

Expected implementation effort is roughly one focused session plus interactive validation. The local module adds a small amount of up-front structure but should make the source links, loader generation, and ordering easier to reason about than ad hoc declarations in `default.nix`. Ongoing updates become a focused lock-file update plus isolated builds instead of `zimfw update`. The configuration will be somewhat more explicit and `flake.lock` substantially larger, but startup will no longer download or mutate plugins, Darwin and Linux will use the same revisions, and a generation rollback will restore the complete shell.

My conclusion: this is worth doing if those reproducibility properties are the objective. If the real objective is only “stop seeing zimfw update machinery,” use the smaller `pkgs.zimfw` compromise and keep the current module workflow.
