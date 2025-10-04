#!/bin/bash
set -euo pipefail

if [ -f /etc/os-release ]; then
  . /etc/os-release
  if ! { [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ] || [[ "$ID_LIKE" == *debian* ]]; }; then
    echo "Error: This script only supports Debian/Ubuntu." >&2
    exit 1
  fi
else
  echo "Error: Cannot detect OS." >&2
  exit 1
fi

link_dotfiles() {
  print_step "Linking dotfiles"

  DOTFILES="$(cd "$(dirname "$0")" && pwd)"

  if [ -f "$DOTFILES/.config/zsh/.zshenv" ]; then
    # shellcheck disable=SC1090
    source "$DOTFILES/.config/zsh/.zshenv"
  fi

  mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_STATE_HOME"
  mkdir -p "$XDG_CONFIG_HOME"/{zsh,git,ghostty,ripgrep,fd}
  mkdir -p "$XDG_CACHE_HOME/zsh" "$XDG_STATE_HOME/zsh"
  mkdir -p "$CARGO_HOME" "$RUSTUP_HOME"
  mkdir -p "$HOME/.local/bin"

  hash -r  # Refresh command hash after package installation

  if command -v stow >/dev/null 2>&1; then
    cd "$DOTFILES"
    stow --restow --no-folding -t "$HOME" .
    echo "✅ Dotfiles linked"
  else
    print_warning "stow not found, skipping dotfiles linking"
    print_warning "Install stow for automatic symlinks: sudo apt-get install stow"
  fi
}

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

install_cargo() {
  print_step "Installing Rust/Cargo"

  if command -v cargo >/dev/null; then
    print_warning "Cargo already installed, skipping"
    return
  fi

  print_step "Installing Rust to $CARGO_HOME"
  mkdir -p "$CARGO_HOME"
  mkdir -p "$RUSTUP_HOME"

  # Use --no-modify-path to prevent rustup from modifying profile files
  curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path

  source "$CARGO_HOME/env"

  if [ -f "$CARGO_HOME/bin/cargo" ]; then
    echo "✅ Cargo installed successfully to $CARGO_HOME/bin/cargo"
  else
    print_warning "Cargo installation may have failed"
  fi
}

install_awscli() {
  if ! command -v aws >/dev/null; then
    print_step "Installing aws cli"
    cd /tmp/

    ARCH=$(uname -m)
    case $ARCH in
    x86_64)
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      ;;
    aarch64)
      curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
      ;;
    *)
      print_warning "Unsupported architecture: $ARCH, skipping AWS CLI"
      return
      ;;
    esac

    unzip -q awscliv2.zip && sudo ./aws/install
  else
    print_warning "Skipping awscli, already installed"
    return
  fi
}

setup_shell() {
  if [ "$(basename -- "$SHELL")" = "zsh" ]; then
    return
  fi

  print_step "Setting zsh as default shell"
  local username="${USER:-$(whoami)}"
  sudo chsh -s $(which zsh) $username
}

install_fzf() {
  print_step "Installing fzf"
  if ! command -v fzf >/dev/null; then
    git clone -q --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --bin

    if [ -f "$HOME/.fzf/bin/fzf" ]; then
      ln -sf "$HOME/.fzf/bin/fzf" "$HOME/.local/bin/fzf"
      print_step "fzf installed, version $(fzf --version)"
    else
      print_warning "fzf installation may have failed"
    fi
  else
    print_warning "Skipping, fzf already installed"
  fi
}

setup_fd_symlink() {
  if command -v fd >/dev/null; then
    return
  fi

  print_step "Creating fd symlink"
  sudo ln -s $(which fdfind) /usr/local/bin/fd
}

install_zoxide() {
  print_step "Installing Zoxide"

  if command -v zoxide >/dev/null; then
    print_warning "zoxide has already been installed, skipping"
    return
  fi

  if ! command -v cargo >/dev/null; then
    print_warning "Cargo not found, installing Rust first"
    install_cargo
  fi

  # Source the cargo environment to ensure it's in PATH
  if [ -f "$CARGO_HOME/env" ]; then
    source "$CARGO_HOME/env"
  fi

  if command -v cargo >/dev/null; then
    print_step "Installing zoxide via cargo (to $CARGO_HOME/bin)"
    cargo install zoxide --locked

    if [ -f "$CARGO_HOME/bin/zoxide" ]; then
      echo "✅ zoxide installed successfully to $CARGO_HOME/bin/zoxide"
      return 0
    fi
  fi

  print_warning "Failed to install zoxide using cargo, trying alternative method"
  mkdir -p "$HOME/.local/bin"
  print_step "Attempting to install zoxide to $HOME/.local/bin via curl"

  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh |
    ZOXIDE_INSTALL_DIR="$HOME/.local/bin" sh

  if [ -f "$HOME/.local/bin/zoxide" ]; then
    echo "✅ zoxide installed successfully to $HOME/.local/bin/zoxide"
  else
    print_warning "Failed to install zoxide"
  fi
}

install_uv() {
  print_step "Installing uv"

  if command -v uv >/dev/null; then
    print_warning "uv has already been installed, skipping"
    return
  fi

  curl -LsSf https://astral.sh/uv/install.sh | sh
}

install_aliastips() {
  print_step "Installing alias-tips"
  print_warning "alias-tips will be installed via antidote, skipping manual installation"
}

install_antidote() {
  if [ -d "${XDG_DATA_HOME}/antidote" ]; then
    print_warning "Antidote already installed, skipping"
    return
  fi

  print_step "Installing Antidote (Zsh plugin manager)"
  git clone --depth=1 https://github.com/mattmc3/antidote.git "${XDG_DATA_HOME}/antidote"

  if [ ! -d "${XDG_DATA_HOME}/antidote" ]; then
    print_warning "Critical: Antidote installation failed"
    return 1
  fi
}

install_nvim() {
  print_step "Installing Neovim"

  if command -v nvim >/dev/null; then
    print_warning "Neovim has already been installed, skipping"
    return
  fi

  sudo apt-get install -yqq software-properties-common
  sudo add-apt-repository -y ppa:neovim-ppa/stable >/dev/null
  sudo apt-get update -qq >/dev/null
  sudo apt-get install -yqq neovim

  if command -v nvim >/dev/null; then
    nvim --version
  else
    print_warning "Neovim installation verification failed"
  fi
}

config_lazyvim() {
  print_step "Configuring neovim with LazyVim"
  if ! command -v nvim >/dev/null 2>&1; then
    print_warning "Neovim not installed, skipping LazyVim configuration"
    return
  fi

  mv ~/.config/nvim{,.bak} 2>/dev/null || true

  mv ~/.local/share/nvim{,.bak} 2>/dev/null || true
  mv ~/.local/state/nvim{,.bak} 2>/dev/null || true
  mv ~/.cache/nvim{,.bak} 2>/dev/null || true

  git clone --depth 1 https://github.com/LazyVim/starter ~/.config/nvim
  rm -rf ~/.config/nvim/.git

  print_step "LazyVim installed. Run 'nvim' to complete setup"
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
  sudo apt-get install -yqq nvidia-driver-${NVIDIA_VERSION}

  if ! dpkg -l | grep -q nvidia-driver-${NVIDIA_VERSION}; then
    print_warning "Critical: NVIDIA driver installation failed"
    return 1
  fi
}

main() {
  setup_color

  while [ $# -gt 0 ]; do
    case $1 in
    --dotfiles) DOTF=yes ;;
    --nvidia) NVIDIA=yes ;;
    --nvidia-version=*) NVIDIA_VERSION="${1#*=}" ;;
    esac
    shift
  done

  echo "Setting up your Ubuntu machine"

  # Set timezone non-interactively before apt install
  export DEBIAN_FRONTEND=noninteractive
  export TZ=UTC
  if [ "$(id -u)" = "0" ]; then
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ >/etc/timezone
  fi

  print_step "Updating package lists"
  sudo apt-get update -qq >/dev/null

  print_step "Installing packages from apt-pkglist"
  sudo apt-get install -yqq $(sed -e 's/#.*//' "$(dirname "$0")/apt-pkglist")

  link_dotfiles
  setup_shell
  setup_fd_symlink
  install_cargo
  install_antidote
  install_awscli
  install_fzf
  install_zoxide
  install_aliastips
  install_uv
  install_nvim
  config_lazyvim
  install_nvidia

  echo
  print_step "Verifying installation..."
  command -v zsh >/dev/null && echo "✅ zsh" || echo "❌ zsh"
  command -v git >/dev/null && echo "✅ git" || echo "❌ git"
  [ -d "${XDG_DATA_HOME}/antidote" ] && echo "✅ antidote" || echo "❌ antidote"
  command -v fzf >/dev/null && echo "✅ fzf" || echo "❌ fzf"
  command -v cargo >/dev/null && echo "✅ cargo" || echo "⚠️  cargo (optional)"
  command -v zoxide >/dev/null && echo "✅ zoxide" || echo "⚠️  zoxide (optional)"
  command -v uv >/dev/null && echo "✅ uv" || echo "⚠️  uv (optional)"
  command -v nvim >/dev/null && echo "✅ nvim" || echo "⚠️  nvim (optional)"
  command -v aws >/dev/null && echo "✅ aws" || echo "⚠️  aws (optional)"
  if [ "$NVIDIA" = yes ]; then
    dpkg -l | grep -q nvidia-driver-${NVIDIA_VERSION} && echo "✅ nvidia-driver-${NVIDIA_VERSION}" || echo "❌ nvidia-driver-${NVIDIA_VERSION}"
  fi
}

main

print_step "Setup successfully completed!"
print_step "Don't forget to init 'zsh' shell!"
