#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Source configuration if available
if [[ -n "${CONFIG_FILE:-}" ]]; then
    source "$CONFIG_FILE"
fi

# Arch Linux Setup Drives Script
# Partitioning and formatting

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

echo "=========================================="
echo "Setting up drives on ${TARGET_DISK}"
echo "=========================================="

gum style --border normal --padding "0 1" --border-foreground 34 "Step 1/5: Partitioning and Formatting Drives"

gum style --border normal --padding "0 1" --border-foreground '#800080' "Stage 1/2: Partitioning ${TARGET_DISK}..."

# Wipe existing partition table
wipefs -af "${TARGET_DISK}"
dd if=/dev/zero of="${TARGET_DISK}" bs=1M count=100 status=none
sgdisk --zap-all "${TARGET_DISK}"

# Create GPT partition table and partitions
sgdisk -n 1:0:+9G -t 1:ef00 -c 1:"das" "${TARGET_DISK}"         # EFI (/boot)
sgdisk -n 2:0:+33G -t 2:8200 -c 2:"Linux swap" "${TARGET_DISK}"         # Swap
sgdisk -n 3:0:+123G -t 3:8300 -c 3:"Linux root" "${TARGET_DISK}"         # Root (btrfs)
sgdisk -n 4:0:0 -t 4:8300 -c 4:"Linux room" "${TARGET_DISK}"             # Room (xfs, remaining space)

# Inform kernel of partition changes
partprobe "${TARGET_DISK}"
sleep 2
partprobe "${TARGET_DISK}"

gum style --border normal --padding "0 1" --border-foreground '#800080' "Stage 2/2: Formatting partitions..."

# Format EFI partition
log_info "Formatting EFI partition ${BOOT_PART} as FAT32..."
mkfs.vfat -F 32 -n das "${BOOT_PART}"

# Format swap partition
log_info "Formatting swap partition ${SWAP_PART}..."
mkswap -L swap "${SWAP_PART}"

# Format root partition with btrfs
log_info "Formatting root partition ${ROOT_PART} as Btrfs..."
wipefs -af "${ROOT_PART}"
dd if=/dev/zero of="${ROOT_PART}" bs=1M count=1 status=none
mkfs.btrfs -f -L root "${ROOT_PART}"

# Check for room partition
DISK_SIZE=$(blockdev --getsize64 "${TARGET_DISK}")
USED_SIZE=$((9000000000 + 33000000000 + 123000000000))
REMAINING=$((DISK_SIZE - USED_SIZE))
MIN_ROOM_SIZE=$((10000000000))

USE_ROOM_PARTITION=false
if [ ${REMAINING} -gt ${MIN_ROOM_SIZE} ]; then
    log_info "Sufficient space available for separate /room partition"
    log_info "Formatting room partition ${ROOM_PART} as XFS..."
    mkfs.xfs -f -L room "${ROOM_PART}"
    USE_ROOM_PARTITION=true
else
    log_info "Using @room subvolume (insufficient space for separate partition)"
fi

# Store variables for later scripts
echo "${SWAP_PART}" > /tmp/swap_part
echo "${USE_ROOM_PARTITION}" > /tmp/use_room_partition

# Handle existing drives (preserve without formatting)
if [[ -n "${PRESERVE_DRIVES+x}" && ${#PRESERVE_DRIVES[@]} -gt 0 ]]; then
    log_info "Processing preserve drives (preserving data)..."
    
    for drive_config in "${PRESERVE_DRIVES[@]}"; do
        IFS=':' read -r device mountpoint <<< "$drive_config"
        
        if [[ "$device" =~ ^/dev/ && ! -b "$device" ]]; then
            log_warn "Preserve drive $device does not exist, skipping"
            continue
        fi
        
        # Store mount info for later scripts (without formatting)
        echo "$device:$mountpoint" >> /tmp/external_drives
        log_success "Preserved drive $device"
    done
fi

# Format external drives if configured
format_external_drives() {
    log_info "Checking for external drives to format..."
    if [[ -n "${EXTERNAL_DRIVES+x}" && ${#EXTERNAL_DRIVES[@]} -gt 0 ]]; then
        log_info "Found ${#EXTERNAL_DRIVES[@]} external drive(s) to process"
        
        for drive_config in "${EXTERNAL_DRIVES[@]}"; do
            log_info "Processing external drive config: $drive_config"
            IFS=':' read -r device mountpoint label <<< "$drive_config"
            log_info "Parsed device: $device, mountpoint: $mountpoint, label: $label"
            
            if [[ ! -b "$device" ]]; then
                log_warn "External drive $device does not exist, skipping"
                continue
            fi
            
            # Determine partition naming scheme
            if [[ "$device" =~ nvme ]] || [[ "$device" =~ mmcblk ]]; then
                PART_DEVICE="${device}p1"
            else
                PART_DEVICE="${device}1"
            fi
            
            log_info "Partitioning $device with one partition using 100% space"
            
            # Wipe existing partition table
            wipefs -af "${device}"
            dd if=/dev/zero of="${device}" bs=1M count=1 status=none
            sgdisk --zap-all "${device}"
            
            # Create one partition using 100% space
            sgdisk -n 1:0:0 -t 1:8300 -c 1:"$label" "${device}"
            
            # Inform kernel of partition changes
            partprobe "${device}"
            sleep 2
            partprobe "${device}"
            
            # Verify partition was created
            if [[ ! -b "$PART_DEVICE" ]]; then
                log_error "Partition $PART_DEVICE not found after partitioning $device"
                exit 1
            fi
            
            log_info "Formatting $PART_DEVICE as XFS with label '$label'"
            mkfs.xfs -f -L "$label" "$PART_DEVICE"
            
            # Store mount info for later scripts (use partition device)
            echo "$PART_DEVICE:$mountpoint" >> /tmp/external_drives
            log_success "Partitioned and formatted $device (XFS, label: $label)"
        done
    fi
}

log_info "About to call format_external_drives"
format_external_drives

log_info "Script completed"