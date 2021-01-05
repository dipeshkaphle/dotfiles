" Comments in Vimscript start with a `"`.

" If you open this file in Vim, it'll be syntax highlighted for you.

" Vim is based on Vi. Setting `nocompatible` switches from the default
" Vi-compatibility mode and enables useful Vim functionality. This
" configuration option turns out not to be necessary for the file named
" '~/.vimrc', because Vim automatically enters nocompatible mode if that file
" is present. But we're including it here just in case this config file is
" loaded some other way (e.g. saved as `foo`, and then Vim started with
" `vim -u foo`).
"
"
"
"
set nocompatible
set hidden
if has('nvim')
	set termguicolors
endif


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



" General rules
set autoindent
set showcmd
set showmatch
set tabstop=4
set shiftwidth=4
"set softtabstop=4
"set expandtab
set clipboard+=unnamed

syntax enable



"" Enable mouse support. You should avoid relying on this too much, but it can
"sometimes be convenient.
set mouse+=a

filetype plugin indent on


	
" My mappings
imap <C-k> <Up>
imap <C-j> <Down>
imap <C-l> <Right>
imap <C-h> <Left>

"ctrl s save in insert mode
"C-b will move back a word
"C-Shift-b will move to first character on the line
"C-Shift-f will move to the end of the line in insert mode
"ctrl w to move by word
inoremap <C-s> <Esc>:w<CR>i
inoremap <C-w> <C-o>W
inoremap <C-b> <C-o><C-Left>
inoremap <C-f> <C-o>^
inoremap <C-e> <C-o>$
inoremap <C-t> <C-o>O
inoremap <C-d> <C-o>o



nnoremap <S-j> <C-e>
nnoremap <S-k> <C-y>


" My leader
let mapleader = "\<Space>"


" Protecting plugins from vscode
if !exists('g:vscode')

call plug#begin()
Plug 'tpope/vim-surround'
Plug 'raimondi/delimitmate'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-ruby/vim-ruby'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'morhetz/gruvbox'
Plug 'tomasr/molokai'
Plug 'scrooloose/nerdtree'
Plug 'neovimhaskell/haskell-vim'
Plug 'lambdalisue/suda.vim'
Plug 'atelierbram/vim-colors_atelier-schemes'
Plug 'nbouscal/vim-stylish-haskell'
Plug 'honza/vim-snippets'
Plug 'scrooloose/nerdcommenter'
Plug 'alvan/vim-closetag'
Plug 'dense-analysis/ale'
Plug 'bfrg/vim-cpp-modern'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()

" polyglot cpp 
let g:cpp_no_function_highlight = 1
let g:cpp_simple_highlight = 1
let g:cpp_attributes_highlight = 1
let g:cpp_member_highlight = 1
" Haskell vim
let g:haskell_enable_quantification = 1   " to enable highlighting of `forall`
let g:haskell_enable_recursivedo = 1      " to enable highlighting of `mdo` and `rec`
let g:haskell_enable_arrowsyntax = 1      " to enable highlighting of `proc`
let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of `pattern`
let g:haskell_enable_typeroles = 1        " to enable highlighting of type roles
let g:haskell_enable_static_pointers = 1  " to enable highlighting of `static`
let g:haskell_backpack = 1                " to enable highlighting of backpack keywords
" let g:haskell_classic_highlighting = 1

" vim close-tag config
"
let g:closetag_filenames = '*.html,*.xhtml,*.xml,*.js,*.html.erb,*.md'


" Airline Config
let g:airline_theme='Atelier_DuneDark'
let g:airline_powerline_fonts=1
"ALE stuff

let g:ale_disable_lsp = 1
" let g:ale_sign_error = '>>'
" let g:ale_sign_warning = '-'
let g:ale_fixers = {
      \    'ruby': ['rubocop'],
      \}
" let g:ale_linters = { 'c':['cc'],'cpp':['cc']}
" let g:ale_cpp_cc_options = '-std=c++2a -Wall'
let g:ale_fix_on_save = 1
let g:airline#extensions#ale#enabled = 1

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


" cpp enhanced highlight
" let g:cpp_no_function_highlight = 1
" let g:cpp_concepts_highlight = 1



" Haskell specific
autocmd FileType haskell setlocal softtabstop=4 expandtab
autocmd FileType javascript setlocal ts=2 sts=2 sw=2
autocmd FileType c setlocal ts=2 sts=2 sw=2
autocmd FileType cpp setlocal ts=2 sts=2 sw=2
autocmd FileType haskell ALEDisable
autocmd FileType cpp ALEDisable


let ruby_operators = 1
let ruby_pseudo_operators = 1
let ruby_space_errors = 1



let g:gruvbox_contrast_dark='hard'
let g:gruvbox_contrast_light="hard"
let g:gruvbox_invert_signs=0
let g:gruvbox_improved_strings=0
let g:gruvbox_improved_warnings=1
let g:gruvbox_undercurl=1
set background=dark
colorscheme gruvbox


" colorscheme Atelier_SeasideDark
" colorscheme Atelier_DuneDark
let g:solarized_contrast="normal"
let g:solarized_termcolors=256
" colorscheme solarized
" colorscheme molokai
" let g:molokai_original = 1
" colorscheme solarized
" set background=dark
" Removes color bleeding on kitty
set t_ut=
set t_Co=256
" set t_md=
"set cursorline
cmap w!! :SudaWrite
"cmap w!! w !sudo tee %
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


"Mapping to resize the splits a bit faster
nnoremap <C-w>> 3<C-w>>
nnoremap <C-w>< 3<C-w><

nnoremap <leader>fmt :!clang-format -i %<CR>
nnoremap <leader>cpp : ! g++ -std=c++20 -lm % -o %:t:r -Wall -g -fsanitize=address
nnoremap <leader>c :! gcc -lm % -o %:t:r -Wall -g -fsanitize=address
nnoremap <leader>py : terminal python %
nnoremap <leader>rb :terminal ruby %
nnoremap <leader>irb :terminal irb
nnoremap <leader>ipy :terminal python
nnoremap <leader>hs :! ghc %
nnoremap <leader>runhs : terminal ./%:t:r
nnoremap <leader>ghs : terminal ghci %
nnoremap <leader>runc : terminal ./%:t:r
vnoremap <leader>y "+y<CR>
nnoremap <leader>yy "+yy<CR>
nnoremap <leader>p "+p<CR>
nnoremap <leader>n :NERDTree
nnoremap <leader>qn :NERDTreeClose
nnoremap <leader>rn :NERDTreeRefreshRoot
nnoremap <leader>nh :nohl<CR>
map <leader>z <plug>NERDCommenterToggle



" --------------------------------------------------------------------------
" Pressing these will take me to places with errors
nmap <silent> [n <Plug>(coc-diagnostic-prev)
nmap <silent> ]n <Plug>(coc-diagnostic-next)
" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)


" Use K to show documentation in float window.
nnoremap <silent> Q :call <SID>show_documentation()<CR>


function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Remap <C-f> and <C-b> for scroll float windows/popups.
" if has('nvim1.4.0') || has('patch-8.2.0750')
"   nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
"   nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
"   inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
"   inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
"   vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
"   vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
" endif


"----------------------------------------------------------------------------------------------
" Markdown specific mapping
autocmd FileType markdown nnoremap <leader>pdf :! zsh ~/scripts/mdMake.sh %



" For transparency in termite in i3 with picom
" hi Normal guibg=NONE ctermbg=NONE
" hi Normal ctermbg=NONE
" highlight Visual cterm=bold ctermbg=NONE ctermfg=NONE
"
"	for molakai selection highlighting
    " if molokai_original
    "     hi Visual term=reverse cterm=reverse
    " endif


endif

" -----------------------------------------------------------------------
" Create default mappings
let g:NERDCreateDefaultMappings = 1

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" Enable NERDCommenterToggle to check all selected lines is commented or not
let g:NERDToggleCheckAllLines = 1



" -----------------------------------------------------------------------
" -----------------------------------------------------------------------
" -----------------------------------------------------------------------
" -----------------------------------------------------------------------
let g:fzf_preview_window = ['right:50%', 'ctrl-/']
" -----------------------------------------------------------------------
" -----------------------------------------------------------------------
" -----------------------------------------------------------------------
" -----------------------------------------------------------------------


