#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Source configuration if available
if [[ -n "${CONFIG_FILE:-}" ]]; then
    source "$CONFIG_FILE"
fi

# Arch Linux Setup Mounts Script
# Creating btrfs subvolumes and mounting filesystems

TARGET_DISK="${1:-$TARGET_DISK}"

# Determine partition naming scheme
if [[ "$TARGET_DISK" =~ nvme ]] || [[ "$TARGET_DISK" =~ mmcblk ]]; then
    BOOT_PART="${TARGET_DISK}p1"
    SWAP_PART="${TARGET_DISK}p2"
    ROOT_PART="${TARGET_DISK}p3"
    ROOM_PART="${TARGET_DISK}p4"
else
    BOOT_PART="${TARGET_DISK}1"
    SWAP_PART="${TARGET_DISK}2"
    ROOT_PART="${TARGET_DISK}3"
    ROOM_PART="${TARGET_DISK}4"
fi

ROOT_MOUNT="${ROOT_PART}"
USE_ROOM_PARTITION=$(cat /tmp/use_room_partition 2>/dev/null || echo "false")

sudo pacman --noconfirm -Sy gum

gum style --border normal --padding "0 1" --border-foreground 34 "Step 2/5: Creating Subvolumes and Mounting Filesystems"

gum style --border normal --padding "0 1" --border-foreground '#800080' "Stage 1/2: Creating btrfs subvolumes..."

# Mount root partition temporarily
mount "${ROOT_MOUNT}" "${TARGET_DIR}"

# Create btrfs subvolumes for snapper
btrfs subvolume create ${TARGET_DIR}/@
btrfs subvolume create ${TARGET_DIR}/@home
btrfs subvolume create ${TARGET_DIR}/@snapshots
btrfs subvolume create ${TARGET_DIR}/@var_log

# Create @room subvolume under @home if not using separate partition
if [ "${USE_ROOM_PARTITION}" = false ]; then
    btrfs subvolume create ${TARGET_DIR}/@room
fi

# Unmount to remount with proper subvolumes
umount ${TARGET_DIR}

gum style --border normal --padding "0 1" --border-foreground '#800080' "Stage 2/2: Mounting filesystems..."

# Mount options for btrfs (optimized for SSD/NVMe)
BTRFS_OPTS="noatime,compress=zstd:1,space_cache=v2,discard=async"

# Mount root subvolume
mount -o ${BTRFS_OPTS},subvol=@ "${ROOT_MOUNT}" ${TARGET_DIR}

# Create mount points
mkdir -p ${TARGET_DIR}/home
mkdir -p ${TARGET_DIR}/boot
mkdir -p ${TARGET_DIR}/room
mkdir -p ${TARGET_DIR}/.snapshots
mkdir -p ${TARGET_DIR}/var/log
mkdir -p ${TARGET_DIR}/.btrfsroot

# Mount other subvolumes
mount -o ${BTRFS_OPTS},subvol=@home "${ROOT_MOUNT}" ${TARGET_DIR}/home
mount -o ${BTRFS_OPTS},subvol=@snapshots "${ROOT_MOUNT}" ${TARGET_DIR}/.snapshots
mount -o ${BTRFS_OPTS},subvol=@var_log "${ROOT_MOUNT}" ${TARGET_DIR}/var/log
mount -o ${BTRFS_OPTS},subvol=/ "${ROOT_MOUNT}" ${TARGET_DIR}/.btrfsroot

# Mount boot partition
mount "${BOOT_PART}" ${TARGET_DIR}/boot

# Mount room partition or subvolume
if [ "${USE_ROOM_PARTITION}" = true ]; then
    mount "${ROOM_PART}" ${TARGET_DIR}/room
else
    mount -o ${BTRFS_OPTS},subvol=@room "${ROOT_MOUNT}" ${TARGET_DIR}/room
fi

# Mount external drives if configured
if [[ -f /tmp/external_drives ]]; then
    log_info "Mounting external drives..."
    
    while IFS=':' read -r device mountpoint; do
        # Create mount point
        mkdir -p "${TARGET_DIR}${mountpoint}"
        
        # Check if device is already mounted and unmount if necessary
        if mount | grep -q "^$device "; then
            log_info "Device $device is already mounted, unmounting..."
            umount "$device" || log_warn "Failed to unmount $device"
        fi
        
        # Unmount if mountpoint is already in use
        if mountpoint -q "${TARGET_DIR}${mountpoint}"; then
            log_info "Unmounting existing mount at ${TARGET_DIR}${mountpoint}"
            umount "${TARGET_DIR}${mountpoint}" || log_warn "Failed to unmount ${TARGET_DIR}${mountpoint}"
        fi
        
        log_info "Mounting $device at ${TARGET_DIR}${mountpoint}"
        mount "$device" "${TARGET_DIR}${mountpoint}"
        log_success "Mounted $device at ${TARGET_DIR}${mountpoint}"
    done < /tmp/external_drives
fi