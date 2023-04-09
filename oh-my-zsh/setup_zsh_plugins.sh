#!/bin/sh
# source: https://github.com/romkatv/zsh-bench/blob/master/configs/diy%2B%2B/skel/.zshrc
# https://github.com/romkatv/zsh-bench

OMZ_PLUGINS=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins
if [[ ! -e $OMZ_PLUGINS/zsh-autosuggestions ]]; then
  echo "Cloning repositories for zsh plugins..."
  echo "oh-my-zsh custom path: ${OMZ_PLUGINS}"
fi

function zcompile-many() {
  local f
  for f; do zcompile -R -- "$f".zwc "$f"; done
}

# omz plugins
# Clone and compile to wordcode missing plugins.
if [[ ! -e $OMZ_PLUGINS/zsh-autosuggestions ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git $OMZ_PLUGINS/zsh-autosuggestions
#  zcompile-many $OMZ_PLUGINS/zsh-autosuggestions/{zsh-autosuggestions.zsh,src/**/*.zsh}
fi

# zsh-autosuggestion should go before zsh-syntax-highlighting
if [[ ! -e $OMZ_PLUGINS/zsh-syntax-highlighting ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git $OMZ_PLUGINS/zsh-syntax-highlighting
#  zcompile-many $OMZ_PLUGINS/zsh-syntax-highlighting/{zsh-syntax-highlighting.zsh,highlighters/*/*.zsh}
fi

if [[ ! -e $OMZ_PLUGINS/zsh-completions ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-completions.git $OMZ_PLUGINS/zsh-completions
#  zcompile-many $OMZ_PLUGINS/zsh-completions/zsh-completions.plugins.zsh
fi

if [[ ! -e $OMZ_PLUGINS/powerlevel10k ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $OMZ_PLUGINS/powerlevel10k
#  make -C $OMZ_PLUGINS/powerlevel10k pkg
fi

if [[ ! -e $OMZ_PLUGINS/jq ]]; then
  git clone --depth=1 https://github.com/reegnz/jq-zsh-plugin.git $OMZ_PLUGINS/jq
#  zcompile-many $OMZ_PLUGINS/jq/**/*.zsh
fi

[[ ~/.zcompdump.zwc -nt ~/.zcompdump ]] || zcompile-many ~/.zcompdump
unfunction zcompile-many

