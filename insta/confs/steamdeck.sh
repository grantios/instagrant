# Steamdeck configuration file for Arch Linux installation
# This file is automatically loaded by the installation scripts
# Copy this to config.sh and modify as needed, then source it manually: source config.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/../utils/common.sh"

# Configuration name (used for skel directory)
export CONFIG_NAME="steamdeck"

# Disk configuration
export TARGET_DISK="/dev/sda"
export TARGET_DIR="/target"

# External drives configuration (uncomment and modify as needed)
# These drives will be partitioned (single partition), formatted as XFS, and mounted during installation
# Format: DEVICE:MOUNTPOINT:LABEL
# DEVICE should be the whole drive (e.g., /dev/sdb)
export EXTERNAL_DRIVES=(
    "/dev/sdb:/drv/games:games"
)

# Preserve drives configuration (uncomment and modify as needed)
# These drives will be mounted but NOT reformatted during installation
# Useful for preserving existing data partitions
# Format: DEVICE:MOUNTPOINT
# DEVICE can be /dev/sdx, LABEL=label, or UUID=uuid
#export PRESERVE_DRIVES=(
#    "LABEL=room/room"
#    "LABEL=steam:/room/steampunk/.steam"
#)

# System configuration
export TIMEZONE="America/Chicago"
export LOCALE="en_US.UTF-8"
export KEYMAP="us"
export HOSTNAME="STEAMDECK"
export USERNAME="STEAMPUNK"
export HOMEDIR="/room/steampunk"
export PASSWORD="change!"
export PASSROOT="change!"

# Software configuration
export KERNEL="linux-lts"
export DESKTOP="hyprland"  # plasma, hyprland, none
export GPU_DRIVER="amd"  # auto, nvidia, nvidia-lts, nvidia-open, amd, intel, modesetting

# Ensure INSTA_TOPLVL is set
ensure_insta_toplvl

# Source the hyprland bundle for Hyprland desktop
source "$INSTA_TOPLVL/insta/confs/bundles/hypr.sh"

# Gaming packages
EXTRA_PACKAGES+=(
    "mangohud"
    "gamemode"
    "lutris"
    "wine"
    "dxvk"
    "vkd3d"
    "discord"
    "obs-studio"
    "handbrake"
)

AUR_PACKAGES+=(
    "proton-ge-custom-bin"
    "steamdeck-dsp"
)