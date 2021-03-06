""""""""""""""""""""
" General settings "
""""""""""""""""""""

set nocompatible        " Use vim defaults
set termencoding=utf-8  " character encoding
set enc=utf-8
set fenc=utf-8
set bs=2                " Authorize all deletion
set ai                  " Always auto-indent
set viminfo='20,\"50    " Read/write a .viminfo file, 50 lines max
set history=200         " Save the last 200 commands in history
set undolevels=100      " Save the last 100 undos in history
set ruler               " Always show the cursor
set shiftwidth=4        " Number of characters per indentation
set tabstop=4           " Number of spaces per tabulation
set softtabstop=4       " Number of spaces per backspace
set expandtab           " Convert tabs into spaces
set tw=80               " 80 characters max per line
set nu                  " Display the number of each line
set showcmd             " Display incomplete commands
set ttyfast             " Fast terminal connection
set title               " Name of the file in the window tab's title
set noerrorbells        " Shut the bell
"set spell               " Enable spellchecking
"set spelllang=en,fr     " spellchecking english and french
"set spellsuggest=10     " 10 alternative spelling maximum
set isfname+=32         " gf support filenames with spaces
set t_Co=256            " get 256 colors in term
set lazyredraw          " Clear and redraw screen when executing a script
colorscheme asu1dark     " set colorscheme
if v:version >= 703
    set colorcolumn=80      " Coloration of the 80th column
    "set cursorcolumn
    "set cursorline
endif
if &t_Co> 2 || has("gui_running")
" When terminal has colors, active syntax coloration
    syntax on
    set hlsearch " Highlight results
" TIP: Type 'nohl' to remove highlight
    set incsearch " Highlight of the first matching string
    set smartcase " Highlight first matching string using history
endif

" Show hidden characters like tab or endl
set list
set lcs:tab:>-,trail:.

set backup " Keep a backup file
if !filewritable($HOME."/.vim/backup")
    call mkdir($HOME."/.vim/backup", "p") " Creation of the backup dir
endif
set backupdir=$HOME/.vim/backup " directory for ~ files
set directory=.,./.backup,/tmp

let mapleader = ","

" .vimrc autoreload
autocmd BufWritePost .vimrc source %

" Deactivate keyboard arrows
noremap  <Up> ""
noremap! <Up> <Esc>
noremap  <Down> ""
noremap! <Down> <Esc>
noremap  <Left> ""
noremap! <Left> <Esc>
noremap  <Right> ""
noremap! <Right> <Esc>

set wildmenu " Enable menu at the bottom of the vim window
set wildmode=list:longest,full


" load pathogen
source ~/.vim/bundle/pathogen/autoload/pathogen.vim
filetype off
"call pathogen#runtime_append_all_bundles()
 call pathogen#infect()
call pathogen#helptags()



"""""""""""""""""""""""""""""""
" BASIC EDITING AND DEBUGGING "
"""""""""""""""""""""""""""""""

" type 'za' to open and close a fold.
set foldmethod=indent
set foldlevel=99

" bind Ctrl+<movement> keys to move around the windows, instead of using Ctrl+w + <movement>
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h

" Override some mappings which are in conflict
if !hasmapto('<Plug>TaskList')
    map <unique> <Leader>T <Plug>TaskList
endif
if !hasmapto('MakeGreen')
  map <unique> <silent> <Leader>M :call MakeGreen()<cr>
endif


" Map the task list to find TODO and FIXME
map <leader>td <Plug>TaskList

" View diff's of every save on a file we've made, quickly revert back and forth
map <leader>g :GundoToggle<CR>


""""""""""""""""""""""""""""""""""""""
" SYNTAX HIGHLIGHTING AND VALIDATION "
""""""""""""""""""""""""""""""""""""""

syntax on                           " syntax highlighing
filetype on                          " try to detect filetypes
filetype plugin on
filetype plugin indent on    " enable loading indent file for filetype

" Don't let pyflakes use the quickfix window
let g:pyflakes_use_quickfix = 0

" map pep8
let g:pep8_map='<leader>8'

" coloration with doctest.vim
au BufRead,BufNewFile *.txt set filetype=doctest

" Python syntax test from syntax/python.vim plugin
let python_highlight_all = 1

" Red background to highlight searched patterns
hi Search  term=reverse ctermbg=Red ctermfg=White guibg=Red guifg=White


" ------- Cleaning stuff ---------
function! <SID>Flake8()
  " Close any existing cwindows.
  cclose
  let l:grepformat_save = &grepformat
  let l:grepprogram_save = &grepprg
  set grepformat&vim
  let &grepformat = '%f:%l:%m'
  let &grepprg = 'flake8'
  if &readonly == 0 | update | endif
  silent! grep! %
  let &grepformat = l:grepformat_save
  let &grepprg = l:grepprogram_save
  let l:mod_total = 0
  let l:win_count = 1
  " Determine correct window height
  windo let l:win_count = l:win_count + 1
  if l:win_count <= 2 | let l:win_count = 4 | endif
  windo let l:mod_total = l:mod_total + winheight(0)/l:win_count |
        \ execute 'resize +'.l:mod_total
  " Open cwindow
  execute 'belowright copen '.l:mod_total
  nnoremap <buffer> <silent> c :cclose<CR>
  redraw!
endfunction


" Function: CleanText
function! CleanText()
    " Remove trailing spaces
    let curcol = col(".")
    let curline = line(".")
    exe ":retab"
    exe ":%s/ \\+$//e"
    " add spaces to {% var %} and {{ var  }} in the templates if missing
    " silent will hide the press-Enter
    " ge will hide the Not Found errors raised
    silent :%s/[^ ]\zs\ze[}%]}/ /ge
    silent :%s/{[%{]\zs\ze[^ ]/ /ge
    " Put 2 empty lines before a class (take the decorators into account)
    silent :%s/\(@\w*\)\@<!\n*\(\(\n@\w*\)*\n\(class\|def\) \)\@=/\r\r/ge
    " Put spaces between == if there aren't
    silent :%s/\(\S\)\@ == =\(\S\)\@=/ == /ge
    " Put a space after a coma if missing
    "silent :%s/,\(\S\)\@=/, /ge
    " Remove unwanted spaces after (or before)
    silent :%s/(/(/ge
    silent :%s/)/)/ge  " you can do better ...
    call cursor(curline, curcol)
    if &filetype == 'python'
        " if the current file is in python, we launch flake8
        call <SID>Flake8()
    endif
endfun

map <F6> :call CleanText()<CR>
" ------- end Cleaning stuff ---------


"fun ExecPython()
    "" Try to execute the script in python 2.6, else python 3.1
    "try
        "pyf @%
    "catch
        "silent !python3.1 %
        "" PS: if you launch a graphical interface such as a pygame script, your
        "" vim window may be all black. In this case, redraw the vim window with
        "" ^L
    "endtry
"endfun
" Execute the python script from vim
"map <silent> <F4> :call ExecPython()<CR>




""""""""""""""""""""""""""""""""""""
" TAB COMPLETION AND DOCUMENTATION "
""""""""""""""""""""""""""""""""""""

let g:snips_author = "Adrien Lemaire"
" custom snipMate func for acp to display snippets if start writing in
" uppercase
let g:acp_behaviorSnipmateLength = 1

" make SuperTab context sensitive and enable omni code completion
au FileType python set omnifunc=pythoncomplete#Complete
"autocmd BufNewFile,BufRead *.py compiler nose
"let g:pydiction_location = "~/.vim/bundle/pydiction/complete-dict"
"let g:pydiction_menu_height = 20
"let g:SuperTabDefaultCompletionType = "context"

" Enable the menu and pydoc preview to get the most useful info out of the
" code completion. <leader>pwd open a new window with the whole doc page.
set completeopt=menuone,longest,preview

" Use F1 to find the help for the word under the cursor
map <F1> <ESC>:exec "help ".expand("<cWORD>")<CR>

" Ignore some files with tab autocompletion
set suffixes=*~,*.pyc,*.pyo

" Google translator
let g:langpair="fr|en"
let g:vtranslate="T"

" Display python code calltips for autocomplete
set iskeyword+=.
let g:loaded_python_calltips = 0


"""""""""""""""""""
" CODE NAVIGATION "
"""""""""""""""""""

" With minibufexpl plugin, type :buffers to get the list of buffers
" Switch buffer: b<number> or :b filenam<tab> with file name autocompletion
" close a buffer:  :bd or :bw
" command-t settings. by default bound to <leader>t, needs a "rake make" !
"  supports searching only through opened buffers, instead of files
" using <leader>b.
" ALERT: minibufexpl and command-t have been removed from submodules

map <leader>n :NERDTreeToggle<CR>

" Ropevim settings
map <leader>j :RopeGotoDefinition<CR>
map <leader>r :RopeRename<CR>
let ropevim_vim_completion=1
let ropevim_extended_complete=1
" add the name of modules you want to autoimport
let g:ropevim_autoimport_modules = ["os", "shutil"]

" Binding for fuzzy text search via ack (similar to grep)
nmap <leader>a <Esc>:Ack!

" List classes and methods in the opened files
map <F8> :TlistToggle<cr>
let Tlist_GainFocus_On_ToggleOpen=0
let Tlist_Exit_OnlyWindow=1

" use MiniBufExplorer inside TagList
"let g:miniBufExplModSelTarget = 1

" Mapping of Control + hjkl to window movement commands
"let g:miniBufExplMapWindowNavVim = 1


""""""""""""""""""""""""
" INTEGRATION WITH GIT "
""""""""""""""""""""""""

" Git.vim provides syntax highlighting for git config files
" fugitive.vim provides an interface for interacting with git including
" getting diffs, status updates, commiting, and moving files

" Show what branch we are working on
" better statusline
" left side
set statusline=%#User1#%F\ %#User2#%m%r%h%w\ %<%{&ff}%-15.y
set statusline+=\ [ascii:\%03.3b/hexa:\%02.2B]
" right side
set statusline+=\ %=%{fugitive#statusline()}\ %0.((%l,%v%))%5.p%%/%L
" set statusline+=\ %=\ %{SetTimeOfDayColors()}\ %0.((%l,%v%))%5.p%%/%L
set laststatus=2

" Commands to know: Gblame, Gwrite, Gread, Gcommit


""""""""""""""""""""
" TEST INTEGRATION "
""""""""""""""""""""

" Mapping for Makegreen
map <leader>dt :set makeprg=python\ manage.py\ test\|:call MakeGreen()<CR>

" Execute the tests
nmap <silent><Leader>tf <Esc>:Pytest file<CR>
nmap <silent><Leader>tc <Esc>:Pytest class<CR>
nmap <silent><Leader>tm <Esc>:Pytest method<CR>
" cycle through test errors
nmap <silent><Leader>tn <Esc>:Pytest next<CR>
nmap <silent><Leader>tp <Esc>:Pytest previous<CR>
nmap <silent><Leader>te <Esc>:Pytest error<CR>


"""""""""""""""
" VIRTUALENV  "
"""""""""""""""

" Add the virtualenv's site-packages to vim path
py << EOF
import os.path
import sys
import vim
if 'VIRTUAL_ENV' in os.environ:
    project_base_dir = os.environ['VIRTUAL_ENV']
    sys.path.insert(0, project_base_dir)
    activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
    execfile(activate_this, dict(__file__=activate_this))
EOF


"""""""""""
" DJANGO  "
"""""""""""

" Get code completion for django modules by importing DJANGO_SETTINGS_MODULE
" add : export DJANGO_SETTINGS_MODULE=project.settings   to .zshrc

"hi Normal ctermbg=NONE
"

