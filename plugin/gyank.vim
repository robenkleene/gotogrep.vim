nnoremap <expr> gyg gyank#YankGrep()
xnoremap <expr> gyg gyank#YankGrep()
nnoremap <expr> gygg gyank#YankGrep({}, '', 1) .. '_'
nnoremap <expr> gygG gyank#YankGrep({}, '', 1, 1) .. '_'

nnoremap <expr> gym gyank#YankMarkdown()
xnoremap <expr> gym gyank#YankMarkdown()
nnoremap <expr> gymm gyank#YankMarkdown({}, '', 1) .. '_'
nnoremap <expr> gymM gyank#YankMarkdown({}, '', 1, 1) .. '_'

nnoremap gypp <Cmd>call gyank#YankPath(expand('%:p:~'))<CR>
nnoremap gypr <Cmd>call gyank#YankPath(expand('%:.'))<CR>
nnoremap gypn <Cmd>call gyank#YankPath(expand('%:t'))<CR>

command! -nargs=1 Gtgrep call gyank#Gtgrep(<q-args>)
