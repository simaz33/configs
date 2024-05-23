call plug#begin()

Plug 'sheerun/vim-polyglot'
Plug 'pineapplegiant/spaceduck', { 'branch': 'main' }
Plug 'kien/ctrlp.vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
Plug 'prabirshrestha/asyncomplete-file.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/asyncomplete-ultisnips.vim'
Plug 'prabirshrestha/asyncomplete-tags.vim'
Plug 'mattn/vim-lsp-settings'
Plug 'keremc/asyncomplete-clang.vim'
Plug 'mbbill/undotree'
Plug 'hashivim/vim-terraform'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

call plug#end()

syntax on
set number
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set hlsearch

if 1

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  " Revert with ":filetype off".
  filetype plugin indent on

  " Put these in an autocmd group, so that you can revert them with:
  " ":augroup vimStartup | au! | augroup END"
  augroup vimStartup
    au!

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid, when inside an event handler
    " (happens when dropping a file on gvim) and for a commit message (it's
    " likely a different one than last time).
    autocmd BufReadPost *
      \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
      \ |   exe "normal! g`\""
      \ | endif

  augroup END

endif

if exists('+termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
endif

colorscheme spaceduck

" vim-lsp setup
function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes
  echom "loaded"
  " Find definition of word under cursor
  nnoremap <buffer> <leader>ld :LspDefinition<CR>
  " Find callers of word under cursor
  nnoremap <buffer> <leader>lr :LspReferences<CR>
  " Rename symbol throughout project
  nnoremap <buffer> <leader>lR :LspRename<CR>
  " Show docs (e.g. from libraries)
  nnoremap <buffer> <leader>lK :LspHover<CR>
  " Format document layout
  nnoremap <buffer> <leader>lf :LspDocumentFormat<CR>
endfunction
augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

let g:UltiSnipsExpandTrigger="<c-q>"
let g:UltiSnipsJumpForwardTrigger="<c-f>"
let g:UltiSnipsJumpBackwardTrigger="<c-b>"
" Weirdly needed to work with Neovim
let g:UltiSnipsSnippetDirectories = [$HOME.'/.vim/UltiSnips']
" How UltiSnips splits window when editting snippets
let g:UltiSnipsEditSplit="vertical"

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"

let g:lsp_diagnostics_enabled = 0
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_virtual_text_enabled = 0

au BufNewFile,BufRead,BufReadPost *.dockerfile set syntax=dockerfile
au BufNewFile,BufRead,BufReadPost *.{yaml,yml} set tabstop=2 softtabstop=2 shiftwidth=2
au BufNewFile,BufRead,BufReadPost *.{js,jsx,json,ts,tsx,css} set tabstop=2 softtabstop=2 shiftwidth=2

set shm+=F
