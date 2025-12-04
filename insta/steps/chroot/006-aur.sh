#!/usr/bin/env bash
set -euo pipefail

# Source configuration file first, then common.sh to combine packages
source "$(dirname "$0")/../../confs/$(basename "${CONFIG_FILE:-default.sh}")"
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Chroot AUR Script
# Installing AUR packages

ensure_gum

gum style --border normal --padding "0 1" --border-foreground 86 "Step 5: Installing AUR packages..."

# Install AUR packages
if [[ ${#AUR_PACKAGES[@]} -gt 0 ]]; then
    log_info "Installing AUR packages: ${AUR_PACKAGES[*]}"
    sudo -u "$USERNAME" yay -S --noconfirm "${AUR_PACKAGES[@]}"
else
    log_info "No AUR packages to install"
fi