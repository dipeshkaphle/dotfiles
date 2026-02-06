#!/bin/bash
set -e

# Install Nix packages
echo "Installing Nix packages..."
nix-env -iA nixpkgs.myPackages
echo "Nix packages done."

# Fisher (Fish plugin manager)
echo "Installing Fisher..."
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
echo "Fisher done."

# TPM (Tmux Plugin Manager)
if [ ! -d ~/.tmux/plugins/tpm ]; then
    echo "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "TPM done."
else
    echo "TPM already installed."
fi

# Set Fish as default shell
FISH_PATH=$(which fish)
if ! grep -qF "$FISH_PATH" /etc/shells; then
    echo "Adding Fish to /etc/shells (requires sudo)..."
    echo "$FISH_PATH" | sudo tee -a /etc/shells
fi
if [ "$SHELL" != "$FISH_PATH" ]; then
    echo "Setting Fish as default shell..."
    chsh -s "$FISH_PATH"
    echo "Default shell changed to Fish."
else
    echo "Fish is already the default shell."
fi

echo "All done!"
