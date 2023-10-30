# dotfiles & environment configuration

What's dotfiles:
<https://dotfiles.github.io/>

## Initial setup and configuration

There are 2 main scripts to configure fresh setup:

[install_macOS.sh](install_macos.sh)  
Install Brew, Pyenv, fzf, oh-my-zsh and install other packages using [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle)

[setup-macos.sh](setup-macos.sh)  
Configure macos using defaults (see <https://macos-defaults.com/>)

### Github

[Add key to keychain](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent)  
`git config --global core.excludesfile ~/.gitignore`

### Fonts smoothing

```shell
defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO  
defaults -currentHost write -g AppleFontSmoothing -int 0  
```

<https://www.reddit.com/r/MacOSBeta/comments/jiwwga/big_sur_font_smoothing_antialiasing/>  
<https://osxdaily.com/2022/04/06/change-remove-font-smoothing-macos/>

<details>
<summary>Previous manual instructions</summary>

#### Homebrew

Install all apps using [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle) listed Brewfile  
`brew bundle` (part of [setup_macos.sh](setup_macos.sh))

[Brew Bundle Brewfile Tips](https://gist.github.com/ChristopherA/a579274536aab36ea9966f301ff14f3f)

#### Fonts

[Fira Code](https://github.com/tonsky/FiraCode) is a good choice

Use a patched version to include various glyphs and icons (already included in Brewfile)

Patched variant

```shell
brew cask install font-firacode-nerd-font
```

Original font

```shell
brew cask install font-fira-code
```

Might require additional [setup in other apps, e.g. JetBrains products, VSCode, etc](https://github.com/romkatv/powerlevel10k/blob/master/README.md#manual-font-installation)

## Spellchecking

Install Ukrainian spellchecking (included in installation script)
https://github.com/titoBouzout/Dictionaries
copy to $HOME/Library/Spelling

### Useful links

[Selected fonts by Joshukraine](https://github.com/joshukraine/dotfiles#my-favorite-programming-fonts)
[Programming fonts - Test Drive](https://app.programmingfonts.org/)

## Conda autocomplete for zsh

https://github.com/esc/conda-zsh-completion

## Mac

### System Preferences

Most of the settings can be set using `defaults` command line. See [setup-macos.sh](setup-macos.sh) for details.

References:  
https://www.defaults-write.com/  
https://macos-defaults.com/  
[macOS Commands Reference.md](https://gist.github.com/nikitajz/8ff97fb3e10a8949a2833c0ead7c8263)

</details>

## CLI tools

[bat](https://github.com/sharkdp/bat) is `cat` with highlighting

[eza](https://github.com/eza-community/eza) - A modern replacement for `ls` ([exa](https://github.com/ogham/exa)  is not maintained anymore)

[entr](https://github.com/eradman/entr) - Run arbitrary commands when files change

[fd](https://github.com/sharkdp/fd) - A simple, fast and user-friendly alternative to 'find'

[fzf](https://github.com/junegunn/fzf) is a general-purpose command-line fuzzy finder.

[jq](https://stedolan.github.io/jq/) - jq is a lightweight and flexible command-line JSON processor.

[ripgrep](https://github.com/BurntSushi/ripgrep) - ripgrep recursively searches directories for a regex pattern while respecting your gitignore (replacement for 'grep')

[zoxide](https://github.com/ajeetdsouza/zoxide) - a smarter cd command. A faster alternative to z/z.lua

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

| Hotkey    | Command          |
|-----------|------------------|
| ctrl-x    | remove           |
| f2/ctrl-v | toggle preview   |
| f3        | bat/less preview |
| f4/ctrl-o | run $EDITOR      |

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
| ctrl-y  | yank (copy)                           |
| ctrl-x  | delete selected file                  |

#### Navigation in Preview

| Hotkey     | Command                |
|------------|------------------------|
| shift-up   | up                     |
| shift-down | down                   |
| alt-j      | preview-half-page-down |
| alt-k      | preview-half-page-up   |
| alt-h      | preview-top            |
| alt-l      | preview-bottom         |
| alt-w      | toggle-preview-wrap    |

### Zoxide

`jj`/`zz` jump to previous directory
`j`/`z` `+tab` - disambiguate (choose) if z has few options where to jump
Tip: Using the same command twice jump to the next directory that matches

## Windows manager

[Rectangle](https://rectangleapp.com/)

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

https://apple.stackexchange.com/a/212607  
https://apple.stackexchange.com/a/377092
</details>

### Karabiner Elements

[Karabiner Elements](https://karabiner-elements.pqrs.org/) (KE) allows to supercharge keyboard shortcuts to maximum.  
See example: <https://wiki.nikiv.dev/macOS/apps/karabiner/>

#### CapsLock

Tap: `Esc`  
Hold: `RShift+RCtrl+ROpt+RCmd` (all right keys)- serve as Hyperkey modifier

Activate CapsLock:  
`Left Shift + Right Shift`
`CapsLock + Esc` (alternative)

| Hotkey          | Command  |
|-----------------|----------|
| Hyper+Cmd+Space | Emoji 😜 |

#### Meh

Run/activate applications  
`Meh = CapsLock+Cmd`

| Hotkey | Command                         |
|--------|---------------------------------|
| Meh+w  | Chrome ([w]eb surfing)          |
| Meh+e  | Chrome m[e]et.google.com        |
| Meh+s  | [S]lack                         |
| Meh+d  | [D]ictionary                    |
| Meh+f  | [F]inder                        |
| Meh+c  | Py[C]harm                       |
| Meh+v  | [V]SCode                        |
| Meh+t  | i[T]erm2 - open new             |
| Meh+i  | [i]Term2 - focus on existing    |
| Meh+y  | Amphetamine* (who knows wh[y]?) |
| Meh+k  | [K]arabiner                     |
| Meh+m  | Spotify ([m]usic)               |
| Meh+h  | Das[h]*                         |

#### Hyper Navigation

Activates navigation with inverted T-shape key cluster (jikl) when Hyperkey is hold  
`Hyper+<key>`

| Hotkey        | Command                                     |
|---------------|---------------------------------------------|
| Hyper+j       | left                                        |
| Hyper+k       | down                                        |
| Hyper+i       | up                                          |
| Hyper+l       | right                                       |
| Hyper+Shift+j | shift+left (select character to the left)   |
| Hyper+Shift+k | shift+down (select line down)               |
| Hyper+Shift+i | shift+up (select line up)                   |
| Hyper+Shift+l | shift+right (select character to the right) |
| Hyper+;       | backspace (works with Opt/Cmd as well)      |
| Hyper+u       | PgUp                                        |
| Hyper+o       | PgDown                                      |
