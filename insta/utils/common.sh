# Common configuration and functions for Arch Linux installation scripts

# Set default kernel if not set
KERNEL=${KERNEL:-linux-lts}

# Base Packages For Install.
BASE_PACKAGES="base base-devel sudo just zsh tmux btop acpi fastfetch glow gum ${KERNEL} linux-firmware efibootmgr btrfs-progs xfsprogs networkmanager curl wget reflector restic rclone rsync syncthing openssh tailscale git-lfs git"

# Default package lists
DEFAULT_EXTRA_PACKAGES=("github-cli")
DEFAULT_AUR_PACKAGES=("chez-scheme" "chibi-scheme")
DEFAULT_SERVICES="NetworkManager fstrim.timer reflector.timer"

# Combine defaults with config additions
if [[ -z "${EXTRA_PACKAGES+x}" ]]; then
    EXTRA_PACKAGES=()
fi
if [[ -z "${AUR_PACKAGES+x}" ]]; then
    AUR_PACKAGES=()
fi
SERVICES=${SERVICES:-""}
EXTRA_PACKAGES=("${DEFAULT_EXTRA_PACKAGES[@]}" "${EXTRA_PACKAGES[@]}")
AUR_PACKAGES=("${DEFAULT_AUR_PACKAGES[@]}" "${AUR_PACKAGES[@]}")
SERVICES="$DEFAULT_SERVICES $SERVICES"

# Trim leading/trailing spaces for services
SERVICES=$(echo "$SERVICES" | sed 's/^ *//;s/ *$//')

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Install gum if not present
ensure_gum() {
    if ! command -v gum &> /dev/null; then
        log_info "Installing gum..."
        retry_pacman pacman --noconfirm -Sy gum
    fi
}

# Confirm action
confirm() {
    local message="$1"
    if [[ "${AUTO_CONFIRM}" == "true" ]]; then
        log_info "Auto-confirming: $message"
        return 0
    fi
    gum confirm "$message"
}

# Validate disk exists
validate_disk() {
    local disk="$1"
    if [[ ! -b "$disk" ]]; then
        log_error "Disk $disk does not exist or is not a block device"
        exit 1
    fi
    log_info "Validated disk: $disk"
}

# Ensure target directory exists
ensure_target_dir() {
    if [[ ! -d "$TARGET_DIR" ]]; then
        log_info "Creating target directory: $TARGET_DIR"
        mkdir -p "$TARGET_DIR"
    fi
    log_info "Target directory ready: $TARGET_DIR"
}

# Check if target disk is unmounted and has no active swap
check_disk_unmounted() {
    local disk="$1"
    log_info "Checking if $disk is fully unmounted..."
    
    # Stop multipath daemon if running (can cause device busy issues)
    log_info "Stopping multipath daemon if present..."
    systemctl stop multipathd 2>/dev/null || true
    
    # Remove all device mapper devices
    log_info "Removing device mapper devices..."
    dmsetup remove_all 2>/dev/null || true
    
    # Deactivate all swap first
    log_info "Deactivating all swap..."
    swapoff -a 2>/dev/null || true
    
    # Kill any processes using partitions on this disk
    log_info "Killing processes using partitions on $disk..."
    for part in $(lsblk -ln -o NAME "$disk" | grep -E "^${disk##*/}[0-9]+" | sed "s|^|/dev/|"); do
        fuser -k "$part" 2>/dev/null || true
        # Also kill any remaining processes with lsof
        for pid in $(lsof "$part" 2>/dev/null | awk 'NR>1 {print $2}' | sort -u); do
            kill -9 "$pid" 2>/dev/null || true
        done
    done
    
    # Check for mounted partitions on this disk
    local mounted_parts
    mounted_parts=$(mount | grep "^$disk" | awk '{print $1}' || true)
    
    if [[ -n "$mounted_parts" ]]; then
        log_warn "The following partitions from $disk are still mounted:"
        echo "$mounted_parts" | while read -r part; do
            echo "  - $part"
        done
        log_info "Force unmounting partitions..."
        
        # Try to unmount /mnt first if it's mounted
        if mountpoint -q ${TARGET_DIR}; then
            log_info "Force unmounting ${TARGET_DIR}..."
            umount -f ${TARGET_DIR} 2>/dev/null || umount -l ${TARGET_DIR} 2>/dev/null || log_error "Failed to unmount ${TARGET_DIR}"
        fi
        
        # Force unmount any remaining partitions from this disk
        echo "$mounted_parts" | while read -r part; do
            log_info "Force unmounting $part..."
            umount -f "$part" 2>/dev/null || umount -l "$part" 2>/dev/null || log_warn "Failed to unmount $part"
        done
    fi
    
    # Final check - make sure everything is clean
    mounted_parts=$(mount | grep "^$disk" | awk '{print $1}' || true)
    active_swap=$(swapon --show | grep "^$disk" | awk '{print $1}' || true)
    
    if [[ -n "$mounted_parts" ]] || [[ -n "$active_swap" ]]; then
        log_error "Failed to fully unmount/deactivate all partitions from $disk"
        log_error "Please manually unmount/deactivate and try again, or boot from live USB"
        log_error "Mounted partitions: $mounted_parts"
        log_error "Active swap: $active_swap"
        exit 1
    fi
    
    log_success "Disk $disk is fully unmounted and ready"
}

# Validate timezone
validate_timezone() {
    local tz="$1"
    if [[ ! -f "/usr/share/zoneinfo/$tz" ]]; then
        log_error "Timezone $tz does not exist"
        exit 1
    fi
}

# Retry pacman commands up to 3 times
retry_pacman() {
    local attempts=3
    local cmd="$*"
    for ((i=1; i<=attempts; i++)); do
        log_info "Attempt $i/$attempts: $cmd"
        if $cmd; then
            return 0
        else
            log_error "Attempt $i failed: $cmd"
            if [[ $i -lt $attempts ]]; then
                log_warn "Retrying in 5 seconds..."
                sleep 5
            fi
        fi
    done
    log_error "All attempts failed: $cmd"
    return 1
}

# Retry pacstrap commands up to 3 times
retry_pacstrap() {
    local attempts=3
    local cmd="$*"
    for ((i=1; i<=attempts; i++)); do
        log_info "Attempt $i/$attempts: $cmd"
        if $cmd; then
            return 0
        else
            log_error "Attempt $i failed: $cmd"
            if [[ $i -lt $attempts ]]; then
                log_warn "Retrying in 5 seconds..."
                sleep 5
            fi
        fi
    done
    log_error "All attempts failed: $cmd"
    return 1
}

# Detect GPU and return appropriate driver
detect_gpu_driver() {
    log_info "Detecting GPU..."

    # Check for NVIDIA
    if lspci | grep -i nvidia > /dev/null; then
        log_info "NVIDIA GPU detected"
        echo "nvidia"
        return
    fi

    # Check for AMD
    if lspci | grep -i amd > /dev/null || lspci | grep -i radeon > /dev/null; then
        log_info "AMD GPU detected"
        echo "amd"
        return
    fi

    # Check for Intel
    if lspci | grep -i intel > /dev/null; then
        log_info "Intel GPU detected"
        echo "intel"
        return
    fi

    log_info "No specific GPU detected, using modesetting"
    echo "modesetting"
}

# Install GPU drivers
install_gpu_driver() {
    local driver="$1"

    case "$driver" in
        nvidia)
            log_info "Installing NVIDIA drivers..."
            if [[ "$KERNEL" == "linux-lts" ]]; then
                retry_pacman pacman -S --noconfirm nvidia-lts nvidia-utils nvidia-settings nvtop cuda
            else
                retry_pacman pacman -S --noconfirm nvidia nvidia-utils nvidia-settings nvtop cuda
            fi
            ;;
        amd)
            log_info "Installing AMD drivers..."
            retry_pacman pacman -S --noconfirm mesa xf86-video-amdgpu
            ;;
        intel)
            log_info "Installing Intel drivers..."
            retry_pacman pacman -S --noconfirm mesa xf86-video-intel
            ;;
        modesetting)
            log_info "Using modesetting driver (no specific GPU driver needed)"
            ;;
        *)
            log_warn "Unknown GPU driver: $driver, skipping"
            ;;
    esac
}

# Show configuration summary
show_config() {
    echo "=========================================="
    echo "Configuration Summary"
    echo "=========================================="
    echo "Disk: $DISK"
    echo "Target Directory: $TARGET_DIR"
    echo "Timezone: $TIMEZONE"
    echo "Locale: $LOCALE"
    echo "Keymap: $KEYMAP"
    echo "Hostname: $HOSTNAME"
    echo "Username: $USERNAME"
    echo "Root Password: [HIDDEN]"
    echo "Kernel: $KERNEL"
    echo "Desktop: $DESKTOP"
    echo "GPU Driver: $GPU_DRIVER"
    echo "Auto-confirm: $AUTO_CONFIRM"
    
    if [[ -n "${EXTERNAL_DRIVES+x}" && ${#EXTERNAL_DRIVES[@]} -gt 0 ]]; then
        echo "External Drives:"
        for drive_config in "${EXTERNAL_DRIVES[@]}"; do
            IFS=':' read -r device label mountpoint filesystem <<< "$drive_config"
            echo "  - $device -> $mountpoint ($filesystem, label: $label)"
        done
    fi
    
    if [[ -n "${PRESERVE_DRIVES+x}" && ${#PRESERVE_DRIVES[@]} -gt 0 ]]; then
        echo "Preserve Drives (preserved):"
        for drive_config in "${PRESERVE_DRIVES[@]}"; do
            IFS=':' read -r device label mountpoint filesystem <<< "$drive_config"
            echo "  - $device -> $mountpoint ($filesystem, label: $label)"
        done
    fi
    
    echo "=========================================="
}

# Install desktop environment
install_desktop() {
    case "$DESKTOP" in
        plasma)
            log_info "Installing KDE Plasma desktop..."
            retry_pacman pacman -S --noconfirm plasma kde-applications plasma-x11-session sddm
            systemctl enable sddm
            systemctl start sddm
            ;;
        hyprland)
            log_info "Installing Hyprland desktop..."
            retry_pacman pacman -S --noconfirm hyprland sddm
            systemctl enable sddm
            systemctl start sddm
            ;;
        none)
            log_info "Skipping desktop installation"
            ;;
        *)
            log_warn "Unknown desktop: $DESKTOP, skipping"
            ;;
    esac
    
    # Set X11 keymap for SDDM and desktop
    if [[ "$DESKTOP" != "none" ]]; then
        log_info "Setting X11 keymap to $KEYMAP..."
        mkdir -p /etc/X11/xorg.conf.d
        cat > /etc/X11/xorg.conf.d/00-keyboard.conf << EOF
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "us"
    Option "XkbVariant" "$KEYMAP"
EndSection
EOF
    fi
}

# Validate installation
validate_installation() {
    log_info "Validating installation..."

    # Check if root is mounted
    if ! mountpoint -q ${TARGET_DIR}; then
        log_error "${TARGET_DIR} is not a mountpoint"
        return 1
    fi

    # Check if EFI partition exists
    if [[ ! -d "${TARGET_DIR}/boot" ]]; then
        log_error "${TARGET_DIR}/boot does not exist"
        return 1
    fi

    # Check if basic directories exist
    for dir in ${TARGET_DIR}/home ${TARGET_DIR}/.snapshots ${TARGET_DIR}/var/log; do
        if [[ ! -d "$dir" ]]; then
            log_error "$dir does not exist"
            return 1
        fi
    done

    log_success "Installation validation passed"
    return 0
}
