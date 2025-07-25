# This is sourced from the ~/.zshrc file
export ZDOTDIR=${ZDOTDIR:-$HOME/.config/zsh}

# General configs
export PATH=$HOME/.local/bin:/usr/local/bin:$PATH
export LANG=en_US.UTF-8
export DOTFILES=$HOME/.dotfiles

# XDG configs
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state
export XDG_RUNTIME_DIR=/run/user/$UID

export RIPGREP_CONFIG_PATH=$XDG_CONFIG_HOME/ripgrep/.ripgreprc

# Cargo & Rustup
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export GOPATH="$XDG_DATA_HOME/go"

# Node / NPM / `n` package manager 
export N_PREFIX="$HOME/.local/bin"
export PATH=$N_PREFIX/bin:$PATH
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node_repl_history"
export NPM_CONFIG_INIT_MODULE="$XDG_CONFIG_HOME/npm/config/npm-init.js"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NPM_CONFIG_TMP="$XDG_RUNTIME_DIR/npm"

# tldr, supports only C-client
export TLDR_CACHE_DIR="$XDG_CACHE_HOME"/tldr

# required for sqllite & zlib that used by pyenv
# export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/sqlite/lib"
# export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/sqlite/include"
# export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig:/usr/local/opt/sqlite/lib/pkgconfig"

# Add sourcing of Cargo environment to include cargo bin in PATH
if [ -f "$CARGO_HOME/env" ]; then
  # shellcheck disable=SC1091
  source "$CARGO_HOME/env"
fi
