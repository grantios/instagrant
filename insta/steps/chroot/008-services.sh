#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Chroot Services Script
# Enabling services

mark_step "Step 8/14: Enabling Services"

mark_stage "Stage 1/1: Enabling services..."

# Enable configured services
for service in $SERVICES; do
    log_info "Enabling service: $service"
    systemctl enable "$service"
done