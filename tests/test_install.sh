#!/bin/bash
set -euo pipefail

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"

# Source user zsh environment (loads XDG dirs, PATH, etc.)
if [ -f "$HOME/.zshenv" ]; then
  # shellcheck disable=SC1090
  source "$HOME/.zshenv"
fi
if [ -f "$HOME/.config/zsh/.zshenv" ]; then
  source "$HOME/.config/zsh/.zshenv"
fi

# Add debug information AFTER sourcing environment
echo "==== DEBUG INFO ===="
echo "PATH: $PATH"
echo "Current user: $(whoami)"
echo "HOME directory: $HOME"
echo "XDG variables:"
echo "  XDG_CONFIG_HOME: ${XDG_CONFIG_HOME:-not set}"
echo "  XDG_DATA_HOME: ${XDG_DATA_HOME:-not set}"
echo "  XDG_CACHE_HOME: ${XDG_CACHE_HOME:-not set}"
echo "  XDG_STATE_HOME: ${XDG_STATE_HOME:-not set}"
echo "Cargo:"
echo "  CARGO_HOME: ${CARGO_HOME:-not set}"
echo "Tools availability:"
echo "  zoxide: $(which zoxide 2>/dev/null || echo "not found in PATH")"
echo "===================="

# Source common test functions
source "$SCRIPT_DIR/test_common.sh"

log_info "Running installation verification tests..."

# Test essential tools
start_test_group "Essential Tools"
for cmd in zsh git curl wget; do
    assert_command "$cmd"
done
end_test_group "Essential Tools"

# Test optional tools
start_test_group "Optional Tools"
if [ "${OPTIONAL:-yes}" = "yes" ]; then
    # Test fzf (multiple possible locations)
    assert_true "fzf is available" "command -v fzf >/dev/null 2>&1 || [ -x '$HOME/.fzf/bin/fzf' ] || [ -x '/usr/local/bin/fzf' ]"
    
    # Test other optional tools
    for cmd in fd rg zoxide nvim uv; do
        assert_command "$cmd"
    done
else
    log_info "Optional tools testing skipped (OPTIONAL=no)"
fi
end_test_group "Optional Tools"

# Test shell configuration
start_test_group "Shell Configuration"
assert_directory "$XDG_DATA_HOME/antidote"

# Test shell plugins directory
assert_directory "$XDG_CONFIG_HOME/zsh"
assert_file "$XDG_CONFIG_HOME/zsh/.zsh_plugins.txt"
assert_file "$XDG_CONFIG_HOME/zsh/aliases.zsh"
end_test_group "Shell Configuration"

# Test dotfiles configuration (XDG compliant)
start_test_group "Dotfiles Configuration"
assert_symlink "$HOME/.zshenv"

assert_symlink "$XDG_CONFIG_HOME/git/ignore"
assert_directory "$XDG_CONFIG_HOME/zsh"
assert_symlink "$XDG_CONFIG_HOME/zsh/.zshrc"
assert_symlink "$XDG_CONFIG_HOME/zsh/.p10k.zsh"
end_test_group "Dotfiles Configuration"

# Test Neovim installation
start_test_group "Neovim Configuration"
assert_command "nvim"
if [ "${LAZYVIM:-no}" = "yes" ]; then
    assert_directory "$HOME/.config/nvim"
else
    log_info "Skipping LazyVim configuration check (LAZYVIM=no)"
fi
end_test_group "Neovim Configuration"

# Test interactive shell behavior
start_test_group "Interactive Shell"
assert_true "Interactive zsh includes ~/.local/bin in PATH" "zsh -i -c '[[ ":\$PATH:" == *":$HOME/.local/bin:"* ]]'"
assert_true "zoxide works in interactive shell" "zsh -i -c 'command -v zoxide >/dev/null'"
assert_true "uv works in interactive shell" "zsh -i -c 'command -v uv >/dev/null'"
end_test_group "Interactive Shell"

# Test PATH configuration
start_test_group "PATH Configuration"
assert_in_path "$HOME/.local/bin"
# Note: We don't test for Cargo bin directories in PATH since tools like zoxide
# can be installed via Homebrew instead. The important thing is that the tools work.
end_test_group "PATH Configuration"

# Test XDG directories
start_test_group "XDG Compliance"

# Create XDG directories if they don't exist (as applications should)
mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"

assert_directory "$XDG_CONFIG_HOME"
assert_directory "$XDG_CACHE_HOME"
assert_directory "$XDG_DATA_HOME"
assert_directory "$XDG_STATE_HOME"

assert_directory "$XDG_CONFIG_HOME/zsh"
# Only check nvim config if LazyVim was configured
if [ "${LAZYVIM:-no}" = "yes" ]; then
    assert_directory "$XDG_CONFIG_HOME/nvim"
fi
assert_directory "$XDG_CONFIG_HOME/git"
assert_directory "$XDG_CACHE_HOME/zsh"
assert_directory "$XDG_DATA_HOME/antidote"
# Note: We don't test for Cargo/Rustup directories since they're only needed if Rust is installed
end_test_group "XDG Compliance"

# Final status
if [ $TEST_FAILURES -eq 0 ]; then
    log_success "All test groups completed successfully!"
    exit 0
else
    log_error "Some tests failed. Please check the output above."
    exit 1
fi 