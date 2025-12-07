# Hyprstation configuration file for Arch Linux installation
# This file is automatically loaded by the installation scripts
# Copy this to config.sh and modify as needed, then source it manually: source config.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/../utils/common.sh"

# Configuration name (used for skel directory)
export CONFIG_NAME="hyprstation"

# Disk configuration
export TARGET_DISK="/dev/sdb"
export TARGET_DIR="/target"

# External drives configuration (uncomment and modify as needed)
# These drives will be partitioned (single partition), formatted as XFS, and mounted during installation
# Format: DEVICE:MOUNTPOINT:LABEL
# DEVICE should be the whole drive (e.g., /dev/sdb)
export EXTERNAL_DRIVES=(
    "/dev/sdc:/drv/data:data"
    "/dev/sdd:/drv/dada:dada"
    "/dev/sda:/drv/ship:ship"
)

# Preserve drives configuration (uncomment and modify as needed)
# These drives will be mounted but NOT reformatted during installation
# Useful for preserving existing data partitions
# Format: DEVICE:MOUNTPOINT
# DEVICE can be /dev/sdx, LABEL=label, or UUID=uuid
#export PRESERVE_DRIVES=(
#    "LABEL=room:/room"
#    "LABEL=data:/drv/data"
#    "LABEL=dada:/drv/dada"
#)

# System configuration
export TIMEZONE="America/Chicago"
export LOCALE="en_US.UTF-8"
export KEYMAP="colemak"
export HOSTNAME="HYPRSTATION"
export USERNAME="STEIN"
export HOMEDIR="/room/stein"
export PASSWORD="change!"
export PASSROOT="change!"

# Software configuration
export KERNEL="linux-lts"
export DESKTOP="hyprland"  # plasma, hyprland, none
export GPU_DRIVER="nvidia-lts"  # auto, nvidia, nvidia-lts, nvidia-open, amd, intel, modesetting

# Additional packages and services (appended to defaults)
# Edit common.sh as-needed if you need to edit base packages
# But really suggest you don't. Trying to keep as minimal as possible.

# Ensure INSTA_TOPLVL is set
ensure_insta_toplvl

# Source the station bundle for common packages
source "$INSTA_TOPLVL/insta/confs/bundles/station.sh"

# Source the hyprland bundle for Hyprland desktop
source "$INSTA_TOPLVL/insta/confs/bundles/hypr.sh"

# Boot options (appended to kernel command line)
# export BOOT_OPTIONS="fbcon=rotate:2"

# Installation options


# Full package/service overrides (replaces defaults entirely)
# export BASE_PACKAGES="base linux-lts linux-firmware base-devel networkmanager openssh"
# export EXTRA_PACKAGES="htop neofetch vim git"
# export AUR_PACKAGES="your-aur-package"
# export SERVICES="NetworkManager fstrim.timer reflector.timer"
# Note: sshd service is enabled automatically since openssh is in BASE_PACKAGES