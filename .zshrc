bindkey \^U backward-kill-line  # fix Ctrl-U in terminal

# TOOLS
# z - jump around, z.lua is a faster version: https://github.com/skywind3000/z.lua
eval "$(lua /usr/local/opt/z.lua/share/z.lua/z.lua --init zsh)"
source "$(brew --prefix z.lua)/share/z.lua/z.lua.plugin.zsh"
