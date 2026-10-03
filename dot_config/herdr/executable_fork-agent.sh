#!/usr/bin/env bash
# Fork the focused Claude agent (cmux/orca-style fork), keeping its history.
# Bound to hotkeys via [[keys.command]] in ~/.config/herdr/config.toml.
#
# Usage: fork-agent.sh [here|split|new]
#   here   new tab in the current workspace, same cwd   (default)
#   split  new pane beside the current one, same cwd
#   new    new workspace: a fork/<stamp> git worktree if the cwd is a repo,
#          otherwise a plain workspace on the same cwd
#
# The transcript is copied into the target path's project dir when the fork
# lands elsewhere, so `claude --fork-session --resume <id>` can find it.

set -euo pipefail

MODE="${1:-here}"
H="${HERDR_BIN_PATH:-herdr}"
LOG="$HOME/.config/herdr/fork-agent.log"
exec >>"$LOG" 2>&1
echo "--- fork ($MODE) requested $(date)"

fail() {
  echo "FAIL: $1"
  "$H" notification show "Fork failed" --body "$1" --sound none || true
  exit 1
}

# Claude slugifies the cwd into a ~/.claude/projects/<slug> directory.
slug() { printf '%s' "$1" | sed 's/[^A-Za-z0-9]/-/g'; }

snap=$("$H" api snapshot) || fail "no herdr server"
pane="${HERDR_ACTIVE_PANE_ID:-$(jq -r '.result.snapshot.focused_pane_id' <<<"$snap")}"
ws="${HERDR_ACTIVE_WORKSPACE_ID:-$(jq -r '.result.snapshot.focused_workspace_id' <<<"$snap")}"

IFS=$'\t' read -r agent sid cwd < <(
  jq -r --arg p "$pane" '
    .result.snapshot.agents[] | select(.pane_id == $p)
    | [.agent, (.agent_session.value // ""), .cwd] | @tsv' <<<"$snap"
) || true

[ -n "${agent:-}" ] || fail "no agent detected in pane $pane"
[ "$agent" = "claude" ] || fail "fork is wired for claude only (pane runs: $agent)"
[ -n "${sid:-}" ] || fail "claude session id not known yet for pane $pane"

stamp=$(date +%m%d-%H%M%S)
case "$MODE" in
  here)
    out=$("$H" tab create --workspace "$ws" --cwd "$cwd" --label "fork" --focus) \
      || fail "tab create failed"
    ;;
  split)
    out=$("$H" pane split "$pane" --direction right --cwd "$cwd" --focus) \
      || fail "pane split failed"
    ;;
  new)
    if root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null); then
      out=$("$H" worktree create --cwd "$root" --branch "fork/$stamp" \
            --label "fork $stamp" --focus --json) || fail "worktree create failed"
    else
      out=$("$H" workspace create --cwd "$cwd" --label "fork $stamp" --focus) \
        || fail "workspace create failed"
    fi
    ;;
  *) fail "unknown mode '$MODE' (use here|split|new)" ;;
esac

newpane=$(jq -r '[.. | objects | select(has("pane_id")) | .pane_id] | first' <<<"$out")
newcwd=$(jq -r '[.. | objects | select(has("cwd")) | .cwd] | first' <<<"$out")
[ -n "$newpane" ] && [ "$newpane" != "null" ] || fail "could not read new pane id"

# Only needed when the fork lands in a different directory (worktree mode).
src="$HOME/.claude/projects/$(slug "$cwd")/$sid.jsonl"
if [ -n "$newcwd" ] && [ "$newcwd" != "null" ] && [ "$newcwd" != "$cwd" ] && [ -f "$src" ]; then
  dstdir="$HOME/.claude/projects/$(slug "$newcwd")"
  mkdir -p "$dstdir"
  cp "$src" "$dstdir/$sid.jsonl"
fi

"$H" pane send-text "$newpane" "claude --fork-session --resume $sid"
"$H" pane send-keys "$newpane" enter
echo "OK: forked $sid from $pane into $newpane ($MODE, ${newcwd:-$cwd})"
