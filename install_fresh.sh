#!/bin/bash

set -eu

echo "Setting up your Mac..."
# These variables should be the same as in .zshrc
# Path to dotfiles
export DOTFILES=$HOME/.dotfiles

# Load custom oh-my-zsh preferences, including all *.zsh files (automatically)
ZSH_CUSTOM=$DOTFILES/oh-my-zsh

# Backup previous .zshrc config and use one from the repo
if [ -f $HOME/.zshrc ]; then
  echo "Backing up existing .zshrc file to .zshrc_old"
  mv $HOME/.zshrc $HOME/.zshrc_old
fi
ln -s $DOTFILES/.zshrc $HOME/.zshrc

# Check for Homebrew and install if we don't have it
if ! command -v brew > /dev/null; then
  echo "Installing homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Check for Oh My Zsh and install if we don't have it
if ! command -v omz > /dev/null; then
  echo "Installing Oh My Zsh"
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)" --keep-zshrc
fi

# Update Homebrew recipes
brew update

echo "Installing brew dependencies from Brewfile"
brew tap homebrew/bundle
brew bundle --file $DOTFILES/Brewfile

