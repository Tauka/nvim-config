call plug#begin('~/.vim/plugged')
  Plug 'HerringtonDarkholme/yats.vim'
  Plug 'mhartington/nvim-typescript', {'do': './install.sh'}
  " For async completion:
  Plug 'Shougo/denite.nvim', { 'do': ':UpdateRemotePlugins' }
  Plug 'preservim/nerdtree'
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'preservim/nerdcommenter'

  " Theme
  Plug 'morhetz/gruvbox'
  Plug 'vim-airline/vim-airline-themes'

  " Layout
  Plug 'bling/vim-bufferline'

  " Git
  Plug 'airblade/vim-gitgutter'
call plug#end()

set number
set lcs+=space:·
set invlist
set background=light
" On pressing tab, insert 2 spaces
set expandtab
" show existing tab with 2 spaces width
set tabstop=2
set softtabstop=2
set shiftwidth=2
set foldmethod=syntax
set foldlevel=99
" Indent in visual and select mode automatically re-selects
vnoremap > >gv
vnoremap < <gv

" autoload changed files
if ! exists("g:CheckUpdateStarted")
    let g:CheckUpdateStarted=1
    call timer_start(1,'CheckUpdate')
endif
function! CheckUpdate(timer)
    silent! checktime
    call timer_start(1000,'CheckUpdate')
endfunction

function Styles()
  colorscheme gruvbox
  hi CocUnderline gui=undercurl term=undercurl
  hi CocErrorHighlight ctermfg=red  guifg=#c4384b gui=undercurl term=undercurl
  hi CocWarningHighlight ctermfg=yellow guifg=#c4ab39 gui=undercurl term=undercurl
endfunction

autocmd vimenter * call Styles()

let g:gruvbox_italic='1'
let g:gruvbox_contrast_light='hard'
let mapleader = " "

set hidden
set splitright

" === Custom maps === "
nmap <silent> <leader>xx :noh<CR>
nmap <leader>di di"i
nmap <leader>du di'i
nmap <leader>dy f)i
nmap <leader>p "0p
nnoremap <C-i> <C-o>
nnoremap <C-o> <C-i>
nmap <leader>w :BD<CR>
inoremap kj <Esc>
cnoremap kj <C-C>
nmap <leader>e :bufdo e<CR>
noremap l h
noremap ; l
noremap h ;
noremap <C-w>l <C-w>h
noremap <C-w>; <C-w>l
noremap <C-w>h <C-w>;
inoremap <C-u> <C-o>I
inoremap <C-a> <C-o>A
inoremap <C-d> <C-o>d0
inoremap <C-j> <Down>
inoremap <C-k> <Up>
noremap <Space> <Nop>
" === Denite setup ==="
" Use ripgrep for searching current directory for files
" By default, ripgrep will respect rules in .gitignore
"   --files: Print each file that would be searched (but don't search)
"   --glob:  Include or exclues files for searching that match the given glob
"            (aka ignore .git files)
"
call denite#custom#var('file/rec', 'command', ['rg', '--files', '--glob', '!.git'])

" Use ripgrep in place of "grep"
call denite#custom#var('grep', 'command', ['rg'])

" Custom options for ripgrep
"   --vimgrep:  Show results with every match on it's own line
"   --hidden:   Search hidden directories and files
"   --heading:  Show the file name above clusters of matches from each file
"   --S:        Search case insensitively if the pattern is all lowercase
call denite#custom#var('grep', 'default_opts', ['--hidden', '--vimgrep', '--heading', '-S'])

" Recommended defaults for ripgrep via Denite docs
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])

" Remove date from buffer list
call denite#custom#var('buffer', 'date_format', '')

" Custom options for Denite
"   auto_resize             - Auto resize the Denite window height automatically.
"   prompt                  - Customize denite prompt
"   direction               - Specify Denite window direction as directly below current pane
"   winminheight            - Specify min height for Denite window
"   highlight_mode_insert   - Specify h1-CursorLine in insert mode
"   prompt_highlight        - Specify color of prompt
"   highlight_matched_char  - Matched characters highlight
"   highlight_matched_range - matched range highlight
let s:denite_options = {'default' : {
\ 'split': 'floating',
\ 'start_filter': 1,
\ 'auto_resize': 1,
\ 'source_names': 'short',
\ 'prompt': 'λ ',
\ 'highlight_matched_char': 'QuickFixLine',
\ 'highlight_matched_range': 'Visual',
\ 'highlight_window_background': 'Visual',
\ 'highlight_filter_background': 'DiffAdd',
\ 'winrow': 1,
\ 'vertical_preview': 1
\ }}

" Loop through denite options and enable them
function! s:profile(opts) abort
  for l:fname in keys(a:opts)
    for l:dopt in keys(a:opts[l:fname])
      call denite#custom#option(l:fname, l:dopt, a:opts[l:fname][l:dopt])
    endfor
  endfor
endfunction

call s:profile(s:denite_options)





" ============================================================================ "
" ===                             KEY MAPPINGS                             === "
" ============================================================================ "

" === Denite shorcuts === "
"   ;         - Browser currently open buffers
"   <leader>t - Browse list of files in current directory
"   <leader>g - Search current directory for occurences of given term and close window if no results
"   <leader>j - Search current directory for occurences of word under cursor
nmap m :Denite buffer<CR>
nmap <leader>t :DeniteProjectDir file/rec<CR>
nmap <leader>g :<C-u>Denite grep:. -no-empty<CR>
nnoremap <leader>j :<C-u>DeniteCursorWord grep:.<CR>


" Define mappings while in 'filter' mode
"   <C-o>         - Switch to normal mode inside of search results
"   <Esc>         - Exit denite window in any mode
"   <CR>          - Open currently selected file in any mode
"   <C-t>         - Open currently selected file in a new tab
"   <C-v>         - Open currently selected file a vertical split
"   <C-h>         - Open currently selected file in a horizontal split
autocmd FileType denite-filter call s:denite_filter_my_settings()
function! s:denite_filter_my_settings() abort
  imap <silent><buffer> <C-o>
  \ <Plug>(denite_filter_quit)
  inoremap <silent><buffer><expr> kj
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> kj
  \ denite#do_map('quit')
  inoremap <silent><buffer><expr> <CR>
  \ denite#do_map('do_action')
  inoremap <silent><buffer><expr> <C-t>
  \ denite#do_map('do_action', 'tabopen')
  inoremap <silent><buffer><expr> <C-v>
  \ denite#do_map('do_action', 'vsplit')
  inoremap <silent><buffer><expr> <C-h>
  \ denite#do_map('do_action', 'split')
endfunction

" Define mappings while in denite window
"   <CR>        - Opens currently selected file
"   q or <Esc>  - Quit Denite window
"   d           - Delete currenly selected file
"   p           - Preview currently selected file
"   <C-o> or i  - Switch to insert mode inside of filter prompt
"   <C-t>       - Open currently selected file in a new tab
"   <C-v>       - Open currently selected file a vertical split
"   <C-h>       - Open currently selected file in a horizontal split
autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
  nnoremap <silent><buffer><expr> <CR>
  \ denite#do_map('do_action')
  nnoremap <silent><buffer><expr> o
  \ denite#do_map('do_action')
  nnoremap <silent><buffer><expr> q
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> <Esc>
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> d
  \ denite#do_map('do_action', 'delete')
  nnoremap <silent><buffer><expr> p
  \ denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr> i
  \ denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr> <C-o>
  \ denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr> <C-t>
  \ denite#do_map('do_action', 'tabopen')
  nnoremap <silent><buffer><expr> <C-v>
  \ denite#do_map('do_action', 'vsplit')
  nnoremap <silent><buffer><expr> <C-h>
  \ denite#do_map('do_action', 'split')
endfunction

" === coc.nvim === "
"   <leader>dd    - Jump to definition of current symbol
"   <leader>dr    - Jump to references of current symbol
"   <leader>dj    - Jump to implementation of current symbol
"   <leader>ds    - Fuzzy search current project symbols
nmap <silent> <leader>dd <Plug>(coc-definition)
nmap <silent> <leader>dr <Plug>(coc-references)
nmap <silent> <leader>dj <Plug>(coc-implementation)
nnoremap <silent> <leader>ds :<C-u>CocList -I -N --top symbols<CR>
nmap <leader>rn <Plug>(coc-refactor)
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
nmap <leader>rf :CocCommand workspace.renameCurrentFile<CR>
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
" Use <C-j> for jump to next placeholder, it's default of coc.nvim
let g:coc_snippet_next = '<c-o>'

" Use <C-k> for jump to previous placeholder, it's default of coc.nvim
let g:coc_snippet_prev = '<c-i>'

nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

nmap f <Plug>(coc-smartf-forward)
nmap F <Plug>(coc-smartf-backward)
nmap ' <Plug>(coc-smartf-repeat)
nmap , <Plug>(coc-smartf-repeat-opposite)

augroup Smartf
  autocmd User SmartfEnter :hi Conceal ctermfg=200 guifg=#875fd7
  autocmd User SmartfLeave :hi Conceal ctermfg=239 guifg=#504945
augroup end

" === NERDTree === "
nmap <C-n> :NERDTreeToggle<CR>
nmap <leader>f :NERDTreeFind<CR>
