#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Chroot Mirror Script
# Configuring mirrors for pacman using reflector

gum style --border normal --padding "0 1" --border-foreground 34 "Step 4/14: Configuring Pacman Mirrors"

gum style --border normal --padding "0 1" --border-foreground '#800080' "Stage 1/1: Configuring pacman mirrors..."

# Enable multilib repository for 32-bit packages
log_info "Enabling multilib repository..."
sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf

# Clear the mirrorlist to avoid config warnings
> /etc/pacman.d/mirrorlist

cat > /etc/xdg/reflector/reflector.conf << EOF
--save /etc/pacman.d/mirrorlist
--protocol https
--country US
--latest 20
--sort rate
EOF

# Run reflector to update mirrorlist
reflector --save /etc/pacman.d/mirrorlist --protocol https --country US --latest 20 --sort rate

systemctl enable reflector.timer

# Repoulate the pacman database
log_info "Populating pacman database..."
retry_pacman pacman -Syy --noconfirm