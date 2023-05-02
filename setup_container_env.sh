#!/bin/bash

function check_success() {
	if [ $? -ne 0 ]; then
		echo "ERROR: $1"
		exit 1
	fi
}

# Step 1
echo ">>> Setting up environment..."
SHELL_ENV="
# Add clangd to PATH.
export PATH=/opt/llvm-13.0_038/bin/:\$PATH

# AppImage launch settings.
export APPIMAGE_EXTRACT_AND_RUN=1

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

alias nvim='neovim'

# Add Cargo path.
. \"\$HOME/.cargo/env\"
"
echo "$SHELL_ENV" >>~/.bashrc
source ~/.bashrc

# Step 1
echo "
##############################################
>>> Installing ZAP package manager...
##############################################"
curl https://raw.githubusercontent.com/srevinsaju/zap/main/install.sh | bash -s
check_success "Fail to install ZAP package manager!"

# Step 2
echo "
##############################################
>>> Install NeoVim...
##############################################"
zap install --update --select-first --silent neovim
check_success "Fail to install NeoVim!"

# Step 3
echo "
##############################################
>>> Installing AstroNVim...
##############################################"
git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim
check_success "Fail to install AstroNVim!"

if [ -z $1 ]; then
	echo ">>> Skipping AstroNvim configuration. No user name provided."
else
	echo ">>> Configuring AstroNVim..."
	git clone https://github.com/$1/astronvim-config.git ~/.config/nvim/lua/user
	check_success "Fail to get AstroNvim configuration from user repository!"
fi

# Step 4
echo "
##############################################
>>> Installing Rust toolchain...
##############################################"
wget -O ~/rustup.sh https://sh.rustup.rs
check_success "Fail to download RustUp script!"

chmod +x ~/rustup.sh
check_success "Fail to change permissions of RustUp script!"
~/rustup.sh -qy
check_success "Fail to execute RustUp script!"
rm ~/rustup.sh
source "$HOME/.cargo/env"

# Step 5
echo "
##############################################
>>> Installing RipGrep...
##############################################"
cargo install ripgrep
check_success "Fail to install RipGrep!"

# Step 6
echo "
##############################################
>>> Installing exa...
##############################################"
cargo install exa
check_success "Fail to install exa!"

# Step 7
echo "
##############################################
>>> Installing Golang...
##############################################"
GOLANG_PAYLOAD="go1.20.3.linux-amd64.tar.gz"
GOLANG_URL="https://go.dev/dl/$GOLANG_PAYLOAD"
mkdir ~/Downloads
cd ~/Downloads
curl -O -L $GOLANG_URL
check_success "Fail to download Golang installer!"

tar -xf $GOLANG_PAYLOAD
mkdir -p ~/.local/bin
rm -rf ~/.local/bin/go
mv -vf go ~/.local/bin/
rm $GOLANG_PAYLOAD

# Step 8
echo "
##############################################
>>> Installing LazyGit...
##############################################"
go install github.com/jesseduffield/lazygit@latest
check_success "Fail to install LazyGit!"

# Step 9
echo "
##############################################
>>> Instaling scan-build...
##############################################"
pip install scan-build
check_success "Fail to install scan-build tool!"

# Step 10
echo "
##############################################
>>> Configuring oh-my-bash...
##############################################"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended
check_success "Fail to install oh-my-bash!"

sed -i '/OSH_THEME=*/c OSH_THEME=\"powerline-multiline\"' ~/.bashrc
check_success "Fail to change oh-my-bash theme!"

echo "$SHELL_ENV" >>~/.bashrc

echo "DONE!"
