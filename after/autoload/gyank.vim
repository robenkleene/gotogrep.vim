function gyank#Yank(context = {}, type = '', onlyline = 0, includecolumn = 0) abort
  if a:type == ''
    let context = #{
          \ dot_command: v:false,
          \ extend_block: '',
          \ virtualedit: [&l:virtualedit, &g:virtualedit],
          \ only_line: a:onlyline,
          \ cursor_position: getpos("."),
          \ include_column: a:includecolumn,
          \ format: get(a:context, 'format', 'grep'),
          \ }
    let &operatorfunc = function('gyank#Yank', [context])
    set virtualedit=block
    return 'g@'
  endif

  let save = #{
        \ clipboard: &clipboard,
        \ selection: &selection,
        \ virtualedit: [&l:virtualedit, &g:virtualedit],
        \ register: getreginfo('"'),
        \ visual_marks: [getpos("'<"), getpos("'>")],
        \ }

  try
    set clipboard= selection=inclusive virtualedit=
    if a:context.only_line
      " Setting the visual commands will lose the cursor column when
      " executing, e.g., so the grep column will be wrong and the cursor will
      " jump to the beginning of the line unnecessarily
      let commands = ''
    else
      let commands = #{
            \ line: "'[V']",
            \ char: "`[v`]",
            \ block: "`[\<C-V>`]",
            \ }[a:type]
    endif
    let [_, _, col, off] = getpos("']")
    if off != 0
      let vcol = getline("'[")->strpart(0, col + off)->strdisplaywidth()
      if vcol >= [line("'["), '$']->virtcol() - 1
        let a:context.extend_block = '$'
      else
        let a:context.extend_block = vcol .. '|'
      endif
    endif
    if a:context.extend_block != ''
      let commands ..= 'oO' .. a:context.extend_block
    endif

    " Workaround where visual line mode gets stuck on otherwise
    if a:type == 'line'
      redraw
    endif

    let commands ..= 'y'
    let l:register = v:register
    execute 'silent noautocmd keepjumps normal! ' .. commands
    let l:contents = @@
    let l:result = ''
    let l:idx = line('.')
    let l:file_path = expand('%:~')

    if a:context.only_line
      " For the `only_line` variants we're passing in the `_` motion, e.g.,
      " `gyank#Yank({}, '', 1) .. '_'`. `_` is a motion that moves to
      " the first non-blank character on a line, so restore the cursor
      " position here
      call setpos('.', a:context.cursor_position)
      let l:col = col('.')
      if a:context.format == 'markdown'
        if a:context.include_column
          let l:result = '``` grep' .. "\n" .. l:file_path .. ':' .. l:idx .. ':' .. l:col .. ':' .. "\n" .. '```'
        else
          let l:result = '``` grep' .. "\n" .. l:file_path .. ':' .. l:idx .. ':' .. "\n" .. '```'
        endif
        echom l:file_path .. ':' .. l:idx
      else
        if a:context.include_column
          let l:result = l:file_path .. ':' .. l:idx .. ':' .. l:col
        else
          " Don't include the column for one line because it isn't always
          " supported (e.g., when creating breakpoints in `lldb`)
          let l:result = l:file_path .. ':' .. l:idx
        endif
        echom l:result
      endif
    else
      if a:context.format == 'markdown'
        let l:ft = &filetype
        let l:result = '``` grep' .. "\n" .. l:file_path .. ':' .. l:idx .. ':1:' .. "\n" .. '```' .. "\n"
        let l:result ..= "\n" .. '``` ' .. l:ft .. "\n" .. l:contents
        " Ensure the code block closing is on its own line
        if l:contents[-1:] != "\n"
          let l:result ..= "\n"
        endif
        let l:result ..= '```'
      else
        let l:result = l:file_path .. ':' .. l:idx .. ":1:\n"
        let l:result ..= l:contents
      endif
    endif

    " Use temporary buffer to force `TextYankPost` to trigger
    let @@ = l:result
    new
    setlocal buftype=nofile bufhidden=hide noswapfile
    if a:context.only_line
      " Avoid yanking the line break for one line
      exe 'silent keepjumps normal! VPgg"' .. l:register .. 'yg_'
    else
      exe 'silent keepjumps normal! VPgg"' .. l:register .. 'yG'
    endif
    bd!

  finally
    call setpos("'<", save.visual_marks[0])
    call setpos("'>", save.visual_marks[1])
    let &clipboard = save.clipboard
    let &selection = save.selection
    let [&l:virtualedit, &g:virtualedit] = get(a:context.dot_command ? save : a:context, 'virtualedit')
    let a:context.dot_command = v:true
  endtry
endfunction

function! gyank#YankPath(kind) abort
  let l:file = expand('%')
  " `expand('%')` returns empty in netrw buffers opened via `nvim .` or
  " `nvim <dir>` because the initial buffer is unnamed. Navigating into a
  " directory from within netrw does set `%`, so only the initial invocation
  " is affected. Fall back to `b:netrw_curdir` which netrw always sets to
  " the directory being browsed. The `&filetype == 'netrw'` guard ensures we
  " don't use `b:netrw_curdir` in a regular unnamed buffer.
  if empty(l:file) && &filetype == 'netrw' && exists('b:netrw_curdir')
    let l:file = b:netrw_curdir
  endif
  if empty(l:file)
    echohl ErrorMsg | echomsg 'gyank: No file path available' | echohl None
    return
  endif
  if a:kind == 'p'
    let l:path = fnamemodify(l:file, ':p:~')
  elseif a:kind == 'r'
    let l:path = fnamemodify(l:file, ':.')
  else
    let l:path = fnamemodify(l:file, ':t')
  endif
  let l:register = v:register
  let @@ = l:path
  new
  setlocal buftype=nofile bufhidden=hide noswapfile
  exe 'silent keepjumps normal! VPgg"' .. l:register .. 'yg_'
  bd!
  echom l:path
endfunction

function! gyank#Gtgrep(args)
  let content = a:args
  if content =~# '^\([^:]\+\):\(\d\+\):\?\(\d*\)'
    let file = matchstr(content, '^\([^:]\+\)')
    let line = matchstr(content, ':\zs\d\+\ze')
    let col = matchstr(content, ':\d\+:\zs\d\+\ze')
    if empty(col)
        let col = 1
    endif

    " `filereadable` isn't working, maybe doesn't support a virtual file system?
    " if filereadable(file)
    execute 'edit ' . file
    execute 'normal! ' . line . 'G' . col . '|'
    " else
    "     echo "Error: File '" . file . "' not found."
    " endif
  else
    echo "Error: Invalid format in register. Expected '<filename>:<linenumber>[:<columnumber>]'."
  endif
endfunction

