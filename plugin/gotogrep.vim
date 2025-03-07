nnoremap <expr> gyg operators#YankGrep()
xnoremap <expr> gyg operators#YankGrep()
nnoremap <expr> gygg operators#YankGrep({}, '', 1) .. '_'
nnoremap <expr> gygG operators#YankGrep({}, '', 1, 1) .. '_'

command! -nargs=1 Ggrep call commands#Ggrep(<q-args>)
