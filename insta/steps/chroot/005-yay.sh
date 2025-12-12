#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Chroot Yay Script
# Installing yay AUR helper

mark_step "Step 5/14: Installing Yay AUR Helper"

mark_stage "Stage 1/1: Installing yay AUR helper..."

# Clone yay as root
log_info "Cloning yay from AUR..."
git clone https://aur.archlinux.org/yay.git /tmp/yay

# Change ownership to stein
log_info "Setting ownership to ${USERNAME}..."
chown -R ${USERNAME}:${USERNAME} /tmp/yay

# Build and install yay as stein
log_info "Building and installing yay as ${USERNAME}..."
runuser -u ${USERNAME} -- bash -c "cd /tmp/yay && makepkg -si --noconfirm"

# Clean up
log_info "Cleaning up..."
rm -rf /tmp/yay

log_success "yay AUR helper installed successfully!"