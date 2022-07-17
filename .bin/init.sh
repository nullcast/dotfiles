#!/bin/bash

if [ "$(uname)" != "Darwin" ] ; then
	echo "Not macOS!"
	exit 1
fi

# Set bash
chsh -s /bin/bash

# Install xcode
xcode-select --install > /dev/null

# Update software
softwareupdate --install-rosetta --agree-to-license

# Install brew
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh > /dev/null
