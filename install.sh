#!/usr/bin/env bash
# Install this pack into agent tools. Edits always happen in this folder.
#
# - Tools with a plugin system get the pack as ONE plugin (Codex today), so its skills are grouped
#   and do not crowd the tool's loose skill list. Re-run after editing to refresh the tool's copy.
# - Other tools get each skill linked into their skills folder; edits show up through the links.
#
# Usage:
#   ./install.sh                 # every detected tool
#   ./install.sh <dir> [<dir>…]  # link into the given skills folders only
#   ./install.sh --copy …        # copy instead of link (for tools that do not follow links)
#   ./install.sh --uninstall …   # remove links/copies this pack created (plugins: use the tool's own remove)
set -euo pipefail

PACK="$(cd "$(dirname "$0")" && pwd)"
MODE=link
case "${1:-}" in
  --copy) MODE=copy; shift ;;
  --uninstall) MODE=uninstall; shift ;;
esac

is_windows() { case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) return 0 ;; *) return 1 ;; esac; }
native_path() { if is_windows; then cygpath -w "$1"; else printf '%s' "$1"; fi; }

# Codex: install as a plugin from this folder's local marketplace (.agents/plugins/marketplace.json).
codex_bin() {
  command -v codex 2>/dev/null && return
  for c in "$HOME/.codex/plugins/.plugin-appserver/codex.exe" "$HOME/.codex/plugins/.plugin-appserver/codex"; do
    [ -x "$c" ] && { printf '%s' "$c"; return; }
  done
}
install_codex_plugin() {
  local bin; bin="$(codex_bin)"
  [ -n "$bin" ] || { echo "SKIP     Codex found but its CLI is not; add $(native_path "$PACK") as a marketplace manually" >&2; return; }
  "$bin" plugin marketplace add "$(native_path "$PACK")" >/dev/null 2>&1 || true   # already added is fine
  "$bin" plugin add dev-loop@dev-loop >/dev/null && echo "plugin   codex: dev-loop@dev-loop (refreshed)"
}

# Tools without a plugin system for skills: <tool home>:<skills folder>
LINKED=(
  "$HOME/.claude:$HOME/.claude/skills"
  "$HOME/.cursor:$HOME/.cursor/skills"
  "$HOME/.agents:$HOME/.agents/skills"
)

targets=()
if [ $# -gt 0 ]; then
  targets=("$@")
else
  if [ "$MODE" != uninstall ] && [ -d "$HOME/.codex" ]; then install_codex_plugin; fi
  for entry in "${LINKED[@]}"; do
    home="${entry%%:*}"; dir="${entry#*:}"
    [ -d "$home" ] && targets+=("$dir")
  done
fi
[ ${#targets[@]} -gt 0 ] || exit 0

link_dir() { # $1 source, $2 destination
  if is_windows; then
    cmd //c mklink //J "$(cygpath -w "$2")" "$(cygpath -w "$1")" >/dev/null
  else
    ln -s "$1" "$2"
  fi
}

is_ours() { # destination already points into this pack (link or marked copy)
  [ -f "$1/.dev-loop-copy" ] && return 0
  [ -e "$1/SKILL.md" ] || return 1
  [ "$(cd "$1" && pwd -P)" = "$(cd "$PACK/skills/$(basename "$1")" && pwd -P)" ]
}

remove_ours() {
  if is_windows && [ ! -f "$1/.dev-loop-copy" ]; then
    cmd //c rmdir "$(cygpath -w "$1")" >/dev/null   # removes the junction only, not the target
  else
    rm -rf "$1"
  fi
}

for dir in "${targets[@]}"; do
  mkdir -p "$dir"
  for src in "$PACK"/skills/*/; do
    name="$(basename "$src")"; dest="$dir/$name"
    if [ "$MODE" = uninstall ]; then
      if [ -e "$dest" ] && is_ours "$dest"; then remove_ours "$dest"; echo "removed  $dest"; fi
      continue
    fi
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      if is_ours "$dest"; then echo "ok       $dest"; continue; fi
      echo "SKIP     $dest exists and is not from this pack; move it away first" >&2; continue
    fi
    if [ "$MODE" = copy ]; then
      cp -R "$src" "$dest"; : > "$dest/.dev-loop-copy"; echo "copied   $dest"
    else
      link_dir "${src%/}" "$dest"; echo "linked   $dest"
    fi
  done
done
