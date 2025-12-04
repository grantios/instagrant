#!/usr/bin/env bash
set -euo pipefail

# Arch Linux Chroot Bootctl Script
# Installing and configuring systemd-boot

gum style --border normal --padding "0 1" --border-foreground 86 "Step 8: Installing and configuring systemd-boot..."

# Install systemd-boot with --esp-path=/boot
bootctl install --esp-path=/boot

# Detect root partition - look for the mounted root btrfs partition
ROOT_DEVICE=$(findmnt -n -o SOURCE / 2>/dev/null || echo "")
if [ -z "$ROOT_DEVICE" ]; then
    echo "ERROR: Unable to detect root device. Aborting."
    exit 1
fi
if [[ "$ROOT_DEVICE" =~ \[/@\] ]]; then
    # Extract the actual device from btrfs subvolume notation
    ROOT_DEVICE=$(echo "$ROOT_DEVICE" | sed 's/\[.*\]//')
fi

# Get root partition UUID
if ! ROOT_UUID=$(blkid -s UUID -o value "$ROOT_DEVICE" 2>/dev/null); then
    echo "ERROR: Could not get UUID for root device $ROOT_DEVICE"
    exit 1
fi

# Create loader configuration
cat > /boot/loader/loader.conf << EOF
default arch.conf
timeout 3
console-mode max
editor no
EOF

# Create Arch Linux boot entry
cat > /boot/loader/entries/arch.conf << EOF
title   Arch Linux LTS
linux   /vmlinuz-linux-lts
initrd  /initramfs-linux-lts.img
options root=UUID=${ROOT_UUID} rootflags=subvol=@ rw quiet splash
EOF

# Create fallback boot entry
cat > /boot/loader/entries/arch-fallback.conf << EOF
title   Arch Linux LTS (fallback)
linux   /vmlinuz-linux-lts
initrd  /initramfs-linux-lts-fallback.img
options root=UUID=${ROOT_UUID} rootflags=subvol=@ rw
EOF

# Update bootctl
bootctl update