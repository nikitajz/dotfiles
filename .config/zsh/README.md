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
- `aliases.zsh`: Contains custom aliases and functions

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

## Installation

Antidote is installed automatically by the `install_ubuntu.sh` or `install_macos.sh` scripts. It can be installed:

- Via Homebrew on macOS: `brew install antidote`
- Via Git on any system: `git clone --depth=1 https://github.com/mattmc3/antidote.git ${XDG_DATA_HOME:-$HOME/.local/share}/antidote`
