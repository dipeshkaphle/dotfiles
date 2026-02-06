#!/bin/bash
set -e

# Symlinks (no dependencies, can run on a fresh machine)
echo "Setting up symlinks..."
mkdir -p ~/.config/fish
ln -sf ~/dotfiles/.vimrc ~/.vimrc
ln -sf ~/dotfiles/nvim ~/.config/nvim
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/.doom.d ~/.doom.d
ln -sf ~/dotfiles/ghostty ~/.config/ghostty
ln -sf ~/dotfiles/nixpkgs ~/.nixpkgs
ln -sf ~/dotfiles/config.fish ~/.config/fish/config.fish
echo "Symlinks done."

# Install Nix
if ! command -v nix-env &> /dev/null; then
    echo "Installing Nix..."
    sh <(curl -L https://nixos.org/nix/install)
    echo "Nix installed. Restart your terminal, then run: bash ~/dotfiles/post-install.sh"
    exit 0
else
    echo "Nix already installed."
fi

# If Nix is available, continue with post-install
bash ~/dotfiles/post-install.sh
