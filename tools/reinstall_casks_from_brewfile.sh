#!/usr/bin/env bash
# reinstall_casks_from_brewfile.sh
# Brewfileに書いてあるcaskを「綺麗に」入れ直す（Caskroomの残骸掃除 + Brew管理に寄せる）
#
#   1. Brewfile の cask を一旦アンインストールし、Caskroom の残骸を消す
#   2. Homebrew 管理外で /Applications に残っている同名アプリを退避する
#   3. cask を入れ直す
#
# Usage: tools/reinstall_casks_from_brewfile.sh [Brewfile] [-y]
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script is for macOS only." >&2
  exit 1
fi

ASSUME_YES=0
BREWFILE="$HOME/.Brewfile"
for arg in "$@"; do
  case "$arg" in
    -y|--yes) ASSUME_YES=1 ;;
    *) BREWFILE="$arg" ;;
  esac
done

if [[ ! -f "$BREWFILE" ]]; then
  echo "Brewfile not found: $BREWFILE" >&2
  echo "Usage: $0 [/path/to/Brewfile] [-y]  (default: ~/.Brewfile)" >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "brew not found in PATH." >&2
  exit 1
fi

# jq は cask の .app 名の抽出に使う（無ければ /Applications の退避をスキップ）
HAVE_JQ=0
if command -v jq >/dev/null 2>&1; then
  HAVE_JQ=1
fi

# 1) Brewfileのcask一覧（macOS 標準の bash 3.2 でも動くよう mapfile は使わない）
CASKS=()
while IFS= read -r c; do
  [[ -n "$c" ]] && CASKS+=("$c")
done < <(brew bundle list --file "$BREWFILE" --cask | sed '/^[[:space:]]*$/d' | sort -u)

if [[ ${#CASKS[@]} -eq 0 ]]; then
  echo "No casks found in Brewfile."
  exit 0
fi

echo "==> Brewfile: $BREWFILE"
echo "==> Casks in Brewfile: ${#CASKS[@]}"
printf "  - %s\n" "${CASKS[@]}"
echo

if [[ "$ASSUME_YES" -ne 1 ]]; then
  read -r -p "これらの cask をアンインストールして入れ直します。続けますか? [y/N] " answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *) echo "中止しました。"; exit 1 ;;
  esac
fi

TS="$(date +%Y%m%d%H%M%S)"
BACKUP_DIR="$HOME/Applications/_manual_backup_${TS}"

# cask が配置する .app 名（target 指定があればそちら）を列挙する
cask_apps() { # cask_apps <cask>
  [[ "$HAVE_JQ" -eq 1 ]] || return 0
  brew info --cask --json=v2 "$1" 2>/dev/null | jq -r '
    .casks[0].artifacts[]? | .app? // empty
    | if (length > 1 and (.[1] | type) == "object" and .[1].target)
      then .[1].target else .[0] end
    | select(type == "string")' || true
}

# 2) Caskroomの「.metadataだけ残ってる」ゴミを全掃除（Brewfile関係なく）
CASKROOM="$(brew --prefix)/Caskroom"
if [[ -d "$CASKROOM" ]]; then
  echo "==> Cleaning empty Caskroom entries (only .metadata)..."
  for d in "$CASKROOM"/*; do
    [[ -d "$d" ]] || continue
    # .metadata しか無い判定（完全一致）
    content="$(ls -A "$d" | tr '\n' ' ' | sed 's/[[:space:]]*$//')"
    if [[ "$content" == ".metadata" ]]; then
      echo "  REMOVE EMPTY: $d"
      rm -rf "${d:?}"
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
      rm -rf "${CASKROOM:?}/${c:?}"
    fi
  done
  echo
fi

# 5) Homebrew 管理外で残っているアプリを退避（cask の install が衝突しないように）
if [[ "$HAVE_JQ" -eq 1 ]]; then
  echo "==> Moving unmanaged apps out of /Applications..."
  for c in "${CASKS[@]}"; do
    while IFS= read -r app; do
      [[ -n "$app" ]] || continue
      if [[ -e "/Applications/$app" ]]; then
        mkdir -p "$BACKUP_DIR"
        echo "  move: /Applications/$app -> $BACKUP_DIR/"
        mv "/Applications/$app" "$BACKUP_DIR/"
      fi
    done < <(cask_apps "$c")
  done
  echo
else
  echo "==> jq not found: skip moving unmanaged apps (install may fail if an app already exists)"
  echo
fi

# 6) 入れ直し
echo "==> Reinstalling Brewfile casks..."
FAILED=()
for c in "${CASKS[@]}"; do
  echo "  install: $c"
  if ! brew install --cask "$c"; then
    FAILED+=("$c")
  fi
done
echo

echo "==> Cleanup (optional)"
brew cleanup -s >/dev/null 2>&1 || true
echo

echo "==> Result (brew-managed casks):"
brew list --cask --versions || true
echo

if [[ -d "$BACKUP_DIR" ]]; then
  echo "Apps moved out of /Applications are in: $BACKUP_DIR"
fi
if [[ ${#FAILED[@]} -gt 0 ]]; then
  echo "FAILED to reinstall:" >&2
  printf "  - %s\n" "${FAILED[@]}" >&2
  exit 1
fi
echo "DONE."
