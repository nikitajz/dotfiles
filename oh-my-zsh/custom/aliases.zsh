alias ea="source venv/bin/activate"
alias ed="deactivate"

vea() {
  source ~/.virtualenvs/$(basename $PWD)/bin/activate
}

alias zshconf="$EDITOR ~/.zshrc"
alias diff="code --diff" # use vscode for diff file

alias t2="tree -L 2"
alias t3="tree -L 3"

## exa
if command -v exa &>/dev/null; then
  alias ls="exa"
  alias ll="exa -lh"
  alias la="exa -alh"
  alias tree="exa --tree"
fi

## bat
# Sometimes bat is installed as batcat.
if command -v batcat >/dev/null; then
	alias cat="batcat"
elif command -v bat >/dev/null; then
	alias cat="bat"
fi

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

alias nv=nvim


alias yaml2js="python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)'"
alias js2yaml="python -c 'import sys, yaml, json; yaml.dump(json.load(sys.stdin), sys.stdout, indent=4)'"

