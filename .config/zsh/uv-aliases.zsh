# uv – shorter aliases (uv-prefixed aliases provided by ohmyzsh/uv plugin)
# https://gist.github.com/nikitagor-zen/30412f98f942b376b48c3a06c6b0f8fb
if (( ! ${+commands[uv]} )); then
  return
fi

# Project
alias ui='uv init'
alias uinw='uv init --no-workspace'
alias ur='uv run'
alias utr='uv tree'

# Dependencies
alias ua='uv add'
alias urm='uv remove'
alias ul='uv lock'
alias ulr='uv lock --refresh'
alias ulu='uv lock --upgrade'
alias us='uv sync'
alias usr='uv sync --refresh'
alias usu='uv sync --upgrade'
alias uexp='uv export --format requirements-txt'

# Python versions
alias py='uv python'
alias upy='uv python'
alias upi='uv python install'
alias upu='uv python uninstall'
alias upl='uv python list'
alias upp='uv python pin'

# Tools & environments
alias up='uv pip'
alias ux='uv tool run'
alias uti='uv tool install'
alias utl='uv tool list'
alias utu='uv tool uninstall'
alias utup='uv tool upgrade'
alias uve='uv venv'
alias uup='uv self update'
