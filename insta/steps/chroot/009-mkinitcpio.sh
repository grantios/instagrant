#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Chroot Mkinitcpio Script
# Configuring mkinitcpio

mark_step "Step 9/14: Configuring Mkinitcpio"

mark_stage "Stage 1/1: Configuring mkinitcpio..."

# Add btrfs to MODULES in mkinitcpio.conf
sed -i 's/^MODULES=()/MODULES=(btrfs)/' /etc/mkinitcpio.conf

# Regenerate initramfs
mkinitcpio -P