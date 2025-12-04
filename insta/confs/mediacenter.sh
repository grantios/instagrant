# HTPC Configuration - Hyprland + Kodi Media Center
# Copy this to config.sh and modify as needed, then source it manually: source config.sh

# Disk configuration
export DISK="/dev/sda"
export TARGET_DIR="/target"

# System configuration
export TIMEZONE="America/Chicago"
export LOCALE="en_US.UTF-8"
export KEYMAP="colemak"
export HOSTNAME="CENTER"
export USERNAME="MMEDIA"
export PASSWORD="change!"
export PASSROOT="change!"

# Software configuration
export KERNEL="linux-lts"
export DESKTOP="hyprland"
export GPU_DRIVER="auto"

# Media packages
export EXTRA_PACKAGES=(
    "kodi"
    "rtorrent"
    "jellyfin"
    "pavucontrol"
    "easyeffects"
)
export SERVICES="jellyfin.service"

# Installation options
export AUTO_CONFIRM="false"
