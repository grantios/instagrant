#!/usr/bin/env bash
set -euo pipefail

# Set project top level directory
INSTA_TOPLVL="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export INSTA_TOPLVL

# Source configuration generator
source "$INSTA_TOPLVL/insta/utils/configuration-generator.sh"

# Source common.sh early for functions
source "$INSTA_TOPLVL/insta/utils/common.sh"

# Function to check if an official package exists
check_arch_package() {
    if pacman -Si "$1" &>/dev/null; then
        return 0
    elif pacman -S --print "$1" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to check if an AUR package exists
check_aur_package() {
    if curl -s "https://aur.archlinux.org/rpc/?v=5&type=info&arg=$1" | grep -q '"resultcount":1'; then
        return 0
    else
        return 1
    fi
}

# Parse command line options
if [[ "${1:-}" == "--config-gen" ]]; then
    shift
    handle_config_gen "$@"
fi

# Handle --config-list option
if [[ "${1:-}" == "--config-list" ]]; then
    echo "Available configuration files in $INSTA_TOPLVL/insta/confs/:"
    echo ""
    for config in "$INSTA_TOPLVL/insta/confs/"*.sh; do
        if [[ -f "$config" ]]; then
            config_name=$(basename "$config" .sh)
            echo "  $config_name"
        fi
    done
    echo ""
    echo "Use --config <name> to select a configuration."
    exit 0
fi

# Require --config option
if [[ "${1:-}" != "--config" ]]; then
    echo "Error: --config option is required."
    echo ""
    echo "Available configuration files in $INSTA_TOPLVL/insta/confs/:"
    echo ""
    for config in "$INSTA_TOPLVL/insta/confs/"*.sh; do
        if [[ -f "$config" ]]; then
            config_name=$(basename "$config" .sh)
            echo "  $config_name"
        fi
    done
    echo ""
    echo "Usage: $0 --config <name> [--config-gen [NAME]]"
    echo "Example: $0 --config workstation"
    echo "Example: $0 --config-list"
    exit 1
fi

# Parse --config option
config_arg="${2:-}"
if [[ -z "$config_arg" ]]; then
    echo "Error: --config requires a configuration name."
    exit 1
fi

# Try the config name as-is first
if [[ -f "$INSTA_TOPLVL/insta/confs/${config_arg}" ]]; then
    CONFIG_FILE="$INSTA_TOPLVL/insta/confs/${config_arg}"
# If not found, try adding .sh extension
elif [[ -f "$INSTA_TOPLVL/insta/confs/${config_arg}.sh" ]]; then
    CONFIG_FILE="$INSTA_TOPLVL/insta/confs/${config_arg}.sh"
else
    echo "Error: Config file '$config_arg' or '${config_arg}.sh' not found in $INSTA_TOPLVL/insta/confs/"
    exit 1
fi

shift 2

export CONFIG_FILE

# Source default config first (if it exists)
DEFAULT_CONFIG="$INSTA_TOPLVL/insta/confs/default.sh"
if [[ -f "$DEFAULT_CONFIG" ]]; then
    source "$DEFAULT_CONFIG"
    combine_config_arrays
fi

# Source configuration file
source "$CONFIG_FILE"
log_info "Config loaded from $CONFIG_FILE, EXTERNAL_DRIVES defined: $([[ -v EXTERNAL_DRIVES ]] && echo yes || echo no)"
combine_config_arrays

# Source common configuration again for package combining logic
source "$INSTA_TOPLVL/insta/utils/common.sh"

# Check package availability
log_warn "Checking package availability (this may take a moment)..."
for pkg in "${EXTRA_PACKAGES[@]}"; do
    if [[ "$pkg" == " " || -z "$pkg" || "$pkg" == "steam" ]]; then continue; fi
    if ! check_arch_package "$pkg"; then
        log_error "Official package '$pkg' not found in Arch repositories"
        exit 1
    fi
done
for pkg in "${AUR_PACKAGES[@]}"; do
    if [[ "$pkg" == " " || -z "$pkg" ]]; then continue; fi
    if ! check_aur_package "$pkg"; then
        log_error "AUR package '$pkg' not found in AUR"
        exit 1
    fi
done
log_success "All packages are available"

# Start logging everything to debug.log
exec > >(stdbuf -o0 tee /dev/tty | stdbuf -o0 sed 's/\x1b\[[0-9;]*m//g' > debug.log)

# GrantiOS ASCII Art
cat << 'EOF'
   _____                 _   _  ____   _____ 
  / ____|               | | (_)/ __ \ / ____|
 | |  __ _ __ __ _ _ __ | |_ _| |  | | (___  
 | | |_ | '__/ _` | '_ \| __| | |  | |\___ \ 
 | |__| | | | (_| | | | | |_| | |__| |____) |
  \_____|_|  \__,_|_| |_|\__|_|\____/|_____/ 
                                             
                                             
EOF

# Arch Linux Full Installation Script
# Automates the entire installation process

if [[ "${1:-}" == "--help" ]]; then
    echo "GrantiOS Full Installation Script"
    echo ""
    echo "This script automates the complete Arch Linux installation:"
    echo "  1. Run setup (partitioning, mounting, pacstrapping)"
    echo "  2. Enter chroot automatically"
    echo "  3. Run chroot configuration"
    echo "  4. Run post-installation steps"
    echo "  5. Exit chroot and provide final instructions"
    echo ""
    echo "Options:"
    echo "  --config-gen [NAME]    Generate a config template with skeleton structure (default name: template)"
    echo "  --config FILE          Use specified config file (REQUIRED - no default)"
    echo "                         default.sh is loaded first, then the specified config"
    echo "                         Packages, AUR packages, and services are combined (not overwritten)"
    echo "                         FILE can be with or without .sh extension"
    echo "  --config-list          List all available configuration files"
    echo ""
    echo "Configuration (set as environment variables or in config file):"
    echo "  DISK         - Target disk (default: /dev/sda)"
    echo "  TARGET_DIR   - Installation target directory (default: /mnt)"
    echo "  TIMEZONE     - Timezone (default: America/Chicago)"
    echo "  HOSTNAME     - Hostname (default: archlinux)"
    echo "  USERNAME     - User to create (default: stein)"
    echo "  PASSWORD     - Default user password (default: GATEKEEP)"
    echo "  PASSROOT     - Default root password (default: GATEKEEP)"
    echo "  KERNEL       - Kernel to install (default: linux-lts)"
    echo "  DESKTOP      - Desktop environment (default: plasma)"
    echo "  AUTO_CHROOT_CONFIRM - Skip chroot confirmation (default: true)"
    echo ""
    echo "Usage: $0 --config <name> [--config-gen [NAME]]"
    echo "Example: $0 --config workstation"
    echo "Example: $0 --config homeserver --config-gen"
    echo "Example: $0 --config-list"
    echo "Example: DISK=/dev/sdb KERNEL=linux-zen $0 --config mediacenter"
    echo ""
    echo "WARNING: This will completely wipe and repartition the target disk!"
    exit 0
fi

check_root
ensure_gum
validate_disk "$TARGET_DISK"
check_disk_unmounted "$TARGET_DISK"

show_config

echo ""
log_warn "WARNING: This will completely wipe and repartition $TARGET_DISK!"
if ! confirm "Are you absolutely sure you want to proceed?"; then
    log_info "Installation cancelled"
    exit 0
fi

log_step "Starting full installation process..."

# Run setup
log_step "Phase 1: Setup (partitioning, mounting, pacstrapping)"
"$INSTA_TOPLVL/insta/cmds/setup.sh"

# Verify that the scripts were copied correctly
if [[ ! -f "${TARGET_DIR}/tios/insta/cmds/chroot.sh" ]]; then
    log_error "Setup failed: chroot script not found at ${TARGET_DIR}/tios/insta/cmds/chroot.sh"
    log_error "Please check the setup process and try again"
    exit 1
fi

# Enter chroot and run configuration
log_step "Phase 2: Chroot configuration"
arch-chroot ${TARGET_DIR} /bin/bash 2>&1 <<EOF | stdbuf -o0 tee /dev/tty | stdbuf -o0 sed 's/\x1b\[[0-9;]*m//g' >> debug.log
cd /tios
./insta/cmds/chroot.sh
EOF

# Copy debug.log to the chroot for reference
cp "$INSTA_TOPLVL/debug.log" ${TARGET_DIR}/tios/insta/

# Run after-chroot steps
log_step "Phase 3: Post-installation steps"
for script in "$INSTA_TOPLVL/insta/steps/after/"*.sh; do
    if [[ -f "$script" ]]; then
        log_info "Running $(basename "$script")"
        bash "$script"
    fi
done

log_success "Installation complete!"
echo ""
echo "=========================================="
echo "Final Steps"
echo "=========================================="
echo "1. Exit the live environment: exit"
echo "2. Unmount filesystems: umount -R ${TARGET_DIR}"
echo "3. Reboot: reboot"
echo ""
echo "After reboot:"
echo "  - Login as '${USERNAME}' / '${PASSWORD}'"
echo "  - Change passwords immediately: passwd (for user) and passwd root (for root)"
echo "  - Check snapshots: sudo snapper list"
if [[ "$DESKTOP" != "none" ]]; then
    echo "  - Desktop environment: $DESKTOP"
fi
echo "  - Run post-install script: /tios/post.sh (optional)"
echo ""
echo "System Information:"
echo "  - Hostname: $HOSTNAME"
echo "  - Kernel: $KERNEL"
echo "  - Filesystem: Btrfs with Snapper"
echo "  - Bootloader: systemd-boot"
echo "=========================================="