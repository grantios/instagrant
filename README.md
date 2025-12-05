# INSTAGRANT

INSTAGRANT is a collection of modular install x setup scripts to be run on an ArchLinux LiveUSB for an opinionated install of arguable 'best practices'. It features root on a Btrfs filesystem + Snapper based rollbacks, Linux-lts kernel, and using systemd-boot. It provides a semi-declarative configuation system to setup your user, and packages. It's a fully automated script but with manual intervention to redo from a given step if needed, making it easy (enough) to deploy. [GrantsForm](https://github.com/grantsform) is trying to daily-drive this. And he doesn't really suggest anyone use this for anything at this point, this is more proof-of-concept... though it "mostly works" lol.

> The name is a bad pun on 'instagram' ya know, because it's a place to save your snapshots. lol

## Key Features

- **Automated Install**: Complete opinionated ArchLinux setup from partitioning to desktop environment
- **Btrfs + Snapper**: Automatic filesystem snapshots and rollback capabilities
- **Modular Design**: Run individual steps for debugging or customization
- **Multiple Desktop Support**: KDE Plasma, Hyprland, or minimal setups
- **GPU Driver Detection**: Automatic installation of appropriate graphics drivers
- **Comprehensive Logging**: Color-coded output with progress indicators. And generates a debug.log

## Getting Started

For detailed installation instructions, see [GUIDE.md](GUIDE.md).

## Quick Install

```bash
git clone https://github.com/grantios/instagram.git && cd instagram
DISK=/dev/sda ./insta/run.sh
```

## Requirements

- Arch Linux live USB
- Decent internet connection
- Target disk with at least 165GB space

## License

See [LICENSE.txt](LICENSE.txt) for details.
