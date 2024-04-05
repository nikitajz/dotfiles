" Not vi compatible
set nocompatible

" Check if vim-plug is installed, otherwise install it
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Install `vim-plug` plugin manager
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" Run :PlugInstall
call plug#begin()

" Filetype detection and syntax highlighting
filetype plugin indent on
syntax on

" Plugins
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

" language pack 
Plug 'sheerun/vim-polyglot'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Colorscheme
Plug 'morhetz/gruvbox'

call plug#end()

" Colorscheme
set background=dark
autocmd vimenter * ++nested colorscheme gruvbox

" Basic editing settings
set number                      " nu
set relativenumber              " rnu
set linebreak                   " lbr
set backspace=indent,eol,start  " allow backspacing over everything
set showcmd                     " display incomplete commands
set nobackup                    " do not keep a backup file
set ruler                       " show the current row and column
set scrolloff=5
set autoindent
set expandtab

set tabstop=4                   " use 4 spaces instead of tabs during formatting
set shiftwidth=4
set softtabstop=4
set mouse+=a                    " enable mouse mode (scrolling, selection, etc)
"set hlsearch                   " highlight searches
set incsearch                   " do incremental searching
set showmatch                   " jump to matches when entering regexp
set ignorecase                  " ignore case when searching
set smartcase                   " no ignorecase if Uppercase char present

" folding, enabled by default
set foldmethod=indent
"set foldmethod=syntax
set foldcolumn=2
set foldlevel=2
set nowrapscan

" Force saving files that require root permission
cnoremap w!! w !sudo tee > /dev/null %

" Leader key
let mapleader = " "

" Window navigation
nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>

nmap <leader>w :w<CR> " Quick saved
nmap <leader>q :q<CR> " Quick quit
nmap <leader>x :wq<CR> " Quick save and quit
nmap <leader>/ :set hlsearch!<CR> " Toggle search highlighting
nmap <leader>ln :set nu! rnu!<CR> " Toggle line numbers
nmap <leader>pp :set paste!<CR>  " Toggle paste mode

" Toggle NERDTree
nmap <leader>nt :NERDTreeToggle<CR>

" Clipboard settings
vmap <C-x> :!pbcopy<CR>
vmap <C-c> :w !pbcopy<CR><CR>
set clipboard=unnamed

" Function to format JSON using jq if installed and file is not too large
function! FormatJsonWithJq()
  " Check if jq is installed
  if executable('jq')
    " Check if the file has less than or equal to 10000 lines
    if line('$') <= 10000
      %!jq .
    else
      echo "File is too large to format with jq (> 10000 lines)"
    endif
  else
    echo "jq is not installed, cannot format JSON"
  endif
endfunction

" Autoformat JSON files using the FormatJsonWithJq function
autocmd FileType json autocmd BufWritePre <buffer> call FormatJsonWithJq()

" useful help docs (use CTRL-D for autocomplete, CTRL+] to follow the
" reference, CTRL-O/CTRL-I to jump back and forth)
" :help user-manual - Table of Content for main user manual
" :help vimrc-intro - Intro how to configure vimrc file
