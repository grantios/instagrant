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

# Arch Linux Chroot Packages Script
# Installing additional packages

ensure_gum

gum style --border normal --padding "0 1" --border-foreground 86 "Step 6: Installing additional packages..."

# Install extra packages
log_info "Installing extra packages: ${EXTRA_PACKAGES[*]}"
retry_pacman pacman -Sy --noconfirm
retry_pacman pacman -S --noconfirm "${EXTRA_PACKAGES[@]}"
