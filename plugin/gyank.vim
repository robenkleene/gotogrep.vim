nnoremap <expr> gyg gyank#Yank()
xnoremap <expr> gyg gyank#Yank()
nnoremap <expr> gygg gyank#Yank({}, '', 1)
nnoremap <expr> gygG gyank#Yank({}, '', 1, 1)

nnoremap <expr> gym gyank#Yank(#{format: 'markdown'})
xnoremap <expr> gym gyank#Yank(#{format: 'markdown'})
nnoremap <expr> gymm gyank#Yank(#{format: 'markdown'}, '', 1)
nnoremap <expr> gymM gyank#Yank(#{format: 'markdown'}, '', 1, 1)

nnoremap gypp <Cmd>call gyank#YankPath(gyank#ResolvePath(':p:~'))<CR>
nnoremap gypr <Cmd>call gyank#YankPath(gyank#ResolvePath(':.'))<CR>
nnoremap gypt <Cmd>call gyank#YankPath(gyank#ResolvePath(':t'))<CR>

command! -nargs=1 Gtgrep call gyank#Gtgrep(<q-args>)
