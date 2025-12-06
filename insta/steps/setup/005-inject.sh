#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Setup Inject Script
# Injecting tios system files

# Set project top level if not set
if [[ -z "${INSTA_TOPLVL:-}" ]]; then
    INSTA_TOPLVL="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
fi

gum style --border normal --padding "0 1" --border-foreground 34 "Step 5/5: Injecting System Files"

gum style --border normal --padding "0 1" --border-foreground '#800080' "Stage 1/1: Injecting tios system files..."

# Copy the entire repository to ${TARGET_DIR}/tios
if [ -d "$INSTA_TOPLVL" ]; then
    echo "Injecting repository from $INSTA_TOPLVL to ${TARGET_DIR}/tios..."
    rsync -a "$INSTA_TOPLVL"/insta ${TARGET_DIR}/tios/
    echo "tios files injected successfully!"
    
    # Verify the copy was successful
    if [[ -f "${TARGET_DIR}/tios/insta/cmds/chroot.sh" ]]; then
        echo "Verification: chroot.sh found at ${TARGET_DIR}/tios/insta/cmds/chroot.sh"
    else
        echo "Error: Inject verification failed - chroot.sh not found"
        exit 1
    fi
else
    echo "Warning: Repository directory not found at $INSTA_TOPLVL"
    exit 1
fi