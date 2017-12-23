set guioptions+=a     " Synchronize visual mode with system clipboard.
set guioptions+=A     " Synchronize mode-less selection with system clipboard.
set guioptions+=c     " Use console dialogs instead of popup dialogs.
set guioptions-=t     " Disable tearoff menu items.
set guioptions-=T     " Disable toolbar.
set guioptions-=m     " Disable menu bar.
set guioptions-=r     " Disable right-hand scroll.
set guioptions-=l     " Disable left-hand srcolll.
set guioptions-=R     " Disable right-hand scroll.
set guioptions-=L     " Disable left-hand scroll.
set vb t_vb=          " Disable visual bell.
set lines=50          " Set initial size to 50 lines.
set columns=120       " Set initial size to 120 columns.
set clipboard=unnamed " Synchronize system clipboard with yank register.

" Disable cursor blinking.
set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,ve:ver35-Cursor-blinkon0,o:hor50-Cursor-blinkon0,i-ci:ver25-Cursor/lCursor-blinkon0,r-cr:hor20-Cursor/lCursor-blinkon0,sm:block-Cursor-blinkon0

colorscheme erikc
