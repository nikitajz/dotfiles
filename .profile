# required for sqllite & zlib that used by pyenv
export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/sqlite/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/sqlite/include"
export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig:/usr/local/opt/sqlite/lib/pkgconfig"

# Use pyenv to manage python versions
if command -v pyenv 1>/dev/null 2>&1; then
	eval "$(pyenv init -)"
else
	echo "Warning: pyenv is not installed. Please install it to manage Python versions."
fi
. "$HOME/.cargo/env"
