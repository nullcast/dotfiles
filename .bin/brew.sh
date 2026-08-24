#!/usr/bin/env bash
if [ "$(arch)" != "arm64" ]; then
  exec arch -arm64 /usr/bin/env bash "$0" "$@"
fi

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

eval "$(/opt/homebrew/bin/brew shellenv)"

if [ "$(uname)" != "Darwin" ] ; then
  echo "Not macOS!"
  exit 1
fi

# --- sudo: ask once, keep alive ---
sudo -v
( while true; do sudo -n true; sleep 60; done ) 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null || true' EXIT
# ----------------------------------

# Rosetta: already installedならスキップ（毎回走らせない）
if ! /usr/sbin/pkgutil --pkg-info com.apple.pkg.RosettaUpdateAuto >/dev/null 2>&1; then
  sudo softwareupdate --install-rosetta --agree-to-license
fi

brew update

# タップの破損（origin無し等）を修復
brew tap --repair

# extractを安定させる（APIモードを切る + coreを--force）
export HOMEBREW_NO_INSTALL_FROM_API=1
brew tap --force homebrew/core
brew tap homebrew/cask
brew tap bagonyi/homebrew-formulae

brew developer on

# Keep personal casks reproducible from this repository.  The tap itself is a
# Homebrew-managed Git directory, so copy only the version-controlled cask
# definitions after creating the tap on a new machine.
PERSONAL_TAP="my/casks"
PERSONAL_TAP_SOURCE="$SCRIPT_DIR/.config/brew/homebrew-casks"
if ! brew tap | grep -qxF "$PERSONAL_TAP"; then
  brew tap-new "$PERSONAL_TAP"
fi
PERSONAL_TAP_REPO="$(brew --repo "$PERSONAL_TAP")"
personal_casks=("$PERSONAL_TAP_SOURCE"/Casks/*.rb)
if [ ! -e "${personal_casks[0]}" ]; then
  echo "No version-controlled personal casks found in $PERSONAL_TAP_SOURCE" >&2
  exit 1
fi
install -d "$PERSONAL_TAP_REPO/Casks"
for source in "${personal_casks[@]}"; do
  target="$PERSONAL_TAP_REPO/Casks/$(basename "$source")"
  if ! cmp -s "$source" "$target"; then
    install -m 0644 "$source" "$target"
  fi
done

# leveldb@1.22 を確実に用意（extractがダメなら bundle だけでも進める）
if ! brew extract --force --version=1.22 leveldb bagonyi/homebrew-formulae; then
  echo "WARN: brew extract(leveldb 1.22) failed. Continue without it."
fi

# 非公式tap（repoから同期した my/casks・leveldb用 bagonyi）を信頼登録する。
# Homebrew 6系は信頼されていないtapからの cask/formula 読み込みを拒否するため、
# これが無いと bundle が untrusted tap で止まる（例: genspark-ai-browser, leveldb@1.22）。
# まだtapされていなくても trust.json への登録は可能（旧brew/未存在でも || true で継続）。
brew trust --tap bagonyi/homebrew-formulae || true
brew trust --tap my/casks || true

# Brewfileは「repoの .Brewfile」を正にする（globalズレ事故を防ぐ）
brew bundle --verbose --global

brew developer off

# git-secrets is installed by the Brewfile above.  Refresh the dedicated
# template hooks on every run, then register the de-duplicated global AWS rules.
git secrets --install --force "$HOME/.git-templates/git-secrets"
git secrets --register-aws --global

# leveldb link（存在する場合だけ）
if [ -d "/opt/homebrew/Cellar/leveldb@1.22/1.22" ]; then
  sudo ln -nfs /opt/homebrew/Cellar/leveldb@1.22/1.22 /opt/homebrew/opt/leveldb
fi

# Install Java (openjdk@17 を Brewfileで入れてる前提に合わせる)
if [ -d "$(brew --prefix)/opt/openjdk@17/libexec/openjdk.jdk" ]; then
  sudo ln -sfn "$(brew --prefix)/opt/openjdk@17/libexec/openjdk.jdk" /Library/Java/JavaVirtualMachines/openjdk.jdk
fi

# Minikube (only when docker is available and minikube is running)
if command -v docker >/dev/null 2>&1 && command -v minikube >/dev/null 2>&1; then
  if minikube status >/dev/null 2>&1; then
    sudo mkdir -p /etc/resolver
    ip="$(minikube ip 2>/dev/null || true)"
    if [ -n "$ip" ]; then
      cat << EOF | sudo tee /etc/resolver/minikube-test >/dev/null
domain minikube.local
nameserver $ip
search_order 1
timeout 5
EOF
    else
      echo "minikube ip が取得できないので /etc/resolver はスキップします"
    fi
  else
    echo "minikube が起動していないので /etc/resolver はスキップします"
  fi
else
  echo "docker/minikube が未導入なので /etc/resolver はスキップします"
fi

# --- fish をログインシェルにする（fish は上の brew bundle で導入済み） ---
FISH_BIN="$(brew --prefix)/bin/fish"
if [ -x "$FISH_BIN" ]; then
  # /etc/shells に未登録なら追加（chsh はここに無いシェルを拒否する）
  if ! grep -qxF "$FISH_BIN" /etc/shells 2>/dev/null; then
    echo "$FISH_BIN" | sudo tee -a /etc/shells >/dev/null
  fi
  # 現在のログインシェルが fish でなければ変更
  current_shell="$(dscl . -read "$HOME" UserShell 2>/dev/null | awk '{print $2}')"
  if [ "$current_shell" != "$FISH_BIN" ]; then
    echo "Setting login shell to fish: $FISH_BIN"
    chsh -s "$FISH_BIN"
  fi
fi
