#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Setup Drives Script
# Partitioning and formatting

DISK="${1:-$DISK}"

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

echo "=========================================="
echo "Setting up drives on ${DISK}"
echo "=========================================="

ensure_gum

gum style --border normal --padding "0 1" --border-foreground 86 "Step 1: Partitioning ${DISK}..."

# Wipe existing partition table
wipefs -af "${DISK}"
dd if=/dev/zero of="${DISK}" bs=1M count=100 status=none
sgdisk --zap-all "${DISK}"

# Create GPT partition table and partitions
sgdisk -n 1:0:+9G -t 1:ef00 -c 1:"das" "${DISK}"         # EFI (/boot)
sgdisk -n 2:0:+33G -t 2:8200 -c 2:"Linux swap" "${DISK}"         # Swap
sgdisk -n 3:0:+123G -t 3:8300 -c 3:"Linux root" "${DISK}"         # Root (btrfs)
sgdisk -n 4:0:0 -t 4:8300 -c 4:"Linux room" "${DISK}"             # Room (xfs, remaining space)

# Inform kernel of partition changes
partprobe "${DISK}"
sleep 5
partprobe "${DISK}"

gum style --border normal --padding "0 1" --border-foreground 86 "Step 2: Formatting partitions..."

# Format EFI partition
mkfs.vfat -F 32 -n das "${BOOT_PART}"

# Format swap partition
mkswap -L swap "${SWAP_PART}"

# Format root partition with btrfs
wipefs -af "${ROOT_PART}"
dd if=/dev/zero of="${ROOT_PART}" bs=1M count=1 status=none
mkfs.btrfs -f -L root "${ROOT_PART}"

# Check for room partition
DISK_SIZE=$(blockdev --getsize64 "${DISK}")
USED_SIZE=$((9000000000 + 33000000000 + 123000000000))
REMAINING=$((DISK_SIZE - USED_SIZE))
MIN_ROOM_SIZE=$((10000000000))

USE_ROOM_PARTITION=false
if [ ${REMAINING} -gt ${MIN_ROOM_SIZE} ]; then
    log_info "Sufficient space available for separate /room partition"
    mkfs.xfs -f -L room "${ROOM_PART}"
    USE_ROOM_PARTITION=true
else
    log_info "Using @room subvolume (insufficient space for separate partition)"
fi

# Store variables for later scripts
echo "${ROOT_PART}" > /tmp/crypt_root
echo "${SWAP_PART}" > /tmp/swap_part
echo "${USE_ROOM_PARTITION}" > /tmp/use_room_partition

# Format external drives if configured
format_external_drives() {
    if [[ -n "${EXTERNAL_DRIVES+x}" && ${#EXTERNAL_DRIVES[@]} -gt 0 ]]; then
        log_info "Formatting external drives..."
        
        for drive_config in "${EXTERNAL_DRIVES[@]}"; do
            IFS=':' read -r device label mountpoint filesystem <<< "$drive_config"
            
            if [[ ! -b "$device" ]]; then
                log_warn "External drive $device does not exist, skipping"
                continue
            fi
            
            log_info "Formatting $device as $filesystem with label '$label'"
            
            case "$filesystem" in
                xfs)
                    mkfs.xfs -f -L "$label" "$device"
                    ;;
                btrfs)
                    mkfs.btrfs -f -L "$label" "$device"
                    ;;
                ext4)
                    mkfs.ext4 -F -L "$label" "$device"
                    ;;
                *)
                    log_error "Unsupported filesystem: $filesystem for $device"
                    continue
                    ;;
            esac
            
            # Store mount info for later scripts
            echo "$device:$mountpoint:$filesystem" >> /tmp/external_drives
            log_success "Formatted $device ($filesystem, label: $label)"
        done
    fi
}

format_external_drives

# Handle existing drives (preserve without formatting)
if [[ -n "${PRESERVE_DRIVES+x}" && ${#PRESERVE_DRIVES[@]} -gt 0 ]]; then
    log_info "Processing preserve drives (preserving data)..."
    
    for drive_config in "${PRESERVE_DRIVES[@]}"; do
        IFS=':' read -r device label mountpoint filesystem <<< "$drive_config"
        
        if [[ ! -b "$device" ]]; then
            log_warn "Preserve drive $device does not exist, skipping"
            continue
        fi
        
        # Store mount info for later scripts (without formatting)
        echo "$device:$mountpoint:$filesystem" >> /tmp/external_drives
        log_success "Preserved drive $device ($filesystem, label: $label)"
    done
fi