#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Chroot Timezone Script
# Setting timezone, locale, and keymap

mark_step "Step 1/14: Setting Timezone, Locale, and Keymap"

mark_stage "Stage 1/1: Setting timezone, locale, and keymap..."

# Set timezone
log_info "Setting timezone to ${TIMEZONE}"
ln -sf /usr/share/zoneinfo/"${TIMEZONE}" /etc/localtime
hwclock --systohc

# Generate and set locale
log_info "Setting locale to ${LOCALE}"
echo "${LOCALE} UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=${LOCALE}" > /etc/locale.conf

# Set virtual console keymap
log_info "Setting keymap to ${KEYMAP}"
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf