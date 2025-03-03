# always use emacs style for zsh
# https://zsh.sourceforge.io/Guide/zshguide04.html#l75
bindkey -e

# Environment variables
export XDG_CONFIG_HOME=$HOME/.config
export DOTFILES=$HOME/.dotfiles
export PATH=$HOME/.local/bin:/usr/local/bin:$PATH
export LANG=en_US.UTF-8
export RIPGREP_CONFIG_PATH=$DOTFILES/.ripgreprc
export N_PREFIX="$HOME/.local/bin"

# Preferred editor for local and remote sessions
export EDITOR='nvim'
[[ -n $SSH_CONNECTION ]] && export EDITOR='vim'

# Oh-my-zsh configuration
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.dotfiles/oh-my-zsh/custom"
ZSH_THEME="powerlevel10k/powerlevel10k"
DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="dd.mm.yyyy"

# Install plugins & compile
source ${DOTFILES}/setup_zsh_plugins.sh

# gh completions
# if [[ ! -d "$ZSH/completions" || ! -f "$ZSH/completions/_gh" ]]; then
#     mkdir -pv $ZSH/completions
#     gh completion --shell zsh > $ZSH/completions/_gh
# #    echo "gh added completions: gh completion --shell zsh > $ZSH/completions/_gh"
# fi

# zsh-completions
# Don't use zsh-completions as oh-my-zsh plugin (including `compinit`)
# https://github.com/zsh-users/zsh-completions/issues/603
fpath+="${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src"

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
  alias-tips
  aws
  fzf
  jq # https://github.com/reegnz/jq-zsh-plugin
  # don't use zsh-completions as oh-my-zsh plugin, it's added above as `fpath`
  zsh-autosuggestions # should be before zsh-syntax-highlighting
  zsh-syntax-highlighting
  uv
  )

# Load custom oh-my-zsh preferences
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
source $ZSH/oh-my-zsh.sh

# Use (j, ji) as default commands instead of (z, zi)
eval "$(zoxide init zsh --cmd j)"

# uv run autocomplete
# https://github.com/astral-sh/uv/issues/8432#issuecomment-2605216865
eval "$(uv generate-shell-completion zsh)"

_uv_run_mod() {
    if [[ "$words[2]" == "run" && "$words[CURRENT]" != -* ]]; then
        local venv_binaries
        if [[ -d .venv/bin ]]; then
            venv_binaries=( ${(@f)"$(_call_program files ls -1 .venv/bin 2>/dev/null)"} )
        fi
        
        _alternative \
            'files:filename:_files' \
            "binaries:venv binary:(($venv_binaries))"
    else
        _uv "$@"
    fi
}
compdef _uv_run_mod uv

# Key bindings
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
bindkey '^ ' autosuggest-accept
bindkey \^U backward-kill-line

# Powerlevel10k Instant Prompt
[[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] && source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# fd and fzf configuration
FD_OPTIONS="--hidden --follow --exclude .git --exclude node_modules --exclude .zshrc --exclude venv"
export FZF_VIM_DIR="$HOME/.local/bin/fzf.vim"
export FZF_DEFAULT_OPTS="--no-mouse --height 80% --reverse --multi --info=inline --marker='' --pointer='→' --color='pointer:white' --preview='$FZF_VIM_DIR/bin/preview.sh {}' --preview-window='right:60%:wrap' --bind='ctrl-x:execute(rm -i {+})+abort' --bind='f2:toggle-preview,ctrl-v:toggle-preview' --bind='f3:execute(bat --style=numbers {} || less -f {})' --bind='f4:become($EDITOR {}),ctrl-o:become($EDITOR {})' --bind='ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-y:execute-silent(echo {+} | pbcopy),ctrl-l:clear-query' --bind='alt-w:toggle-preview-wrap,alt-j:preview-half-page-down,alt-k:preview-half-page-up,alt-h:preview-top,alt-l:preview-bottom' --bind='ctrl-x:+reload(eval $FZF_DEFAULT_COMMAND)'"
export FZF_DEFAULT_COMMAND="git ls-files --cached --others --exclude-standard 2>/dev/null || fd --type f --type l $FD_OPTIONS"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d $FD_OPTIONS"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

source <(fzf --zsh)

# Source additional configs
[[ -f ~/.profile ]] && source ~/.profile
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
[[ -e "${HOME}/.iterm2_shell_integration.zsh" ]] && source "${HOME}/.iterm2_shell_integration.zsh"

# pnpm
export PNPM_HOME="${HOME}/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
