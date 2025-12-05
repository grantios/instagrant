# GrantiOS Installation Guide

This guide provides detailed instructions for using the GrantiOS install scripts to set up Arch Linux with Btrfs, Snapper, and systemd-boot.

## Quick Start

### Option 1: Fully Automated
```bash
git clone https://github.com/grantios/instagram.git && cd instagram
DISK=/dev/sda ./insta/run.sh --config workstation
```

### Option 2: Manual Steps
```bash
git clone https://github.com/grantios/instagram.git && cd instagram
./insta/cmds/setup.sh --config workstation
arch-chroot /mnt
./insta/cmds/chroot.sh --config workstation
```

### Option 3: Individual Steps
```bash
./insta/steps/setup/001-drives.sh
./insta/steps/setup/002-mounts.sh
# ... etc
```

### Option 4: Rerun Specific Steps
```bash
./insta/cmds/setup.sh --redo-step 1     # Rerun drives partitioning only
./insta/cmds/setup.sh --redo-from 1     # Rerun from drives to end
./insta/cmds/chroot.sh --redo-step 3    # Rerun user creation only
./insta/cmds/chroot.sh --redo-from 3    # Rerun from user creation to end
```

## Configuration

Set environment variables to customize:

- `DISK` - Target disk (default: `/dev/sda`)
- `TIMEZONE` - Timezone (default: `America/Chicago`)
- `LOCALE` - System locale (default: `en_US.UTF-8`)
- `KEYMAP` - Console keymap (default: `us`)
- `HOSTNAME` - Hostname (default: prompt for input)
- `USERNAME` - User to create (default: `stein`)
- `PASSWORD` - Default user password (default: `change!`)
- `PASSROOT` - Default root password (default: `change!`)
- `KERNEL` - Kernel to install (default: `linux-lts`)
- `DESKTOP` - Desktop environment: `none`, `plasma`, `hyprland` (default: `plasma`)
- `GPU_DRIVER` - GPU driver: `auto`, `nvidia`, `amd`, `intel`, `modesetting` (default: `auto`)
- `AUTO_CHROOT_CONFIRM` - Skip chroot confirmation (default: `true`)

Example: `DISK=/dev/nvme0n1 TIMEZONE=Europe/London KERNEL=linux-zen DESKTOP=gnome ./insta/run.sh --config homeserver`

The `insta/confs/default.sh` file is loaded first (if it exists), providing base configuration that applies to all installations. Then the specified configuration file is loaded and **combined** with the defaults (packages, AUR packages, and services are merged rather than overwritten). Available configurations are:

- `workstation` - Full workstation with Plasma desktop and development packages
- `homeserver` - Server configuration with minimal desktop
- `mediacenter` - Kodi/Jellyfin media center with Hyprland
- `smartclock` - Rotated display configuration for smart clock
- `template` - Template for creating new configurations

Use `./insta/run.sh --config-list` to see all available configurations.

## External Drives

You can configure additional drives to be automatically formatted and mounted during installation. Edit `insta/confs/default.sh` or your specific config file and uncomment the `EXTERNAL_DRIVES` array:

```bash
export EXTERNAL_DRIVES=(
    "/dev/sdb1:data:/drv/data:xfs"
    "/dev/sdc1:backup:/mnt/backup:btrfs"
)
```

Each entry follows the format: `DEVICE:LABEL:MOUNTPOINT:FILESYSTEM`

Supported filesystems: `xfs`, `btrfs`, `ext4`

## Scripts

- `insta/run.sh` - Complete automated installation (requires --config)
- `insta/cmds/setup.sh` - Pre-chroot setup (partitioning, mounting, pacstrapping)
- `insta/cmds/chroot.sh` - In-chroot configuration
- `insta/steps/setup/` - Individual setup steps
- `insta/steps/chroot/` - Individual chroot steps
- `insta/utils/common.sh` - Shared configuration and utilities

## Skeleton System

The installation system uses a skeleton-based configuration approach:

- **`insta/skel/default/`** - Base skeleton files copied to ALL installations
- **`insta/skel/{config}/`** - Configuration-specific skeleton files (workstation, mediacenter, etc.)

Files are copied in order: default skeleton first, then config-specific skeleton (allowing overrides).

### Skeleton Structure:
- **@sys/** - Files copied to system root (/)
- **@root/** - Files copied to root user's home (/root/)
- **@user/** - Files copied to configured user's home

Post-installation script is available at `/tios/post.sh` on installed systems.

## Features

- **Modular Design**: Run individual steps for debugging
- **Configurable**: Customize via environment variables
- **Validation**: Checks disk, timezone, and installation integrity
- **Desktop Support**: Optional GNOME, KDE Plasma, or Xfce installation
- **Btrfs + Snapper**: Automatic snapshots and rollback support
- **systemd-boot**: Modern bootloader configuration
- **Yay AUR Helper**: Automatic installation and configuration
- **Comprehensive Logging**: Color-coded output with progress indicators

## Package Customization

Edit `insta/utils/common.sh` to modify package lists:
- `BASE_PACKAGES` - Core system packages
- `EXTRA_PACKAGES` - Additional utilities
- `SERVICES` - Services to enable

## Troubleshooting

If a step fails:
1. Check the error message
2. Fix the issue (edit script if needed)
3. Re-run the individual script: `./insta/steps/setup/001-drives.sh`
4. Or use the --redo-step flag: `./insta/cmds/setup.sh --redo-step 1` or `./insta/cmds/setup.sh --redo-step 01`
5. Or use --redo-from to continue: `./insta/cmds/setup.sh --redo-from 1`
6. Or restart from the main script

Use `./insta/cmds/setup.sh --help` or `./insta/cmds/chroot.sh --help` to see all steps.