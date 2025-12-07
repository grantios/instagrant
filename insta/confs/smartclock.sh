# Smart Clock Configuration - Hyprland + Godot Development
# Copy this to config.sh and modify as needed, then source it manually: source config.sh

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/../utils/common.sh"

# Configuration name (used for skel directory)
export CONFIG_NAME="smartclock"

# Disk configuration
export TARGET_DISK="/dev/sda"
export TARGET_DIR="/target"

# System configuration
export TIMEZONE="America/Chicago"
export LOCALE="en_US.UTF-8"
export KEYMAP="colemak"
export HOSTNAME="LEGRUNE"
export USERNAME="CLOCKED"
export HOMEDIR="/room/eight"
export PASSWORD="change!"
export PASSROOT="change!"

# Software configuration
export KERNEL="linux-lts"
export DESKTOP="hyprland"
export GPU_DRIVER="auto"

# Ensure INSTA_TOPLVL is set
ensure_insta_toplvl

# Source the hyprland bundle for Hyprland desktop
source "$INSTA_TOPLVL/insta/confs/bundles/hypr.sh"

# Development packages (Godot engine included)
EXTRA_PACKAGES+=(
    "godot"
    "dolphin"
    "chromium"
    "wireplumber"
    "brightnessctl"
)

AUR_PACKAGES+=(
    "tty-clock"
)

# Boot options (appended to kernel command line)
export BOOT_OPTIONS="fbcon=rotate:2"

# Installation options
