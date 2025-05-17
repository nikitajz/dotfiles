# Powerlevel10k Instant Prompt (should be at the top)
[[ -r "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh" ]] && source "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh"

# Antidote (Zsh plugin manager)
[[ -f "${XDG_DATA_HOME}/antidote/antidote.zsh" ]] && source "${XDG_DATA_HOME}/antidote/antidote.zsh"

zstyle ':antidote:bundle' use-friendly-names 'yes'
antidote load ${XDG_CONFIG_HOME}/zsh/.zsh_plugins.txt

compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"
export HISTFILE="$XDG_STATE_HOME/zsh/history"

# Use (j, ji) as default commands instead of (z, zi)
eval "$(zoxide init zsh --cmd j)"

## Completion
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

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

## Key bindings
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

## Additional configs
# Powerlevel10k should be sourced near the end of the file
# [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
[[ -f $XDG_CONFIG_HOME/zsh/.p10k.zsh ]] && source $XDG_CONFIG_HOME/zsh/.p10k.zsh

# Aliases
[[ -f "${XDG_CONFIG_HOME}/zsh/aliases.zsh" ]] && source "${XDG_CONFIG_HOME}/zsh/aliases.zsh"

# Local config (do not commit, can contain secrets)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
[[ -e "${HOME}/.iterm2_shell_integration.zsh" ]] && source "${HOME}/.iterm2_shell_integration.zsh"
