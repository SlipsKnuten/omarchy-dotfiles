#!/bin/bash
set -e

echo "Installing dev tools..."

# tmux
echo "Installing tmux..."
sudo pacman -S --needed --noconfirm tmux

# Rust
if ! command -v rustc &> /dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Node.js via mise (already in dotfiles)
if command -v mise &> /dev/null; then
    echo "Installing Node.js via mise..."
    mise install
fi

# Python (usually pre-installed on Arch)
echo "Installing Python..."
sudo pacman -S --needed --noconfirm python python-pip

# npm global tools
if command -v npm &> /dev/null; then
    echo "Installing TypeScript globally..."
    npm install -g typescript typescript-language-server
fi

echo ""
echo "Done! Restart your shell or run: source ~/.bashrc"
echo "Then open nvim - Mason will auto-install LSP servers."
