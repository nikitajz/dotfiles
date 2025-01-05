#!/bin/bash

set -euo pipefail

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

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

# These variables should be the same as in .zshrc
# Load custom oh-my-zsh preferences, including all *.zsh files (automatically)
#ZSH_CUSTOM=$DOTFILES/oh-my-zsh

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
  export DOTFILES=$HOME/.dotfiles

  print_step "Configuring dotfiles"
  if [[ ! -d $DOTFILES ]]; then
    print_warning "Dotfiles do not exist"
    return
  fi

  echo "Linking dotfiles"
  create_symlink $DOTFILES/.zshrc $HOME/.zshrc
  create_symlink $DOTFILES/.profile $HOME/.profile
  create_symlink $DOTFILES/.p10k.zsh $HOME/.p10k.zsh
  create_symlink $DOTFILES/.config/ghostty/config $XDG_CONFIG_HOME/ghostty/config
  create_symlink $DOTFILES/gitignore_global $HOME/.gitignore_global
}

install_brew_dependencies() {
  print_step "Installing brew dependencies from Brewfile"

  brew update
  brew tap homebrew/bundle
  brew bundle --file $DOTFILES/Brewfile
}

# Use pyenv to manage python versions
install_pyenv() {
  if ! command -v pyenv >/dev/null; then
    print_step "Installing Python using pyenv"
    # verify zlib and sqlite3 are installed (required for pyenv)
    echo '[[ ! -f ~/.profile ]] || source ~/.profile' >>~/.bash_profile
    pyenv install 3.10
    pyenv global 3.10
  else
    print_warning "Skipping pyenv, already installed"
  fi
}

install_iterm2_integration() {
  print_step "Installing iTerm2 shell integration"
  curl -L https://iterm2.com/shell_integration/install_shell_integration.sh | bash
}

install_fzf() {
  if ! command -v fzf >/dev/null; then
    print_step "fzf install"

    $(brew --prefix)/opt/fzf/install --all --xdg --no-fish
  else
    print_warning "Skipping fzf, already installed"
  fi
}

install_oh_my_zsh() {
  if ! command -v omz >/dev/null; then
    print_step "Installing Oh My Zsh"
    /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)" "" --keep-zshrc
  else
    print_warning "Skipping Oh My Zsh, already installed"
  fi
}

main() {
  print_step "Setting up your Mac..."
  # Path to dotfiles
  export DOTFILES=$HOME/.dotfiles

  config_dotfiles
  install_homebrew
  install_brew_dependencies
  install_pyenv
  install_iterm2_integration
  install_fzf
  install_oh_my_zsh
}

main
