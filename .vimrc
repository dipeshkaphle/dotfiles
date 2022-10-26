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
" TODO
set encoding=utf-8
"
set nocompatible
set hidden
" Works lol so idc
if exists('+termguicolors')
  let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif
" if has('nvim')
"     set termguicolors
" endif
" Sets command height
set cmdheight=2

set splitright
set splitbelow

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
" if !has('nvim')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" end
Plug 'vim-ruby/vim-ruby'
Plug 'neoclide/coc.nvim'
" Plug 'morhetz/gruvbox'
Plug 'sainnhe/gruvbox-material'
Plug 'tomasr/molokai'
Plug 'scrooloose/nerdtree'
Plug 'neovimhaskell/haskell-vim'
Plug 'lambdalisue/suda.vim'
Plug 'atelierbram/vim-colors_atelier-schemes'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'scrooloose/nerdcommenter'
Plug 'alvan/vim-closetag'
Plug 'dense-analysis/ale'
Plug 'bfrg/vim-cpp-modern'
" Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
" Plug 'junegunn/fzf.vim'
Plug 'fannheyward/telescope-coc.nvim'

Plug 'rust-lang/rust.vim'
Plug 'voldikss/vim-floaterm'
Plug 'tpope/vim-fugitive'
if has('nvim')
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
	Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': 'python3 -m chadtree deps'}
	Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
	Plug 'famiu/feline.nvim'
	Plug 'nvim-treesitter/playground'
	Plug 'nvim-lua/plenary.nvim'
	Plug 'lewis6991/gitsigns.nvim'
	Plug 'kyazdani42/nvim-web-devicons'
    Plug 'kyazdani42/nvim-tree.lua'
endif

Plug 'sheerun/vim-polyglot'
Plug 'stsewd/fzf-checkout.vim'
Plug 'szw/vim-maximizer' 

" Session management
Plug 'xolox/vim-misc'
Plug 'xolox/vim-session'
call plug#end()


let g:session_autosave = 'no'


" Copied from someone
let $FZF_DEFAULT_OPTS="--ansi --preview-window 'right:60%' --layout reverse --margin=1,4 --preview 'bat --color=always --style=header,grid {}'"


" Chadtree config


" Snippets 
" defaults
" let g:UltiSnipsExpandTrigger=<Tab>
" let g:UltiSnipsListSnippets =<c-Tab>
" let g:UltiSnipsJumpForwardTrigger          <c-j>
" let g:UltiSnipsJumpBackwardTrigger         <c-k>



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
let g:airline_powerline_fonts=1
let g:airline_theme='base16_adwaita'
" let g:airline_theme='random'
let g:airline#extensions#branch#enabled = 1
"tabline

let g:airline#extensions#tabline#enabled = 1           " enable airline tabline                                                           
let g:airline#extensions#tabline#show_close_button = 0 " remove 'X' at the end of the tabline                                            
let g:airline#extensions#tabline#tabs_label = ''       " can put text here like BUFFERS to denote buffers (I clear it so nothing is shown)
let g:airline#extensions#tabline#buffers_label = ''    " can put text here like TABS to denote tabs (I clear it so nothing is shown)
" let g:airline#extensions#tabline#fnamemod = ':t'       " disable file paths in the tab
let g:airline#extensions#tabline#show_tab_count = 0    " dont show tab numbers on the right                                                           
let g:airline#extensions#tabline#show_buffers = 0      " dont show buffers in the tabline                                                 
let g:airline#extensions#tabline#tab_min_count = 2     " minimum of 2 tabs needed to display the tabline                                  
let g:airline#extensions#tabline#show_splits = 0       " disables the buffer name that displays on the right of the tabline               
let g:airline#extensions#tabline#show_tab_nr = 0       " disable tab numbers                                                              
let g:airline#extensions#tabline#show_tab_type = 0     " disables the weird ornage arrow on the tabline

"ALE stuff

let g:ale_disable_lsp = 1
autocmd FileType ruby :ALEEnable
" let g:ale_sign_error = '>>'
" let g:ale_sign_warning = '-'
let g:ale_fixers = {
      \    'ruby': ['rubocop'],
      \}
" let g:ale_linters = { 'c':['cc'],'cpp':['cc']}
let g:ale_linters = {'ruby':['rubocop'], }
" let g:ale_cpp_cc_options = '-std=c++2a -Wall'
let g:ale_fix_on_save = 1
let g:ale_c_parse_makefile=1
let g:ale_c_parse_compile_commands=1

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
" autocmd FileType javascript setlocal ts=2 sts=2 sw=2
autocmd FileType c setlocal ts=2 sts=2 sw=2
autocmd FileType cpp setlocal ts=2 sts=2 sw=2
autocmd FileType haskell :ALEDisable
autocmd FileType sql :ALEDisable
autocmd FileType cpp :ALEDisable


let ruby_operators = 1
let ruby_pseudo_operators = 1
let ruby_space_errors = 1



" morhetz gruvbox
" let g:gruvbox_contrast_dark='hard'
" let g:gruvbox_contrast_light="hard"
" let g:gruvbox_invert_signs=0
" let g:gruvbox_improved_strings=1
" let g:gruvbox_improved_warnings=1
" let g:gruvbox_undercurl=1
" set background=dark
" colorscheme gruvbox


" material gruvbox
" For dark version.
set background=dark
" Set contrast.
" This configuration option should be placed before `colorscheme gruvbox-material`.
" Available values: 'hard', 'medium'(default), 'soft'
let g:gruvbox_material_background= 'hard'
let g:gruvbox_material_palette = 'original'
" let g:gruvbox_material_enable_italic = 1
let g:gruvbox_material_disable_italic_comment = 0
" let g:gruvbox_material_diagnostic_line_highlight = 1
let g:gruvbox_material_better_performance = 1
" let g:gruvbox_material_cursor= 'red' // works in gvim only
let g:gruvbox_material_visual= 'reverse'
colorscheme gruvbox-material
" colorscheme molokai

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
nnoremap <C-w>> 10<C-w>>
nnoremap <C-w>< 10<C-w><

nnoremap <leader>cpp : ! g++ -std=c++20 -lm % -o %:t:r -Wall -Wpedantic -Wextra -Werror -g -fsanitize=address
nnoremap <leader>c :! gcc -lm % -o %:t:r -Wall -Wpedantic -Wextra -Werror -g -fsanitize=address
nnoremap <leader>hs :! ghc %
if has('nvim')
	nnoremap <leader>runc :vnew term://zsh -c ./%:t:r
	nnoremap <leader>ghs :vnew term://zsh -c 'ghci %'
	nnoremap <leader>runhs :vnew term://zsh -c ./%:t:r
	nnoremap <leader>py :vnew term://zsh -c 'python %:p'
	nnoremap <leader>rb :vnew term://zsh -c 'ruby %'
	nnoremap <leader>irb :vnew term://zsh -c irb
	nnoremap <leader>ipy :vnew term://zsh -c python
	nnoremap <leader>term :vnew term://zsh
else
	nnoremap <leader>runc :vert terminal ./%:t:r
	nnoremap <leader>ghs :vert term ghci %
	nnoremap <leader>runhs :vert term ./%:t:r
	nnoremap <leader>py :vert term python %
	nnoremap <leader>rb :vert term ruby %
	nnoremap <leader>irb :vert term irb
	nnoremap <leader>ipy :vert term python
	nnoremap <leader>term :vert term
end
vnoremap <leader>y "+y<CR>
nnoremap <leader>yy "+yy<CR>
nnoremap <leader>p "+p<CR>
if has('nvim')
	nnoremap <leader>n :NvimTreeToggle
else
	nnoremap <leader>n :NERDTreeOpen
	nnoremap <leader>qn :NERDTreeClose
	nnoremap <leader>rn :NERDTreeRefreshRoot
endif
nnoremap <leader>nh :nohl<CR>
nnoremap <leader>tn :FloatermNew
nnoremap <leader>th :FloatermHide
nnoremap <leader>ts :FloatermShow
nnoremap <leader>tt :FloatermToggle

nnoremap <leader>fs :Telescope find_files find_command=rg,--ignore,--files prompt_prefix=🔍<CR>
nnoremap <leader>fsh :Telescope find_files find_command=rg,--ignore,--hidden,--files prompt_prefix=🔍<CR>
nnoremap <leader>fsih :Telescope find_files find_command=rg,--no-ignore-vcs,--hidden,--files prompt_prefix=🔍<CR>
nnoremap <leader>buf :Telescope buffers<CR>
nnoremap <leader>rg :Telescope live_grep<CR>
map <leader>z <plug>NERDCommenterToggle
nmap <leader>rnm <Plug>(coc-rename)
" nmap :rename <Plug>(coc-rename)

" fugitive maps
nmap <leader>gs :G<CR>
nnoremap <leader>gc :GCheckout<CR>
nnoremap <leader>max :MaximizerToggle


" --------------------------------------------------------------------------
" COC stuff
" Pressing these will take me to places with errors
nmap <silent> [n <Plug>(coc-diagnostic-prev)
nmap <silent> ]n <Plug>(coc-diagnostic-next)
" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)



" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap  <leader>cr :CocRestart

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


" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
"
" codelens actions, this is bestttttttttttttttttttttttttttttttttttttttttt
" TODO, not really just to highlight
nmap <leader>lens <Plug>(coc-codelens-action)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
" Idk what this does. Just copied from coc.nvim page
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)
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


highlight Comment cterm=italic gui=italic
highlight Function cterm=none gui=none
endif

" -----------------------------------------------------------------------
" Create default mappings
let g:NERDCreateDefaultMappings = 1

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 0

" Align line-wise comment delimiters flush left instead of following code indentation
" let g:NERDDefaultAlign = 'left'

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 0

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

function IN()
	if !has('nvim')
		execute  "below term++rows=10"
		execute "NERDTreeToggle"
	elseif has('nvim')
		execute "FloatermNew --wintype=split --position=botright"
		execute "resize 10"
		execute "NERDTreeToggle"
	end
endfunction
command! In call IN()
nnoremap <leader>in :In

function Belowterm()
	if !has('nvim')
		execute  "below term++rows=10"
	elseif has('nvim')
		execute "FloatermNew --wintype=split --position=botright"
		execute "resize 10"
	end
endfunction
command! Belowterm call Belowterm()
nnoremap <leader>bterm :Belowterm

au BufNewFile,BufRead *.lpp set ft=lex
au BufNewFile,BufRead *.ypp set ft=yacc
" " autocmd ColorScheme * highlight Normal ctermbg=Black
"
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"


hi! CocErrorVirtualText guifg=#d1666a
hi! CocInfoVirtualText guibg=#353b45
hi! CocWarningVirtualText guifg=#d1cd66
