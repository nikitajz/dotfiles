# This is sourced from the ~/.zshrc file
export ZDOTDIR=${ZDOTDIR:-$HOME/.config/zsh}

# Environment variables
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export DOTFILES=$HOME/.dotfiles
export PATH=$HOME/.local/bin:/usr/local/bin:$PATH
export LANG=en_US.UTF-8
export RIPGREP_CONFIG_PATH=$XDG_CONFIG_HOME/ripgrep/.ripgreprc
export N_PREFIX="$HOME/.local/bin"

# required for sqllite & zlib that used by pyenv
# export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/sqlite/lib"
# export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/sqlite/include"
# export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig:/usr/local/opt/sqlite/lib/pkgconfig"

# Add sourcing of Cargo environment to include ~/.cargo/bin in PATH
if [ -f "$HOME/.cargo/env" ]; then
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"
fi
