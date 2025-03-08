nnoremap <expr> gyg gotogrep#YankGrep()
xnoremap <expr> gyg gotogrep#YankGrep()
nnoremap <expr> gygg gotogrep#YankGrep({}, '', 1) .. '_'
nnoremap <expr> gygG gotogrep#YankGrep({}, '', 1, 1) .. '_'

command! -nargs=1 Gtgrep call gotogrep#Gtgrep(<q-args>)
command! Gtopencfile call gotogrep#Gtgopencfile()
command! Gtopen call gotogrep#Gtgopen()
nnoremap gX :Gtopencfile<CR>
nnoremap gygX :Gtopen<CR>
