" Reference {{{1
"   https://github.com/amix/vimrc


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Lang & Encoding {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 设置环境变量 LANG=utf8 可以保证启动日志文件不乱码
set encoding=utf-8     " 最好放在 vimrc 文件的开始处
language chinese_china " 使消息和日志输出为中文


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Features {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 'nocompatible' to ward off unexpected things that your distro might
" have made, as well as sanely reset options when re-sourcing .vimrc
set nocompatible

" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto-indenting for each filetype,
" and for plugins that are filetype specific.
filetype indent plugin on

" Enable syntax highlighting
syntax on


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VAM Setup {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
fun! s:EnsureVamIsOnDisk(plugin_root_dir)
  let vam_autoload_dir = a:plugin_root_dir.'/vim-addon-manager/autoload'
  if isdirectory(vam_autoload_dir)
    return 1
  else
    call mkdir(a:plugin_root_dir, 'p')
    execute '!git clone --depth=1 git://github.com/MarcWeber/vim-addon-manager '.
                \       shellescape(a:plugin_root_dir, 1).'/vim-addon-manager'
    exec 'helptags '.fnameescape(a:plugin_root_dir.'/vim-addon-manager/doc')
    return isdirectory(vam_autoload_dir)
  endif
endfun

fun! s:SetupVAM()
  if !exists("g:vim_addon_manager")
    set noswapfile
    let g:vim_addon_manager = {
      \ 'log_to_buf': 1,
      \ 'log_buffer_name': '~/vam_install.log',
      \ 'shell_commands_run_method': 'system',
      \ 'auto_install': 1,
      \ 'plugin_sources': {},
      \ 'plugin_root_dir': fnamemodify($MYVIMRC, ":h"),
    \ }
  endif
  let c = g:vim_addon_manager
  if !<SID>EnsureVamIsOnDisk(c.plugin_root_dir)
    echohl ErrorMsg | echomsg "No VAM found!" | echohl NONE
    return
  endif

  let &rtp.=(empty(&rtp)?'':',').c.plugin_root_dir.'/vim-addon-manager'
  let scripts = readfile(c.plugin_root_dir.'/vim-plugins.file')
  let scripts = map(filter(scripts, 'v:val !~ "\\v^\\s*$|^\\s*#"'), 'eval(v:val)')
  for l in filter(copy(scripts), 'type(v:val) == type({}) && has_key(v:val, "url")')
    let c.plugin_sources[l.name] = l
  endfor
  call vam#Scripts(scripts, {'tag_regex': '.*'})
  unlet scripts
endfun
call <SID>SetupVAM()


finish "{{{1
===============================================================
" vim:ts=2:sw=2:fdm=marker:commentstring=\ \"\ %s:noet:nolist:nowrap
