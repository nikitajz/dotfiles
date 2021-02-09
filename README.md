# dotfiles & environment configuration

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

## Tools
#### bat
[bat](https://github.com/sharkdp/bat) is `cat` with highlighting

#### fzf
[fzf](https://github.com/junegunn/fzf) is a general-purpose command-line fuzzy finder.
