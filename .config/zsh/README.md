# ZSH Configuration with Antidote

This directory contains the ZSH configuration files for the dotfiles repository.

## Migration from Oh My Zsh to Antidote

The dotfiles repository has migrated from Oh My Zsh to [Antidote](https://github.com/mattmc3/antidote) as the plugin manager. This change provides:

- Faster startup times
- Simpler configuration
- XDG compliance
- Better plugin management

## Structure

- `.zsh_plugins.txt`: Contains the list of plugins to be loaded by Antidote
- `.zshrc`: Main ZSH configuration file
- `aliases.zsh`: Contains custom aliases and functions
- `git-aliases.zsh`: Git-specific aliases

## Oh My Zsh Plugins

We still use some Oh My Zsh plugins, but they are now managed through Antidote. You can see the configuration in `.zsh_plugins.txt`:

```
# OMZ plugins through Antidote
getantidote/use-omz        # handle OMZ dependencies
ohmyzsh/ohmyzsh path:lib   # load OMZ's library, including git.zsh
ohmyzsh/ohmyzsh path:plugins/git
ohmyzsh/ohmyzsh path:plugins/aws
ohmyzsh/ohmyzsh path:plugins/uv
```

## Prompt Configuration

### Starship with Transient Prompt

The configuration uses [Starship](https://starship.rs/) prompt.
It's much easier to configure then [powerlevel10k](https://github.com/romkatv/powerlevel10k) which also is on bare-minimum maintenance mode.
By default doesn't support transient prompt for zsh, hence support is via [zsh-transient-prompt](https://github.com/olets/zsh-transient-prompt).

**Features:**

- Current prompt: Full 2-line Starship prompt with directory, git status, and context
- Past prompts: Simplified 1-line display showing only `❯` (success) or `✗` (error)

**Configuration:**

- Starship config: `~/.config/starship.toml`
- Transient prompt setup: `.zshrc` (after Starship initialization)

## Installation

Antidote is installed automatically by the `install_ubuntu.sh` or `install_macos.sh` scripts. It can be installed:

- Via Homebrew on macOS: `brew install antidote`
- Via Git on any system: `git clone --depth=1 https://github.com/mattmc3/antidote.git ${XDG_DATA_HOME:-$HOME/.local/share}/antidote`

Starship can be installed via:

- Homebrew: `brew install starship`
- Official installer: `curl -sS https://starship.rs/install.sh | sh`
