alias gsla="git --no-pager log --oneline --decorate --all --graph -35"

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

vea() {
  source ~/.virtualenvs/$(basename $PWD)/bin/activate
}

alias zshconf="$EDITOR ~/.zshrc"
alias vscode="code"
alias diff="code --diff" # use vscode for diff file

alias t2="tree -L 2"
alias t3="tree -L 3"

## eza
if command -v eza &>/dev/null; then
  alias ls="eza"
  alias ll="eza -lh"
  alias la="eza -alh"
  alias tree="eza --tree"
fi

## bat
# Sometimes bat is installed as batcat.
# if command -v batcat >/dev/null; then
# 	alias cat="batcat"
# elif command -v bat >/dev/null; then
# 	alias cat="bat"
# fi

## zoxide
alias z="j"
# jump to the previous directory
alias jj="j -"
alias zz="z -"

# serverless
alias sls=serverless

vij() {
	vim -c ':%!jq' -c 'set filetype=json' $1
}

# Open Pycharm app for the specified folder (similar to vscode: `code <dir>`)
pycharm() {
  open -a /Applications/PyCharm.app/Contents/MacOS/pycharm $1
}

alias nv=nvim


alias yaml2js="python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)'"
alias js2yaml="python -c 'import sys, yaml, json; yaml.dump(json.load(sys.stdin), sys.stdout, indent=4)'"

