# Complements ~/.config/git/config aliases
# Shell aliases = frequently typed commands (ga, gst, gco)
# Git aliases = complex operations (tree, be, amend, uncommit)
#
# Forgit (https://github.com/wfxr/forgit) - fzf-powered interactive git
#   ga     - git add selector
#   glo    - git log viewer
#   gd     - git diff viewer
#   grh    - git reset HEAD selector
#   gss    - git stash viewer
#   gcf    - git checkout <file> selector
#   gcb    - git checkout <branch> selector
#   gco    - git checkout <commit> selector
#   gbd    - git branch delete selector
#   gclean - git clean selector
#   gcp    - git cherry-pick selector
#   grb    - git rebase selector
#   gbl    - git blame viewer
#   gfu    - git fixup
#   grl    - git reflog
#   gso    - git show
#   gsp    - git stash push
#   gi     - .gitignore generator
#   gct    - git checkout <tag>
#   grc    - git revert <commit>

alias gst='git status'
# gss='git status -sb' (defined by **forgit**)

## Add
# ga='git add' (defined by **forgit**)
alias gaa='git add --all'
alias gap='git add --patch' # choose hunks to add
alias gau='git add --update' # only already tracked files

## Commit
alias gc='git commit -v'
alias gca='git commit -v --all' # auto-stage files
alias gcm='git commit -m -v' # <commit message>
alias gcam='git commit -am'
alias gcu='git commit --amend --no-edit' # update

## Branch
alias gb='git branch'
alias gba='git branch -a'
alias gbe='git be' # extended info: author, date, ahead/behind
# gbd='git branch -d' (defined by **forgit**)
alias gbD='git branch -D' # delete force
alias gbm='git branch -m' # <old_branch> <new_branch> move/rename

## Checkout & Switch
# gco='git checkout' (defined by **forgit**)
# gcb='git checkout -b' (defined by **forgit**)
alias gw='git switch'
alias gsw='git switch'
alias gswc='git switch -c' # <branch> # create branch == 'gcb'

## Diff
# gd='git diff' (defined by **forgit**)
alias gds='git diff --stat'
alias gdc='git diff --cached'
alias gdw='git diff --word-diff'
alias gdt='git difftool' # open vscode

## Push & Pull
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpsup='git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD 2>/dev/null)'
alias gu='git pull'
alias gup='git pull --rebase'

## Fetch & Remote
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfo='git fetch origin'
alias gsync='git fetch origin && git remote prune origin'

## Log
# glo='git log --oneline --decorate' (defined by **forgit**)
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glol='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
alias glola='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'
# Note: git config has tree, graph, ls, ll, ld, lds, ldr, structure, last

## Stash
alias gstp='git stash push'
alias gsta='git stash apply'
alias gsto='git stash pop'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gsts='git stash show --text'
alias gstc='git stash clear'

## Rebase
# grb='git rebase' (defined by **forgit**)
alias grbi='git rebase -i'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbs='git rebase --skip'

## Merge
alias gm='git merge'
alias gma='git merge --abort'
alias gms='git merge --squash'

## Cherry-pick
# gcp='git cherry-pick' (defined by **forgit**)
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'

## Reset & Clean
alias gr='git reset'
# grh='git reset --hard' (defined by **forgit**)
# gclean='git clean -id' (defined by **forgit**)
alias gpristine='git reset --hard && git clean -dffx'
# Note: git config has 'undo', 'res', 'uncommit', 'unstage'

## Worktree
alias gw='git worktree'
alias gwa='git worktree add'
alias gwl='git worktree list'
alias gwls='git worktree list'
alias gwrm='git worktree remove'

## Tags
alias gt='git tag'
alias gta='git tag -a' # annotate
alias gtd='git tag -d'
alias gtl='git tag -l'

## Bisect - redundant for now

# Helper Functions

## Get current branch name
gcurrent() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null
}

## Push current branch to origin
## 'gg' = "git go"
ggp() {
  local branch=$(gcurrent)
  if [[ -n "$branch" ]]; then
    git push origin "$branch" "$@"
  else
    echo "Not on a branch"
    return 1
  fi
}

## Force push current branch (with lease)
ggpf() {
  local branch=$(gcurrent)
  if [[ -n "$branch" ]]; then
    git push --force-with-lease origin "$branch" "$@"
  else
    echo "Not on a branch"
    return 1
  fi
}

## Pull current branch from origin
ggl() {
  local branch=$(gcurrent)
  if [[ -n "$branch" ]]; then
    git pull origin "$branch" "$@"
  else
    echo "Not on a branch"
    return 1
  fi
}

## Clone and cd into repo
gclone() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: gccd <repository-url>"
    return 1
  fi
  git clone "$@" && cd "$(basename "$1" .git)"
}

## Show git aliases (shell, forgit, and git config)
galiases() {
  echo "=== Shell Git Aliases ==="
  alias | grep '^g[a-z]*=' | sort

  echo "\n=== Forgit Aliases (fzf-powered interactive) ==="
  alias | grep "forgit::" | sort

  echo "\n=== Git Config Aliases ==="
  git aliases 2>/dev/null || git config --get-regexp '^alias\.' | sed 's/^alias\.//' | sort
}

## Undo last commit but keep changes staged
gundo() {
  git reset --soft HEAD~1
}

# Show what would be pushed
gwhat() {
  local branch=$(gcurrent)
  if [[ -n "$branch" ]]; then
    git log origin/$branch..$branch --oneline
  else
    echo "Not on a branch"
    return 1
  fi
}
