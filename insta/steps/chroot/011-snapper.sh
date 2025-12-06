#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Chroot Snapper Script
# Configuring snapper

gum style --border normal --padding "0 1" --border-foreground 34 "Step 11/14: Configuring Snapper"

gum style --border normal --padding "0 1" --border-foreground '#800080' "Stage 1/1: Configuring snapper..."

pacman -S --noconfirm snapper snap-pac

# Unmount .snapshots temporarily so snapper can work
umount /.snapshots
rmdir /.snapshots

# Create snapper config for root (using --no-dbus since we're in chroot)
# This will create a new .snapshots subvolume
snapper --no-dbus -c root create-config /

# Delete the subvolume snapper just created (we already have @snapshots)
btrfs subvolume delete /.snapshots

# Recreate the mount point
mkdir /.snapshots

# Remount our @snapshots subvolume
mount -a

# Configure snapper
cat > /etc/snapper/configs/root << EOF
# subvolume to snapshot
SUBVOLUME="/"

# filesystem type
FSTYPE="btrfs"

# btrfs qgroup for space aware cleanup algorithms
QGROUP=""

# fraction or absolute size of the filesystems space the snapshots may use
SPACE_LIMIT="0.5"

# fraction or absolute size of the filesystems space that should be free
FREE_LIMIT="0.2"

# users and groups allowed to work with config
ALLOW_USERS=""
ALLOW_GROUPS=""

# sync users and groups from ALLOW_USERS and ALLOW_GROUPS to .snapshots
# directory
SYNC_ACL="no"

# start comparing pre- and post-snapshot in background after creating
# post-snapshot
BACKGROUND_COMPARISON="yes"

# run daily number cleanup
NUMBER_CLEANUP="yes"

# limit for number cleanup
NUMBER_MIN_AGE="1800"
NUMBER_LIMIT="50"
NUMBER_LIMIT_IMPORTANT="10"

# create hourly snapshots
TIMELINE_CREATE="yes"

# cleanup hourly snapshots after some time
TIMELINE_CLEANUP="yes"

# limits for timeline cleanup
TIMELINE_MIN_AGE="1800"
TIMELINE_LIMIT_HOURLY="10"
TIMELINE_LIMIT_DAILY="10"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="10"
TIMELINE_LIMIT_YEARLY="10"

# cleanup empty pre-post-pairs
EMPTY_PRE_POST_CLEANUP="yes"

# limits for empty pre-post-pair cleanup
EMPTY_PRE_POST_MIN_AGE="1800"
EOF

# Enable snapper timers
systemctl enable snapper-timeline.timer
systemctl enable snapper-cleanup.timer

# Configure snap-pac for automatic snapshots on pacman operations
mkdir -p /etc/pacman.d/hooks
cat > /etc/pacman.d/hooks/50-bootbackup.hook << 'EOF'
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Path
Target = usr/lib/modules/*/vmlinuz

[Action]
Depends = rsync
Description = Backing up /boot...
When = PreTransaction
Exec = /usr/bin/rsync -a --delete /boot /.bootbackup
EOF