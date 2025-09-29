alias g=git
alias gsla="git --no-pager log --oneline --decorate --all --graph -35"

alias zconf="$EDITOR ${ZDOTDIR:-~}/.zshrc"
alias zsource="source $XDG_CONFIG_HOME/zsh/.zshrc"
alias dot="cd ~/.dotfiles/"
alias vscode="code"
alias diff="code --diff" # use vscode for diff file
alias lg="lazygit"
alias pn=pnpm
alias zj=zellij

## eza
if command -v eza &>/dev/null; then
  alias ls="eza"
  alias ll="eza -lh"
  alias la="eza -alh"
  alias tree="eza --tree"
fi

alias tt="tree -L 2"
alias t3="tree -L 3"
alias t4="tree -L 4"

## zoxide
alias z="j" # backward compatibility
# jump to the previous directory
alias jj="j -"
alias zz="z -"

# serverless
alias sls=serverless

# Open Pycharm app for the specified folder (similar to vscode: `code <dir>`)
pycharm() {
  open -a /Applications/PyCharm.app/Contents/MacOS/pycharm $1
}

vij() {
        vim -c ':%!jq' -c 'set filetype=json' $1
}

alias v=nvim
alias nv=nvim

alias yaml2js="python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)'"
alias js2yaml="python -c 'import sys, yaml, json; yaml.dump(json.load(sys.stdin), sys.stdout, indent=4)'"

function ea() {
    if [[ -d venv ]]; then
        source venv/bin/activate
    elif [[ -d .venv ]]; then
        source .venv/bin/activate
    else
        echo "No virtual environment found."
    fi
}
alias ed="deactivate"
