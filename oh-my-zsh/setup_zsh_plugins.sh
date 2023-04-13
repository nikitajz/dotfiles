#!/bin/sh
# source: https://github.com/romkatv/zsh-bench/blob/master/configs/diy%2B%2B/skel/.zshrc
# https://github.com/romkatv/zsh-bench

OMZ_PLUGINS=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins
OMZ_THEMES=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes

# List of plugin name and repository tuples (github is assumed by default)
declare -a plugins=(
  "jq reegnz/jq-zsh-plugin"
  "alias-tips djui/alias-tips"
)

function clone_plugin_repo() {
  for elem in "${plugins[@]}"; do
    read -a plugin <<< "$elem"  # uses default whitespace IFS
    plugin_name="${plugin[0]}"
    repo_url="${plugin[1]}"
   
    if [[ "$repo_url" != http* ]]; then
      repo_url="https://github.com/$repo_url.git"
    fi
    
    if [[ ! -e "$OMZ_PLUGINS/$plugin_name" ]]; then
      echo "Cloning the repo for plugin ${plugin_name}"
      git clone --depth=1 "$repo_url" "$OMZ_PLUGIN/$plugin_name"
    fi
  done
}

if [[ ! -e $OMZ_THEMES ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $OMZ_THEMES
  make -C $OMZ_THEMES/powerlevel10k pkg
fi
