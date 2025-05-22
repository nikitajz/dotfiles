#!/bin/bash

set -euo pipefail

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Define DOTFILES path, defaulting to $HOME/.dotfiles
# This makes the script work locally by default
export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

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

setup_color

print_step() {
  echo "${FMT_BOLD}${FMT_YELLOW}--> ${FMT_RESET}${FMT_BOLD} $1${FMT_RESET}"
}

print_warning() {
  echo "${FMT_GREEN}[!] $1${FMT_RESET} "
}

# Ukrainian spellchecking
if [ ! -f $HOME/Library/Spelling/Ukrainian_uk_UA.dic ]; then
  print_step "Installing Ukranian language spelling"
  curl -LJO https://raw.githubusercontent.com/titoBouzout/Dictionaries/master/Ukrainian_uk_UA.aff --output-dir $HOME/Library/Spelling
  curl -LJO https://raw.githubusercontent.com/titoBouzout/Dictionaries/master/Ukrainian_uk_UA.dic --output-dir $HOME/Library/Spelling
fi

# Check for Homebrew and install if we don't have it
install_homebrew() {
  if ! command -v brew >/dev/null; then
    print_step "Installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>$HOME/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

create_symlink() {
  local src="${1}"
  local dest="${2}"
  local dest_backup="${dest}.bk"

  mkdir -p "$(dirname "${dest}")"

  if [[ -L "${dest}" ]]; then
    print_warning "${dest} already symlinked, skipping"
    return
  fi

  if [[ -f "${dest}" ]]; then
    echo "Backing up existing ${dest} file to ${dest_backup}"
    mv "${dest}" "${dest_backup}"
  fi

  ln -s "${src}" "${dest}"
  echo "Symlinked ${dest}"
}

config_dotfiles() {
  print_step "Configuring dotfiles"
  # Check if the target DOTFILES directory exists
  if [[ ! -d $DOTFILES ]]; then
    print_warning "Dotfiles directory not found: $DOTFILES"
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

  echo "Linking dotfiles from $DOTFILES"
  create_symlink "$DOTFILES/.zshenv" "$HOME/.zshenv"
  create_symlink "$DOTFILES/.config/ghostty/config" "$XDG_CONFIG_HOME/ghostty/config"
  create_symlink "$DOTFILES/.config/ripgrep/.ripgreprc" "$XDG_CONFIG_HOME/ripgrep/.ripgreprc"
  create_symlink "$DOTFILES/.config/git/ignore" "$XDG_CONFIG_HOME/git/ignore"
  
  # Symlink the entire zsh directory rather than individual files
  create_symlink "$DOTFILES/.config/zsh" "$XDG_CONFIG_HOME/zsh"
  # p10k.zsh is symlinked above
  # create_symlink "$DOTFILES/.p10k.zsh" "$HOME/.p10k.zsh"
}

install_brew_dependencies() {
  print_step "Installing brew dependencies"

  brew update
  
  # Always install essential command-line tools
  print_step "Installing essential tools from Brewfile"
  brew bundle --file "$DOTFILES/Brewfile" --no-upgrade
  
  # In CI environment, skip GUI apps
  if [ -z "${CI:-}" ]; then
    print_step "Installing GUI apps and fonts from Brewfile.extras"
    brew bundle --file "$DOTFILES/Brewfile.extras" --no-upgrade
  else
    print_step "CI environment detected, skipping GUI apps and fonts"
  fi
}

install_antidote() {
  export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
  if [ ! -d "${XDG_DATA_HOME}/antidote" ]; then
    print_step "Installing Antidote (Zsh plugin manager)"
    git clone --depth=1 https://github.com/mattmc3/antidote.git "${XDG_DATA_HOME}/antidote"
  else
    print_warning "Antidote already installed, skipping"
  fi
}

install_fzf() {
  if ! command -v fzf >/dev/null; then
    print_step "fzf install"
    $(brew --prefix)/opt/fzf/install --all --xdg --no-fish
  else
    print_warning "Skipping fzf, already installed"
  fi
}

main() {
  print_step "Setting up your Mac..."
  install_homebrew
  install_brew_dependencies
  install_antidote
  config_dotfiles
  install_fzf
}

main
