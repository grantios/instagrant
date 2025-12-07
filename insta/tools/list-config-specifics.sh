#!/bin/bash

# Test script to show package loading order for configurations

# Set project top level directory
INSTA_TOPLVL="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Handle --config-list option
if [[ "${1:-}" == "--config-list" ]]; then
    echo "Available configuration files in $INSTA_TOPLVL/insta/confs/:"
    echo ""
    for config in "$INSTA_TOPLVL/insta/confs/"*.sh; do
        if [[ -f "$config" && "$(basename "$config")" != "default.sh" ]]; then
            config_name=$(basename "$config" .sh)
            echo "  $config_name"
        fi
    done
    echo ""
    echo "Use --config <name> to test a specific configuration."
    exit 0
fi

# Parse --config option
CONFIG_NAME="devestation"
if [[ "${1:-}" == "--config" && -n "${2:-}" ]]; then
    CONFIG_NAME="$2"
    shift 2
fi

echo "=== TESTING PACKAGE LOADING FOR: $CONFIG_NAME ==="
echo

# Check if config file exists
CONFIG_FILE="$INSTA_TOPLVL/insta/confs/${CONFIG_NAME}.sh"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Configuration file '$CONFIG_FILE' not found."
    echo ""
    echo "Available configurations:"
    for config in "$INSTA_TOPLVL/insta/confs/"*.sh; do
        if [[ -f "$config" && "$(basename "$config")" != "default.sh" ]]; then
            config_name=$(basename "$config" .sh)
            echo "  $config_name"
        fi
    done
    exit 1
fi

# Reset arrays
unset EXTRA_PACKAGES
unset AUR_PACKAGES
unset SERVICES

echo "1. Loading default.sh..."
source "$INSTA_TOPLVL/insta/confs/default.sh"
echo "   EXTRA_PACKAGES: ${#EXTRA_PACKAGES[@]} items"
echo "   AUR_PACKAGES: ${#AUR_PACKAGES[@]} items"
echo "   SERVICES: $SERVICES"
echo

echo "2. Loading station.sh bundle..."
source "$INSTA_TOPLVL/insta/confs/bundles/station.sh"
echo "   EXTRA_PACKAGES: ${#EXTRA_PACKAGES[@]} items"
echo "   AUR_PACKAGES: ${#AUR_PACKAGES[@]} items"
echo "   SERVICES: $SERVICES"
echo

echo "3. Loading ${CONFIG_NAME}.sh..."
source "$CONFIG_FILE"
echo "   EXTRA_PACKAGES: ${#EXTRA_PACKAGES[@]} items"
echo "   AUR_PACKAGES: ${#AUR_PACKAGES[@]} items"
echo "   SERVICES: $SERVICES"
echo

echo "=== FINAL PACKAGE COUNTS ==="
echo "EXTRA_PACKAGES: ${#EXTRA_PACKAGES[@]} total"
echo "AUR_PACKAGES: ${#AUR_PACKAGES[@]} total"
echo "SERVICES: $SERVICES"
echo

echo "=== ALL EXTRA_PACKAGES ==="
printf '%s\n' "${EXTRA_PACKAGES[@]}"
echo

echo "=== ALL AUR_PACKAGES ==="
printf '%s\n' "${AUR_PACKAGES[@]}"
echo

echo "=== SERVICES ==="
echo "$SERVICES"