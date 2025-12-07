# Configuration Bundles

This directory contains shared configuration bundles that can be sourced by multiple configuration files to avoid duplication.

## Available Bundles

### station.sh
Contains common packages, AUR packages, and services shared between workstation variants like:
- `workstation.sh` (Plasma-based)
- `devestation.sh` (Hyprland-based)

**Includes:**
- Multimedia and creative tools (VLC, Blender, Krita, OBS Studio, etc.)
- Development tools (programming languages, compilers, IDEs)
- Browsers and communication apps
- Audio tools (PipeWire, EasyEffects)
- AUR packages (VS Code, gaming tools, etc.)
- Services (Syncthing)

### hypr.sh
Contains common packages for Hyprland desktop environments.

**Includes:**
- Hyprland compositor and Wayland essentials
- Terminal (Kitty), launcher (Wofi), notifications (Dunst)
- Screenshots and screen locking tools
- Qt Wayland support and desktop portals

Used by configurations with `DESKTOP="hyprland"`:
- `devestation.sh`
- `mediacenter.sh`
- `smartclock.sh`
- `steamdeck.sh`

## Usage

To use a bundle in a configuration file, add this line in the packages section:

```bash
# Source the bundle
source "$INSTA_TOPLVL/insta/confs/bundles/bundle.sh"
```

Then add only the configuration-specific packages after sourcing the bundle.

## Benefits

- **DRY Principle**: Don't Repeat Yourself - shared packages are defined once
- **Maintainability**: Updates to common packages only need to be made in one place
- **Consistency**: Ensures all workstation variants have the same base packages
- **Flexibility**: Each configuration can still add its own specific packages


## Known Issues.
- Legacy Boot via CSM (Basically) Doesn't Work Yet.
- Not nearly as modular as I want. 
  - (I want to make a libtios to do basic operations ultimately)
