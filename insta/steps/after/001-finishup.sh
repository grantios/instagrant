#!/bin/bash
# 001-finishup.sh - Final configuration steps after chroot

set -euo pipefail

# Source common functions
source "$INSTA_TOPLVL/insta/utils/common.sh"

log_step "Final Configuration"
#######################################################################################
#######################################################################################
#######################################################################################
# NOTE: This copying might not be working as expected - copying back and then removing
#######################################################################################
#######################################################################################
#######################################################################################

# Copy the entire repository to ${TARGET_DIR}/tios
if [ -d "$INSTA_TOPLVL" ]; then
    log_info "Copying repository from $INSTA_TOPLVL to ${TARGET_DIR}/tios..."
    rsync -a "$INSTA_TOPLVL"/insta ${TARGET_DIR}/tios/
    log_success "tios files copied successfully!"
fi

# Move debug.log up and clean up insta directory
log_info "Moving debug.log and cleaning up installation files..."
if [ -f "${TARGET_DIR}/tios/insta/debug.log" ]; then
    mv "${TARGET_DIR}/tios/insta/debug.log" "${TARGET_DIR}/tios/debug.log"
fi
if [ -d "${TARGET_DIR}/tios/insta" ]; then
    rm -rf "${TARGET_DIR}/tios/insta"
fi

log_info "Final configuration complete"