" If you add new plugins, install them with::
"
"     make vimpire
"
" using https://bitbucket.org/sirex/home Makefile

" Pathogen is responsible for vim's runtimepath management.
"" call pathogen#infect()

set nocompatible


function! T(...)  " Default values support Vim 8.1.1310 https://github.com/vim/vim/commit/42ae78cfff171fbd7412306083fe200245d7a7a6
    let startline = line("'<")
    let endline = line("'>")
python3 << EOF

from datetime import datetime, timedelta
import vim, math, os

def log_doing(doing):
    '''Note: Could add tags for activity filtering'''

    if not doing.isdigit():
        start = int(vim.eval("startline"))
        end = int(vim.eval("endline"))
        if start and not doing:
            doing = vim.current.buffer[start - 1].strip()

        if not doing:
            print('Please select a task')
            return

        vim.eval('timer_stopall()')

        doing_prev = vim.eval("get(g:, 'doing', '')")
        doing_started_at = vim.eval("get(g:, 'doing_started_at', '')")
        if doing_started_at:
            doing_started_at = datetime.fromtimestamp(int(doing_started_at))

        with open(os.path.expanduser('~/.vim/var/logs'), 'a') as f:
            now = datetime.now().replace(microsecond=0)
            log = f'{now}'

            duration_part = '        '
            if doing_prev and '**' not in doing:
                duration = now - doing_started_at
                if duration < timedelta(hours=5):
                    duration_part = f' {duration}'

            log += f'{duration_part} | {doing}\n'
            f.write(log)

        vim.command(f'let g:doing = "{doing}"')
        vim.command(f'let g:doing_started_at = "{int(datetime.now().timestamp())}"')

        show_doing_for = datetime.now() + timedelta(minutes=5)
        vim.command(f'let g:show_doing_for = {show_doing_for.timestamp()}')
        vim.command("call timer_start(10000, 'T', {'repeat': 30})")
    else:
        doing = vim.eval('g:doing')
        show_doing_for = datetime.fromtimestamp(float(vim.eval("get(g:, 'show_doing_for', '0')")))

    time_left = show_doing_for - datetime.now()
    minutes = math.ceil(time_left.total_seconds()) // 60
    seconds = math.ceil(time_left.total_seconds()) % 60
    if minutes > 0 or seconds > 0:
        print(f"  {doing}   {minutes}:{seconds:02d}")
    else:
        print(f"  {doing}")
        vim.eval('timer_stopall()')

doing = vim.eval("get(a:, 1, '')")
log_doing(doing)

EOF
endfunction


function! TestVS() range
    " This is an example how to get selection range in vimscript-Python
    let startline = line("'<")
    let endline = line("'>")
    echo "vim-start:".startline . " vim-endline:".endline
python3 << EOF
import vim
s = "I was set in python"
vim.command("let sInVim = '%s'"% s)
start = vim.eval("startline")
end = vim.eval("endline")
print("start, end in python:%s,%s"% (start, end))
EOF
    echo sInVim
endfunction


function! CallMakeTestWithCurrentPythonTest()
python3 << EOF
import re
import os
import vim  # https://vimhelp.org/if_pyth.txt.html

cursor = vim.current.window.cursor
test_filename = vim.eval("expand('%p')")
if os.path.basename(test_filename).startswith('test_'):
    test_name = None
    class_name = None
    for line_no in range(cursor[0]-1, -1, -1):
        line = vim.current.buffer[line_no]
        if not test_name and line.lstrip().startswith('def test'):
            test_name = re.findall('def (\w+)\(', line)[0]
        if not class_name and line.startswith('class'):
            class_name = re.findall('class (\w+)\(', line)[0]
            break

    run_py_test_format = vim.eval("get(g:, 'run_py_test_format', '')")
    if run_py_test_format == 'dotted':
        test_path = '{test_filename}'.format(test_filename=test_filename)[:-3].replace('/', '.')
        if class_name:
            test_path += '.{class_name}'.format(class_name=class_name)
        if test_name:
            test_path += '.{test_name}'.format(test_name=test_name)
    else:
        test_path = '{test_filename}'.format(test_filename=test_filename)
        if class_name:
            test_path += '::{class_name}'.format(class_name=class_name)
        if test_name:
            test_path += ' -k {test_name}'.format(test_name=test_name)

    print('\nRUN:', test_path, '\n')
    vim.command('let $TEST_ME_PLEASE="{test_path}"'.format(test_path=test_path))
    cmd = '!TEST_ME_PLEASE="{test_path}" make test'.format(test_path=test_path)
    vim.command(cmd)
else:
    vim.command('!make test')

EOF
endfunction

" function! LoadNestedList()
" python3 << EOF
" import sys
" sys.path.append('/home/niekas/.vim')
"
" from nested_list import load_state
" load_state()
" EOF
" endfunction


" function! SaveNestedList()
" python3 << EOF
" import sys
" sys.path.append('/home/niekas/.vim')
"
" from nested_list import save_state
" save_state()
" EOF
" endfunction


function! ToggleNERDTreeAndTagbar()
    " Detect which plugins are open
    if exists('t:NERDTreeBufName')
        let nerdtree_open = bufwinnr(t:NERDTreeBufName) != -1
        let nerdtree_window = bufwinnr(t:NERDTreeBufName)
    else
        let nerdtree_open = 0
        let nerdtree_window = -1
    endif
    let tagbar_open = bufwinnr('__Tagbar__') != -1
    let tagbar_window = bufwinnr('__Tagbar__')
    let current_window = winnr()

    " Perform the appropriate action
    if nerdtree_open && tagbar_open
        NERDTreeFind
    elseif nerdtree_open && current_window == nerdtree_window
        NERDTreeToggle
        TagbarOpen
        execute bufwinnr('__Tagbar__') . 'wincmd w'
    elseif nerdtree_open
        NERDTreeFind
    elseif tagbar_open && current_window == tagbar_window
        TagbarClose
        NERDTreeToggle
        execute bufwinnr(t:NERDTreeBufName) . 'wincmd w'
    elseif tagbar_open
        TagbarShowTag
        execute bufwinnr('__Tagbar__') . 'wincmd w'
    else
        NERDTreeFind
    endif
endfunction

function! GetBufferList()
  redir =>buflist
  silent! ls
  redir END
  return buflist
endfunction

function! ToggleList(bufname, pfx)
  let buflist = GetBufferList()
  for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
    if bufwinnr(bufnum) != -1
      exec(a:pfx.'close')
      return
    endif
  endfor
  if a:pfx == 'l' && len(getloclist(0)) == 0
      echohl ErrorMsg
      echo "Location List is Empty."
      return
  endif
  let winnr = winnr()
  exec('botright '.a:pfx.'open')
  if winnr() != winnr
    wincmd p
  endif
endfunction

set makeprg=make\ test  " sirex wouldn't do this

" Mappings
let mapleader = ","
nmap    <F1>        :Gstatus<CR>
nmap    <F2>        :update<CR>
imap    <F2>        <ESC>:update<CR>a
nmap    <F3>        :BufExplorer<CR>
nmap    <F4>        :call ToggleNERDTreeAndTagbar()<CR>
nmap    <F5>        :cnext<CR>
nmap    <S-F5>      :cprevious<CR>
nmap    <C-F5>      :cc<CR>
map     <F6>        <C-^>
" vmap    <F6>        <ESC>:exec "'<,'>w !vpaste ".&ft<CR>
nmap    <F7>        :call ToggleList("Quickfix List", 'c')<CR>
nmap    <F8>        :make!<CR>
nmap    <F11>       :set hlsearch!<CR>
nmap    <F12>       :setlocal spell!<CR>
map    <SPACE>     ^
map     ;i          oimport pdb; pdb.set_trace()<esc>
map     ;d          O<esc>:.! date "+\%Y-\%m-\%d"<Enter>A[]<esc>hx<Space>P<CR>
" map     ;f          o<esc>:.! date "+\%Y-\%m-\%d \%H:\%M"<Enter>A[]<Space><esc>hhx<Space>P$a
map     ;f          :Files<CR>
map     ;j          :call g:Jsbeautify()<CR>
map     ;c          oconsole.log();<esc>hi
" map     ;a          :w<CR>:!snakemake<CR>
map     ;a          :w<CR>:!make<CR>
map     ;t          :w<CR>:!make test<CR>
" :w<CR>:!snakemake test<CR>
map     ;s          :w<CR>:!python3 %<CR>
map     ;y          "+y
map     ;p          "+p
map     ;da          GVggxi
" map     ;z          :call LoadNestedList()<CR>
" map     ;q          :call SaveNestedList()<CR>:q!
map     ;g          :w<CR>:call CallMakeTestWithCurrentPythonTest()<CR>
map     ;q          :call T('')<Left><Left>
map     \           gc
map     _           @q
imap    <F10>       <nop>

" set     timeoutlen=300    " Remove delay after delete dd command

" Jump between windows and tabs.
" nmap    <TAB>       <C-W>p   " These two commands break <C-i> command
" nmap    <S-TAB>     <C-W>w
nmap    <M-k>       <C-W>k
nmap    <M-j>       <C-W>j
nmap    <M-l>       <C-W>l
nmap    <M-h>       <C-W>h
nmap    <M-1>       1gt
nmap    <M-2>       2gt
nmap    <M-3>       3gt
nmap    <M-4>       4gt
nmap    <M-5>       5gt
nmap    <M-6>       6gt
nmap    <M-7>       7gt
nmap    <M-8>       8gt
nmap    <M-9>       9gt
nmap    to          :tabedit %<CR>
nmap    tc          :tabclose %<CR>
nmap    tt          :tabnew \| tjump <C-R><C-W><CR>
nmap    tj          gT
nmap    tk          gt
nmap    th          :tabfirst<CR>
nmap    tl          :tablast<CR>

" Quick search for python class and def statments.
nmap    c/          /\<class
nmap    m/          /\<def

" Jump to tag in split window
" nmap    g}              :stselect <c-r><c-w><cr>

" Scroll half page down
" nn <c-j> <c-d>
map <c-j> <c-d>
" Scroll half page up
" nn <c-k> <c-u>
map <c-k> <c-u>

" Scroll half screen to left and right vertically
" no <s-h> zH
" no <s-l> zL

" Autocomplete
ino <c-k> <c-p>
ino <c-j> <c-n>
" Scan only opened buffers and current file, makes autocompletion faster.
set complete=.,w,b,u

" Digraphs
ino <c-d> <c-k>

" Helpers to open files in same directory as current or previous file, more
" quickly
nmap <leader>r :e <c-r>=expand("%:h")<CR>/<c-d>
nmap <leader>R :e <c-r>=expand("#:h")<CR>/<c-d>

" Emacs style command line
cnoremap        <C-G>           <C-C>
cnoremap        <C-A>           <Home>
cnoremap        <Esc>b          <S-Left>
cnoremap        <Esc>f          <S-Right>

" Alt-Backspace deletes word backwards
cnoremap        <M-BS>          <C-W>

" Look and feel.
" colorscheme desert
" set background=dark
colors wombat256
" set guifont=Terminus\ 12
" set guioptions=irL
set wildmenu
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,windows-1257
" set foldmethod=syntax  " marker   - evil command - lags vim as hell
" set foldlevel=20
set foldmethod=indent
set foldlevel=20
set foldclose=all " zo zc zm zr zR
set showcmd     " Show count of selected lines or characters
set shell=/bin/sh

" Text wrapping
set textwidth=99
set linebreak

" Spelling
set spelllang=lt,en

" Cursor movement behaviour
set scrolloff=2
set nostartofline

" Search
set ignorecase
set incsearch
set nohlsearch
set number
set nowrap
set undofile
set undodir=~/.vim/undo/

" Tabs
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

" Indenting
set autoindent
set nosmartindent

" Use relative line numbers
set nonu
set rnu

" Tags " Do not use ctags anymore - I use Jedi instead
" set tags=./tags,./../tags,./../../tags,tags

" Ignores
set suffixes+=.pyc,.pyo
set wildignore+=*.pyc,*.pyo
let g:netrw_list_hide='\.\(pyc\|pyo\)$'

" Backups
if v:version >= 730
    " Backups are not needed, since persistent undo is enabled. Also, these days
    " everyone uses version control systems.
    set nobackup
    set writebackup
    " set undodir=~/.vim/var/undo
    " set undofile
else
    set backup
    set backupdir=~/.vim/var/backup
endif
set directory=~/.vim/var/swap

" Python tracebacks (unittest + doctest output)
set errorformat=\ %#File\ \"%f\"\\,\ line\ %l\\,\ %m
set errorformat+=\@File\:\ %f
set errorformat+=%f:%l:\ [%t]%m,%f:%l:%m

" Set python input/output encoding to UTF-8.
let $PYTHONIOENCODING = 'utf_8'

" Get ride of annoying parenthesis matching, I prefer to use %.
let loaded_matchparen = 1

" Disable A tag underlining
let html_no_rendering = 1

" Grep
" Do recursive grep by default and do not grep binary files.
set grepprg=ag\ --nogroup\ --nocolor\ --smart-case
function! SilentGrep(args)
    execute "silent! grep! " . a:args
    botright copen
endfunction
command! -nargs=* -complete=file G call SilentGrep(<q-args>)
nmap <leader>gg :G
nmap <leader>gG :G <c-r><c-w>
vmap <leader>gg y:G "<c-r>""<left>
nmap <leader>gf :G <c-r>%<home><c-right>
nmap <leader>gF :G <c-r>%<home><c-right> <c-r><c-w>
vmap <leader>gf y:G <c-r>%<home><c-right> "<c-r>""<left>

" Find
function! Find(args)
    execute "cgetexpr system('ag --nocolor --nogroup --smart-case -g " . a:args . " \\\| sed ''s/^/@File: /''')"
    botright copen
endfunction
command! -nargs=* -complete=file F call Find(<q-args>)

" GNU id-utils
function! IDSearch(args)
    let grepprg = &grepprg
    set grepprg=gid
    execute "silent! grep! " . a:args
    botright copen
    execute "set grepprg=" . escape(grepprg, " ")
endfun
command! -nargs=* -complete=file ID call IDSearch(<q-args>)
nmap <leader>gi :ID
nmap <leader>gI :ID <c-r><c-w>


" Execute selected vim script.
vmap <leader>x y:@"<CR>


function! Browser()
"    let line = getline(".")
"    let line = matchstr(line, "\%(http://\|www\.\)[^ ,;\t\n\r]*")

    let uri = matchstr(getline("."), '[a-z]*:\/\/[^ >,;]*')
    echo uri
    if uri != ""
        exec ":silent !firefox \"" . uri . "\""
    else
        echo "No URI found in line."
    endif
endfunction
map <Leader>w :call Browser()<CR>


" Diff
" Open diff window with diff for all files in current directory.
function! FullDiff()
  execute "edit " . getcwd()
  execute "VCSDiff"
endfunction
map <leader>d :call FullDiff()<CR>

" Jump to line in source code from diff output.
"
" This script is found in:
" http://vim.wikia.com/wiki/Jump_to_file_from_CVSDiff_output
"
" Also check this script:
" http://www.vim.org/scripts/script.php?script_id=3892
function! DiffJumpToFile()
 " current line number
  let current_line = line(".")

 " search for line like @@ 478,489 @@
  let diff_line = search('^\(---\|\*\*\*\|@@\) ', 'b')

 " get first number from line like @@ -478,8 +489,12 @@
  let chunk = getline(diff_line)

  " get the first line number (478) from that string
  let source_line = split(chunk, '[-+, ]\+')[3]

  " calculate real source line with offset taken from cursor position
  let source_line = source_line + current_line - diff_line - 1

  " search for and get line like *** fileincvs.c ....
  let chunk = getline(search("^\\(---\\|\\*\\*\\*\\) [^\\S]\\+", "b"))

  " get filename (terminated by tab) in string
  let filename = strpart(chunk, 4, match(chunk, "\\(\\s\\|$\\)", 4) - 4)

  " restore cursor position
  execute "normal ". current_line . "G"

  " go to upper window
  execute "normal \<c-w>k"

  " open
  execute "edit " . filename
  execute "normal " . source_line . "G"
endfunction
au FileType diff nmap <buffer> <CR> :call DiffJumpToFile()<CR>


" File type dependent settings
" ============================

" Zope
function! FT_XML()
  setf xml
  if v:version >= 700
    setlocal shiftwidth=2 softtabstop=2 expandtab
  elseif v:version >= 600
    setlocal shiftwidth=2 softtabstop=2 expandtab
    setlocal indentexpr=
  else
    set shiftwidth=2 softtabstop=2 expandtab
  endif
endf

function! FT_Maybe_ReST()
  if glob(expand("%:p:h") . "/*.py") != ""
        \ || glob(expand("%:p:h:h") . "/*.py") != ""
    set ft=rest
    setlocal shiftwidth=4 softtabstop=4 expandtab
    setlocal textwidth=72
    setlocal spell
    map <buffer> <F5>    :ImportName <C-R><C-W><CR>
    map <buffer> <C-F5>  :ImportNameHere <C-R><C-W><CR>
    map <buffer> <C-F6>  :SwitchCodeAndTest<CR>

    " doctest
    syntax region doctest_value start=+^\s\{2,4}+ end=+$+
    syntax region doctest_code start=+\s\+[>.]\{3}+ end=+$+
    syntax region doctest_literal start=+`\++ end=+`\++

    syntax region doctest_header start=+=\+\n\w\++ start=+\w.\+\n=\++ end=+=$+
    syntax region doctest_header start=+-\+\n\w\++ start=+\w.\+\n-\++ end=+-$+
    syntax region doctest_header start=+\*\+\n\w\++ start=+\w.\+\n\*\++ end=+\*$+

    syntax region doctest_note start=+\.\{2} \[+ end=+(\n\n)\|\%$+

    hi link doctest_header Statement
    hi link doctest_code Special
    hi link doctest_value Define
    hi link doctest_literal Comment
    hi link doctest_note Comment
    " end of doctest
  endif
endf

" This checking allows to source .vimrc again, withoud defining autocmd's
" dwice.
" if !exists("autocommands_loaded")
"     let autocommands_loaded = 1
"     if has("autocmd")
"
"         " Python
"         " if v:version >= 703
"         "     au BufEnter *.py    setl  colorcolumn=+1
"         "     au BufLeave *.py    setl  colorcolumn=
"         " endif
"         if v:version >= 600
"             " Mark trailing spaces and highlight tabs
"             au FileType python,html  setl list
"             au FileType python,html  setl listchars=tab:>-,trail:.,extends:>
"
"             " I don't want [I to parse import statements and look for modules
"             au FileType python  setl include=
"
"             au FileType python  syn sync minlines=300
"         endif
"         au FileType python  setl formatoptions=croql
"         au FileType python  setl shiftwidth=4
"         au FileType python  setl expandtab
"         au FileType python  setl softtabstop=4
"
"         " SnipMate
"         autocmd FileType python set ft=python.django
"         autocmd FileType html set ft=htmldjango.html
"
"         " Makefile
"         au FileType make    setl noexpandtab
"         au FileType make    setl softtabstop=8
"         au FileType make    setl shiftwidth=8
"
"         " UltiSnips
"         au FileType snippets setl noexpandtab
"         au FileType snippets setl softtabstop=8
"         au FileType snippets setl shiftwidth=8
"
"         " SASS
"         au FileType sass    setl softtabstop=2
"         au FileType sass    setl shiftwidth=2
"
"         " LESS
"         au FileType less    setl softtabstop=2
"         au FileType less    setl shiftwidth=2
"
"         " HTML
"         au FileType html    setl softtabstop=4
"         au FileType html    setl shiftwidth=4
"         au FileType html    setl foldmethod=indent
"         au FileType html    setl foldnestmax=5
"         au FileType htmldjango setl softtabstop=4
"         au FileType htmldjango setl shiftwidth=4
"         au FileType htmldjango setl foldmethod=indent
"         au FileType htmldjango setl foldnestmax=5
"
"         " XML
"         au FileType xml     setl softtabstop=4
"         au FileType xml     setl shiftwidth=4
"
"         " Mercurial
"         au BufRead,BufNewFile *.mercurial  setl spell
"         au BufRead,BufNewFile *.hglog  setl syntax=diff
"         au BufRead,BufNewFile *.hglog  setl foldmethod=expr
"         au BufRead,BufNewFile *.hglog  setl foldexpr=(getline(v:lnum)=~'^HGLOG:\ '\|\|getline(v:lnum)=~'^diff\ ')?'>1':'1
"
"         " Sage Math
"         au BufRead,BufNewFile *.sage,*.spyx,*.pyx set ft=python
"
"         augroup Zope
"           au!
"           au BufRead,BufNewFile *.zcml   call FT_XML()
"           au BufRead,BufNewFile *.pt     call FT_XML()
"           au BufRead,BufNewFile *.tt     setlocal et tw=44 wiw=44
"           au BufRead,BufNewFile *.txt    call FT_Maybe_ReST()
"         augroup END
"
"         " SPARQL
"         au BufRead,BufNewFile *.rq setl ft=sparql
"
"         " JSON
"         au BufRead,BufNewFile *.json setl ft=javascript
"
"         " ARFF
"         au BufRead,BufNewFile *.arff setl ft=arff
"
"         " TTL
"         au BufRead,BufNewFile *.ttl setl ft=n3
"
"         " Mail
"         au BufRead,BufNewFile alot.* setl ft=mail
"         au FileType mail setl spell
"         au FileType mail setl comments=n:>,n:#,nf:-,nf:*
"         au FileType mail setl formatoptions=tcroqn
"         au FileType mail setl textwidth=72
"
"         " Jinja
"         autocmd BufRead,BufNewFile *.jinja setl ft=htmldjango.jinja
"
"         " Markdown
"         au BufRead,BufNewFile *.md setl ft=markdown
"
"         " json-ld
"         au BufRead,BufNewFile *.jsonld setl ft=javascript
"
"         " Gradle
"         au BufRead,BufNewFile *.gradle setl ft=groovy
"
"         " SaltStack
"         au BufRead,BufNewFile *.sls setl ft=yaml
"
"         " YAML
"         au FileType yaml    setl softtabstop=2
"         au FileType yaml    setl shiftwidth=2
"
"         " autocmd BufRead,BufNewFile *.cfg set ft=cisco
"     endif
" endif


" Plugins
" =======

" How to install Vundle:
"
"     git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
"
" https://github.com/gmarik/Vundle.vim
" set the runtime path to include Vundle and initialize
"
filetype plugin on  " filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin("~/.vim/vundle")

Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'

Plugin 'gmarik/Vundle.vim'

Plugin 'lervag/file-line'
let g:file_line_crosshairs=0

let g:run_py_test_format = "pytest"

Plugin 'bufexplorer.zip'
"   Do not show buffers from other tabs.
let g:bufExplorerFindActive=0
let g:bufExplorerShowTabBuffer=0
let g:bufExplorerShowRelativePath=1

"" These plugins should be investigated.
" Plugin 'python-mode/python-mode'
" Plugin 'ycm-core/YouCompleteMe'


" Plugin 'Python-mode-klen'
" let g:pymode_lint_checkers = ['pyflakes']
" let g:pymode_lint_cwindow = 0
" let g:pymode_lint_on_write = 0
" let g:pymode_rope_complete_on_dot = 0
" let g:pyflakes_use_quickfix = 0
" let g:pymode_lint_cwindow = 0
" nmap <C-c>i :PymodeRopeAutoImport<CR>

Plugin 'davidhalter/jedi-vim'
let g:jedi#goto_command = "<leader>d"
let g:jedi#goto_assignments_command = "<leader>g"
let g:jedi#usages_command = "<leader>n"
let g:jedi#rename_command = "<leader>r"
let g:jedi#goto_definitions_command = ""
let g:jedi#documentation_command = "K"
let g:jedi#completions_command = "<C-Space>"
let g:jedi#completions_enabled = 0

Plugin 'surround.vim'

Plugin 'Syntastic'
let g:syntastic_enable_signs = 1
let g:syntastic_disabled_filetypes = ['html']
let g:syntastic_quiet_messages={'level':'warnings'}
let g:syntastic_python_python_exec = '/usr/bin/python3'
let g:syntastic_python_checkers = ['python', 'flake8']
let g:syntastic_filetype_map = {'python.django': 'python'}
let g:syntastic_python_pep8_args = '--ignore=E501'
let g:syntastic_python_flake8_args = '--ignore=E501,E702,E303'
let g:syntastic_cpp_compiler_options = ' -std=c++11'
let g:syntastic_python_flake8_args="--max-line-length=99"

Plugin 'UltiSnips'
Plugin 'honza/vim-snippets'
Plugin 'burneyy/vim-snakemake'

" Former zen coding, now renamed to emmet.
" Key to expand: <c-y>,
Plugin 'mattn/emmet-vim'
let g:user_zen_settings = {
\  'indentation' : '    '
\}

Plugin 'delimitMate.vim'

Plugin 'The-NERD-tree'
let g:NERDTreeQuitOnOpen = 0
let g:NERDTreeWinPos = "right"
let g:NERDTreeWinSize = 30
let g:NERDTreeIgnore = ['^__pycache__$', '\.egg-info$', '\~$', '\.aux$', '\.idx$', '\.log$', '\.out$', '\.toc$', '\.bbl$', '\.bcf$', '\.blg$', '\.run.xml$']

" Start NERDTree and put the cursor back in the other window.
autocmd VimEnter * NERDTree | wincmd p
" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') |
    \ quit | endif
" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif


" Adds syntax highlighting to NERDTree based on filetype
" TODO need a patched font to use icons in NERD tree
" Plugin 'tiagofumo/vim-nerdtree-syntax-highlight'
" Plugin 'ryanoasis/vim-devicons'
" Plugin 'ryanoasis/nerd-fonts'

Plugin 'Tagbar'
let g:tagbar_width = 30
let g:tagbar_sort = 0

Plugin 'less-syntax'

Plugin 'VOoM'

Plugin 'ludovicchabant/vim-lawrencium'
let g:lawrencium_trace = 0

Plugin 'vim-coffee-script'

Plugin 'sparql.vim'

Plugin 'mustache/vim-mustache-handlebars'

Plugin 'Jinja'

Plugin 'openscad.vim'

Plugin 'Handlebars'

Plugin 'fugitive.vim'

Plugin 'ctrlp.vim'

Plugin 'n3.vim'

" Plugin 'benekastah/neomake'

Plugin 'editorconfig/editorconfig-vim'

Plugin 'tomtom/tcomment_vim'

Plugin 'octol/vim-cpp-enhanced-highlight'

Plugin 'vim-scripts/Cpp11-Syntax-Support'
" Plugin 'vim-scripts/Cpp11-Syntax-Support'

" let g:tex_no_error=1
" Plugin 'lervag/vimtex'
" let g:Tex_IgnoredWarnings = "Underfull\n".
" \"Overfull\n".
" \"specifier changed to\n".
" \"You have requested\n".
" \"Missing number, treated as zero.\n".
" \"There were undefined references\n"
" \"Citation %.%# undefined"
" \"Wrong length of dash may have been used"
" let g:Tex_IgnoreLevel = 9


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" plugin: nginx git git@github.com:evanmiller/nginx-vim-syntax.git


function! QuickFixBookmark()
  let bookmarks_file = expand("~/.vim/bookmarks.txt")
  let item  = "  File \"".expand("%")."\", line ".line('.').", in unknown\n"
  let item .= "    ".getline('.')
  exec 'cgetfile '.bookmarks_file
  caddexpr item
  exec 'redir >> '.bookmarks_file
  silent echo item
  redir END
  clast!
endfunction
map <leader>, :call QuickFixBookmark()<CR>


" visual incrementing
if !exists("*Incr")
    fun! Incr()
        let l  = line(".")
        let c  = virtcol("'<")
        let l1 = line("'<")
        let l2 = line("'>")
        if l1 > l2
            let a = l - l2
        else
            let a = l - l1
        endif
        if a != 0
            exe 'normal '.c.'|'
            exe 'normal '.a."\<c-a>"
        endif
        normal `<
    endfunction
endif
vnoremap <c-a> :call Incr()<cr>


" Load project specific settings.
for s:name in [
\ expand('../rc.vim'),
\ expand('~/.vim/projects/' . fnamemodify(getcwd(), ":t") . '.vim'),
\ expand('~/.vim/projects/' . fnamemodify(getcwd(), ":h:t") . '.vim'),
\]
    if filereadable(expand(s:name))
        exe "source " . expand(s:name)
    endif
endfor


" Neovim settings
syntax on
nmap <C-6> :buffer #<CR>
set backspace=2

" http://vim.wikia.com/wiki/Repeat_command_on_each_line_in_visual_block
vnoremap . :normal .<CR>
nnoremap ` @a
vnoremap ` :normal @q<CR>

" https://vim.fandom.com/wiki/Search_for_visually_selected_text
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" Remove trailing line spaces
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

autocmd FileType c,cpp,java,php,ruby,python autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()
