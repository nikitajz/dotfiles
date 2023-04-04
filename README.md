# dotfiles & environment configuration

## Github
[Add key to keychain](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent)

## Homebrew
Install all apps using Brewfile from this repo  
`brew bundle`

[Brew Bundle Brewfile Tips](https://gist.github.com/ChristopherA/a579274536aab36ea9966f301ff14f3f)

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
#### bat
[bat](https://github.com/sharkdp/bat) is `cat` with highlighting

#### fd
[fd](https://github.com/sharkdp/fd) - A simple, fast and user-friendly alternative to 'find'

#### fzf
[fzf](https://github.com/junegunn/fzf) is a general-purpose command-line fuzzy finder.

#### jq
[jq](https://stedolan.github.io/jq/) - jq is a lightweight and flexible command-line JSON processor.

#### ripgrep
[ripgrep](https://github.com/BurntSushi/ripgrep) - ripgrep recursively searches directories for a regex pattern while respecting your gitignore (replacement for 'grep')

#### zoxide
[zoxide](https://github.com/ajeetdsouza/zoxide) - a smarter cd command. Supports all major shells. A faster alternative to z/z.lua
