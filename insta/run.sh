#!/usr/bin/env bash
set -euo pipefail

# Set project top level directory
INSTA_TOPLVL="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export INSTA_TOPLVL

# Parse command line options
CONFIG_FILE="$INSTA_TOPLVL/insta/confs/default.sh"
if [[ "${1:-}" == "--config" ]]; then
    CONFIG_FILE="$INSTA_TOPLVL/insta/confs/${2:-default.sh}"
    shift 2
fi

export CONFIG_FILE

# Source configuration file
source "$CONFIG_FILE"

# Source common configuration
source "$INSTA_TOPLVL/insta/utils/common.sh"

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
    echo "  4. Exit chroot and provide final instructions"
    echo ""
    echo "Options:"
    echo "  --config FILE    Use alternative config file (default: insta/confs/default.sh)"
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
    echo "  AUTO_CONFIRM - Skip confirmations (default: false)"
    echo ""
    echo "Usage: $0 [--config FILE]"
    echo "Example: $0 --config homeserver.sh"
    echo "Example: DISK=/dev/sdb KERNEL=linux-zen $0"
    echo ""
    echo "WARNING: This will completely wipe and repartition the target disk!"
    exit 0
fi

check_root
ensure_gum
validate_disk "$DISK"
validate_timezone "$TIMEZONE"
check_disk_unmounted "$DISK"

show_config

echo ""
log_warn "WARNING: This will completely wipe and repartition $DISK!"
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
echo "  - Run post-install script: ./insta/post.sh (optional)"
echo ""
echo "System Information:"
echo "  - Hostname: $HOSTNAME"
echo "  - Kernel: $KERNEL"
echo "  - Filesystem: Btrfs with Snapper"
echo "  - Bootloader: systemd-boot"
echo "=========================================="