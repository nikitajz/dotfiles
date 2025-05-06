#!/bin/bash
set -euo pipefail

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"

# Source common test functions
source "$SCRIPT_DIR/test_common.sh"

# Ensure required paths are in PATH
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.fzf/bin:$PATH"

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
assert_directory "$HOME/.oh-my-zsh"

# Test oh-my-zsh plugins
for plugin in alias-tips jq; do
    assert_directory "$HOME/.oh-my-zsh/custom/plugins/$plugin"
done
end_test_group "Shell Configuration"

# Test dotfiles configuration
start_test_group "Dotfiles Configuration"
for file in .zshrc .p10k.zsh .gitignore_global; do
    assert_symlink "$HOME/$file"
done
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

# Test shell configuration files
start_test_group "Shell Environment"
assert_contains "$HOME/.zshrc" "export PATH=.*\.local/bin.*PATH"
assert_contains "$HOME/.zshrc" "eval.*zoxide init zsh"
end_test_group "Shell Environment"

# Test PATH configuration
start_test_group "PATH Configuration"
for dir in "$HOME/.local/bin" "$HOME/.cargo/bin"; do
    assert_in_path "$dir"
done
end_test_group "PATH Configuration"

# Final status
if [ $TEST_FAILURES -eq 0 ]; then
    log_success "All test groups completed successfully!"
    exit 0
else
    log_error "Some tests failed. Please check the output above."
    exit 1
fi 