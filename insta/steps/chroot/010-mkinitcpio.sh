#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Chroot Mkinitcpio Script
# Configuring mkinitcpio

gum style --border normal --padding "0 1" --border-foreground 34 "Step 10/14: Configuring Mkinitcpio"

gum style --border normal --padding "0 1" --border-foreground '#800080' "Stage 1/1: Configuring mkinitcpio..."

# Add btrfs to MODULES in mkinitcpio.conf
sed -i 's/^MODULES=()/MODULES=(btrfs)/' /etc/mkinitcpio.conf

# Regenerate initramfs
mkinitcpio -P