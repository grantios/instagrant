#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Chroot Copy Skel Script
# Copying skeleton files for configuration-specific setup

gum style --border normal --padding "0 1" --border-foreground 34 "Step 13/14: Copying Skeleton Files"

gum style --border normal --padding "0 1" --border-foreground '#800080' "Stage 1/1: Copying skeleton files..."

# Set paths
TIOS_DIR="/tios"
SKEL_DIR="${TIOS_DIR}/insta/skel"
CONFIG_SKEL="${SKEL_DIR}/${CONFIG_NAME}"
DEFAULT_SKEL="${SKEL_DIR}/default"

# Check if CONFIG_NAME is set
if [ -z "${CONFIG_NAME:-}" ]; then
    echo "CONFIG_NAME not set, skipping skeleton copy"
    exit 0
fi

# Copy default skeleton files first (if they exist)
if [ -d "$DEFAULT_SKEL" ]; then
    echo "Copying default skeleton files from $DEFAULT_SKEL to /"
    
    # Copy @sys skeleton files (system-wide files)
    if [ -d "${DEFAULT_SKEL}/@sys" ]; then
        echo "Copying default system skeleton files from ${DEFAULT_SKEL}/@sys to /"
        rsync -a "${DEFAULT_SKEL}/@sys/" /
    fi

    # Copy @root skeleton files (root user home)
    if [ -d "${DEFAULT_SKEL}/@root" ]; then
        echo "Copying default root skeleton files from ${DEFAULT_SKEL}/@root to /root"
        mkdir -p /root
        rsync -a "${DEFAULT_SKEL}/@root/" /root/
    fi

    # Copy @user skeleton files
    if [ -d "${DEFAULT_SKEL}/@user" ] && [ -n "${HOMEDIR:-}" ]; then
        echo "Copying default user skeleton files from ${DEFAULT_SKEL}/@user to ${HOMEDIR}"
        mkdir -p "$HOMEDIR"
        rsync -a "${DEFAULT_SKEL}/@user/" "$HOMEDIR/"
        # Set ownership to the user
        if [ -n "${USERNAME:-}" ]; then
            chown -R "$USERNAME:$USERNAME" "$HOMEDIR"
        fi
    fi
fi

# Check if config-specific skel exists
if [ ! -d "$CONFIG_SKEL" ]; then
    echo "Skeleton directory $CONFIG_SKEL not found, skipping config-specific copy"
else
    echo "Copying config-specific skeleton files from $CONFIG_SKEL to / (may override defaults)"
    
    # Copy @sys skeleton files (system-wide files) - these will override defaults
    if [ -d "${CONFIG_SKEL}/@sys" ]; then
        echo "Copying system skeleton files from ${CONFIG_SKEL}/@sys to /"
        rsync -a "${CONFIG_SKEL}/@sys/" /
    fi

    # Copy @root skeleton files (root user home) - these will override defaults
    if [ -d "${CONFIG_SKEL}/@root" ]; then
        echo "Copying root skeleton files from ${CONFIG_SKEL}/@root to /root"
        mkdir -p /root
        rsync -a "${CONFIG_SKEL}/@root/" /root/
    fi

    # Copy @user skeleton files - these will override defaults
    if [ -d "${CONFIG_SKEL}/@user" ] && [ -n "${HOMEDIR:-}" ]; then
        echo "Copying user skeleton files from ${CONFIG_SKEL}/@user to ${HOMEDIR}"
        mkdir -p "$HOMEDIR"
        rsync -a "${CONFIG_SKEL}/@user/" "$HOMEDIR/"
        # Set ownership to the user
        if [ -n "${USERNAME:-}" ]; then
            chown -R "$USERNAME:$USERNAME" "$HOMEDIR"
        fi
    fi
fi

echo "Skeleton files copied successfully!"