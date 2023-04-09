#!/bin/sh
set -eu

echo "Setting up your Mac..."
# These variables should be the same as in .zshrc
# Path to dotfiles
export DOTFILES=$HOME/.dotfiles

# Load custom oh-my-zsh preferences, including all *.zsh files (automatically)
ZSH_CUSTOM=$DOTFILES/oh-my-zsh

# Check for Oh My Zsh and install if we don't have it
if test ! $(which omz); then
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Backup previous .zshrc config and use one from the repo
mv $HOME/.zshrc $HOME/.zshrc_old
ln -s $DOTFILES/.zshrc $HOME/.zshrc

# Update Homebrew recipes
brew update

# Install all dependencies using bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle --file ./Brewfile

