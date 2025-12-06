#!/usr/bin/env bash
set -euo pipefail


# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set project top level if not set
if [[ -z "${INSTA_TOPLVL:-}" ]]; then
    INSTA_TOPLVL="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

# Source common.sh early for functions
source "$SCRIPT_DIR/../utils/common.sh"

ensure_gum

# Arch Linux Chroot Script
# Runs all chroot steps in order

if [[ "${1:-}" == "--help" ]]; then
    echo "Arch Linux Chroot Script"
    echo ""
    echo "Runs the following steps in order:"
    echo "  1. 001-timezone   - Set timezone and locale"
    echo "  2. 002-hostname   - Set hostname"
    echo "  3. 003-user       - Create user and set passwords"
    echo "  4. 004-mirr       - Configure mirrors"
    echo "  5. 005-yay        - Install yay AUR helper"
    echo "  6. 006-aur        - Install AUR packages"
    echo "  7. 007-packages   - Install additional packages"
    echo "  8. 008-services   - Enable services"
    echo "  9. 009-bootctl    - Install and configure systemd-boot"
    echo " 10. 010-mkinitcpio - Configure mkinitcpio"
    echo " 12. 012-rollback  - Install snapper-rollback"
    echo " 13. 013-skeleton  - Copy configuration skeleton files"
    echo " 14. 014-cleanup   - Final cleanup tasks"
    echo ""
    echo "Usage:"
    echo "  $0                    - Run all steps"
    echo "  $0 --redo-step <step> - Rerun a specific step (1-13 or 01-13)"
    echo "  $0 --redo-from <step> - Rerun from step to end (1-13 or 01-13)"
    echo "Configuration (set as environment variables):"
    echo "  TIMEZONE     - Timezone (default: America/Chicago)"
    echo "  LOCALE       - System locale (default: en_US.UTF-8)"
    echo "  KEYMAP       - Console keymap (default: us)"
    echo "  HOSTNAME     - Hostname (default: archlinux)"
    echo "  USERNAME     - User to create (default: stein)"
    echo "  PASSWORD     - Default user password (default: GATEKEEP)"
    echo "  PASSROOT     - Default root password (default: GATEKEEP)"
    echo "  KERNEL       - Kernel installed (default: linux-lts)"
    echo "  DESKTOP      - Desktop environment (default: plasma)"
    echo "  GPU_DRIVER   - GPU driver: auto, nvidia, nvidia-lts, amd, intel, modesetting (default: auto)"
    echo "  AUTO_CHROOT_CONFIRM - Skip chroot confirmation (default: true)"
    echo ""
    echo "Usage: $0"
    echo "Run this inside arch-chroot ${TARGET_DIR}"
    exit 0
fi

# Require config file to be set
if [[ -z "${CONFIG_FILE:-}" ]]; then
    echo "Error: CONFIG_FILE environment variable must be set."
    echo "Run from main script: ./insta/run.sh --config <name>"
    echo "Or set manually: CONFIG_FILE=/path/to/config.sh $0"
    exit 1
fi

# Adjust CONFIG_FILE for chroot environment
CONFIG_FILE="insta/confs/$(basename "$CONFIG_FILE")"
export CONFIG_FILE

# Source default config first (if it exists)
DEFAULT_CONFIG="insta/confs/default.sh"
if [[ -f "$DEFAULT_CONFIG" ]]; then
    source "$DEFAULT_CONFIG"
    combine_config_arrays
fi

# Source configuration
source "$CONFIG_FILE"
combine_config_arrays

# Source common configuration again for package combining logic
source "$SCRIPT_DIR/../utils/common.sh"

log_info "Sourced config from $CONFIG_FILE"
log_info "EXTRA_PACKAGES: ${EXTRA_PACKAGES[*]}"
log_info "AUR_PACKAGES: ${AUR_PACKAGES[*]}"

# Define the steps array
STEPS=(
    "001-timezone.sh"
    "002-hostname.sh"
    "003-user.sh"
    "004-mirr.sh"
    "005-yay.sh"
    "006-aur.sh"
    "007-packages.sh"
    "008-services.sh"
    "009-bootctl.sh"
    "010-mkinitcpio.sh"
    "011-snapper.sh"
    "012-rollback.sh"
    "013-skeleton.sh"
    "014-cleanup.sh"
)

# Handle --redo-step and --redo-from arguments
if [[ "${1:-}" == "--redo-step" ]]; then
    STEP="${2:-}"
    if [[ -z "$STEP" ]]; then
        log_error "Error: --redo-step requires a step number (1-14)"
        exit 1
    fi
    
    case "$STEP" in
        1|01) ./insta/steps/chroot/001-timezone.sh ;;
        2|02) ./insta/steps/chroot/002-hostname.sh ;;
        3|03) ./insta/steps/chroot/003-user.sh ;;
        4|04) ./insta/steps/chroot/004-mirr.sh ;;
        5|05) ./insta/steps/chroot/005-yay.sh ;;
        6|06) ./insta/steps/chroot/006-aur.sh ;;
        7|07) ./insta/steps/chroot/007-packages.sh ;;
        8|08) ./insta/steps/chroot/008-services.sh ;;
        9|09) ./insta/steps/chroot/009-bootctl.sh ;;
        11) ./insta/steps/chroot/011-snapper.sh ;;
        12) ./insta/steps/chroot/012-rollback.sh ;;
        13) ./insta/steps/chroot/013-skeleton.sh ;;
        14) ./insta/steps/chroot/014-cleanup.sh ;;
        *) log_error "Error: Invalid step number $STEP. Must be 1-14 or 01-14." ;;
    esac
    exit $?
elif [[ "${1:-}" == "--redo-from" ]]; then
    START_STEP="${2:-}"
    if [[ -z "$START_STEP" ]]; then
        log_error "Error: --redo-from requires a step number (1-14)"
        exit 1
    fi
    
    # Find the starting index
    START_INDEX=$((START_STEP - 1))
    if [[ $START_INDEX -lt 0 || $START_INDEX -ge ${#STEPS[@]} ]]; then
        log_error "Error: Invalid step number $START_STEP. Must be 1-${#STEPS[@]} or 01-${#STEPS[@]}."
        exit 1
    fi
    
    # Run steps from START_INDEX to end
    for ((i = START_INDEX; i < ${#STEPS[@]}; i++)); do
        ./insta/steps/chroot/${STEPS[$i]}
    done
    
    # Install GPU drivers and desktop (always run these at the end for --redo-from)
    if [[ "$GPU_DRIVER" == "auto" ]]; then
        GPU_DRIVER=$(detect_gpu_driver)
    fi
    if [[ "$GPU_DRIVER" != "none" ]]; then
        install_gpu_driver "$GPU_DRIVER"
    fi

    # Install desktop if configured
    if [[ "$DESKTOP" != "none" ]]; then
        install_desktop
    fi

    log_success "Chroot setup complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Exit the chroot: exit"
    echo "  2. Unmount: umount -R ${TARGET_DIR}"
    echo "  3. Reboot: reboot"
    echo ""
    echo "After reboot:"
    echo "  - Login as '${USERNAME}' / '${PASSWORD}'"
    echo "  - Change password: passwd"
    echo "  - Check snapshots: sudo snapper list"
    if [[ "$DESKTOP" != "none" ]]; then
        echo "  - Desktop environment: $DESKTOP"
    fi
    exit $?
fi

validate_timezone "$TIMEZONE"

if ! confirm "Proceed with chroot configuration?"; then
    log_info "Chroot configuration cancelled"
    exit 0
fi

log_info "Starting chroot configuration..."

./insta/steps/chroot/001-timezone.sh
./insta/steps/chroot/002-hostname.sh
./insta/steps/chroot/003-user.sh
./insta/steps/chroot/004-mirr.sh
./insta/steps/chroot/005-yay.sh
./insta/steps/chroot/006-aur.sh
./insta/steps/chroot/007-packages.sh
./insta/steps/chroot/008-services.sh
./insta/steps/chroot/009-bootctl.sh
./insta/steps/chroot/010-mkinitcpio.sh
./insta/steps/chroot/011-snapper.sh
./insta/steps/chroot/012-rollback.sh
./insta/steps/chroot/013-skeleton.sh
./insta/steps/chroot/014-cleanup.sh

# Install GPU drivers
if [[ "$GPU_DRIVER" == "auto" ]]; then
    GPU_DRIVER=$(detect_gpu_driver)
fi
if [[ "$GPU_DRIVER" != "none" ]]; then
    install_gpu_driver "$GPU_DRIVER"
fi

# Install desktop if configured
if [[ "$DESKTOP" != "none" ]]; then
    install_desktop
fi

log_success "Chroot setup complete!"
echo ""
echo "Next steps:"
echo "  1. Exit the chroot: exit"
echo "  2. Unmount: umount -R ${TARGET_DIR}"
echo "  3. Reboot: reboot"
echo ""
echo "After reboot:"
echo "  - Login as '${USERNAME}' / '${PASSWORD}'"
echo "  - Change passwords: passwd (for user) and passwd root (for root)"
echo "  - Check snapshots: sudo snapper list"
if [[ "$DESKTOP" != "none" ]]; then
    echo "  - Desktop environment: $DESKTOP"
fi