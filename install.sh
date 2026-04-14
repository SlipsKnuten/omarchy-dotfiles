#!/usr/bin/env bash
#
# Reproduce this machine on a fresh Omarchy install.
#
# Assumes Omarchy is already installed (Hyprland, Waybar, yay, etc. provided
# by Omarchy base). Installs the extras on top, deploys system-level power /
# lid configs, enables services, and stows the dotfiles.
#
# Usage:
#   cd ~/omarchy-dotfiles && ./install.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

log() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\n\033[1;33m[warn]\033[0m %s\n' "$*" >&2; }

# ---------------------------------------------------------------- prerequisites
log "Checking prerequisites"
if ! command -v omarchy-version &>/dev/null; then
  warn "omarchy-version not found — this script is written for Omarchy."
  warn "Continuing anyway; some services / paths may not exist."
fi

if ! command -v yay &>/dev/null; then
  echo "yay is required but not installed. Install Omarchy first." >&2
  exit 1
fi

if ! command -v stow &>/dev/null; then
  log "Installing GNU stow"
  sudo pacman -S --needed --noconfirm stow
fi

# ------------------------------------------------------------- pacman extras
# Packages beyond the Omarchy base. Keep in sync with the output of:
#   comm -23 <(pacman -Qqe | sort) \
#     <(cat ~/.local/share/omarchy/install/omarchy-*.packages \
#        | grep -v '^#' | grep -v '^$' | sort -u)
PACMAN_EXTRAS=(
  # media
  audacity qbittorrent vlc vlc-plugin-ffmpeg
  # browsers
  firefox torbrowser-launcher
  # terminals / editors
  ghostty neovim
  # dev toolchains
  go rust-src opencode yq
  nodejs npm
  # runtimes / daemons
  flatpak fwupd tailscale
  # wine
  wine wine-gecko wine-mono
  # fonts
  noto-fonts-extra ttf-cascadia-mono-nerd
  # python tooling
  python-pip python-poetry
  # build / misc
  base-devel tmux
)

log "Installing pacman extras (${#PACMAN_EXTRAS[@]} packages)"
sudo pacman -S --needed --noconfirm "${PACMAN_EXTRAS[@]}"

# ----------------------------------------------------------------- AUR extras
AUR_EXTRAS=(
  zen-browser-bin
  plex-media-server
  snapd
  stripe-cli
  makima-bin
)

log "Installing AUR extras (${#AUR_EXTRAS[@]} packages)"
yay -S --needed --noconfirm "${AUR_EXTRAS[@]}"

# ----------------------------------------------------------- system/ deploy
# /etc/ files that aren't stow-managed (stow targets $HOME).
log "Deploying system config files to /etc"
while IFS= read -r -d '' src; do
  dest="/${src#system/}"
  echo "  $src -> $dest"
  sudo install -D -m 644 "$src" "$dest"
done < <(find system -type f -print0)

log "Reloading systemd + udev"
sudo systemctl daemon-reload
sudo udevadm control --reload-rules
sudo udevadm trigger

# ------------------------------------------------------------ enable services
log "Enabling services"
sudo systemctl enable --now power-profiles-daemon.service || warn "power-profiles-daemon enable failed"
if systemctl list-unit-files snapd.socket &>/dev/null; then
  sudo systemctl enable --now snapd.socket || warn "snapd.socket enable failed"
fi
if systemctl list-unit-files tailscaled.service &>/dev/null; then
  sudo systemctl enable --now tailscaled.service || warn "tailscaled enable failed"
fi

# -------------------------------------------------------------------- stow
STOW_PACKAGES=(
  bash bin git ghostty hypr kitty lazygit mise nvim starship systemd tmux waybar zen
)

log "Stowing dotfiles (${STOW_PACKAGES[*]})"
# -R restows (removes dead links first). Fails loudly on conflicts — user
# should resolve manually rather than being clobbered by --adopt.
stow -v -R -t "$HOME" "${STOW_PACKAGES[@]}"

# --------------------------------------------------------------- mise toolchains
if command -v mise &>/dev/null; then
  log "Installing mise-managed toolchains"
  mise install
fi

# ---------------------------------------------------------------- npm globals
# Use `mise exec` so this works even if the user's current shell hasn't
# picked up the mise PATH yet.
if command -v mise &>/dev/null; then
  log "Installing npm globals via mise"
  mise exec -- npm install -g typescript typescript-language-server
elif command -v npm &>/dev/null; then
  log "Installing npm globals via system npm"
  sudo npm install -g typescript typescript-language-server
fi

# ------------------------------------------------------------------- summary
cat <<EOF

Done.

Next steps:
  * Restart hypridle   : pkill hypridle; hyprctl reload
  * Log out / in       : to pick up stowed bash / env changes
  * Verify lid handling: close lid with / without external monitor
  * Verify power switch: powerprofilesctl get  (unplug, plug in)
  * Open nvim          : Mason should auto-install LSP servers
EOF
