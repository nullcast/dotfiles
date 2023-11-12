#!/bin/bash

if [ "$(uname)" != "Darwin" ] ; then
	echo "Not macOS!"
	exit 1
fi

# Software update
sudo softwareupdate --install-rosetta

brew developer on
brew extract --force --version=1.22 leveldb bagonyi/formulae
brew bundle --global
brew developer off
sudo ln -nfs /opt/homebrew/Cellar/leveldb@1.22/1.22 /opt/homebrew/opt/leveldb

# Install Java
sudo ln -sfn $(brew --prefix)/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk

# Install font
#cp -f /opt/homebrew/Cellar/ricty/4.1.1/share/fonts/Ricty*.ttf ~/Library/Fonts/
#fc-cache -vf

# Minikube
sudo mkdir -p /etc/resolver
cat << EOF | sudo tee /etc/resolver/minikube-test
domain minikube.local
nameserver $(minikube ip)
search_order 1
timeout 5
EOF
