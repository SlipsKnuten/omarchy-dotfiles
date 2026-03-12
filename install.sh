#!/bin/bash
set -e

echo "=== Omarchy Dotfiles Setup ==="

# System utilities
echo "Installing system utilities..."
sudo pacman -S --needed --noconfirm stow socat base-devel

# Terminal emulators
echo "Installing terminal emulators..."
sudo pacman -S --needed --noconfirm ghostty kitty

# Desktop apps (official repos)
echo "Installing desktop apps..."
sudo pacman -S --needed --noconfirm nautilus firefox obsidian spotify lazydocker signal-desktop tmux

# Desktop apps (AUR)
echo "Installing AUR packages..."
yay -S --needed --noconfirm typora zen-browser-bin 1password tor-browser-bin openshift-client-bin

# Dev tools
echo "Installing dev tools..."
sudo pacman -S --needed --noconfirm python python-pip go

# Rust
if ! command -v rustc &> /dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Node.js via mise
if command -v mise &> /dev/null; then
    echo "Installing Node.js via mise..."
    mise install
fi

# npm global tools
if command -v npm &> /dev/null; then
    echo "Installing TypeScript globally..."
    npm install -g typescript typescript-language-server
fi

# Stow dotfiles
echo "Stowing dotfiles..."
cd "$(dirname "$0")"
stow --adopt -t ~ bash bin ghostty git hypr kitty lazygit mise nvim starship systemd tmux waybar zen 2>&1 || true

echo ""
echo "Done! Restart your shell or run: source ~/.bashrc"
echo "Then open nvim - Mason will auto-install LSP servers."
