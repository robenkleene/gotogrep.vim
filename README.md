# Gyank

Vim plugin for yanking file references in various formats.

## Mappings

### Yank Grep References

- `gyg{motion}` — Yank a grep-formatted reference for the text covered by `{motion}`. The yanked text is in the format `filepath:line:1:\n<contents>`.
- `gyg` (visual mode) — Yank a grep-formatted reference for the visual selection.
- `gygg` — Yank the current line as `filepath:line` (without column).
- `gygG` — Yank the current line as `filepath:line:col` (with column).

### Yank Markdown References

- `gym{motion}` — Yank a markdown-formatted reference for the text covered by `{motion}`. Includes a grep-style header in a fenced code block followed by the contents in a language-tagged fenced code block.
- `gym` (visual mode) — Yank a markdown-formatted reference for the visual selection.
- `gymm` — Yank the current line as a markdown grep reference (without column).
- `gymM` — Yank the current line as a markdown grep reference (with column).

### Yank Path

- `gypp` — Yank the absolute path of the current file (with `~/` home abbreviation).
- `gypr` — Yank the relative path of the current file.
- `gypn` — Yank the filename of the current file.

## Commands

- `:Gtgrep <file:line[:col]>` — Go to a grep-formatted reference. Accepts `file:line` or `file:line:col`.
