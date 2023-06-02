#!/bin/bash
set -euo pipefail

# install optional, e.g. ripgrep, zoxide
OPTIONAL=${OPTIONAL:-yes}

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_step() {
	echo -e "${BOLD}${YELLOW}--> ${NC}${BOLD} $1${NC}"
}

print_warning() {
	echo -e "${GREEN}[!] $1${NC} "
}

echo "Setting up your Ubuntu machine"
export DOTFILES=$HOME/.dotfiles

print_step "Installing the packages"
sudo apt-get update -q
sudo apt-get install -y python3-dev unzip

if ! command -v aws >/dev/null; then
	print_step "Installing aws cli"
	cd /tmp/
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip -q awscliv2.zip && sudo ./aws/install
fi

setup_shell() {
	# If this user's login shell is already "zsh", do not attempt to switch.
	if [ "$(basename -- "$SHELL")" = "zsh" ]; then
		return
	fi
	print_step "Installing zsh"
	sudo apt-get install -y zsh

	print_step "Installing oh-my-zsh"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_ripgrep() {
	if [ "$OPTIONAL" = no ]; then
		return
	fi
	print_step "Installing ripgrep"

	if command -v rg >/dev/null; then
		print_warning "ripgrep has already been installed, skipping"
		return
	fi

	RIPGREP_VERSION=$(curl -s "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" | grep -Po '"tag_name": "\K[0-9.]+')

	cd /tmp
	curl -Lo ripgrep.deb "https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep_${RIPGREP_VERSION}_amd64.deb"

	sudo apt install -y ./ripgrep.deb

	rg --version
}

install_zoxide() {
	if [ "$OPTIONAL" = no ]; then
		return
	fi

	if command -v z || command -v j >/dev/null; then
		print_warning "zoxide has already been installed, skipping"
		return
	fi

	print_step "Installing Zoxide"
	curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
}

install_jq() {
	if [ "$OPTIONAL" = no ]; then
		return
	fi
	print_step "Installing jq"

	if command -v jq >/dev/null; then
		print_warning "jq has already been installed, skipping"
		return
	fi

	sudo apt install -y jq

	git clone https://github.com/reegnz/jq-zsh-plugin.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/jq
}

install_aliastips() {
	if [ "$OPTIONAL" = no ]; then
		return
	fi

	if [ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/alias-tips ]; then
		print_warning "Alias-tips installed, skipping"
		return
	fi

	print_step "Installing alias-tips"
	git clone https://github.com/djui/alias-tips.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/alias-tips
}

install_nvim() {
	print_step "Installing nvim"
	if command -v nvim >/dev/null; then
		print_warning "nvim already installed, skipping"
		return
	fi

	sudo apt-get install -qy ninja-build gettext cmake unzip curl

	cd /tmp

	git clone https://github.com/neovim/neovim

	cd neovim

	git checkout stable

	make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$HOME/.local/bin

	# build DEB
	cd build && cpack -G DEB && sudo dpkg -i nvim-linux64.deb
}

config_lazyvim() {
	print_step "Configuring neovim with LazyVim config"
	if
		command -v nvim >/dev/null 2>&1 &&
			! [ -d $HOME/.config/nvim ]
	then
		print_warning "Skipping nvim configuration with LazyVim"
		return
	fi

	mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null || true
	mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null || true

	git clone https://github.com/LazyVim/starter ~/.config/nvim

	rm -rf ~/.config/nvim/.git
}

setup_shell

install_ripgrep
install_zoxide
install_jq
install_aliastips
install_nvim
config_lazyvim

echo "Setup completed"
