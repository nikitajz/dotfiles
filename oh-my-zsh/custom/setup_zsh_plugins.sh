#!/bin/sh

if ! command -v git &> /dev/null
then
    echo "git could not be found. Please install it and run the script again."
    exit
fi

# source: https://github.com/romkatv/zsh-bench/blob/master/configs/diy%2B%2B/skel/.zshrc
# https://github.com/romkatv/zsh-bench
OMZ_PLUGINS=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins
OMZ_THEMES=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes

# List of plugin name and repository tuples (github is assumed by default)
declare -a plugins=(
  "zsh-syntax-highlighting zsh-users/zsh-syntax-highlighting"
  "zsh-autosuggestions zsh-users/zsh-autosuggestions"
  "zsh-nvm lukechilds/zsh-nvm"
  "jq reegnz/jq-zsh-plugin"
  "alias-tips djui/alias-tips"
)

function clone_plugin_repo() {
  for elem in "${plugins[@]}"; do
    IFS=' ' read -r plugin_name repo_url <<< "$elem" 
   
    if [[ "$repo_url" != http* ]]; then
      repo_url="https://github.com/$repo_url.git"
    fi
    
    if [[ ! -d "$OMZ_PLUGINS/$plugin_name" ]]; then
      echo "Cloning the repo for plugin ${plugin_name}"
      git clone --depth=1 "$repo_url" "$OMZ_PLUGINS/$plugin_name" &
    fi
  done
  wait
}

clone_plugin_repo

if [[ ! -d $OMZ_THEMES/powerlevel10k ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $OMZ_THEMES/powerlevel10k
  make -C $OMZ_THEMES/powerlevel10k pkg
fi

# Check and clone fzf.vim
FZF_VIM_DIR="$HOME/.local/bin/fzf.vim"
if [[ ! -d "$FZF_VIM_DIR" ]]; then
  echo "Cloning fzf.vim to $FZF_VIM_DIR"
  mkdir -p "$(dirname "$FZF_VIM_DIR")"
  git clone --depth=1 "git@github.com:junegunn/fzf.vim.git" "$FZF_VIM_DIR" || {
    echo "Failed to clone fzf.vim repository"
    exit 1
  }
fi
