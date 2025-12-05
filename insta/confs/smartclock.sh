# Smart Clock Configuration - Hyprland + Godot Development
# Copy this to config.sh and modify as needed, then source it manually: source config.sh

# Configuration name (used for skel directory)
export CONFIG_NAME="smartclock"

# Disk configuration
export DISK="/dev/sda"
export TARGET_DIR="/target"

# System configuration
export TIMEZONE="America/Chicago"
export LOCALE="en_US.UTF-8"
export KEYMAP="colemak"
export HOSTNAME="LOADED"
export USERNAME="CLOCKD"
export HOMEDIR="/room/clockd"
export PASSWORD="timesUP!"
export PASSROOT="timesUP!"

# Software configuration
export KERNEL="linux-lts"
export DESKTOP="hyprland"
export GPU_DRIVER="auto"

# Development packages (Godot engine included)
EXTRA_PACKAGES+=(
    "godot"
    "kitty"
    "dolphin"
    "chromium"
    "wofi"
    "wireplumber"
    "brightnessctl"
)

AUR_PACKAGES+=(
    "tty-clock"
)

# Boot options (appended to kernel command line)
export BOOT_OPTIONS="fbcon=rotate:2"

# Installation options
