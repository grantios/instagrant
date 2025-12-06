#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Chroot Hostname Script
# Setting hostname

gum style --border normal --padding "0 1" --border-foreground 34 "Step 2/14: Setting Hostname"

gum style --border normal --padding "0 1" --border-foreground '#800080' "Stage 1/1: Setting hostname..."

log_info "Setting hostname to ${HOSTNAME}"
echo "${HOSTNAME}" > /etc/hostname

# Create hosts file
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOF