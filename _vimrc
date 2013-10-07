let ruby_path = 'c:\ruby193\bin\'
set nocompatible
" Windows Compatible {
" On Windows, also use '.vim' instead of 'vimfiles'; this makes synchronization
" across (heterogeneous) systems easier. 
if has('win32') || has('win64')
    set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
endif

filetype plugin indent on
syntax on
set mouse=a

set viewoptions=folds,options,cursor,unix,slash " better unix / windows compatibility
set virtualedit=onemore 	   	" allow for cursor beyond last character
set history=1000  				" Store a ton of history (default is 20)
" Setting up the directories {
set backup 						" backups are nice ...
set undofile					" so is persistent undo ...
set undolevels=1000 "maximum number of changes that can be undone
set undoreload=10000 "maximum number lines to save for undo on a buffer reload
" Moved to function at bottom of the file
"set backupdir=$HOME/.vimbackup//  " but not when they clog .
"set directory=$HOME/.vimswap// 	" Same for swap files
"set viewdir=$HOME/.vimviews// 	" same for view files

"" Creating directories if they don't exist
"silent execute '!mkdir -p $HVOME/.vimbackup'
"silent execute '!mkdir -p $HOME/.vimswap'
"silent execute '!mkdir -p $HOME/.vimviews'
au BufWinLeave * silent! mkview  "make vim save view (state) (folds, cursor, etc)
au BufWinEnter * silent! loadview "make vim load view (state) (folds, cursor, etc)
" }

set tabpagemax=15 				" only show 15 tabs
set showmode                   	" display the current mode

set cursorline  				" highlight current line
hi cursorline guibg=#333333 	" highlight bg color of current line
hi CursorColumn guibg=#333333   " highlight cursor


if has('cmdline_info')
    set ruler                  	" show the ruler
    set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " a ruler on steroids
    set showcmd                	" show partial commands in status line and
    " selected characters/lines in visual mode
endif


if has('statusline')
    set laststatus=2

    " Broken down into easily includeable segments
    set statusline=%<%f\    " Filename
    set statusline+=%w%h%m%r " Options
   " set statusline+=%{fugitive#statusline()} "  Git Hotness
    set statusline+=\ [%{&ff}/%Y]            " filetype
    set statusline+=\ [%{getcwd()}]          " current dir
    "set statusline+=\ [A=\%03.3b/H=\%02.2B] " ASCII / Hexadecimal value of char
    set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
endif


set backspace=indent,eol,start	" backspace for dummys
set linespace=0					" No extra spaces between rows
set nu							" Line numbers on
set showmatch					" show matching brackets/parenthesis
set incsearch					" find as you type search
set hlsearch					" highlight search terms
set winminheight=0				" windows can be 0 line high 
set ignorecase					" case insensitive search
set smartcase					" case sensitive when uc present
set wildmenu					" show list instead of just completing
set wildmode=list:longest,full	" command <Tab> completion, list matches, then longest common part, then all.
set whichwrap=b,s,h,l,<,>,[,]	" backspace and cursor keys wrap to
set scrolljump=5 				" lines to scroll when cursor leaves screen
set scrolloff=3 				" minimum lines to keep above and below cursor
set foldenable  				" auto fold code
set gdefault					" the /g flag on :s substitutions by default
set listchars=tab:>.,trail:.,extends:#,nbsp:. " Highlight problematic whitespace


" }

" Formatting {
set nowrap                     	" wrap long lines
set autoindent                 	" indent at the same level of the previous line
set shiftwidth=4               	" use indents of 4 spaces
set expandtab 	  	     		" tabs are spaces, not tabs
set tabstop=4 					" an indentation every four columns
set softtabstop=4 				" let backspace delete indent
"set matchpairs+=<:>            	" match, to be used with % 
set pastetoggle=<F12>          	" pastetoggle (sane indentation on pastes)
"set comments=sl:/*,mb:*,elx:*/  " auto format comment blocks
" Remove trailing whitespaces and ^M chars
autocmd FileType c,cpp,java,php,js,python,twig,xml,yml autocmd BufWritePre <buffer> :call setline(1,map(getline(1,"$"),'substitute(v:val,"\\s\\+$","","")'))
" }

" Key (re)Mappings {

"The default leader is '\', but many people prefer ',' as it's in a standard
"location
let mapleader = ','

" Making it so ; works like : for commands. Saves typing and eliminates :W style typos due to lazy holding shift.
nnoremap ; :


" Easier moving in tabs and windows
map <C-J> <C-W>j
map <C-K> <C-W>k
map <C-L> <C-W>l
map <C-H> <C-W>h

" Wrapped lines goes down/up to next row, rather than next line in file.
nnoremap j gj
nnoremap k gk

" The following two lines conflict with moving to top and bottom of the
" screen
" If you prefer that functionality, comment them out.
map <S-H> gT          
map <S-L> gt

" Stupid shift key fixes
cmap W w
cmap WQ wq
cmap wQ wq
cmap Q q
cmap Tabe tabe

" Yank from the cursor to the end of the line, to be consistent with C and D.
nnoremap Y y$

""" Code folding options

"clearing highlighted search
nmap <leader>c :nohlsearch<CR>

" Shortcuts
" Change Working Directory to that of the current file
cmap cwd lcd %:p:h
cmap cd. lcd %:p:h

" visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv 

" Fix home and end keybindings for screen, particularly on mac
" - for some reason this fixes the arrow keys too. huh.
map [F $
imap [F $
map [H g0
imap [H g0

" For when you forget to sudo.. Really Write the file.
cmap w!! w !sudo tee % >/dev/null
" }
"

" GUI Settings {
	" GVIM- (here instead of .gvimrc)
	if has('gui_running')
		set guioptions-=T          	" remove the toolbar
		set lines=40               	" 40 lines of text instead of 24,
	else
		set term=builtin_ansi       " Make arrow and other keys work
	endif
" }

function! InitializeDirectories()
  let separator = "."
  let parent = $HOME 
  let prefix = '.vim'
  let dir_list = { 
			  \ 'backup': 'backupdir', 
			  \ 'views': 'viewdir', 
			  \ 'swap': 'directory', 
			  \ 'undo': 'undodir' }

  for [dirname, settingname] in items(dir_list)
	  let directory = parent . '/' . prefix . dirname . "/"
	  if exists("*mkdir")
		  if !isdirectory(directory)
			  call mkdir(directory)
		  endif
	  endif
	  if !isdirectory(directory)
		  echo "Warning: Unable to create backup directory: " . directory
		  echo "Try: mkdir -p " . directory
	  else  
          let directory = substitute(directory, " ", "\\\\ ", "")
          exec "set " . settingname . "=" . directory
	  endif
  endfor
endfunction
call InitializeDirectories() 


function! NERDTreeInitAsNeeded()
    redir => bufoutput
    buffers!
    redir END
    let idx = stridx(bufoutput, "NERD_tree")
    if idx > -1
        NERDTreeMirror
        NERDTreeFind
        wincmd l
    endif
endfunction

" Use local vimrc if available {
    if filereadable(expand("~/.vimrc.local"))
        source ~/.vimrc.local
    endif
" }
set guifont=Consolas:h13
set autochdir
" Ctags
let g:ctags_statusline=1
nnoremap <F5> :GundoToggle<CR>
call pathogen#infect()
"color darkblue" load a colorscheme
colo solarized

map <F4> <ESC>:vs<CR><ESC> :execute "lvimgrep /" . expand("<cword>") . "./**"<CR><ESC>:lw<CR>
nnoremap <F3> :NumbersToggle<CR>

echom '>^.^<'

nnoremap <leader>- ddp
nnoremap <leader>_ ddk[p
inoremap <leader><c-u> <esc>vawUwi
nnoremap <leader><c-u> vawUw
