#!/usr/bin/env bash
if [ "$(arch)" != "arm64" ]; then
  exec arch -arm64 /usr/bin/env bash "$0" "$@"
fi

set -euo pipefail

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

# leveldb@1.22 を確実に用意（extractがダメなら bundle だけでも進める）
if ! brew extract --force --version=1.22 leveldb bagonyi/homebrew-formulae; then
  echo "WARN: brew extract(leveldb 1.22) failed. Continue without it."
fi

# Brewfileは「repoの .Brewfile」を正にする（globalズレ事故を防ぐ）
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
brew bundle --verbose --global

brew developer off

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
