#!/usr/bin/env bash
set -euo pipefail

# Arch Linux Setup Copy Script
# Copying tios system files

# Set project top level if not set
if [[ -z "${INSTA_TOPLVL:-}" ]]; then
    INSTA_TOPLVL="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
fi

echo "Step 7: Copying tios system files..."

# Copy the entire repository to ${TARGET_DIR}/tios
if [ -d "$INSTA_TOPLVL" ]; then
    echo "Copying repository from $INSTA_TOPLVL to ${TARGET_DIR}/tios..."
    rsync -a "$INSTA_TOPLVL"/insta ${TARGET_DIR}/tios/
    echo "tios files copied successfully!"
    
    # Verify the copy was successful
    if [[ -f "${TARGET_DIR}/tios/insta/cmds/chroot.sh" ]]; then
        echo "Verification: chroot.sh found at ${TARGET_DIR}/tios/insta/cmds/chroot.sh"
    else
        echo "Error: Copy verification failed - chroot.sh not found"
        exit 1
    fi
else
    echo "Warning: Repository directory not found at $INSTA_TOPLVL"
    exit 1
fi