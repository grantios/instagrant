#!/usr/bin/env bash
set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set project top level if not set
if [[ -z "${INSTA_TOPLVL:-}" ]]; then
    INSTA_TOPLVL="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

# Source common.sh early for functions
source "$INSTA_TOPLVL/insta/utils/common.sh"

# Source configuration if available
if [[ -n "${CONFIG_FILE:-}" ]]; then
    source "$CONFIG_FILE"
fi

# Arch Linux Setup Script
# Runs all setup stages in order

if [[ "${1:-}" == "--help" ]]; then
    echo "Arch Linux Setup Script"
    echo ""
    echo "Runs the following stages in order:"
    echo "  1. 001-drives     - Partition and format drives"
    echo "  2. 002-mounts     - Create subvolumes and mount filesystems"
    echo "  3. 003-pacstrap   - Install base system"
    echo "  4. 004-fstab      - Generate fstab"
    echo "  5. 005-inject       - Copy system files"
    echo ""
    echo "Usage:"
    echo "  $0                    - Run all stages"
    echo "  $0 --redo-step <stage> - Rerun a specific stage (1-5 or 01-05)"
    echo "  $0 --redo-from <stage> - Rerun from stage to end (1-5 or 01-05)"
    echo ""
    echo "Configuration (set as environment variables):"
    echo "  DISK         - Target disk (default: /dev/sda)"
    echo "  TARGET_DIR   - Installation target directory (default: /mnt)"
    echo "  TIMEZONE     - Timezone (default: America/Chicago)"
    echo "  HOSTNAME     - Hostname (default: archlinux)"
    echo "  USERNAME     - User to create (default: stein)"
    echo "  PASSWORD     - Default user password (default: GATEKEEP)"
    echo "  PASSROOT     - Default root password (default: GATEKEEP)"
    echo "  KERNEL       - Kernel to install (default: linux-lts)"
    echo "  DESKTOP      - Desktop environment (default: kde)"
    echo "  AUTO_CHROOT_CONFIRM - Skip chroot confirmation (default: true)"
    echo ""
    echo "Usage: $0"
    echo "Example: DISK=/dev/sdb TARGET_DIR=/custom/mount KERNEL=linux-zen DESKTOP=gnome $0"
    exit 0
fi

# Require config file to be set
if [[ -z "${CONFIG_FILE:-}" ]]; then
    echo "Error: CONFIG_FILE environment variable must be set."
    echo "Run from main script: ./insta/run.sh --config <name>"
    echo "Or set manually: CONFIG_FILE=/path/to/config.sh $0"
    exit 1
fi

# Source default config first (if it exists)
DEFAULT_CONFIG="$INSTA_TOPLVL/insta/confs/default.sh"
if [[ -f "$DEFAULT_CONFIG" ]]; then
    source "$DEFAULT_CONFIG"
    combine_config_arrays
fi

# Source configuration
source "$CONFIG_FILE"
combine_config_arrays

# Source common configuration again for package combining logic
source "$INSTA_TOPLVL/insta/utils/common.sh"

# Ensure target directory exists
log_info "Ensuring target directory ${TARGET_DIR} exists..."
mkdir -p "${TARGET_DIR}"

# Handle --redo-step and --redo-from arguments
if [[ "${1:-}" == "--redo-step" ]]; then
    STAGE="${2:-}"
    if [[ -z "$STAGE" ]]; then
        log_error "Error: --redo-step requires a stage number (1-5)"
        exit 1
    fi
    
    case "$STAGE" in
        1|01) "$INSTA_TOPLVL/insta/steps/setup/001-drives.sh" ;;
        2|02) "$INSTA_TOPLVL/insta/steps/setup/002-mounts.sh" ;;
        3|03) "$INSTA_TOPLVL/insta/steps/setup/003-pacstrap.sh" ;;
        4|04) "$INSTA_TOPLVL/insta/steps/setup/004-fstab.sh" ;;
        5|05) "$INSTA_TOPLVL/insta/steps/setup/005-inject.sh" ;;
        *) log_error "Error: Invalid stage number $STAGE. Must be 1-5 or 01-05." ;;
    esac
    exit $?
elif [[ "${1:-}" == "--redo-from" ]]; then
    START_STAGE="${2:-}"
    if [[ -z "$START_STAGE" ]]; then
        log_error "Error: --redo-from requires a stage number (1-5)"
        exit 1
    fi
    
    case "$START_STAGE" in
        1|01)
            "$INSTA_TOPLVL/insta/steps/setup/001-drives.sh"
            "$INSTA_TOPLVL/insta/steps/setup/002-mounts.sh"
            "$INSTA_TOPLVL/insta/steps/setup/003-pacstrap.sh"
            "$INSTA_TOPLVL/insta/steps/setup/004-fstab.sh"
            "$INSTA_TOPLVL/insta/steps/setup/005-inject.sh"
            ;;
        2|02)
            "$INSTA_TOPLVL/insta/steps/setup/002-mounts.sh"
            "$INSTA_TOPLVL/insta/steps/setup/003-pacstrap.sh"
            "$INSTA_TOPLVL/insta/steps/setup/004-fstab.sh"
            "$INSTA_TOPLVL/insta/steps/setup/005-inject.sh"
            ;;
        3|03)
            "$INSTA_TOPLVL/insta/steps/setup/003-pacstrap.sh"
            "$INSTA_TOPLVL/insta/steps/setup/004-fstab.sh"
            "$INSTA_TOPLVL/insta/steps/setup/005-inject.sh"
            ;;
        4|04)
            "$INSTA_TOPLVL/insta/steps/setup/004-fstab.sh"
            "$INSTA_TOPLVL/insta/steps/setup/005-inject.sh"
            ;;
        5|05)
            "$INSTA_TOPLVL/insta/steps/setup/005-inject.sh"
            ;;
        *) log_error "Error: Invalid stage number $START_STAGE. Must be 1-5 or 01-05." ;;
    esac
    
    if validate_installation; then
        log_success "Setup complete!"
        echo ""
        echo "Next steps:"
        echo "  1. Enter the chroot: arch-chroot /mnt"
        echo "  2. Run chroot setup: ./chroot.sh"
        echo "  3. Exit chroot, unmount, reboot"
    else
        log_error "Setup validation failed! Check the installation before proceeding."
        exit 1
    fi
    exit $?
fi

validate_timezone "$TIMEZONE"

# Get disk size for confirmation message
DISK_SIZE=$(get_disk_size "$TARGET_DISK")

echo ""
if ! gum confirm "ARE YOU REALLY SURE, THIS WILL COMPLETELY FORMAT $TARGET_DISK (${DISK_SIZE}) !!!" --prompt.foreground="196"; then
    log_info "Setup cancelled"
    exit 0
fi

log_info "Starting setup process..."

"$INSTA_TOPLVL/insta/steps/setup/001-drives.sh"
"$INSTA_TOPLVL/insta/steps/setup/002-mounts.sh"
"$INSTA_TOPLVL/insta/steps/setup/003-pacstrap.sh"
"$INSTA_TOPLVL/insta/steps/setup/004-fstab.sh"
"$INSTA_TOPLVL/insta/steps/setup/005-inject.sh"

if validate_installation; then
    log_success "Setup complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Enter the chroot: arch-chroot /mnt"
    echo "  2. Run chroot setup: ./chroot.sh"
    echo "  3. Exit chroot, unmount, reboot"
else
    log_error "Setup validation failed! Check the installation before proceeding."
    exit 1
fi