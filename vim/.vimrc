""""
" Sección para Vundle
""""
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" UltiSnips
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'

" Autotags (actualización automática de ctags)
Bundle 'craigemery/vim-autotag'

" YouCompleteMe (autocompletado)
Plugin 'Valloric/YouCompleteMe'
Plugin 'rdnetto/YCM-Generator'

" SuperTab (autocompletado)
Plugin 'ervandew/supertab'

" NERDTree - Explorador de archivos (y más cositas chulas)
Plugin 'scrooloose/nerdtree'
"Plugin 'Xuyuanp/nerdtree-git-plugin' " Plugin para mostrar el estado de GIT en NERDTree

" Depuración de código
Plugin 'idanarye/vim-vebugger'

" Muestra las etiquetas sacadas con ctags
Plugin 'majutsushi/tagbar'


"""""""""""""
" Lenguajes "
"""""""""""""


""""
" Scala
"
" Soporte para Scala
Plugin 'derekwyatt/vim-scala'

""""
" PHP
"
" Soporte para PHP
Plugin 'shawncplus/phpcomplete.vim'

" Soporte para LaTeX
Plugin 'lervag/vimtex'

""""
" LOLCODE
"
" Coloreado de sintaxis para LOLCODE
Plugin 'Xe/lolcode.vim'

""""
" Java
"
" Añade getters/setters en Java (:InsertBothGetterSetter, :InsertGetterOnly...)
Plugin 'vim-scripts/java_getset.vim'
Plugin 'artur-shaik/vim-javacomplete2'

""""
" HTML
"
" Cierre automático de etiquetas para HTML y XML
Plugin 'vim-scripts/HTML-AutoCloseTag'


""""
" Android
"
Plugin 'hsanson/vim-android'


" All of your Plugins must be added before the following line
call vundle#end()            " required
"filetype plugin indent on    " required
filetype plugin on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just
" :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

""""
" Fin de la sección para Vundle
""""
filetype plugin on

"""""""""""
" Estilos "
"""""""""""

" Modifica el comportamiento del tabulador
autocmd BufRead,BufNewFile *.html,*.htm,*.css,*.scss set tabstop=4

" Muestra los espacios no deseados (al final de línea o antes de una tabulación)
highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
match ExtraWhitespace /\s\+$\| \+\ze\t/

" Coloreado de sintaxis para GAS (ensamlador de GNU - sintaxis AT&T)
augroup filetype
   au BufRead,BufNewFile *.s,*.s    set filetype=gas
augroup END
au Syntax gas    so ~/.vim/syntax/gas.vim

" Coloreado de sintaxis para CUP
augroup filetype
   au BufRead,BufNewFile *.cup,*.cup    set filetype=cup
augroup END
au Syntax cup    so ~/.vim/syntax/cup.vim

" Detecta los ficheros .cuh (cabeceras de CUDA) como C++
au BufRead,BufNewFile *.cuh set filetype=cuda

set exrc
set secure
set colorcolumn=90
highlight ColorColumn ctermbg=darkgray

"""""""""""""""""
" FIN - Estilos "
"""""""""""""""""

" Compatibilidad de UltiSnips y YouCompleteMe mediante SuperTab
let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
let g:SuperTabDefaultCompletionType = '<C-n>'

let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"

""""
" Configuración de YCM
"
let g:ycm_collect_identifiers_from_tags_files = 1
let g:ycm_autoclose_preview_window_after_completion = 1

" Localización de libClang para el autocompletado semántico
let g:clang_library_path="/usr/lib/llvm-3.8/lib/libclang.so.1"

" Mapea ^X ^O a ^espacio (autocompletado)
inoremap <C-Space> <C-x><C-o>
inoremap <C-@> <C-Space>

""""
" Opciones de Tagbar
"
let g:tagbar_autoclose = 0
let g:tagbar_zoomwidth = 0
let g:tagbar_show_linenumbers = 0

autocmd VimEnter * nested :call tagbar#autoopen(1)
autocmd BufEnter * nested :call tagbar#autoopen(0)
"nmap <F8> :TagbarToggle<CR>


set tags+=tags;/

""""
" Actualiza las etiquetas del proyecto
""""
autocmd BufWritePost *
      \ if filereadable('tags') |
      \   call system('ctags -a '.expand('%')) |
      \ endif

" Establece el archivo de configuración para YCM
let g:ycm_global_ycm_extra_conf = "~/.vim/bundle/YouCompleteMe/third_party/ycmd/examples/.ycm_extra_conf.py"

""""
" Orden para mostrar todas las declaraciones de una función (requiere ctags)
""""
command! -nargs=1 Definiciones call s:Definiciones(<f-args>)
function! s:Definiciones(name)
  " Retrieve tags of the f kind
  let tags = taglist('^'.a:name)
  let tags = filter(tags, 'v:val["kind"] == "f"')

  " Prepare them for inserting in the quickfix window
  let qf_taglist = []
  for entry in tags
    call add(qf_taglist, {
          \ 'pattern':  entry['cmd'],
          \ 'filename': entry['filename'],
          \ })
  endfor

  " Place the tags in the quickfix window, if possible
  if len(qf_taglist) > 0
    call setqflist(qf_taglist)
    copen
  else
    echo "No tags found for ".a:name
  endif
endfunction


""""
" Configuración del soporte para Java
"""
autocmd FileType java setlocal omnifunc=javacomplete#Complete


""""
" Configuración del soporte para Android
""""
"let g:gradle_path = ''
"let g:android_sdk_path = ''

"""
" Deshabilita la columna de color para los archivos de texto plano (Markdown,
" JSON...)
"""
autocmd FileType markdown set colorcolumn=
autocmd FileType json set colorcolumn=


"""
" Busca ficheros de configuración específicos para proyectos
"""
let b:thisdir=expand("%:p:h")
let b:vim=b:thisdir."/.vim.custom"
if (filereadable(b:vim))
	execute "source ".b:vim
endif

" Lo archivos de tipo .vim.custom deben tener la misma sintaxis que la de .vimrc
autocmd BufRead,BufNewFile .vim.custom set syntax=vim
