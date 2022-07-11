#!/bin/bash

if [ "$(uname)" != "Darwin" ] ; then
	echo "Not macOS!"
	exit 1
fi

brew developer on
brew extract --force --version=1.22 leveldb bagonyi/formulae
brew bundle --global
brew developer off
sudo ln -nfs /opt/homebrew/Cellar/leveldb@1.22/1.22 /opt/homebrew/opt/leveldb

# Install font
cp -f /opt/homebrew/Cellar/ricty/4.1.1/share/fonts/Ricty*.ttf ~/Library/Fonts/
fc-cache -vf
