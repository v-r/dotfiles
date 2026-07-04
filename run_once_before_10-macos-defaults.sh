#!/bin/bash
# macOS defaults for dev ergonomics. Runs once per machine (chezmoi run_once).
# Re-run manually after changes: chezmoi state delete-bucket --bucket=scriptState && chezmoi apply
set -eu

# Keyboard: fastest repeat, shortest delay, repeat instead of accent popup.
# Requires logout/login to take effect.
defaults write -g KeyRepeat -int 1
defaults write -g InitialKeyRepeat -int 10
defaults write -g ApplePressAndHoldEnabled -bool false

# Dock: no autohide delay
defaults write com.apple.dock autohide-delay -float 0

# Finder: show extensions, path bar, no .DS_Store on network/USB volumes
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

killall Dock Finder 2>/dev/null || true

echo "macOS defaults applied. Log out/in for keyboard settings to take effect."
