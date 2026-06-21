#!/bin/bash

if [ "$(uname)" != "Darwin" ] ; then
	echo "Not macOS!"
	exit 1
fi

# Install Xcode Command Line Tools (skip if already present)
if ! xcode-select -p >/dev/null 2>&1; then
	xcode-select --install
fi

# Install Rosetta on Apple Silicon (skip if already installed)
if [ "$(uname -m)" = "arm64" ] && \
	! /usr/sbin/pkgutil --pkg-info com.apple.pkg.RosettaUpdateAuto >/dev/null 2>&1; then
	softwareupdate --install-rosetta --agree-to-license
fi

# Install Homebrew (skip if already installed)
if ! command -v brew >/dev/null 2>&1 && [ ! -x /opt/homebrew/bin/brew ]; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
