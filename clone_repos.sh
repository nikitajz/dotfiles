#!/bin/sh

echo "Cloning repositories..."

OMZ_PLUGINS=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins

# omz plugins
git clone https://github.com/reegnz/jq-zsh-plugin.git $OMZ_PLUGINS/jq
