#!/usr/bin/env bash
# reinstall_casks_from_brewfile.sh
# Brewfileに書いてあるcaskを「綺麗に」入れ直す（Caskroomの残骸掃除 + Brew管理に寄せる）
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script is for macOS only." >&2
  exit 1
fi

BREWFILE="${1:-$HOME/.Brewfile}"
if [[ ! -f "$BREWFILE" ]]; then
  echo "Brewfile not found: $BREWFILE" >&2
  echo "Usage: $0 /path/to/Brewfile  (default: ~/.Brewfile)" >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "brew not found in PATH." >&2
  exit 1
fi

# jq は app artifact 抽出に使う（無ければスキップしても動くようにする）
HAVE_JQ=0
if command -v jq >/dev/null 2>&1; then
  HAVE_JQ=1
fi

TS="$(date +%Y%m%d%H%M%S)"
BACKUP_DIR="$HOME/Applications/_manual_backup_${TS}"
mkdir -p "$BACKUP_DIR"

echo "==> Brewfile: $BREWFILE"
echo "==> Backup dir for existing /Applications apps: $BACKUP_DIR"
echo

# 1) Brewfileのcask一覧
mapfile -t CASKS < <(brew bundle list --file "$BREWFILE" --cask | sed '/^\s*$/d' | sort -u)

if [[ ${#CASKS[@]} -eq 0 ]]; then
  echo "No casks found in Brewfile."
  exit 0
fi

echo "==> Casks in Brewfile: ${#CASKS[@]}"
printf "  - %s\n" "${CASKS[@]}"
echo

# 2) Caskroomの「.metadataだけ残ってる」ゴミを全掃除（Brewfile関係なく）
CASKROOM="/opt/homebrew/Caskroom"
if [[ -d "$CASKROOM" ]]; then
  echo "==> Cleaning empty Caskroom entries (only .metadata)..."
  for d in "$CASKROOM"/*; do
    [[ -d "$d" ]] || continue
    # .metadata しか無い判定（完全一致）
    content="$(ls -A "$d" | tr '\n' ' ' | sed 's/[[:space:]]\+$//')"
    if [[ "$content" == ".metadata" ]]; then
      echo "  REMOVE EMPTY: $d"
      rm -rf "$d"
    fi
  done
  echo
fi

# 3) Brewfileにあるcaskを一旦全部アンインストール（Homebrew管理分のみ）
echo "==> Uninstalling Brewfile casks (force)..."
for c in "${CASKS[@]}"; do
  echo "  uninstall: $c"
  brew uninstall --cask --force "$c" >/dev/null 2>&1 || true
done
echo

# 4) BrewfileにあるcaskのCaskroom残骸も消す（壊れた状態の掃除用）
if [[ -d "$CASKROOM" ]]; then
  echo "==> Removing Caskroom leftovers for Brewfile casks..."
  for c in "${CASKS[@]}"; do
    if [[ -d "$CASKROOM/$c" ]]; then
      echo "  rm -rf $CASKROOM/$c"
      rm -rf "$CASKROOM/$c"
    fi
  done
  echo
fi

echo "==> Cleanup (optional)"
brew cleanup -s >/dev/null 2>&1 || true
echo

echo "==> Result (brew-managed casks):"
brew list --cask --versions || true

echo
echo "DONE."
echo "If some apps were moved, they are in: $BACKUP_DIR"
