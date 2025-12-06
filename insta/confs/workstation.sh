# Workstation configuration file for Arch Linux installation
# This file is automatically loaded by the installation scripts
# Copy this to config.sh and modify as needed, then source it manually: source config.sh

# Configuration name (used for skel directory)
export CONFIG_NAME="workstation"

# Disk configuration
export TARGET_DISK="/dev/sda"
export TARGET_DIR="/target"

# External drives configuration (uncomment and modify as needed)
# These drives will be partitioned (single partition), formatted as XFS, and mounted during installation
# Format: DEVICE:MOUNTPOINT:LABEL
# DEVICE should be the whole drive (e.g., /dev/sdb)
export EXTERNAL_DRIVES=(
    "/dev/sdb:/drv/data:data"
    "/dev/sdc:/drv/dada:dada"
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
export HOSTNAME="GATED"
export USERNAME="STEIN"
export HOMEDIR="/room/stein"
export PASSWORD="change!"
export PASSROOT="change!"

# Software configuration
export KERNEL="linux-lts"
export DESKTOP="plasma"  # plasma, hyprland, none
export GPU_DRIVER="auto"  # auto, nvidia, nvidia-lts, amd, intel, modesetting

# Additional packages and services (appended to defaults)
# Edit common.sh as-needed if you need to edit base packages
# But really suggest you don't. Trying to keep as minimal as possible.
EXTRA_PACKAGES+=(
    "vlc" "streamlink" "yt-dlp" "mpv" "mpd"
    "steam" "godot" "blender"
    "yakuake" "krita" "kdenlive"
    "obs-studio"
    "obsidian" "libreoffice" 
    "blender" "lmms" "audacity" "musescore"
    "papirus-icon-theme" noto-fonts noto-fonts-emoji
    "network-manager-applet" "plasma-nm" "proton-vpn-gtk-app"
    "easyeffects" "pipewire" "pipewire-alsa" "pipewire-pulse"
    "chromium" "firefox" "thunderbird" "signal-desktop" "element-desktop" 
    "raylib" "sdl2" "sdl2_net" "sdl2_image" "sdl2_mixer" "sdl2_ttf"
    "qemu-full" "llvm" "lldb" "clang" "cmake" "meson" "ninja" "sbcl" "roswell" "racket" "fennel"
)
AUR_PACKAGES+=(
    "papirus-folders-git" "bazaar"
    "visual-studio-code-bin" "chez-scheme" "chibi-scheme"
    "onlyoffice-bin" "planify" "notesnook-bin" "electronmail-bin" "steamlink"
    "vesktop-bin" "chatterino2-bin"
    "blockbench-bin" "sidequest-bin"
)
SERVICES+=" syncthing@STEIN.service"  # Uncomment to enable Syncthing user service

# Boot options (appended to kernel command line)
# export BOOT_OPTIONS="fbcon=rotate:2"

# Installation options


# Full package/service overrides (replaces defaults entirely)
# export BASE_PACKAGES="base linux-lts linux-firmware base-devel networkmanager openssh"
# export EXTRA_PACKAGES="htop neofetch vim git"
# export AUR_PACKAGES="your-aur-package"
# export SERVICES="NetworkManager fstrim.timer reflector.timer"
# Note: sshd service is enabled automatically since openssh is in BASE_PACKAGES