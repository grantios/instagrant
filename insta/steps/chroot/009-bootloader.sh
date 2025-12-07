#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Chroot Boot Loader Script
# Installing and configuring boot loader (systemd-boot or GRUB)

gum style --border normal --padding "0 1" --border-foreground 34 "Step 9/14: Installing and Configuring Boot Loader"

gum style --border normal --padding "0 1" --border-foreground '#800080' "Stage 1/1: Installing and configuring boot loader..."

# Install systemd-boot with --esp-path=/boot
# Check if we should use legacy BIOS boot
if [[ "${LEGACY_BOOT:-false}" == "true" ]]; then
    log_info "Using legacy BIOS boot with GRUB on /boot"
    
    # Detect root partition
    ROOT_DEVICE=$(findmnt -n -o SOURCE / 2>/dev/null || echo "")
    if [ -z "$ROOT_DEVICE" ]; then
        echo "ERROR: Unable to detect root device. Aborting."
        exit 1
    fi
    if [[ "$ROOT_DEVICE" =~ \[/@\] ]]; then
        # Extract the actual device from btrfs subvolume notation
        ROOT_DEVICE=$(echo "$ROOT_DEVICE" | sed 's/\[.*\]//')
    fi
    
    # Get root disk (remove partition number)
    ROOT_DISK=$(echo "$ROOT_DEVICE" | sed 's/p[0-9]*$//' | sed 's/[0-9]*$//')
    
    # Install GRUB for BIOS
    pacman -S --noconfirm grub
    
    # Install GRUB to the root disk's MBR, with boot files on /boot partition
    grub-install --target=i386-pc --boot-directory=/boot "$ROOT_DISK"
    
    # Generate GRUB config
    grub-mkconfig -o /boot/grub/grub.cfg
    
    log_info "Installed GRUB for legacy BIOS on $ROOT_DISK"
else
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

    # Build boot options string
    BOOT_OPTS="root=UUID=${ROOT_UUID} rootflags=subvol=@ rw quiet splash"
    if [ -n "${BOOT_OPTIONS:-}" ]; then
        BOOT_OPTS="${BOOT_OPTS} ${BOOT_OPTIONS}"
    fi

    # Create Arch Linux boot entry
    cat > /boot/loader/entries/arch.conf << EOF
title   GrantiOS 2025.Q4
linux   /vmlinuz-linux-lts
initrd  /initramfs-linux-lts.img
options ${BOOT_OPTS}
EOF

    # Build fallback boot options (without quiet splash)
    FALLBACK_OPTS="root=UUID=${ROOT_UUID} rootflags=subvol=@ rw"
    if [ -n "${BOOT_OPTIONS:-}" ]; then
        FALLBACK_OPTS="${FALLBACK_OPTS} ${BOOT_OPTIONS}"
    fi

    # Create fallback boot entry
    cat > /boot/loader/entries/arch-fallback.conf << EOF
title   GrantiOS 2025.Q4 (fallback)
linux   /vmlinuz-linux-lts
initrd  /initramfs-linux-lts-fallback.img
options ${FALLBACK_OPTS}
EOF

    # Update bootctl
    bootctl update
fi