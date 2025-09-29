#!/bin/bash
set -euo pipefail

# Ensure this script runs on Ubuntu/Debian systems only
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

# Set up environment
setup_environment() {
  # Environment variables are already sourced from dotfiles in config_dotfiles()
  # Just create the necessary directories
  
  # Create XDG directories if they don't exist
  mkdir -p "$XDG_CONFIG_HOME"
  mkdir -p "$XDG_DATA_HOME"
  mkdir -p "$XDG_CACHE_HOME"
  mkdir -p "$XDG_STATE_HOME"
  mkdir -p "$XDG_CONFIG_HOME/zsh"
  mkdir -p "$XDG_CONFIG_HOME/git"
  mkdir -p "$XDG_CACHE_HOME/zsh"
  mkdir -p "$XDG_STATE_HOME/zsh"
  
  # Create Cargo and Rustup directories if they don't exist
  mkdir -p "$CARGO_HOME"
  mkdir -p "$RUSTUP_HOME"
  
  # Set timezone to avoid interactive prompts
  export TZ=UTC
  # Skip system-wide timezone setup if not root
  if [ "$(id -u)" = "0" ]; then
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
  fi
  
  # Locale is already set in .zshenv (LANG=en_US.UTF-8)
}

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

install_cargo() {
  print_step "Installing Rust/Cargo"

  if command -v cargo >/dev/null; then
    print_warning "Cargo already installed, skipping"
    return
  fi

  # Install Rust with proper XDG paths (already set by setup_environment)
  print_step "Installing Rust to $CARGO_HOME"
  # Ensure the CARGO_HOME and RUSTUP_HOME directories exist
  mkdir -p "$CARGO_HOME"
  mkdir -p "$RUSTUP_HOME"
  
  # Use --no-modify-path to prevent rustup from modifying profile files
  curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path
  
  # Source the cargo environment file
  source "$CARGO_HOME/env"
  
  # Verify installation
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
    
    # Get architecture
    ARCH=$(uname -m)
    case $ARCH in
      x86_64)
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        ;;
      aarch64)
        curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
        ;;
      *)
        echo "Unsupported architecture: $ARCH"
        return 1
        ;;
    esac
    
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

  # Set zsh as default shell
  print_step "Setting zsh as default shell"
  # Check if USER is set, otherwise use the current username
  local username="${USER:-$(whoami)}"
  sudo chsh -s $(which zsh) $username
}

install_fzf() {
  print_step "Installing fzf"
  if ! command -v fzf >/dev/null; then
    # Install fzf using the official installation script
    git clone -q --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --no-fish --no-bash --no-update-rc

    # Add fzf to PATH for the current session (PATH is managed by zsh config)
    PATH="$HOME/.fzf/bin:$PATH"
    
    # Verify installation
    if command -v fzf >/dev/null; then
      print_step "fzf installed, version $(fzf --version)"
    else
      print_warning "fzf installation may have failed"
    fi
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

  # Install fd-find using apt
  sudo apt-get install -y fd-find

  # Create symlink as per official documentation
  if ! command -v fd >/dev/null; then
    sudo ln -s $(which fdfind) /usr/local/bin/fd
  fi

  # Verify installation
  if ! command -v fd >/dev/null; then
    print_warning "fd installation verification failed"
    return 1
  fi
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

  # Install ripgrep using apt as per official instructions
  sudo apt-get install -y ripgrep

  # Verify installation
  if ! command -v rg >/dev/null; then
    print_warning "ripgrep installation verification failed"
    return 1
  fi
}

install_zoxide() {
  if [ "$OPTIONAL" = no ]; then
    return
  fi

  print_step "Installing Zoxide"
  
  if command -v zoxide >/dev/null; then
    print_warning "zoxide has already been installed, skipping"
    return
  fi

  # Ensure cargo is installed and available
  if ! command -v cargo >/dev/null; then
    print_warning "Cargo not found, installing Rust first"
    install_cargo
  fi
  
  # Source the cargo environment to ensure it's in PATH
  if [ -f "$CARGO_HOME/env" ]; then
    source "$CARGO_HOME/env"
  fi
  
  if command -v cargo >/dev/null; then
    # Install zoxide with cargo using XDG paths
    print_step "Installing zoxide via cargo (to $CARGO_HOME/bin)"
    cargo install zoxide --locked
    
    # Verify installation 
    if [ -f "$CARGO_HOME/bin/zoxide" ]; then
      echo "✅ zoxide installed successfully to $CARGO_HOME/bin/zoxide"
      return 0
    fi
  fi
  
  print_warning "Failed to install zoxide using cargo, trying alternative method"
  
  # Fallback to curl installation to ~/.local/bin
  mkdir -p "$HOME/.local/bin"
  print_step "Attempting to install zoxide to $HOME/.local/bin via curl"
  
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | \
    ZOXIDE_INSTALL_DIR="$HOME/.local/bin" sh
  
  # Verify installation
  if [ -f "$HOME/.local/bin/zoxide" ]; then
    echo "✅ zoxide installed successfully to $HOME/.local/bin/zoxide"
    return 0
  else
    print_warning "Failed to install zoxide"
    return 1
  fi
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

  # Install jq using apt
  sudo apt-get install -y jq
  
  # The jq plugin will be installed via antidote
  print_warning "jq zsh plugin will be installed via antidote"
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

  sudo apt-get install -y nvtop
}

install_keychain() {
  if [ "$OPTIONAL" = no ]; then
    return
  fi
  print_step "Installing keychain"

  if command -v keychain >/dev/null; then
    print_warning "keychain has already been installed, skipping"
    return
  fi

  sudo apt-get install -y keychain
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

  print_step "Installing alias-tips"
  # The alias-tips plugin will be installed via antidote
  print_warning "alias-tips will be installed via antidote, skipping manual installation"
}

install_antidote() {
  if [ ! -d "${XDG_DATA_HOME}/antidote" ]; then
    print_step "Installing Antidote (Zsh plugin manager)"
    git clone --depth=1 https://github.com/mattmc3/antidote.git "${XDG_DATA_HOME}/antidote"
  else
    print_warning "Antidote already installed, skipping"
  fi
}

install_nvim() {
  print_step "Installing Neovim"

  if command -v nvim >/dev/null; then
    print_warning "Neovim has already been installed, skipping"
    return
  fi

  # Add Neovim repository
  sudo apt-get install -y software-properties-common
  sudo add-apt-repository -y ppa:neovim-ppa/stable
  sudo apt-get update -q > /dev/null 2>&1
  sudo apt-get install -y neovim

  # Verify installation
  if ! command -v nvim >/dev/null; then
    print_warning "Neovim installation verification failed"
    return 1
  fi
  
  nvim --version
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

  # Set DOTFILES for initial setup (before .zshenv is available)
  DOTFILES="$HOME/.dotfiles"
  
  if [[ -d "$DOTFILES" ]]; then
    print_warning "Dotfiles already exist"
  else
    echo "Clonning dotfiles github repo"
    git clone --depth 1 git@github.com:nikitajz/dotfiles.git "$DOTFILES"
  fi

  if [[ ! -d "$DOTFILES" ]]; then
    print_warning "Dotfiles do not exist"
    return
  fi

  # Source environment variables directly from dotfiles repo (before symlinking)
  if [ -f "$DOTFILES/.config/zsh/.zshenv" ]; then
    # shellcheck disable=SC1090
    source "$DOTFILES/.config/zsh/.zshenv"
    print_step "Sourced environment variables from dotfiles"
  else
    print_warning "No .config/zsh/.zshenv found in dotfiles"
    return 1
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

    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"

    # Create the symlink
    ln -s "$src" "$dest"
    echo "Symlinked $(basename $dest)"
  }

  # Link dotfiles to the config locations (XDG variables are now available)
  link_file "$DOTFILES/.zshenv" "$HOME/.zshenv"
  link_file "$DOTFILES/.config/ghostty/config" "$XDG_CONFIG_HOME/ghostty/config"
  link_file "$DOTFILES/.config/ripgrep/.ripgreprc" "$XDG_CONFIG_HOME/ripgrep/.ripgreprc"
  link_file "$DOTFILES/.config/git/ignore" "$XDG_CONFIG_HOME/git/ignore"
  link_file "$DOTFILES/.config/fd/ignore" "$XDG_CONFIG_HOME/fd/ignore"
  
  # Symlink the entire zsh directory rather than individual files
  link_file "$DOTFILES/.config/zsh" "$XDG_CONFIG_HOME/zsh"
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

  sudo apt-get update -q > /dev/null 2>&1
  sudo apt-get install -y python3-dev unzip jq nvtop keychain zsh

  # Configure dotfiles FIRST so we can source environment variables
  config_dotfiles
  
  # Now set up environment with proper sourcing
  setup_environment

  setup_shell
  install_cargo
  install_antidote
  install_awscli
  install_jq
  install_fzf
  install_fd
  install_ripgrep
  install_zoxide
  install_aliastips
  install_nvtop
  install_keychain
  install_uv
  install_nvim
  config_lazyvim
  install_nvidia
}

main

print_step "Setup successfully completed!"
