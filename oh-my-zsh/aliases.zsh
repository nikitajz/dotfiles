alias python="python3.11"
alias pip="python3.11 -m pip"

alias ea="source venv/bin/activate"
alias vea="source ~/.virtualenvs/$(basename $PWD)/bin/activate"
alias ed="deactivate"

alias zshconf="$EDITOR ~/.zshrc"

# serverless
alias sls=serverless

vij() {
	vim -c ':%!jq' -c 'set filetype=json' $1
}


alias yaml2js="python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=4)'"
alias js2yaml="python -c 'import sys, yaml, json; yaml.dump(json.load(sys.stdin), sys.stdout, indent=4)'"

