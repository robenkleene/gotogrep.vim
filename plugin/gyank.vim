nnoremap <expr> gyg gyank#YankGrep()
xnoremap <expr> gyg gyank#YankGrep()
nnoremap <expr> gygg gyank#YankGrep({}, '', 1) .. '_'
nnoremap <expr> gygG gyank#YankGrep({}, '', 1, 1) .. '_'

command! -nargs=1 Gtgrep call gyank#Gtgrep(<q-args>)
