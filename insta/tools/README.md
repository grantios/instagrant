# Tools Directory

This directory contains utility scripts for testing and development of the instamatic installation system.

## list-config-specifics.sh

A script to list the package and service specifics for any configuration. It simulates the package sourcing process and displays:

- Package counts at each loading stage
- Final combined package lists
- Services to be enabled

### Usage:

```bash
# List specifics for default config (devestation)
./insta/tools/list-config-specifics.sh

# List specifics for specific config
./insta/tools/list-config-specifics.sh --config mediacenter

# List available configs
./insta/tools/list-config-specifics.sh --config-list
```

This helps verify that bundles are loaded correctly and packages are combined properly before running the actual installation.