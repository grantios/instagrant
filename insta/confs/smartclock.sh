# Smart Clock Configuration - Hyprland + Godot Development
# Copy this to config.sh and modify as needed, then source it manually: source config.sh

# Disk configuration
export DISK="/dev/sda"
export TARGET_DIR="/target"

# System configuration
export TIMEZONE="America/Chicago"
export LOCALE="en_US.UTF-8"
export KEYMAP="colemak"
export HOSTNAME="LOADED"
export USERNAME="CLOCKED"
export PASSWORD="timesUP!"
export PASSROOT="timesUP!"

# Software configuration
export KERNEL="linux-lts"
export DESKTOP="hyprland"
export GPU_DRIVER="auto"

# Development packages (Godot engine included)
export EXTRA_PACKAGES=(
    "godot"
)

# Installation options
export AUTO_CONFIRM="false"