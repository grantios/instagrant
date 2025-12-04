#!/usr/bin/env bash
set -euo pipefail

# Arch Linux Chroot Mkinitcpio Script
# Configuring mkinitcpio

gum style --border normal --padding "0 1" --border-foreground 86 "Step 9: Configuring mkinitcpio..."

# Add btrfs to MODULES in mkinitcpio.conf
sed -i 's/^MODULES=()/MODULES=(btrfs)/' /etc/mkinitcpio.conf

# Regenerate initramfs
mkinitcpio -P