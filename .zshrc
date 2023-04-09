export DOTFILES=$HOME/.dotfiles
export PATH=$HOME/.local/bin:/usr/local/bin:$PATH
export LANG=en_US.UTF-8

export ZSH="$HOME/.oh-my-zsh"

# Load custom oh-my-zsh preferences, including all *.zsh files (automatically)
ZSH_CUSTOM=$DOTFILES/oh-my-zsh

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Disable marking untracked files under VCS as dirty. 
# This makes repository status check for large repositories much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Command execution time stamp shown in the history command output.
HIST_STAMPS="dd.mm.yyyy"

# Install plugins & compile
source $ZSH_CUSTOM/setup_zsh_plugins.sh

# zsh-completions
# Don't use zsh-completions as oh-my-zsh plugin (including `compinit`)
# https://github.com/zsh-users/zsh-completions/issues/603
fpath+="${ZSH_CUSTOM:-"$ZSH/custom"}/plugins/zsh-completions/src"

# https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
  git
  jq # https://github.com/reegnz/jq-zsh-plugin
  zsh-autosuggestions # should be before zsh-syntax-highlighting
  zsh-syntax-highlighting
  )

export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$USER

source $ZSH/oh-my-zsh.sh

ZSH_AUTOSUGGEST_MANUAL_REBIND=1
bindkey '^ ' autosuggest-accept

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# CUSTOM

bindkey \^U backward-kill-line  # fix Ctrl-U in terminal

# Activate Powerlevel10k Instant Prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# For completions to work, the above line must be added after compinit is called.
eval "$(zoxide init zsh)"

# "sharkdp/fd" file finder, modern replacement for GNU find
FD_OPTIONS="--hidden --follow --exclude .git --exclude node_modules --exclude .zshrc"

# 'junegunn/fzf', command line fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_OPTS="--no-mouse --height 80% --reverse --multi --info=inline --preview='$HOME/.vim/plugged/fzf.vim/bin/preview.sh {}' --preview-window='right:60%:wrap' --bind='f2:toggle-preview,f3:execute(bat --style=numbers {} || less -f {}),f4:execute($EDITOR {}),alt-w:toggle-preview-wrap,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-y:execute-silent(echo {+} | pbcopy),ctrl-x:execute(rm -i {+})+abort,ctrl-l:clear-query'"
export FZF_DEFAULT_COMMAND="git ls-files --cached --others --exclude-standard 2>/dev/null || fd --type f --type l $FD_OPTIONS"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d $FD_OPTIONS"

# Enable command completion (e.g. for awscli)
complete -C aws_completer aws

