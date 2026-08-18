#!/usr/bin/env bash
# Claude Code status line.
#
# Reads the session JSON Claude Code pipes to stdin and renders one line:
#   <model> │ ctx <pct>% │ <repo>:<branch> │ PR#<n> │ wt:<name> │ job:<id> │ 5h <pct>%
#
# Segments with no data (no PR, not in a worktree, not a background job,
# API-key auth with no rate limits) are omitted entirely.
#
# Source of truth: ~/.dotfiles/nix/nix/claude-code/statusline.sh
# Installed to ~/.claude/statusline.sh by home-manager (nix/claude-code.nix).

command -v jq >/dev/null 2>&1 || { echo "statusline: jq not on PATH"; exit 0; }

input=$(cat)

# One jq call for every field we need; absent fields become "". Joined on the
# \x1f unit separator: a tab in IFS is "IFS whitespace", which collapses empty
# fields and shifts everything left, while a non-whitespace char keeps them.
IFS=$'\x1f' read -r model_id model_name ctx_pct cwd repo_name pr_num pr_state wt_session git_wt five_h five_h_reset < <(
  jq -r '
    def pct(v): if v == null then "" else (v | round | tostring) end;
    [
      (.model.id // ""),
      (.model.display_name // ""),
      pct(.context_window.used_percentage // 0),
      (.workspace.current_dir // .cwd // ""),
      (.workspace.repo.name // ""),
      (.pr.number // "" | tostring),
      (.pr.review_state // ""),
      (.worktree.name // ""),
      (.workspace.git_worktree // ""),
      pct(.rate_limits.five_hour.used_percentage),
      (.rate_limits.five_hour.resets_at // "" | tostring)
    ] | join("\u001f")' <<<"$input" 2>/dev/null
) || true

BOLD=$'\033[1m' DIM=$'\033[2m' RESET=$'\033[0m'
RED=$'\033[31m' GREEN=$'\033[32m' YELLOW=$'\033[33m'
BLUE=$'\033[34m' MAGENTA=$'\033[35m' CYAN=$'\033[36m'

# claude-opus-5[1m] -> Op5·1m, claude-haiku-4-5-20251001 -> Ha4.5,
# claude-3-5-sonnet-20241022 -> So3.5. Falls back to the first two letters
# of display_name if the id has no known family token.
short_model() {
  local id="${1#claude-}" fam="" suffix="" tok toks=() nums=()
  [[ "$1" == *"[1m]"* ]] && suffix="·1m"
  id="${id%%\[*}"
  IFS='-' read -ra toks <<<"$id"
  for tok in "${toks[@]}"; do
    case "$tok" in
      opus) fam="Op" ;;
      sonnet) fam="So" ;;
      fable) fam="Fa" ;;
      haiku) fam="Ha" ;;
      [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]) : ;; # date stamp, drop
      [0-9] | [0-9][0-9]) nums+=("$tok") ;;
    esac
  done
  [[ -z $fam && -n $2 ]] && fam="${2:0:2}"
  local ver=""
  if ((${#nums[@]})); then
    local IFS=.
    ver="${nums[*]}"
  fi
  printf '%s%s%s' "$fam" "$ver" "$suffix"
}

# Green under 70%, yellow 70-89%, red 90%+.
level_color() {
  if (($1 >= 90)); then
    printf '%s' "$RED"
  elif (($1 >= 70)); then
    printf '%s' "$YELLOW"
  else
    printf '%s' "$GREEN"
  fi
}

segs=()

# Model
model=$(short_model "$model_id" "$model_name")
[[ -n $model ]] && segs+=("${BOLD}${CYAN}${model}${RESET}")

# Context
[[ -n $ctx_pct ]] && segs+=("ctx $(level_color "$ctx_pct")${ctx_pct}%${RESET}")

# Repo and branch. repo comes from the origin remote; branch from cwd.
branch="" repo="$repo_name"
if [[ -n $cwd && -d $cwd ]]; then
  branch=$(git -C "$cwd" branch --show-current 2>/dev/null) || branch=""
  if [[ -z $branch ]]; then
    # Detached HEAD: show the short sha instead.
    branch=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null) || branch=""
    [[ -n $branch ]] && branch="@$branch"
  fi
  if [[ -z $repo && -n $branch ]]; then
    top=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null) && repo="${top##*/}"
  fi
fi
if [[ -n $repo || -n $branch ]]; then
  segs+=("${MAGENTA}${repo}${RESET}${branch:+:${branch}}")
fi

# PR, colored by review state.
if [[ -n $pr_num ]]; then
  case "$pr_state" in
    approved) pr_color="$GREEN" ;;
    changes_requested) pr_color="$RED" ;;
    draft) pr_color="$DIM" ;;
    *) pr_color="$YELLOW" ;;
  esac
  segs+=("${pr_color}PR#${pr_num}${RESET}")
fi

# Worktree: prefer the <name> in .../.claude/worktrees/<name>/... from cwd,
# then the --worktree session name, then any linked-worktree name.
wt=""
if [[ $cwd =~ /\.claude/worktrees/([^/]+) ]]; then
  wt="${BASH_REMATCH[1]}"
elif [[ -n $wt_session ]]; then
  wt="$wt_session"
elif [[ -n $git_wt ]]; then
  wt="$git_wt"
fi
[[ -n $wt ]] && segs+=("${BLUE}wt:${wt}${RESET}")

# Background job dir (set only when CLAUDE_CODE_SESSION_KIND=bg; inherited
# from the Claude Code process env). Show just the job id.
[[ -n ${CLAUDE_JOB_DIR:-} ]] && segs+=("${DIM}job:${CLAUDE_JOB_DIR##*/}${RESET}")

# 5-hour rate limit (Pro/Max only; absent until the first API response),
# with the local time the window resets. BSD date wants -r <epoch>, GNU date
# wants -d @<epoch>; try both so it works with either in PATH.
if [[ -n $five_h ]]; then
  seg="5h $(level_color "$five_h")${five_h}%${RESET}"
  if [[ -n $five_h_reset ]]; then
    reset_hm=$(date -r "$five_h_reset" +%H:%M 2>/dev/null) ||
      reset_hm=$(date -d "@$five_h_reset" +%H:%M 2>/dev/null) ||
      reset_hm=""
    [[ -n $reset_hm ]] && seg+=" ${DIM}↻${reset_hm}${RESET}"
  fi
  segs+=("$seg")
fi

# Join with a dim separator.
out=""
for seg in "${segs[@]}"; do
  out+="${out:+ ${DIM}│${RESET} }${seg}"
done
printf '%s\n' "$out"
