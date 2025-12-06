#!/usr/bin/env bash
set -euo pipefail

# Source configuration file first, then common.sh to combine packages
# Load default config first
DEFAULT_CONFIG="$(dirname "$0")/../../confs/default.sh"
if [[ -f "$DEFAULT_CONFIG" ]]; then
    source "$DEFAULT_CONFIG"
fi
source "$(dirname "$0")/../../confs/$(basename "${CONFIG_FILE:-workstation.sh}")"
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Chroot AUR Script
# Installing AUR packages

gum style --border normal --padding "0 1" --border-foreground 34 "Step 6/14: Installing AUR Packages"

gum style --border normal --padding "0 1" --border-foreground '#800080' "Stage 1/1: Installing AUR packages..."

# Install AUR packages
if [[ ${#AUR_PACKAGES[@]} -gt 0 ]]; then
    log_info "Installing AUR packages: ${AUR_PACKAGES[*]}"
    sudo -u "$USERNAME" yay -S --noconfirm "${AUR_PACKAGES[@]}"
else
    log_info "No AUR packages to install"
fi