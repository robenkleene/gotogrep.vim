# Goto Grep

```
nnoremap <expr> gyg gotogrep#YankGrep()
xnoremap <expr> gyg gotogrep#YankGrep()
nnoremap <expr> gygg gotogrep#YankGrep({}, '', 1) .. '_'
nnoremap <expr> gygG gotogrep#YankGrep({}, '', 1, 1) .. '_'

command! -nargs=1 Ggrep call gotogrep#Ggrep(<q-args>)
```

The `gygG` variant also includes the cursor column in the grep yank.
