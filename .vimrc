set nocompatible " not vi compatible

" Install `vim-plug` plugin manager
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" Run :PlugInstall
call plug#begin()

" Detect filetype automatically
filetype plugin indent on

" Enable syntax highlighting
syntax on

" On-demand loading
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

" language pack 
Plug 'sheerun/vim-polyglot'

" fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Colorscheme 
Plug 'morhetz/gruvbox'
Plug 'sainnhe/sonokai'
Plug 'tomasr/molokai'
Plug 'chriskempson/tomorrow-theme'
set background=dark
autocmd vimenter * ++nested colorscheme gruvbox
"colorscheme onedark

call plug#end()

" Force saving files that require root permission 
cnoremap w!! w !sudo tee > /dev/null %

"---------------------
" Basic editing config
"---------------------
set nu " number lines
set rnu " relative line numbering
set lbr " line break
set backspace=indent,eol,start " allow backspacing over everything
" use 4 spaces instead of tabs during formatting
set showcmd             " display incomplete commands
set nobackup            " do not keep a backup file
set ruler               " show the current row and column

set scrolloff=5 " show lines above and below cursor (when possible)
set ai                  " set auto-indenting on for programming
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set mouse+=a " enable mouse mode (scrolling, selection, etc)

"set hlsearch            " highlight searches
set incsearch           " do incremental searching
set showmatch           " jump to matches when entering regexp
set ignorecase          " ignore case when searching
set smartcase           " no ignorecase if Uppercase char present

" folding, enabled by default
"set foldmethod=indent
set foldmethod=syntax
set foldcolumn=2
set foldlevel=2
" Use ctrl-[hjkl] to select the active split!
nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>

" useful help docs (use CTRL-D for autocomplete, CTRL+] to follow the
" reference, CTRL-O/CTRL-I to jump back and forth)
" :help user-manual - Table of Content for main user manual
" :help vimrc-intro - Intro how to configure vimrc file
"
" Copy-paste for macos
vmap <C-x> :!pbcopy<CR>
vmap <C-c> :w !pbcopy<CR><CR>

set clipboard=unnamed

