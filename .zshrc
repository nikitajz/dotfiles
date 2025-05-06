# Environment variables
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export DOTFILES=$HOME/.dotfiles
export PATH=$HOME/.local/bin:/usr/local/bin:$PATH
export LANG=en_US.UTF-8
export RIPGREP_CONFIG_PATH=$DOTFILES/.ripgreprc
export N_PREFIX="$HOME/.local/bin"

# Preferred editor for local and remote sessions
export EDITOR='nvim'
[[ -n $SSH_CONNECTION ]] && export EDITOR='vim'

# Powerlevel10k Instant Prompt
[[ -r "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh" ]] && source "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh"

#  Antidote (support both macOS/Homebrew or Linux/manual)
if command -v brew >/dev/null 2>&1 \
   && [[ -f "$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh" ]]; then
  ANTIDOTE_DIR="$(brew --prefix)/opt/antidote/share/antidote"
else
  ANTIDOTE_DIR="${XDG_DATA_HOME}/antidote"
fi
source "${ANTIDOTE_DIR}/antidote.zsh"

zstyle ':antidote:bundle' use-friendly-names 'yes'
antidote load ${XDG_CONFIG_HOME}/zsh/.zsh_plugins.txt

# completion system
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

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
# always use emacs style for zsh
# https://zsh.sourceforge.io/Guide/zshguide04.html#l75
bindkey -e

ZSH_AUTOSUGGEST_MANUAL_REBIND=1
bindkey '^ ' autosuggest-accept
bindkey \^U backward-kill-line

# fd and fzf configuration
FD_OPTIONS="--hidden --follow --exclude .git --exclude node_modules --exclude .zshrc --exclude venv"
export FZF_VIM_DIR="$(antidote path junegunn/fzf.vim 2>/dev/null || echo "$HOME/.local/bin/fzf.vim")"
export FZF_DEFAULT_OPTS="--no-mouse --height 80% --reverse --multi --info=inline --marker='' --pointer='→' --color='pointer:white' --preview='$FZF_VIM_DIR/bin/preview.sh {}' --preview-window='right:60%:wrap' --bind='ctrl-x:execute(rm -i {+})+abort' --bind='f2:toggle-preview,ctrl-v:toggle-preview' --bind='f3:execute(bat --style=numbers {} || less -f {})' --bind='f4:become($EDITOR {}),ctrl-o:become($EDITOR {})' --bind='ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-y:execute-silent(echo {+} | pbcopy),ctrl-l:clear-query' --bind='alt-w:toggle-preview-wrap,alt-j:preview-half-page-down,alt-k:preview-half-page-up,alt-h:preview-top,alt-l:preview-bottom' --bind='ctrl-x:+reload(eval $FZF_DEFAULT_COMMAND)'"
export FZF_DEFAULT_COMMAND="git ls-files --cached --others --exclude-standard 2>/dev/null || fd --type f --type l $FD_OPTIONS"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d $FD_OPTIONS"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

source <(fzf --zsh)

# Source additional configs
[[ -f "${XDG_CONFIG_HOME}/zsh/aliases.zsh" ]] && source "${XDG_CONFIG_HOME}/zsh/aliases.zsh"
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

# rust
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
