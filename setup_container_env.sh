#!/bin/bash

# Step 1
echo ">>> Setting up environment..."
SHELL_ENV="
# Add clangd to PATH.
export PATH=/opt/llvm-13.0_038/bin/:\$PATH

# AppImage launch settings.
export APPIMAGE_EXTRACT_AND_RUN=1

# Add Cargo path.
. \"\$HOME/.cargo/env\"

# Add Golang paths.
export GOPATH=\$HOME/go
export PATH=~/.local/bin/go/bin:\$PATH

# Aliases.
alias ls='exa --icons'
alias la='exa --icons --all --long --git'
alias tr='exa --icons --tree'
alias trr='exa --icons --tree --level 1'
alias trrr='exa --icons --tree --level 2'
alias trrrr='exa --icons --tree --level 3'

alias nvim='neovim'"
echo "$SHELL_ENV" >>~/.bashrc

# Step 1
echo ">>> Installing ZAP package manager..."
curl https://raw.githubusercontent.com/srevinsaju/zap/main/install.sh | bash -s

# Step 2
echo ">>> Install NeoVim..."
zap install --update neovim

# Step 3
echo ">>> Installing AstroNVim..."
git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim

if [ -z $1 ]; then
	echo ">>> Skipping AstroNvim configuration. No user name provided."
else
	echo ">>> Configuring AstroNVim..."
	git clone https://github.com/$1/astronvim-config.git ~/.config/nvim/lua/user
fi

# Step 4
echo ">>> Installing Rust toolchain..."
wget -O rustup.sh https://sh.rustup.rs
chmod +x ./rustup.sh
./rustup.sh -qy
rm ./rustup.sh
source "$HOME/.cargo/env"

# Step 5
echo ">>> Installing RipGrep..."
cargo install ripgrep

# Step 6
echo ">>> Installing exa..."
cargo install exa

# Step 7
echo ">>> Installing Golang..."
GOLANG_PAYLOAD="go1.20.3.linux-amd64.tar.gz"
GOLANG_URL="https://go.dev/dl/$GOLANG_PAYLOAD"
mkdir ~/Downloads
cd ~/Downloads
curl -O -L $GOLANG_URL
tar -xf $GOLANG_PAYLOAD
mkdir -p ~/.local/bin
rm -rf ~/.local/bin/go
mv -vf go ~/.local/bin/
rm $GOLANG_PAYLOAD

# Step 8
echo ">>> Installing LazyGit..."
go install github.com/jesseduffield/lazygit@latest

# Step 9
echo ">>> Instaling scan-build..."
pip install scan-build

# Step 10
echo ">>> Configuring zsh..."
sudo yum install -y zsh
sh -c "RUNZSH='no' $(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "$SHELL_ENV" >>~/.zshrc

echo "DONE!"

# NOTICE: You probably should run:
# source ~/.bashrc
