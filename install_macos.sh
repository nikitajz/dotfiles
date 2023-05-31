#!/bin/bash

set -euo pipefail

echo "Setting up your Mac..."
# These variables should be the same as in .zshrc
# Path to dotfiles
export DOTFILES=$HOME/.dotfiles

# Load custom oh-my-zsh preferences, including all *.zsh files (automatically)
#ZSH_CUSTOM=$DOTFILES/oh-my-zsh

# Ukrainian spellchecking
if [ ! -f $HOME/Library/Spelling/Ukrainian_uk_UA.dic ]; then
	echo "Installing Ukranian language spelling"
	curl -LJO https://raw.githubusercontent.com/titoBouzout/Dictionaries/master/Ukrainian_uk_UA.aff --output-dir $HOME/Library/Spelling
	curl -LJO https://raw.githubusercontent.com/titoBouzout/Dictionaries/master/Ukrainian_uk_UA.dic --output-dir $HOME/Library/Spelling
fi

# Check for Homebrew and install if we don't have it
if ! command -v brew >/dev/null; then
	echo "Installing homebrew"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>$HOME/.zprofile
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Backup previous .zshrc config and use one from the repo
if [ -f $HOME/.zshrc ]; then
	echo "Backing up existing .zshrc file to .zshrc_old"
	mv $HOME/.zshrc $HOME/.zshrc_old
fi
ln -s $DOTFILES/.zshrc $HOME/.zshrc
ln -s $DOTFILES/.profile $HOME/.profile
ln -s $DOTFILES/.p10k.zsh $HOME/.p10k.zsh
ln -s $DOTFILES/gitignore_global $HOME/.gitignore

# Update Homebrew recipes
brew update

echo "Installing brew dependencies from Brewfile"
brew tap homebrew/bundle
brew bundle --file $DOTFILES/Brewfile

# Use pyenv to manage python versions

# verify zlib and sqlite3 are installed (required for pyenv)
echo '[[ ! -f ~/.profile ]] || source ~/.profile' >>~/.bash_profile

pyenv install 3.10
pyenv global 3.10

# iTerm2 shell integration
curl -L https://iterm2.com/shell_integration/install_shell_integration.sh | bash

# fzf install
$(brew --prefix)/opt/fzf/install

# Check for Oh My Zsh and install if we don't have it
if ! command -v omz >/dev/null; then
	echo "Installing Oh My Zsh"
	/bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)" "" --keep-zshrc
fi
