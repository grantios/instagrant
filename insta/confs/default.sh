# Defaults that gets added to all configurations / installations.
# This file sets base settings that apply to everything.
# Specific configs can override these values

# Base packages that should be available on all systems
export EXTRA_PACKAGES=(
    "tmux" "btop" "fastfetch" "glow" "gum" "acpi"
    "restic" "rclone" "syncthing" "openssh" "tailscale" "git-lfs" "wget"
    "flatpak" "podman" "distrobox"
    "unzip" "exfat-utils" "ntfs-3g" "net-tools" "github-cli"
)

# Base AUR packages for all systems
export AUR_PACKAGES=(
    " "
)

# Base services enabled on all systems
export SERVICES="sshd.service"

# Base boot options (can be extended by specific configs)
# export BOOT_OPTIONS=""