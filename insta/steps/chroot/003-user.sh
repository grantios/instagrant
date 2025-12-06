#!/usr/bin/env bash
set -euo pipefail

# Source common configuration
source "$(dirname "$0")/../../utils/common.sh"

# Arch Linux Chroot User Script
# Creating default user

gum style --border normal --padding "0 1" --border-foreground 34 "Step 3/14: Creating Default User"

gum style --border normal --padding "0 1" --border-foreground '#800080' "Stage 1/1: Creating default user '${USERNAME}'..."

# Create user
log_info "Creating user ${USERNAME} with home ${HOMEDIR}"
mkdir -p "${HOMEDIR}"
useradd -d "${HOMEDIR}" -G wheel,audio,video,optical,storage,power -s /usr/bin/zsh "${USERNAME}"
chown -R "${USERNAME}:${USERNAME}" "${HOMEDIR}"

# Set default password
gum style --foreground 226 "Setting default password for user '${USERNAME}' to: ${PASSWORD}"
echo "${USERNAME}:${PASSWORD}" | chpasswd
gum style --foreground 196 --bold "IMPORTANT: Change this password after first login! Run: passwd"

# Set root password
log_info "Setting default password for root to: ${PASSROOT}"
echo "root:${PASSROOT}" | chpasswd
gum style --foreground 196 --bold "IMPORTANT: Change the root password after installation! Run: passwd"

# Setup room directory permissions
log_info "Setting ownership of /room to ${USERNAME}"
chown -R "${USERNAME}:${USERNAME}" /room
chmod 755 /room

# Configure sudo
log_info "Configuring sudo"
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

# Setup XDG Base Directory for root
log_info "Setting up XDG Base Directory for root"
mkdir -p /root/.local/{cache,config,share,share/Trash,state,mount}
ln -sf /root/.local/config /root/.config
ln -sf /root/.local/cache /root/.cache
ln -sf /root/.local/share/Trash /root/.trash
ln -sf /root/.local/state /root/.state
ln -sf /root/.local/mount /root/.mount
# Symlinks for mount
ln -sf /mnt /root/.local/mount/mnt
ln -sf /run/media /root/.local/mount/auto

# Setup XDG Base Directory for user
log_info "Setting up XDG Base Directory for ${USERNAME}"
su - "${USERNAME}" -c "
mkdir -p ~/.local/{cache,config,share,share/Trash,state,mount}
ln -sf ~/.local/config ~/.config
ln -sf ~/.local/cache ~/.cache
ln -sf ~/.local/share/Trash ~/.trash
ln -sf ~/.local/state ~/.state
ln -sf ~/.local/mount ~/.mount
# Symlinks for mount
ln -sf /mnt ~/.local/mount/mnt
ln -sf /run/media ~/.local/mount/auto
"

# Install oh-my-zsh for root
log_info "Installing oh-my-zsh for root"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
mv /root/.oh-my-zsh /root/.ohmy
sed -i 's|export ZSH="$HOME/.oh-my-zsh"|export ZSH="$HOME/.ohmy"|' /root/.zshrc
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="avit"/' /root/.zshrc

# Set root shell to zsh
log_info "Setting root shell to zsh"
chsh -s /usr/bin/zsh

# Install oh-my-zsh for user
log_info "Installing oh-my-zsh for ${USERNAME}"
su - "${USERNAME}" -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
su - "${USERNAME}" -c 'mv ~/.oh-my-zsh ~/.ohmy'
su - "${USERNAME}" -c 'sed -i "s|export ZSH=\"\$HOME/.oh-my-zsh\"|export ZSH=\"\$HOME/.ohmy\"|" ~/.zshrc'
su - "${USERNAME}" -c 'sed -i "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"candy\"/" ~/.zshrc'

# Set user shell to zsh
log_info "Setting ${USERNAME} shell to zsh"
chsh -s /usr/bin/zsh "${USERNAME}"