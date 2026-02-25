# Goto Grep

Vim plugin for yanking grep-formatted file references and navigating to them.

## Mappings

### Yank Grep References

- `gyg{motion}` — Yank a grep-formatted reference for the text covered by `{motion}`. The yanked text is in the format `filepath:line:1:\n<contents>`.
- `gyg` (visual mode) — Yank a grep-formatted reference for the visual selection.
- `gygg` — Yank the current line as `filepath:line` (without column).
- `gygG` — Yank the current line as `filepath:line:col` (with column).

### Open in VS Code

- `gX` — Open the `file:line` reference under the cursor in VS Code via the `vscode://file/` URI scheme.
- `gygX` — Open the current file at the cursor position in VS Code.

## Commands

- `:Gtgrep <file:line[:col]>` — Go to a grep-formatted reference. Accepts `file:line` or `file:line:col`.
- `:Gtopencfile` — Open the `file:line` reference under the cursor in VS Code (used by `gX`).
- `:Gtopen` — Open the current file at the cursor position in VS Code (used by `gygX`).

## Setup

```vim
" These mappings and commands are set up automatically by the plugin:
" gyg, gygg, gygG, gX, gygX
" :Gtgrep, :Gtopencfile, :Gtopen
```
