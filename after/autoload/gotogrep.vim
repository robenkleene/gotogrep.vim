function gotogrep#YankGrep(context = {}, type = '', onlyline = 0, includecolumn = 0) abort
  if a:type == ''
    let context = #{
          \ dot_command: v:false,
          \ extend_block: '',
          \ virtualedit: [&l:virtualedit, &g:virtualedit],
          \ only_line: a:onlyline,
          \ cursor_position: getpos("."),
          \ include_column: a:includecolumn,
          \ }
    let &operatorfunc = function('gotogrep#YankGrep', [context])
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
      " Settings the visual commands will lose the cursor column when
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
    let l:register=v:register
    execute 'silent noautocmd keepjumps normal! ' .. commands
    let l:contents = @@
    let l:result = ''
    let l:idx = line('.')
      " `fnamemodify(expand("%"), ":~:.")` tries to get the relative path
    " let l:file_path = fnamemodify(expand("%"), ":~:.")
    let l:file_path = expand('%:~')
    let l:lines = split(l:contents, '\n')
    " Vim `:grep` has trouble if there's not a blank space after the `:`
    " Use `:make` instead to process this output
    if a:context.only_line
      " For the `only_line` variants we're passing in the `_` motion, e.g.,
      " `gotogrep#YankGrep({}, '', 1) .. '_'`. `_` is a motion that moves to
      " the first non-black character on a line, so restore the cursor
      " position here
      call setpos('.', a:context.cursor_position)
      let l:col = col('.')
      if a:context.include_column
        let l:result .= l:file_path.':'.l:idx.':'.l:col
      else
        " Don't include the column for one line because it isn't always
        " supported (e.g., when creating breakpoints in `lldb`)
        let l:result .= l:file_path.':'.l:idx
      endif
      echom l:result
    else
      let l:result .= l:file_path.':'.l:idx.":1:\n"
      let l:result .= l:contents
    endif

    " Use termporary buffer to force `YankTextPost` to trigger
    let @@ = l:result
    new
    setlocal buftype=nofile bufhidden=hide noswapfile
    if a:context.only_line
      " Avoid yanking the line break for one line
      exe 'silent keepjumps normal! VPgg"'.l:register.'yg_'
    else
      exe 'silent keepjumps normal! VPgg"'.l:register.'yG'
    endif
    bd!

  finally
    " If the `"` register we're copying to is not `"` than restore the `"`
    " register
    " This was causing a problem where yanking to the `*` register with a
    " visual selection then `"*y`, followed by yanking the grep line with
    " `"*gygg` would result in the original visual selection still being in
    " the `*` register instead of the grep match yank.
    " We don't actually need this at all though, because in Vim yanking to the
    " `*` register always also yanks to the `"` register, since this happens
    " be default, we don't actually have to restore anything.
    "if l:register !=# '"'
    "  setreg('"', save.register)
    "endif
    call setpos("'<", save.visual_marks[0])
    call setpos("'>", save.visual_marks[1])
    let &clipboard = save.clipboard
    let &selection = save.selection
    let [&l:virtualedit, &g:virtualedit] = get(a:context.dot_command ? save : a:context, 'virtualedit')
    let a:context.dot_command = v:true
  endtry
endfunction

function! gotogrep#Ggrep(args)
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
