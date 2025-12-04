#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Setup Fstab Script
# Generating fstab

log_info "Generating fstab"

# Generate fstab
genfstab -U ${TARGET_DIR} >> ${TARGET_DIR}/etc/fstab

# Show the fstab
echo "Generated fstab:"
cat ${TARGET_DIR}/etc/fstab