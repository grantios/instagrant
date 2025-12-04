#!/usr/bin/env bash
set -euo pipefail

# Source configuration file first, then common.sh to combine packages
source "$(dirname "$0")/../../confs/$(basename "${CONFIG_FILE:-default.sh}")"
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Chroot Packages Script
# Installing additional packages

ensure_gum

gum style --border normal --padding "0 1" --border-foreground 86 "Step 6: Installing additional packages..."

# Install extra packages
log_info "Installing extra packages: ${EXTRA_PACKAGES[*]}"
retry_pacman pacman -Sy --noconfirm
retry_pacman pacman -S --noconfirm "${EXTRA_PACKAGES[@]}"

# Enable SSH service
log_info "Enabling SSH service"
systemctl enable sshd