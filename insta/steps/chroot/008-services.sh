#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Chroot Services Script
# Enabling services

ensure_gum

gum style --border normal --padding "0 1" --border-foreground 86 "Step 7: Enabling services..."

# Enable configured services
for service in $SERVICES; do
    log_info "Enabling service: $service"
    systemctl enable "$service"
done