" Comments in Vimscript start with a `"`.

" If you open this file in Vim, it'll be syntax highlighted for you.

" Vim is based on Vi. Setting `nocompatible` switches from the default
" Vi-compatibility mode and enables useful Vim functionality. This
" configuration option turns out not to be necessary for the file named
" '~/.vimrc', because Vim automatically enters nocompatible mode if that file
" is present. But we're including it here just in case this config file is
" loaded some other way (e.g. saved as `foo`, and then Vim started with
" `vim -u foo`).
set nocompatible

" Turn on syntax highlighting.
syntax on
" Disable the default Vim startup message.
set shortmess+=I

" Show line numbers.
set number

" This enables relative line numbering mode. With both number and
" relativenumber enabled, the current line shows the true line number, while
set relativenumber
" all other lines (above and below) are numbered relative to the current line.
" This is useful because you can tell, at a glance, what count is needed to
" jump up or down to a particular line, by {count}k to go up or {count}j to go
" down.


" The backspace key has slightly unintuitive behavior by default. For example,
" by default, you can't backspace before the insertion point set with 'i'.
" This configuration makes backspace behave more reasonably, in that you can
" backspace over anything.
set backspace=indent,eol,start

" By default, Vim doesn't let you hide a buffer (i.e. have a buffer that isn't
" shown in any window) that has unsaved changes. This is to prevent you from "
" forgetting about unsaved changes and then quitting e.g. via `:qa!`. We find
" hidden buffers helpful enough to disable this protection. See `:help hidden`
" for more information on this.
set hidden

" This setting makes search case-insensitive when all characters in the string
" being searched are lowercase. However, the search becomes case-sensitive if
" it contains any capital letters. This makes searching more convenient.
set ignorecase
set smartcase

" Enable searching as you type, rather than waiting till you press enter.
set incsearch

" Unbind some useless/annoying default key bindings.
nmap Q <Nop> " 'Q' in normal mode enters Ex mode. You almost never want this.

" Disable audible bell because it's annoying.
set noerrorbells visualbell t_vb=


filetype plugin indent on


call plug#begin()
Plug 'tpope/vim-surround'
Plug 'raimondi/delimitmate'
Plug 'vim-airline/vim-airline'
Plug 'vim-ruby/vim-ruby'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'morhetz/gruvbox'
Plug 'tomasr/molokai'
Plug 'josuegaleas/jay'
Plug 'altercation/vim-colors-solarized'
Plug 'scrooloose/nerdtree'
Plug 'neovimhaskell/haskell-vim'
call plug#end()




let g:haskell_indent_if = 3
let g:haskell_indent_case = 2
let g:haskell_indent_let = 4
let g:haskell_indent_where = 6
let g:haskell_indent_before_where = 2
let g:haskell_indent_after_bare_where = 2
let g:haskell_indent_do = 3
let g:haskell_indent_in = 1
let g:haskell_indent_guard = 2
let g:haskell_indent_case_alternative = 1
let g:cabal_indent_section = 2




" Haskell specific
autocmd FileType haskell setlocal softtabstop=4 expandtab




" General rules
set autoindent
set showcmd
set showmatch
set tabstop=4
set shiftwidth=4
"set softtabstop=4
"set expandtab
set clipboard=unnamedplus

syntax enable



"" Enable mouse support. You should avoid relying on this too much, but it can
"sometimes be convenient.
set mouse+=a


:let ruby_operators = 1
:let ruby_pseudo_operators = 1
:let ruby_space_errors = 1




"let g:gruvbox_contrast_dark='hard'
"let g:gruvbox_contrast_light='hard'
"colorscheme gruvbox
"let g:molokai_original = 1
"let g:solarized_contrast="low"
colorscheme molokai
"set background=dark
"colorscheme jay
set background=dark
let g:molokai_original = 1
"colorscheme solarized
" Removes color bleeding on kitty
set t_ut=
set cursorline
cmap w!! w !sudo tee %
let g:haskell_enable_quantification = 1   " to enable highlighting of `forall`
let g:haskell_enable_recursivedo = 1      " to enable highlighting of `mdo` and `rec`
let g:haskell_enable_arrowsyntax = 1      " to enable highlighting of `proc`
let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of `pattern`
let g:haskell_enable_typeroles = 1        " to enable highlighting of type roles
let g:haskell_enable_static_pointers = 1  " to enable highlighting of `static`
let g:haskell_backpack = 1                " to enable highlighting of backpack keywords


" Terminal Mode remap
tnoremap <Esc> <C-\><C-n>


" Setting syntax for MD as markdown
" Overriding if it was already set
au BufRead,BufNewFile *.MD set filetype=markdown

"Set syntax for MD as markdown
"Doesnt override if already set tho
"au BufRead,BufNewFile *.MD setfiletype markdown
"
"
" My mappings
inoremap <C-k> <Esc>O
inoremap <C-j> <Esc>o
inoremap <C-l> <Esc>A
inoremap <C-h> <Esc>^i
inoremap <C-b> <Esc>0i
inoremap <C-s> <Esc>:w<CR>i
cnoremap makecpp ! g++ -lm % -o %:t:r
cnoremap makec ! gcc -lm % -o %:t:r 
cnoremap runpy terminal python %
cnoremap runrb terminal ruby %
cnoremap irb terminal irb
cnoremap ipy terminal python
cnoremap makehs ghc %
cnoremap runc terminal ./%:t:r
cnoremap echo ! echo 'Hi' && echo 'Hello'


" My leader
let mapleader = "\<Space>"
		

" Markdown specific mapping
autocmd FileType markdown cnoremap makepdf ! zsh ~/scripts/mdMake.sh %
