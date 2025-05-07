eval "$(/opt/homebrew/bin/brew shellenv)"

# pnpm
export PNPM_HOME="${HOME}/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# rust
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Preferred editor for local and remote sessions
export EDITOR='nvim'
[[ -n $SSH_CONNECTION ]] && export EDITOR='vim'
