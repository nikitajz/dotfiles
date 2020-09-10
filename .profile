# copy&paste to/from console for linux
alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'
# run tiled tmux with htop, nvidia-smi and sensors
alias tmon='tmux new-session "tmux source-file ~/.tmux/tmon"'
# same as above and spare shell in the bottom
alias tx='tmux new-session "tmux source-file ~/.tmux/tmonext"'
