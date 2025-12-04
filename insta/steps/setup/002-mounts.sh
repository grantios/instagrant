#!/usr/bin/env bash
set -euo pipefail

# Arch Linux Setup Mounts Script
# Creating btrfs subvolumes and mounting filesystems

DISK="${1:-/dev/sda}"

# Determine partition naming scheme
if [[ "$DISK" =~ nvme ]] || [[ "$DISK" =~ mmcblk ]]; then
    BOOT_PART="${DISK}p1"
    SWAP_PART="${DISK}p2"
    ROOT_PART="${DISK}p3"
    ROOM_PART="${DISK}p4"
else
    BOOT_PART="${DISK}1"
    SWAP_PART="${DISK}2"
    ROOT_PART="${DISK}3"
    ROOM_PART="${DISK}4"
fi

CRYPT_ROOT="${ROOT_PART}"
USE_ROOM_PARTITION=$(cat /tmp/use_room_partition 2>/dev/null || echo "false")

sudo pacman --noconfirm -Sy gum

gum style --border normal --padding "0 1" --border-foreground 86 "Step 3: Creating btrfs subvolumes..."

# Mount root partition temporarily
mount "${CRYPT_ROOT}" "${TARGET_DIR}"

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

gum style --border normal --padding "0 1" --border-foreground 86 "Step 4: Mounting filesystems..."

# Mount options for btrfs (optimized for SSD/NVMe)
BTRFS_OPTS="noatime,compress=zstd:1,space_cache=v2,discard=async"

# Mount root subvolume
mount -o ${BTRFS_OPTS},subvol=@ "${CRYPT_ROOT}" ${TARGET_DIR}

# Create mount points
mkdir -p ${TARGET_DIR}/home
mkdir -p ${TARGET_DIR}/boot
mkdir -p ${TARGET_DIR}/room
mkdir -p ${TARGET_DIR}/.snapshots
mkdir -p ${TARGET_DIR}/var/log
mkdir -p ${TARGET_DIR}/.btrfsroot

# Mount other subvolumes
mount -o ${BTRFS_OPTS},subvol=@home "${CRYPT_ROOT}" ${TARGET_DIR}/home
mount -o ${BTRFS_OPTS},subvol=@snapshots "${CRYPT_ROOT}" ${TARGET_DIR}/.snapshots
mount -o ${BTRFS_OPTS},subvol=@var_log "${CRYPT_ROOT}" ${TARGET_DIR}/var/log
mount -o ${BTRFS_OPTS},subvol=/ "${CRYPT_ROOT}" ${TARGET_DIR}/.btrfsroot

# Mount boot partition
mount "${BOOT_PART}" ${TARGET_DIR}/boot

# Mount room partition or subvolume
if [ "${USE_ROOM_PARTITION}" = true ]; then
    mount "${ROOM_PART}" ${TARGET_DIR}/room
else
    mount -o ${BTRFS_OPTS},subvol=@room "${CRYPT_ROOT}" ${TARGET_DIR}/room
fi

# Mount external drives if configured
mount_external_drives() {
    if [[ -f /tmp/external_drives ]]; then
        log_info "Mounting external drives..."
        
        while IFS=':' read -r device mountpoint filesystem; do
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
            
            case "$filesystem" in
                xfs)
                    mount "$device" "${TARGET_DIR}${mountpoint}"
                    ;;
                btrfs)
                    mount -o noatime,compress=zstd:1,space_cache=v2 "$device" "${TARGET_DIR}${mountpoint}"
                    ;;
                ext4)
                    mount "$device" "${TARGET_DIR}${mountpoint}"
                    ;;
                *)
                    log_error "Unsupported filesystem: $filesystem for $device"
                    continue
                    ;;
            esac
            
            log_success "Mounted $device at ${TARGET_DIR}${mountpoint}"
        done < /tmp/external_drives
    fi
}

mount_external_drives