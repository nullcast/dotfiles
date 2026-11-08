#!/bin/bash

if [ "$(uname)" != "Darwin" ] ; then
	echo "Not macOS!"
	exit 1
fi

# ====================
#
# Base
#
# ====================


# Disable auto-capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# ====================
#
# Dock
#
# ====================


# Disable animation at application launch
defaults write com.apple.dock launchanim -bool false

# ====================
#
# Finder
#
# ====================


# Disable animation
defaults write com.apple.finder DisableAllAnimations -bool true

# Show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show files with all extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Display the status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Display the path bar
defaults write com.apple.finder ShowPathbar -bool true

# ====================
#
# SystemUIServer
#
# ====================

# Display date, day, and 24-hour time in the menu bar
# (macOS 11+ ignores the old DateFormat key; these are the current ones)
defaults write com.apple.menuextra.clock ShowDate -int 1
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults write NSGlobalDomain AppleICUForce24HourTime -bool true

# Display battery percentage in the menu bar
# (macOS 11+ moved this from com.apple.menuextra.battery to Control Center)
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true


for app in "Dock" \
	"Finder" \
	"SystemUIServer" \
	"ControlCenter"; do
	killall "${app}" &> /dev/null
done
