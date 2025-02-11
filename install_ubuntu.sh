#!/bin/bash
set -euo pipefail

# install optional, e.g. ripgrep, zoxide
OPTIONAL=${OPTIONAL:-yes}
DOTF=${DOTF:-yes}

# source: https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh

# The [ -t 1 ] check only works when the function is not called from
# a subshell (like in `$(...)` or `(...)`, so this hack redefines the
# function at the top level to always return false when stdout is not
# a tty.
if [ -t 1 ]; then
  is_tty() {
    true
  }
else
  is_tty() {
    false
  }
fi

setup_color() {
  # Only use colors if connected to a terminal
  if ! is_tty; then
    FMT_RAINBOW=""
    FMT_RED=""
    FMT_GREEN=""
    FMT_YELLOW=""
    FMT_BLUE=""
    FMT_BOLD=""
    FMT_RESET=""
    return
  fi

  FMT_RED=$(printf '\033[31m')
  FMT_GREEN=$(printf '\033[32m')
  FMT_YELLOW=$(printf '\033[33m')
  FMT_BLUE=$(printf '\033[34m')
  FMT_BOLD=$(printf '\033[1m')
  FMT_RESET=$(printf '\033[0m')

}

print_step() {
  echo "${FMT_BOLD}${FMT_YELLOW}--> ${FMT_RESET}${FMT_BOLD} $1${FMT_RESET}"
}

print_warning() {
  echo "${FMT_GREEN}[!] $1${FMT_RESET} "
}

install_awscli() {
  if ! command -v aws >/dev/null; then
    print_step "Installing aws cli"
    cd /tmp/
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip && sudo ./aws/install
  else
    print_warning "Skipping awscli, already installed"
    return
  fi
}

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

install_fzf() {
  print_step "Installing fzf"
  if ! command -v fzf >/dev/null; then
    rm -rf /tmp/.fzf
    cd /tmp

    git clone -q --depth 1 https://github.com/junegunn/fzf.git /tmp/.fzf
    /tmp/.fzf/install --all --xdg --no-fish
  else
    print_warning "Skipping, fzf already installed"
  fi
}

install_fd() {
  if [ "$OPTIONAL" = no ]; then
    return
  fi
  print_step "Installing fd-find"

  if command -v fd >/dev/null; then
    print_warning "fd-find has already been installed, skipping"
    return
  fi

  FDFIND_VERSION=$(curl -s "https://api.github.com/repos/sharkdp/fd/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
  echo "FD version: ${FDFIND_VERSION}"

  cd /tmp
  curl -Lo fdfind.deb "https://github.com/sharkdp/fd/releases/download/v${FDFIND_VERSION}/fd-musl_${FDFIND_VERSION}_amd64.deb"

  if [ ! -f fdfind.deb ]; then
    print_warning "Failed to download fd-find .deb file"
    return
  fi

  sudo apt install -y ./fdfind.deb
  ln -s $(command -v fdfind) ~/.local/bin/fd

  fd --version
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
  curl -Lo ripgrep_amd64.deb "https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep_${RIPGREP_VERSION}_amd64.deb"

  sudo dpkg -i ./ripgrep_amd64.deb

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
  if [ "$OPTIONAL" = no ]; then
    return
  fi

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
  if [[ "$OPTIONAL" = no ]]; then
    return
  fi

  print_step "Configuring neovim with LazyVim config"
  if command -v nvim >/dev/null 2>&1 &&
    ! [[ -d $HOME/.config/nvim ]]; then
    print_warning "Skipping nvim configuration with LazyVim"
    return
  fi

  mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null || true
  mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null || true

  git clone https://github.com/LazyVim/starter ~/.config/nvim

  rm -rf ~/.config/nvim/.git
}

config_dotfiles() {
  print_step "Configuring dotfiles"
  if [[ $"DOTF" = no ]]; then
    echo "Skipping dotfiles setup as disabled step"
    return
  fi

  export DOTFILES=$HOME/.dotfiles
  if [[ -d $DOTFILES ]]; then
    print_warning "Dotfiles already exist"
  else
    echo "Clonning dotfiles github repo"
    git clone git@github.com:nikitajz/dotfiles.git $DOTFILES
  fi

  if [[ ! -d $DOTFILES ]]; then
    print_warning "Dotfiles do not exist"
    return
  fi

  if [[ ! -f $HOME/.p10k.zsh ]]; then
    ln -s $DOTFILES/.p10k.zsh $HOME/.p10k.zsh
  else
    print_warning ".p10k.zsh already linked"
  fi

  if [[ ! -f $HOME/.gitignore_global ]]; then
    ln -s $DOTFILES/gitignore_global $HOME/.gitignore_global
  else
    print_warning ".gitignore_global already linked"
  fi

  echo "Linking dotfiles"
  # Backup previous .zshrc config and use one from the repo
  if [[ -f $HOME/.zshrc ]] && [[ ! -L $HOME/.zshrc ]]; then
    echo "Backing up existing .zshrc file to .zshrc_old"
    mv $HOME/.zshrc $HOME/.zshrc_old
  elif [[ -L $HOME/.zshrc ]]; then
    print_warning ".zshrc already symlinked, skipping"
    return
  fi

  ln -s $DOTFILES/.zshrc $HOME/.zshrc
  echo "Symlinked .zshrc"
}

main() {
  setup_color

  # Parse arguments
  while [ $# -gt 0 ]; do
    case $1 in
    --optional) OPTIONAL=yes ;;
    --dotfiles) DOTF=yes ;;
    esac
    shift
  done

  echo "Setting up your Ubuntu machine"

  print_step "Installing the packages"
  sudo apt-get update -q
  sudo apt-get install -y python3-dev unzip

  setup_shell

  install_awscli
  install_jq
  install_fzf
  install_fd
  install_ripgrep
  install_zoxide
  install_aliastips
  install_nvim
  config_lazyvim

  config_dotfiles
}

main

print_step "Setup successfully completed!"
