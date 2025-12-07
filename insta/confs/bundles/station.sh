# Station Bundle - Shared packages for workstation variants
# This bundle contains common packages, AUR packages, and services
# shared between different workstation configurations

# Multimedia and creative tools
EXTRA_PACKAGES+=(
    "vlc" "streamlink" "yt-dlp" "mpv" "mpd"
    "steam" "godot" "blender"
    "krita" "kdenlive"
    "obs-studio"
    "obsidian" "libreoffice"
    "blender" "lmms" "audacity" "musescore"
)

# Fonts and themes
EXTRA_PACKAGES+=(
    "papirus-icon-theme" "noto-fonts" "noto-fonts-emoji"
)

# Audio
EXTRA_PACKAGES+=(
    "easyeffects" "pipewire" "pipewire-alsa" "pipewire-pulse"
)

# Browsers and communication
EXTRA_PACKAGES+=(
    "chromium" "firefox" "thunderbird" "signal-desktop" "element-desktop"
)

# Development tools
EXTRA_PACKAGES+=(
    "raylib" "sdl2" "sdl2_net" "sdl2_image" "sdl2_mixer" "sdl2_ttf"
    "qemu-full" "llvm" "lldb" "clang" "cmake" "meson" "ninja" "sbcl" "roswell" "racket" "fennel"
)

# AUR packages
AUR_PACKAGES+=(
    "papirus-folders-git" "bazaar"
    "visual-studio-code-bin" "chez-scheme" "chibi-scheme"
    "onlyoffice-bin" "planify" "notesnook-bin" "electronmail-bin" "steamlink"
    "vesktop-bin" "chatterino2-bin"
    "blockbench-bin" "sidequest-bin"
)

# Services
SERVICES+=" syncthing@${USERNAME}.service"