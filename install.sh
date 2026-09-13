#!/usr/bin/env bash
#
# Reproduce this machine on a fresh Omarchy install.
#
# Assumes Omarchy Quattro is already installed. Installs the extras on top,
# deploys the system-level lid config, enables services, and stows the
# dotfiles.
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
if ! command -v omarchy &>/dev/null; then
  echo "The Omarchy CLI is required. Install Omarchy first." >&2
  exit 1
fi

if ! command -v stow &>/dev/null; then
  log "Installing GNU stow"
  omarchy pkg add stow
fi

# ------------------------------------------------------------- pacman extras
# Packages beyond the Omarchy base. Keep in sync with the output of:
#   comm -23 <(pacman -Qqe | sort) \
#     <(cat /usr/share/omarchy/install/omarchy-*.packages \
#        | grep -v '^#' | grep -v '^$' | sort -u)
PACMAN_EXTRAS=(
  # media
  audacity qbittorrent
  # browsers
  firefox torbrowser-launcher
  # terminals / editors
  ghostty neovim wl-clipboard
  # dev toolchains
  go rust-src opencode yq
  nodejs npm
  # runtimes / daemons
  flatpak fwupd hypridle tailscale
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
omarchy pkg add "${PACMAN_EXTRAS[@]}"

# ----------------------------------------------------------------- AUR extras
AUR_EXTRAS=(
  zen-browser-bin
  plex-media-server
  snapd
  stripe-cli
)

log "Installing AUR extras (${#AUR_EXTRAS[@]} packages)"
omarchy pkg aur add "${AUR_EXTRAS[@]}"

# ----------------------------------------------------------- system/ deploy
# /etc/ files that aren't stow-managed (stow targets $HOME).
log "Deploying system config files to /etc"
while IFS= read -r -d '' src; do
  dest="/${src#system/}"
  echo "  $src -> $dest"
  sudo install -D -m 644 "$src" "$dest"
done < <(find system -type f -print0)

# The Plex bar widget needs a narrowly authorized root helper to toggle the
# system service without prompting on every click.
PLEX_PLUGIN_DIR="$REPO_DIR/omarchy/.config/omarchy/plugins/pepw.plex"
sudo install -D -m 755 "$PLEX_PLUGIN_DIR/plex-service-toggle" /usr/local/bin/plex-service-toggle
sudo install -D -m 644 "$PLEX_PLUGIN_DIR/49-plex-service-toggle.rules" /etc/polkit-1/rules.d/49-plex-service-toggle.rules

log "Reloading systemd"
sudo systemctl daemon-reload

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
  bash bin ghostty hypr kitty nvim omarchy systemd zen
)

BACKUP_SUFFIX="$(date +%Y%m%d%H%M%S)"

backup_stow_conflict() {
  local package="$1"
  local relative="$2"
  local source="$REPO_DIR/$package/$relative"
  local target="$HOME/$relative"

  if [[ -L "$target" && "$(readlink -f "$target")" == "$source" ]]; then
    # GNU Stow does not adopt absolute links, even when they already point at
    # the right file. Remove only that exact link so it can create its normal
    # relative one below.
    unlink "$target"
  elif [[ -e "$target" || -L "$target" ]]; then
    local backup="${target}.bak.${BACKUP_SUFFIX}"
    log "Backing up generated config $target to $backup"
    mv "$target" "$backup"
  fi
}

for hypr_file in autostart.lua bindings.lua hyprland.lua input.lua looknfeel.lua monitors.lua hypridle-kbd.conf; do
  backup_stow_conflict hypr ".config/hypr/$hypr_file"
done
backup_stow_conflict omarchy ".config/omarchy/shell.json"

NVIM_TARGET="$HOME/.config/nvim"
NVIM_SOURCE="$REPO_DIR/nvim/.config/nvim"
if [[ ( -e "$NVIM_TARGET" || -L "$NVIM_TARGET" ) && "$(readlink -f "$NVIM_TARGET")" != "$NVIM_SOURCE" ]]; then
  NVIM_BACKUP="${NVIM_TARGET}.bak.${BACKUP_SUFFIX}"
  log "Backing up existing Neovim config to $NVIM_BACKUP"
  mv "$NVIM_TARGET" "$NVIM_BACKUP"
fi

log "Stowing dotfiles (${STOW_PACKAGES[*]})"
# -R restows (removes dead links first). Fails loudly on conflicts — user
# should resolve manually rather than being clobbered by --adopt.
stow -v -R -t "$HOME" "${STOW_PACKAGES[@]}"

systemctl --user daemon-reload
systemctl --user enable --now hypridle-suspend.service || warn "hypridle-suspend enable failed"

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
  * Restart hypridle   : pkill -f 'hypridle -c .*/hypridle-kbd.conf'; hyprctl reload
  * Restart the shell  : omarchy restart shell
  * Log out / in       : to pick up stowed bash / env changes
  * Verify lid handling: close lid with / without external monitor
  * Verify power switch: powerprofilesctl get  (unplug, plug in)
  * Open nvim          : Mason should auto-install LSP servers
EOF
