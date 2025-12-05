#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Chroot Cleanup Script
# Final cleanup tasks

ensure_gum

# Stop logging to debug.log
exec > /dev/tty 2>&1

gum style --border normal --padding "0 1" --border-foreground 86 "Step 13: Final cleanup..."

# Restore normal sudo behavior for wheel group
log_info "Restoring password requirement for sudo..."
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

log_success "Cleanup complete!"