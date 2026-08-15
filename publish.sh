#!/usr/bin/env bash
#
# Publish the Note Canvas theme into every Obsidian vault under $VAULT_ROOT.
#
# Default mode is --link, which symlinks theme.css and manifest.json out of
# this repo. Edits here then show up in every vault with no republish step
# (reload Obsidian, or use the Hot Reload plugin, to see them).
#
# Use --copy for vaults that live on Obsidian Sync, Dropbox, or anything else
# that does not preserve symlinks.

set -euo pipefail

THEME_NAME="Note Canvas"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_ROOT="${OBSIDIAN_VAULT_ROOT:-$HOME/Obsidian}"
FILES=(theme.css manifest.json)

MODE=link
ACTIVATE=0
DRY=0
FORCE=0

usage() {
  cat <<EOF
Usage: ${0##*/} [options]

  --link          symlink into each vault (default; live updates)
  --copy          copy into each vault (for synced vaults)
  --activate      also set "cssTheme" in each vault's appearance.json
  --vaults DIR    vault root (default: \$OBSIDIAN_VAULT_ROOT or ~/Obsidian)
  --dry-run       show what would happen, change nothing
  --force         replace real files without prompting
  -h, --help      this message

Close Obsidian before using --activate: a running Obsidian may rewrite
appearance.json from memory on exit and undo the change.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --link)     MODE=link ;;
    --copy)     MODE=copy ;;
    --activate) ACTIVATE=1 ;;
    --dry-run)  DRY=1 ;;
    --force)    FORCE=1 ;;
    --vaults)   VAULT_ROOT="${2:?--vaults needs a directory}"; shift ;;
    -h|--help)  usage; exit 0 ;;
    *)          echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

for f in "${FILES[@]}"; do
  [[ -f "$REPO_DIR/$f" ]] || { echo "missing $REPO_DIR/$f" >&2; exit 1; }
done
[[ -d "$VAULT_ROOT" ]] || { echo "no vault root at $VAULT_ROOT" >&2; exit 1; }

run() {
  if (( DRY )); then
    printf '  would: '; printf '%q ' "$@"; printf '\n'
  else
    "$@"
  fi
}

# Refuse to clobber a real file the user may have hand-edited; a symlink we
# planted ourselves, or a copy of our own file, is fair game.
safe_to_replace() {
  local target="$1" source="$2"
  [[ ! -e "$target" && ! -L "$target" ]] && return 0
  [[ -L "$target" ]] && return 0
  (( FORCE )) && return 0
  cmp -s "$target" "$source" && return 0
  return 1
}

published=0
skipped=0

shopt -s nullglob
for vault in "$VAULT_ROOT"/*/; do
  [[ -d "$vault/.obsidian" ]] || continue
  name="$(basename "$vault")"
  dest="$vault.obsidian/themes/$THEME_NAME"

  echo "$name"
  run mkdir -p "$dest"

  vault_ok=1
  for f in "${FILES[@]}"; do
    if ! safe_to_replace "$dest/$f" "$REPO_DIR/$f"; then
      echo "  SKIP $f — real file with local edits (use --force to overwrite)" >&2
      vault_ok=0
      continue
    fi
    if [[ $MODE == link ]]; then
      run ln -sfn "$REPO_DIR/$f" "$dest/$f"
    else
      run rm -f "$dest/$f"
      run cp "$REPO_DIR/$f" "$dest/$f"
    fi
  done

  if (( ACTIVATE )); then
    if (( DRY )); then
      echo "  would: set cssTheme=\"$THEME_NAME\" in $name/.obsidian/appearance.json"
    else
      python3 - "$vault.obsidian/appearance.json" "$THEME_NAME" <<'PY'
import json, sys, pathlib
path, theme = pathlib.Path(sys.argv[1]), sys.argv[2]
cfg = {}
if path.exists():
    try:
        cfg = json.loads(path.read_text() or "{}")
    except json.JSONDecodeError:
        sys.exit(f"  could not parse {path}, leaving it alone")
cfg["cssTheme"] = theme
path.write_text(json.dumps(cfg, indent=2) + "\n")
PY
      echo "  activated"
    fi
  fi

  if (( vault_ok )); then published=$((published + 1)); else skipped=$((skipped + 1)); fi
done

echo
summary="$MODE: $published vault(s) published"
if (( skipped )); then summary+=", $skipped with skipped files"; fi
echo "$summary"
if (( DRY )); then echo "(dry run — nothing changed)"; fi
if (( ! ACTIVATE )); then
  echo "Enable it per vault: Settings → Appearance → Themes → $THEME_NAME"
fi
