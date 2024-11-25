# zmodload zsh/zprof

# always use emacs style for zsh
# https://zsh.sourceforge.io/Guide/zshguide04.html#l75
bindkey -e 


export XDG_CONFIG_HOME=$HOME/.config
export DOTFILES=$HOME/.dotfiles
export PATH=$HOME/.local/bin:/usr/local/bin:$PATH
export LANG=en_US.UTF-8
export RIPGREP_CONFIG_PATH=$DOTFILES/.ripgreprc

# Use local `n` instead of global `/opt/homebrew/bin/n`
export N_PREFIX="$HOME/.local/bin"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.dotfiles/oh-my-zsh/custom"
# Load custom oh-my-zsh preferences, including all *.zsh files (automatically)

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Disable marking untracked files under VCS as dirty. 
# This makes repository status check for large repositories much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Command execution time stamp shown in the history command output.
HIST_STAMPS="dd.mm.yyyy"

# Install plugins & compile
# Do not source this file directly, zsh plugins should be installed automatically except for custom plugins
# source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/setup_zsh_plugins.sh

# Don't use zsh-completions as oh-my-zsh plugin (including `compinit`)
# https://github.com/zsh-users/zsh-completions/issues/603
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

# zsh-completions
# if [[ ! -d "$ZSH/completions" || ! -f "$ZSH/completions/_gh" ]]; then
#     mkdir -pv $ZSH/completions
#     gh completion --shell zsh > $ZSH/completions/_gh
# #    echo "gh added completions: gh completion --shell zsh > $ZSH/completions/_gh"
# fi

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
  alias-tips
  # git # use custom instead
  fzf
  jq # https://github.com/reegnz/jq-zsh-plugin
  zsh-autosuggestions # should be before zsh-syntax-highlighting
  zsh-syntax-highlighting
  uv
  )

export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$USER

source $ZSH/oh-my-zsh.sh

ZSH_AUTOSUGGEST_MANUAL_REBIND=1
bindkey '^ ' autosuggest-accept
bindkey \^U backward-kill-line  # fix Ctrl-U in terminal


# Compilation flags
# export ARCHFLAGS="-arch x86_64"


# Activate Powerlevel10k Instant Prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Use (j, ji) as default commands instead of (z, zi)
eval "$(zoxide init zsh --cmd j)"

# "sharkdp/fd" file finder, modern replacement for GNU find
FD_OPTIONS="--hidden --follow --exclude .git --exclude node_modules --exclude .zshrc --exclude venv"

# 'junegunn/fzf', command line fuzzy finder
# Requires fzf.vim
export FZF_VIM_DIR="$HOME/.local/bin/fzf.vim"

export FZF_DEFAULT_OPTS="--no-mouse \
                         --height 80% \
                         --reverse \
                         --multi \
                         --info=inline \
                         --marker='' \
                         --pointer='→' \
                         --color='pointer:white' \
                         --preview='$FZF_VIM_DIR/bin/preview.sh {}' \
                         --preview-window='right:60%:wrap' \
                         --bind='ctrl-x:execute(rm -i {+})+abort' \
                         --bind='f2:toggle-preview,ctrl-v:toggle-preview' \
                         --bind='f3:execute(bat --style=numbers {} || less -f {})' \
                         --bind='f4:become($EDITOR {}),ctrl-o:become($EDITOR {})' \
                         --bind='ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-y:execute-silent(echo {+} | pbcopy),ctrl-l:clear-query' \
                         --bind='alt-w:toggle-preview-wrap,alt-j:preview-half-page-down,alt-k:preview-half-page-up,alt-h:preview-top,alt-l:preview-bottom' \
                         --bind='ctrl-x:+reload(eval $FZF_DEFAULT_COMMAND)'"

# fzf will use this default command if and only if you don’t give any input.
export FZF_DEFAULT_COMMAND="git ls-files --cached --others --exclude-standard 2>/dev/null || fd --type f --type l $FD_OPTIONS"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d $FD_OPTIONS"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

source <(fzf --zsh)

# Source configs into this one
[[ ! -f ~/.profile ]] || source ~/.profile
[[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Enable command completion (e.g. for awscli)
complete -C aws_completer aws

# zprof
