# HTPC Configuration - Hyprland + Kodi Media Center
# Copy this to config.sh and modify as needed, then source it manually: source config.sh

# Configuration name (used for skel directory)
export CONFIG_NAME="mediacenter"

# Disk configuration
export DISK="/dev/sda"
export TARGET_DIR="/target"

# System configuration
export TIMEZONE="America/Chicago"
export LOCALE="en_US.UTF-8"
export KEYMAP="colemak"
export HOSTNAME="HTPC"
export HOMEDIR="/room/multv"
export USERNAME="MULTV"
export PASSWORD="change!"
export PASSROOT="change!"

# Software configuration
export KERNEL="linux-lts"
export DESKTOP="hyprland"
export GPU_DRIVER="auto"

# Media packages
EXTRA_PACKAGES+=(
    "kodi"
    "retroarch"
    "libretro"
    "rtorrent"
    "blueman"
    "jellyfin-web"
    "jellyfin-server"
    "chromium"
    "pavucontrol"
    "easyeffects"
    "kitty"
    "dolphin"
    "wofi"
    "wireplumber"
    "brightnessctl"
)

AUR_PACKAGES+=(
    "steamlink"
)

SERVICES+=" jellyfin.service"

# Installation options

