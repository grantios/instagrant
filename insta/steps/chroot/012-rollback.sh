#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Chroot Rollback Script
# Installing and configuring snapper-rollback

ensure_gum

gum style --border normal --padding "0 1" --border-foreground 86 "Step 12: Installing and configuring snapper-rollback..."

# Install snapper-rollback from AUR as user
log_info "Installing snapper-rollback from AUR..."
runuser -u ${USERNAME} -- yay -S --noconfirm snapper-rollback

# Configure snapper-rollback.conf
sed -i 's|mountpoint = /btrfsroot|mountpoint = /.btrfsroot|' /etc/snapper-rollback.conf

log_success "snapper-rollback installed and configured"