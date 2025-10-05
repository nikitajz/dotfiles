# dotfiles & environment configuration

What's dotfiles:
<https://dotfiles.github.io/>

## History

The initial setup was using Oh-My-Zsh, but it's too bloated and doesn't provide well-optimized setup.
Now it's using [Antidote](https://antidote.sh/) as plugin manager and [Zephyr](https://github.com/mattmc3/zephyr) for key plugins for proper defaults. It has limited support for non-core OMZ plugins if needed (with optional `getantidote/use-omz` for more).

Since the setup is constantly evolving, the following tools are considered deprecated:

- `pyenv`, `pip` & friends (replaced by `uv`)
- `black`, `flake`, etc (replaced by `ruff`)
- `nvm`` (replaced by`n`)

## Initial setup and configuration

### MacOS

```bash
git clone https://github.com/nikitajz/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install_macos.sh
```

Installs Homebrew, packages (via Brewfile), Antidote, and links dotfiles using [GNU Stow](https://www.gnu.org/software/stow/).

Optional: [setup-macos.sh](setup-macos.sh) - Configure macOS defaults

### Ubuntu

```bash
git clone https://github.com/nikitajz/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install_ubuntu.sh
```

Installs packages via apt (from apt-pkglist), sets up shell tools, and links dotfiles using Stow (if available).

## Dotfiles Management

Dotfiles are managed with [GNU Stow](https://www.gnu.org/software/stow/), creating symlinks from `~/.dotfiles` to your home directory.

**Aliases** (available after installation):

- `dotlink` - Apply/update dotfiles symlinks
- `dotdrylink` - Dry-run (preview changes without applying)

**Manual linking**:

```bash
cd ~/.dotfiles
stow --restow --no-folding -t ~ .
```

## Configuration Structure

Follows the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html):

- `$XDG_CONFIG_HOME` (`~/.config`) - Configuration files
- `$XDG_DATA_HOME` (`~/.local/share`) - Data files
- `$XDG_CACHE_HOME` (`~/.cache`) - Cache files
- `$XDG_STATE_HOME` (`~/.local/state`) - State files

Tool: [xdg-ninja](https://github.com/b3nj5m1n/xdg-ninja) helps audit XDG compliance

### Zsh Configuration

The shell configuration uses [Antidote](https://github.com/mattmc3/antidote) for plugin management.

- `.zshenv`: Sourced by all zsh sessions (login, interactive, scripts). Use this for environment variables and universal settings that should always be set, regardless of how zsh is started.
- `.zprofile`: Sourced for login shells only (like `.profile` in bash). Use this for commands that should run only at login (e.g., starting agents, setting up the environment for login shells).
- `.zshrc` : Main zsh configuration (sourced for interactive shells; put aliases, functions, prompt, etc. here)
- `zsh_plugins.txt`: Plugins list, managed by antidote
- `$XDG_CONFIG_HOME/zsh/`: Contains additional configs (aliases, etc)

Antidote supports Oh My Zsh plugins seamlessly (specified in `zsh_plugins.txt`).

## Windows manager

[Rectangle](https://rectangleapp.com/) or Rectangle Pro

<details>
<summary> Alternative option using built-in macOS functions, but limited to basic </summary>

| Menu Title                          | Keyboard Shortcut  |
|-------------------------------------|--------------------|
| Move Window to Left Side of Screen  | Cmd + Shift + <-   |
| Move Window to Right Side of Screen | Cmd + Shift + ->   |
| Tile Window to Left of Screen       | Cmd + Alt + <-     |
| Tile Window to Right of Screen      | Cmd + Alt + ->     |
| Move to LG HDR 4K Display           | Cmd + Ctrl + ->    |
| Move to Built-in Retina Display     | Cmd + Ctrl + <-    |
| Revert                              | Cmd + Shift + Down |

<https://apple.stackexchange.com/a/212607>
<https://apple.stackexchange.com/a/377092>
</details>

## CLI tools

[bat](https://github.com/sharkdp/bat) is `cat` with highlighting

[eza](https://github.com/eza-community/eza) - A modern replacement for `ls` ([exa](https://github.com/ogham/exa)  is not maintained anymore)

[entr](https://github.com/eradman/entr) - Run arbitrary commands when files change

[fd](https://github.com/sharkdp/fd) - A simple, fast and user-friendly alternative to 'find'

[fzf](https://github.com/junegunn/fzf) is a general-purpose command-line fuzzy finder.

[forgit](https://github.com/wfxr/forgit) - interactive git aliases powered by `fzf`

[jq](https://stedolan.github.io/jq/) - jq is a lightweight and flexible command-line JSON processor.

[ripgrep](https://github.com/BurntSushi/ripgrep) - ripgrep recursively searches directories for a regex pattern while respecting your gitignore (replacement for 'grep')

[zoxide](https://github.com/ajeetdsouza/zoxide) - a smarter `cd` command. A faster alternative to z/z.lua

### Links

<https://github.com/ibraheemdev/modern-unix>
<https://jvns.ca/blog/2022/04/12/a-list-of-new-ish--command-line-tools/>

### fzf keymaps

This is a mix of standard hotkeys and custom set in the .zshrc

Activate **fzf**:
`CTRL-T` - Paste the selected files and directories onto the command-line
`CTRL-R` - Paste the selected command from history onto the command-line
`OPT-C` - cd into the selected directory
`OPT+J` - interactive `jq` (type for example `cat example.json` and then `OPT+J`). Requires `jq` to be installed

Shortcuts in `fzf`:

#### General

| Hotkey  | Command                |
|---------|------------------------|
| ctrl-x  | remove (file)          |
| ctrl-/  | toggle preview         |
| f3      | toggle bat/les preview |
| ctrl-o  | run $EDITOR            |

#### Navigation

| Hotkey | Command           |
|--------|-------------------|
| ctrl-j | scroll down       |
| ctrl-k | scroll up         |
| ctrl-d | half-page-down    |
| ctrl-u | half-page-up      |
| ctrl-a | beginning-of-line |
| ctrl-e | end-of-line       |
| alt-b  | backward-word     |
| alt-f  | forward-word      |

#### Editing

| Hotkey  | Command                               |
|---------|---------------------------------------|
| ctrl-w: | delete prev word (backward-kill-word) |
| alt-bs  | delete prev word (backward-kill-word) |
| alt-d   | delete word (kill-word)               |
| ctrl-l  | clear screen                          |
| ctrl-y  | copy  (yank)                          |
| ctrl-x  | delete selected file                  |

#### Navigation in Preview

| Hotkey     | Command                |
|------------|------------------------|
| shift-up   | up                     |
| shift-down | down                   |
| alt-j      | down                   |
| alt-k      | up                     |
| alt-p      | preview-half-page-down |
| alt-n      | preview-half-page-up   |
| alt-h      | preview-top            |
| alt-l      | preview-bottom         |
| alt-w      | toggle-preview-wrap    |

### Zoxide

`jj`/`zz` jump to previous directory
`j`/`z` `+tab` - disambiguate (choose) if z has few options where to jump
Tip: Using the same command twice jump to the next directory that matches

## Karabiner Elements

[Karabiner Elements](https://karabiner-elements.pqrs.org/) (KE) allows to supercharge keyboard shortcuts to maximum.
See example: <https://wiki.nikiv.dev/macOS/apps/karabiner/>

#### j+k -> Escape

Press `j+k` simultaneously to activate `Escape`

| Hotkey | Command |
|--------|---------|
| j+k    | Escape  |

#### Hyperkey

Hyperkey (*) is a combination of all right keys (RShift+RCtrl+ROpt+RCmd)
It's used as a modifier key to create custom shortcuts. This configuration uses physical CapsLock key to act as Hyperkey.

Tap: `Esc`
Hold: `RShift+RCtrl+ROpt+RCmd` (all right keys)- serve as Hyperkey modifier

Activate CapsLock:
`CapsLock + Esc`
`Left Shift + Right Shift` (alternative)

| Hotkey          | Command  |
|-----------------|----------|
| Hyper+Cmd+Space | Emoji 😜 |

#### Hyper Applications

Run/activate applications

| Hotkey | Command                        |
|--------|--------------------------------|
| *+w    | Chrome ([w]eb surfing)         |
| *+e    | Chrome m[e]et.google.com       |
| *+a    | [A]rc                          |
| *+s    | [S]potify                      |
| *+d    | [D]ictionary                   |
| *+f    | [F]inder                       |
| *+c    | Py[C]harm                      |
| *+v    | [V]SCode                       |
| *+t    | i[T]erm2                       |
| *+g    | [G]hostty (quick, via .config) |
| *+h    | G[h]ostty                      |
| *+i    | Msty (a[i] chat)               |
| *+u    | C[u]rsor                       |
| *+z    | [Z]ed                          |
| *+x    | Notion                         |
| *+n    | Telegram ([n]ear m)            |
| *+m    | Slack ([m]essenger)            |

Raycast:
These shortcuts are configured in Raycast app (but require Hyperkey to be set in Karabiner Elements)

| Hotkey | Command                                      |
|--------|----------------------------------------------|
| *+j    | Raycast hotkey (main)                        |
| *+l    | Locate Files with File Search (Raycast)      |
| *+d    | Define word (Raycast)                        |

#### Hyper Navigation

Activates navigation with inverted T-shape key cluster (jikl) when Hyperkey+LCmd are hold
`Hyper+LCmd+<key>`

| Hotkey             | Command                                     |
|--------------------|---------------------------------------------|
| Hyper+LCmd+j       | left                                        |
| Hyper+LCmd+k       | down                                        |
| Hyper+LCmd+i       | up                                          |
| Hyper+LCmd+l       | right                                       |
| Hyper+LCmd+Shift+j | shift+left (select character to the left)   |
| Hyper+LCmd+Shift+k | shift+down (select line down)               |
| Hyper+LCmd+Shift+i | shift+up (select line up)                   |
| Hyper+LCmd+Shift+l | shift+right (select character to the right) |
| Hyper+LCmd+u       | PgUp                                        |
| Hyper+LCmd+o       | PgDown                                      |
| Hyper+;            | backspace (works with Opt/Cmd as well)      |
| Hyper+'            | Escape (works with Opt/Cmd as well)         |

## Other

### Python uses `uv` by default

[uv](https://github.com/astral-sh/uv) is a modern Python packaging and environment management tool that replaces multiple traditional tools (but still compatible with `pip` and `venv`):

- `pip` for package installation
- `virtualenv`/`venv` for virtual environments
- `pip-tools` for dependency management
- `poetry`/`pipenv` for project management

Key benefits:

- Superior performance (written in Rust and clever optimizations)
- Compatible with existing Python tooling
- Unified interface for all Python packaging needs
- Significantly faster than traditional tools
- Built-in virtual environment management

### Use `n` instead of `nvm`

`nvm` is notorious for it's slowdown of shell startup:
<https://github.com/nvm-sh/nvm/issues/2724>
Despite it's possible to [make it faster by using lazy load](https://dev.to/thraizz/fix-slow-zsh-startup-due-to-nvm-408k), it's better to use <https://github.com/tj/n> instead

### Use `pnpm` instead of `npm`

[pnpm](https://pnpm.io/) is a fast, disk space efficient package manager for Node.js that:

- Uses hard links and a content-addressable store to save disk space
- Enforces strict dependency management
- Maintains compatibility with npm ecosystem
- Significantly faster than npm and yarn

## Misc

### Github

[Add key to keychain](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent)
`git config --global core.excludesfile ~/.gitignore`

## Manual configuration

<details>
<summary>Previous manual instructions</summary>

### Homebrew

Install all apps using [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle) listed in Brewfile and Brewfile.extras
`brew bundle` (part of [setup_macos.sh](setup_macos.sh))

[Brew Bundle Brewfile Tips](https://gist.github.com/ChristopherA/a579274536aab36ea9966f301ff14f3f)

### Fonts

[Fira Code](https://github.com/tonsky/FiraCode) is a good choice

Use a patched version (`*--nerd-font`) to include various glyphs and icons (already included in Brewfile)

Patched variant

```shell
brew cask install font-firacode-nerd-font
```

Original font

```shell
brew cask install font-fira-code
```

Might require additional [setup in other apps, e.g. JetBrains products, VSCode, etc](https://github.com/romkatv/powerlevel10k/blob/master/README.md#manual-font-installation)

### Fonts smoothing

```shell
defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO
defaults -currentHost write -g AppleFontSmoothing -int 0
```

<https://www.reddit.com/r/MacOSBeta/comments/jiwwga/big_sur_font_smoothing_antialiasing/>
<https://osxdaily.com/2022/04/06/change-remove-font-smoothing-macos/>

### Spellchecking

Install Ukrainian spellchecking (included in installation script)
<https://github.com/titoBouzout/Dictionaries>
copy to $HOME/Library/Spelling

### Useful links

[Selected fonts by Joshukraine](https://github.com/joshukraine/dotfiles#my-favorite-programming-fonts)
[Programming fonts - Test Drive](https://app.programmingfonts.org/)

### MacOS System Preferences

Most of the settings can be set using `defaults` command line. See [setup-macos.sh](setup-macos.sh) for details.

References:
<https://www.defaults-write.com/>
<https://macos-defaults.com/>
[macOS Commands Reference.md](https://gist.github.com/nikitajz/8ff97fb3e10a8949a2833c0ead7c8263)

</details>
