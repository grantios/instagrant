# Home Server Configuration - Headless Server (TTY only)
# Copy this to config.sh and modify as needed, then source it manually: source config.sh

# Disk configuration
export TARGET_DISK="/dev/sda"
export TARGET_DIR="/target"

# System configuration
export TIMEZONE="America/Chicago"
export LOCALE="en_US.UTF-8"
export KEYMAP="colemak"
export HOSTNAME="HOMERR"
export USERNAME="SERVER"
export PASSWORD="change!"
export PASSROOT="change!"

# Software configuration
export KERNEL="linux-lts"
export DESKTOP="none"  # TTY only, no desktop environment
export GPU_DRIVER="auto"

# Server packages (appended to defaults)
EXTRA_PACKAGES+=(
    "samba"
    "docker"
)

# Installation options
