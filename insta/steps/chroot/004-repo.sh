#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Chroot Repository Script
# Configuring repositories and mirrors for pacman

mark_step "Step 4/14: Configuring Pacman Repositories"

mark_stage "Stage 1/1: Configuring pacman mirrors..."

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