if has('win32') || has('win64')
" Use .vim on Windows as well.
set runtimepath+=$USERPROFILE/.vim
endif

set hidden              " Allow switching from modified buffer without saving.
set shortmess+=A        " Ignore existing swap files, no intro message,
set shortmess+=I        " Don't show intro message.
set shortmess+=t        " Truncate messages that are too long on command line.
set shortmess+=a        " Use abbreviated status line messages.
set nowrap              " Don't wrap text.
set noswapfile          " Littering swap files in directories is annoying.
set nobackup            " Backups are what git is for.
set autoread            " Automatically reload files modified outside vim.
set fileformat=unix     " Use UNIX line endings.
set history=1000        " 1000 history entries should be enough for everybody.
set undolevels=1000     " 1000 undo levels should enough for everybody.
set modeline            " Use modeline settings at the beginning of the file.
set tabstop=8           " Number of spaces to represent tabs as.
set softtabstop=2       " Number of spaces to insert for tabs.
set shiftwidth=2        " Number of spaces to use for autoindentation.
set expandtab           " Use spaces to insert tabs.
set ignorecase          " Case insensitive searching by default, but...
set smartcase           " Case sensitive if search pattern has uppercase.
set hlsearch            " Highlight all search matches.
set showmatch           " When a )]}> is inserted, flash the matching ([{<.
set incsearch           " Show search matches as you type.
set matchpairs+=<:>     " Match <> pairs for C++ templates.
set laststatus=2        " Always show status line.
set autoindent          " Use indent from current line when starting new line.
set smartindent         " Automatically indent according to language.
set cindent             " Specialized automatic indenting for C languages.
set path=./**           " Path for finding files.
set vb t_vb=            " Disable terminal bell.
set wildmenu            " Show completions in the status line.
set encoding=utf-8      " Support UTF-8 file encodings.
set diffopt+=filler     " Show filler lines to keep diff text sychronized.
set diffopt+=vertical   " Start diff mode with a vertical split.
set colorcolumn=81      " Thou shalt not cross the 80th column.
set foldmethod=marker   " Use {{{,}}} markers for folding.
set cinoptions+=l1      " Align with case labels in switch statements.
set cinoptions+=g0      " Place C++ scope declarations (public, private, etc).
set cinoptions+=t0      " Don't indent function return types.
set cinoptions+=(0      " Indent unclosed parentheses under first character.
set cinoptions+=w1      " Indent unclosed parentheses under first whitespace.

" Syntax highlight Doxygen comments.
let g:load_doxygen_syntax=1

" Don't report ({ ... }) braces as an error; they're a GCC extension.
let c_no_curly_error=1

if has('win32') || has('win64')
colorscheme default
else
colorscheme erikc
endif

" Enable file type-specific syntax highlighting and indentation.
syntax on
filetype plugin indent on

" Reopen files at the last position when they were closed.
autocmd BufReadPost *
\ if line("'\"") > 0 && line ("'\"") <= line("$") |
\   exe "normal g'\"" |
\ endif

" HTML indentation configuration.
let g:html_indent_script1 = "auto"
let g:html_indent_style1 = "auto"

" Treat .gss files as .css files.
autocmd BufNewFile,BufRead *.gss set filetype=css

" Remove trailing whitespace when writing files.
autocmd BufWritePre * :%s/\s\+$//e

" Open alternate file (e.g. .h<->.c).
nmap <silent> <C-h> :A<CR>

" Use CtrlP for fast file opens.
nmap <silent> <C-o> :CtrlPMixed<CR>

" Navigate errors and search results.
nmap <silent> <M-]> :cn<CR>
nmap <silent> <M-[> :cp<CR>

" Grep in git repositories with fugitive.
nmap <C-s> :silent Ggrep\
nmap <C-k> :Gblame<CR>

" Disable line joining cause I tend to hit it accidentally.
nmap J <Nop>
vmap J <Nop>

" Autoindent with tab for consistency with Emacs.
nmap <silent> <Tab> ==
vmap <silent> <Tab> =

" Use C-G as an additional to ESC.
vmap <silent> <C-G> <ESC>
imap <silent> <C-G> <ESC>

" Swap gc-] and c-] so tag list is shown by default.
nnoremap <c-]> g<c-]>
vnoremap <c-]> g<c-]>
nnoremap g<c-]> <c-]>
vnoremap g<c-]> <c-]>
