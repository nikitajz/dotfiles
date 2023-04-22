# dotfiles & environment configuration

## Github
[Add key to keychain](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent)

## Homebrew
Install all apps using Brewfile from this repo  
`brew bundle`

[Brew Bundle Brewfile Tips](https://gist.github.com/ChristopherA/a579274536aab36ea9966f301ff14f3f)

## Fonts
[Fira Code](https://github.com/tonsky/FiraCode) is a good choice

Use a patched version to include various glyphs and icons (already included in Brewfile)
```
# Original font
$ brew cask install font-fira-code

# Patched variant
$ brew cask install font-firacode-nerd-font
```
Might require additional [setup in other apps, e.g. JetBrains products, VSCode, etc](https://github.com/romkatv/powerlevel10k/blob/master/README.md#manual-font-installation)

## Spellchecking
Install Ukrainial spellchecking (included in installation script)
https://github.com/titoBouzout/Dictionaries
copy to $HOME/Library/Spelling

### Useful links
[Selected fonts by Joshukraine](https://github.com/joshukraine/dotfiles#my-favorite-programming-fonts)
[Programming fonts - Test Drive](https://app.programmingfonts.org/)

## Conda autocomplete for zsh:
https://github.com/esc/conda-zsh-completion

## Mac
### Hotkeys for window tiles:  
Menu Title | Keyboard Shortcut
---------- | -----------------
Move Window to Left Side of Screen | Cmd + Shift + <-
Move Window to Right Side of Screen | Cmd + Shift + ->
Tile Window to Left of Screen | Cmd + Alt + <-
Tile Window to Right of Screen | Cmd + Alt + ->
Move to LG HDR 4K Display | Cmd + Ctrl + ->
Move to Built-in Retina Display | Cmd + Ctrl + <-
Revert | Cmd + Shift + Down

https://apple.stackexchange.com/a/212607  
https://apple.stackexchange.com/a/377092

### Fonts smoothing: 
`defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO`   
`defaults -currentHost write -g AppleFontSmoothing -int 0`  
https://www.reddit.com/r/MacOSBeta/comments/jiwwga/big_sur_font_smoothing_antialiasing/  
https://osxdaily.com/2018/09/26/fix-blurry-thin-fonts-text-macos-mojave/

## CLI tools
[bat](https://github.com/sharkdp/bat) is `cat` with highlighting

[fd](https://github.com/sharkdp/fd) - A simple, fast and user-friendly alternative to 'find'

[fzf](https://github.com/junegunn/fzf) is a general-purpose command-line fuzzy finder.

[jq](https://stedolan.github.io/jq/) - jq is a lightweight and flexible command-line JSON processor.

[ripgrep](https://github.com/BurntSushi/ripgrep) - ripgrep recursively searches directories for a regex pattern while respecting your gitignore (replacement for 'grep')

[zoxide](https://github.com/ajeetdsouza/zoxide) - a smarter cd command. Supports all major shells. A faster alternative to z/z.lua


### fzf keymaps
*Navigation*
ctrl-j:     scroll down
ctrl-k:     scroll up
ctrl-d:     half-page-down
ctrl-u:     half-page-up

ctrl-a:     beginning-of-line
ctrl-e:     end-of-line
alt-b:      backward-word
alt-f:      forward-word

Editing
ctrl-w:     delete prev word (backward-kill-word)
alt-bs:     delete prev word (backward-kill-word)
alt-d:      delete word (kill-word)
ctrl-l:     clear screen

ctrl-y:     yank (copy)
ctrl-x:     delete selected file

**Navigation Preview**
shift-up:   up
shift-down: down
alt-j:      preview-half-page-down
alt-k:      preview-half-page-up
alt-h:      preview-top
alt-l:      preview-bottom

alt-w:      toggle-preview-wrap


