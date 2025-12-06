#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Check if BASE_PACKAGES is set
if [[ -z "$BASE_PACKAGES" ]]; then
    echo "ERROR: BASE_PACKAGES is not set. Check common.sh or config file."
    exit 1
fi

# Arch Linux Setup Pacstrap Script
# Installing base system


gum style --border normal --padding "0 1" --border-foreground 34 "Step 3/5: Installing Base System"

gum style --border normal --padding "0 1" --border-foreground '#800080' "Stage 1/1: Installing base system..."

# Install base packages
log_info "Installing base packages: $BASE_PACKAGES"
if ! retry_pacstrap pacstrap ${TARGET_DIR} $BASE_PACKAGES; then
    log_error "Pacstrap failed after 3 attempts"
    exit 1
fi
log_success "Base system installation completed"