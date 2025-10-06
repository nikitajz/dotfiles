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

stow_dotfiles() {
  print_step "Linking dotfiles"

  mkdir -p "$XDG_CONFIG_HOME"/{git,zsh,ghostty,fd,ripgrep}

  cd "$DOTFILES"
  stow --restow --no-folding -t "$HOME" .
}

install_packages() {
  print_step "Installing packages"

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
  install_packages
  install_antidote
  stow_dotfiles
  install_fzf
  print_step "Installation completed successfully"
}

main
