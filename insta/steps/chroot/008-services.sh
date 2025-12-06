#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Chroot Services Script
# Enabling services

gum style --border normal --padding "0 1" --border-foreground 34 "Step 8/14: Enabling Services"

gum style --border normal --padding "0 1" --border-foreground '#800080' "Stage 1/1: Enabling services..."

# Enable configured services
for service in $SERVICES; do
    log_info "Enabling service: $service"
    systemctl enable "$service"
done