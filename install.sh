#!/usr/bin/env bash
# Link every skill in this pack into one or more agent tools' skill folders.
# Edits always happen here; the tools see them through the links.
#
# Usage:
#   ./install.sh                 # link into every known tool folder whose tool is installed
#   ./install.sh <dir> [<dir>…]  # link into the given skills folders
#   ./install.sh --copy …        # copy instead of link (for tools that do not follow links)
#   ./install.sh --uninstall …   # remove links/copies this pack created
set -euo pipefail

PACK="$(cd "$(dirname "$0")" && pwd)"
MODE=link
case "${1:-}" in
  --copy) MODE=copy; shift ;;
  --uninstall) MODE=uninstall; shift ;;
esac

# Known user-level skill folders: <tool home>:<skills folder>
KNOWN=(
  "$HOME/.codex:$HOME/.codex/skills"
  "$HOME/.claude:$HOME/.claude/skills"
  "$HOME/.cursor:$HOME/.cursor/skills"
  "$HOME/.agents:$HOME/.agents/skills"
)

targets=()
if [ $# -gt 0 ]; then
  targets=("$@")
else
  for entry in "${KNOWN[@]}"; do
    home="${entry%%:*}"; dir="${entry#*:}"
    [ -d "$home" ] && targets+=("$dir")
  done
fi
[ ${#targets[@]} -gt 0 ] || { echo "No tool folders found; pass a skills folder explicitly." >&2; exit 1; }

is_windows() { case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) return 0 ;; *) return 1 ;; esac; }

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
