# TODO: remove benchmarking
# zmodload zsh/zprof

# Environment variables (including XDG) are setup in ./.zshenv

# Powerlevel10k Instant Prompt (should be at the top)
[[ -r "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh" ]] && source "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh"

# Adding fpath for completions MUST BE before loading plugins (incl. completion)
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

## Antidote (Zsh plugin manager)
# Configure plugins with 'zstyle' BEFORE loading them
# Proper zsh defaults are enabled by 'zephyr' plugins:
# https://github.com/mattmc3/zephyr/tree/main?tab=readme-ov-file#plugins
# Zephyr enable XDG-compliance by default
zstyle ':zephyr:plugin:editor' 'magic-enter' no

zstyle ':antidote:bundle' use-friendly-names 'yes'

[[ -f "${XDG_DATA_HOME}/antidote/antidote.zsh" ]] && source "${XDG_DATA_HOME}/antidote/antidote.zsh"
antidote load ${XDG_CONFIG_HOME}/zsh/.zsh_plugins.txt

# Use (j, ji) as default commands instead of (z, zi)
eval "$(zoxide init zsh --cmd j)"

## uv autocomplete
# https://github.com/astral-sh/uv/issues/8432#issuecomment-2605216865
# currently sourced from ohmyzsh/uv plugin
# eval "$(uv generate-shell-completion zsh)"
# `uv` completion fix to source .venv binaries
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

## fzf, fd and forgit configuration
# Ripgrep uses git ignore: ~/.config/git/ignore
# fd uses ignore: ~/.config/fd/ignore
FD_OPTIONS="--hidden --follow --exclude .git --exclude node_modules --exclude .venv"
export FORGIT_FZF_DEFAULT_OPTS="--layout=reverse"
export FZF_VIM_DIR="$(antidote path junegunn/fzf.vim 2>/dev/null || echo "$HOME/.local/bin/fzf.vim")"
export FZF_DEFAULT_OPTS="
  --height 80% 
  --layout=reverse
  --multi 
  --pointer='›'
  --marker='✓'
  --info=inline 
  --color='pointer:white' 
  --preview-window='right:60%:wrap' 
  --bind='f3:execute(bat --style=numbers {} || less -f {})' 
  --bind='ctrl-x:execute(rm -i {+})+abort' 
  --bind='ctrl-o:become($EDITOR {})'
  --bind='ctrl-/:toggle-preview'
  --bind='ctrl-y:execute-silent(echo {+} | pbcopy),ctrl-l:clear-query' 
  --bind='ctrl-a:select-all,ctrl-q:deselect-all'
  --bind='ctrl-d:half-page-down,ctrl-u:half-page-up'
  --bind='alt-n:preview-half-page-down,alt-p:preview-half-page-up'
  --bind='alt-j:preview-down,alt-k:preview-up'
  --bind='alt-h:preview-top,alt-l:preview-bottom' 
  --bind='alt-w:toggle-preview-wrap'
  "
export FZF_DEFAULT_COMMAND="git ls-files --cached --others --exclude-standard 2>/dev/null || fd --type f --type l $FD_OPTIONS"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS --preview='fzf-preview.sh {}'"
export FZF_ALT_C_COMMAND="fd --type d $FD_OPTIONS"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200' --walker-skip .git,node_modules,.venv"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
    ssh)          fzf "$@" ;;  # no preview
    vim|nvim|v|nv|code) fzf --preview 'fzf-preview.sh {}' "$@" ;;
    *)            fzf --preview 'fzf-preview.sh {}' "$@" ;;
  esac
} 

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

# TODO: remove benchmarking
# zprof

