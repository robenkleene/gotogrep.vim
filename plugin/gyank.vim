nnoremap <expr> gyg gyank#Yank()
xnoremap <expr> gyg gyank#Yank()
nnoremap <expr> gygg gyank#Yank({}, '', 1) .. '_'
nnoremap <expr> gygG gyank#Yank({}, '', 1, 1) .. '_'

nnoremap <expr> gym gyank#Yank(#{format: 'markdown'})
xnoremap <expr> gym gyank#Yank(#{format: 'markdown'})
nnoremap <expr> gymm gyank#Yank(#{format: 'markdown'}, '', 1) .. '_'
nnoremap <expr> gymM gyank#Yank(#{format: 'markdown'}, '', 1, 1) .. '_'

nnoremap gypp <Cmd>call gyank#YankPath(expand('%:p:~'))<CR>
nnoremap gypr <Cmd>call gyank#YankPath(expand('%:.'))<CR>
nnoremap gypn <Cmd>call gyank#YankPath(expand('%:t'))<CR>

command! -nargs=1 Gtgrep call gyank#Gtgrep(<q-args>)
