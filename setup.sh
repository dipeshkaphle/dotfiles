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
ln -sf ~/dotfiles/fish_plugins ~/.config/fish/fish_plugins
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
mkdir -p ~/.claude
ln -sf ~/dotfiles/claude/statusline-command.sh ~/.claude/statusline-command.sh
ln -sf ~/dotfiles/claude/settings.json ~/.claude/settings.json
# Link centralized skills to Claude (Global Skills)
ln -sf ~/dotfiles/skills ~/.claude/skills

# Pi setup
mkdir -p ~/.pi
# Safety check: Back up existing local agent data before linking.
# 1. Checks if ~/.pi/agent exists (-d)
# 2. Checks if it is NOT already a symlink (! -L) (i.e., a real directory with data)
# 3. Checks if it is NOT already pointing to our dotfiles (prevents redundant backups)
if [ -d ~/.pi/agent ] && [ ! -L ~/.pi/agent ] && [ "$(realpath ~/.pi/agent)" != "$(realpath ~/dotfiles/pi/agent)" ]; then
    echo "Backing up existing ~/.pi/agent to ~/.pi/agent.bak"
    mv ~/.pi/agent ~/.pi/agent.bak
fi
ln -sf ~/dotfiles/pi/agent ~/.pi/agent

# Link centralized skills to Pi's agent folder
mkdir -p ~/dotfiles/pi/agent
ln -sf ~/dotfiles/skills ~/dotfiles/pi/agent/skills

# Link centralized skills to standard ~/.agents location (Opencode, Codex, Gemini)
mkdir -p ~/.agents
ln -sf ~/dotfiles/skills ~/.agents/skills

# Secrets file from template
if [ ! -f ~/dotfiles/secrets.fish ]; then
    echo "Creating secrets.fish from template..."
    cp ~/dotfiles/secrets.fish.template ~/dotfiles/secrets.fish
    echo "Fill in your API keys in ~/dotfiles/secrets.fish"
fi

# Make scripts executable
chmod +x ~/dotfiles/scripts/*.sh ~/dotfiles/scripts/*.fish 2>/dev/null

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

# Install Fisher and plugins if fish is available
if command -v fish &> /dev/null; then
    echo "Installing Fisher plugins..."
    fish -c "
        if not type -q fisher
            curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
        end
        fisher update
    "
    echo "Fisher plugins installed."
fi
