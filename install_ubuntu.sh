#!/bin/bash
set -euo pipefail

# install optional, e.g. ripgrep, zoxide
OPTIONAL=${OPTIONAL:-yes}
DOTF=${DOTF:-yes}
NVIDIA=${NVIDIA:-no}
NVIDIA_VERSION=${NVIDIA_VERSION:-550}

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
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --keep-zshrc
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
  echo "ripgrep version: $RIPGREP_VERSION"

  cd /tmp

  curl -LO https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep_${RIPGREP_VERSION}-1_amd64.deb
  sudo dpkg -i ripgrep_${RIPGREP_VERSION}-1_amd64.deb

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

  git clone --depth 1 https://github.com/reegnz/jq-zsh-plugin.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/jq
}

install_nvtop() {
  if [ "$OPTIONAL" = no ]; then
    return
  fi
  print_step "Installing nvtop"

  if command -v nvtop >/dev/null; then
    print_warning "nvtop has already been installed, skipping"
    return
  fi

  sudo apt install -y nvtop
}

install_uv() {
  if [ "$OPTIONAL" = no ]; then
    return
  fi
  print_step "Installing uv"

  if command -v uv >/dev/null; then
    print_warning "uv has already been installed, skipping"
    return
  fi

  curl -LsSf https://astral.sh/uv/install.sh | sh
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
  git clone --depth 1 https://github.com/djui/alias-tips.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/alias-tips
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

  git clone --depth 1 https://github.com/neovim/neovim

  cd neovim

  git checkout stable

  make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$HOME/.local/bin

  # build DEB
  cd build && cpack -G DEB && sudo dpkg -i nvim-linux-x86_64.deb
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

  git clone --depth 1 https://github.com/LazyVim/starter ~/.config/nvim

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
    git clone --depth 1 git@github.com:nikitajz/dotfiles.git $DOTFILES
  fi

  if [[ ! -d $DOTFILES ]]; then
    print_warning "Dotfiles do not exist"
    return
  fi

  # Helper function to create symlink with checks
  link_file() {
    local src=$1
    local dest=$2

    if [[ -L "$dest" ]]; then
      print_warning "$(basename $dest) already linked, skipping"
      return
    fi

    if [[ -f "$dest" ]]; then
      echo "Backing up existing $(basename $dest) to $(basename $dest)_old"
      mv "$dest" "${dest}_old"
    fi

    ln -s "$src" "$dest"
    echo "Symlinked $(basename $dest)"
  }

  # Link each dotfile using the helper function
  link_file "$DOTFILES/.p10k.zsh" "$HOME/.p10k.zsh"
  link_file "$DOTFILES/gitignore_global" "$HOME/.gitignore_global"
  link_file "$DOTFILES/.zshrc" "$HOME/.zshrc"
}

install_nvidia() {
  if [ "$NVIDIA" = no ]; then
    return
  fi
  print_step "Installing NVIDIA drivers"

  if dpkg -l | grep -q nvidia-driver; then
    print_warning "NVIDIA drivers already installed, skipping"
    return
  fi

  print_step "Installing NVIDIA driver version ${NVIDIA_VERSION}"
  sudo apt install -y nvidia-driver-${NVIDIA_VERSION}
}

main() {
  setup_color

  # Parse arguments
  while [ $# -gt 0 ]; do
    case $1 in
    --optional) OPTIONAL=yes ;;
    --dotfiles) DOTF=yes ;;
    --nvidia) NVIDIA=yes ;;
    --nvidia-version=*) NVIDIA_VERSION="${1#*=}" ;;
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
  install_nvtop
  install_uv
  install_nvim
  config_lazyvim
  install_nvidia

  config_dotfiles
}

main

print_step "Setup successfully completed!"
