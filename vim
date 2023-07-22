" For set <option>=<value>: White space between '=' and <value> is not allowed.

set encoding=utf-8
set visualbell

if has("win32") || has("win64")
	let $rcdir = "$HOME\\rc\\"
else
	let $rcdir = "$HOME/rc/"
endif

" --- Abbreviations ---

let $rc = $rcdir .. "vim"
let $ps = $rcdir .. "profile.ps1"
let $bash = $rcdir .. "bashrc"

" --- GUI ---

set guioptions-=m
set guioptions-=T
set guioptions-=r
set guioptions-=L

set guifont=Consolas:h11:cANSI:qCLEARTYPE
set guifontwide=NSimSun:h14:cGB2312:qCLEARTYPE

" --- Highlighting & Colors ---

syntax off
highlight ExtraWhitespace ctermbg=red
highlight ExtraWhitespace guibg=red
match ExtraWhitespace /\s\+$/
set colorcolumn=101
highlight ColorColumn ctermbg=white
highlight ColorColumn guibg=white

highlight Normal guifg=#0F9DBA
highlight Normal guibg=#000000
set background=dark

" --- Insert ---

set smartindent
set backspace=indent,eol,start
set formatoptions+=r
set formatoptions+=o

" --- NETRW File Explorer ---

if !argc() && line2byte('$') == -1
	augroup explore_on_empty_buffer
		autocmd!
		autocmd VimEnter * :Explore
		autocmd WinNew * :Explore
	augroup end
endif

let g:netrw_list_hide = '^NTUSER\.DAT{.*'
let g:netrw_keepdir = 0

" --- Search ---

set ignorecase
set smartcase
set hlsearch
highlight Search ctermbg=blue
highlight Search guibg=blue

" --- Windowing ---

set ruler
set laststatus=2

map <up> <C-w><up>
map <down> <C-w><down>
map <left> <C-w><left>
map <right> <C-w><right>

nnoremap <C-l> :noh<CR><C-l>
nnoremap ç ~

" inoremap { {}<Esc>i
" inoremap [ []<Esc>i
