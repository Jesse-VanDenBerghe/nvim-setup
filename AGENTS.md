# Neovim Config — Agent Guidelines

This repository is a personal Neovim configuration written entirely in Lua,
using [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager.
There is no build system, test suite, or CI pipeline — changes are validated
by launching Neovim and observing runtime behaviour.

---

## Repository Layout

```
~/.config/nvim/
├── init.lua                        # Entry point — sets leader, loads jesse.*
├── lazy-lock.json                  # Plugin lockfile (commit this on updates)
└── lua/jesse/
    ├── init.lua                    # Core options, autocmds, global keymaps
    ├── lazy_init.lua               # Bootstraps lazy.nvim, calls lazy.setup{}
    ├── languages_init.lua          # Auto-requires every file in languages/
    ├── lazy/                       # One file per plugin (or plugin group)
    │   ├── init.lua                # Minimal plugins (plenary, guess-indent)
    │   ├── lsp.lua                 # nvim-lspconfig + Mason + blink.cmp wiring
    │   ├── conform.lua             # Auto-formatting (stylua for Lua)
    │   ├── treesitter.lua          # nvim-treesitter setup & parser list
    │   ├── telescope.lua           # Fuzzy finder + keymaps
    │   ├── harpoon.lua             # File navigation
    │   ├── gitsigns.lua            # Git decorations in the sign column
    │   ├── fugitive.lua            # Git commands via :G
    │   ├── blink.lua               # Completion engine (blink.cmp + LuaSnip)
    │   ├── mini.lua                # mini.nvim modules (ai, surround, pairs…)
    │   ├── which-key.lua           # Keymap discovery & group labels
    │   ├── lualine.lua             # Status line
    │   ├── alpha-vim.lua           # Start screen
    │   ├── tree.lua                # File explorer (nvim-tree)
    │   ├── opencode.lua            # opencode.nvim AI integration
    │   ├── render-markdown.lua     # Markdown rendering
    │   └── themes.lua              # Colorscheme (onedark, warmer, transparent)
    └── languages/                  # Per-language autocmds & keymaps
        └── elixir.lua              # Elixir build / run / test keymaps
```

---

## "Build / Lint / Test" Commands

There is no Makefile or shell script. Validation happens inside Neovim.

### Lua linting & formatting

| Tool | Command |
|------|---------|
| Format current buffer | `<leader>f` (calls `conform.nvim` → `stylua`) |
| Format from CLI | `stylua --column-width 120 lua/jesse/**/*.lua` |
| Lua type-check (lazydev) | Errors surface in the editor via `lua_ls` |

Stylua is the sole formatter for Lua. The column width is **120 characters**
(configured in `conform.lua`). Install with Mason (`:Mason`, find `stylua`) or
`cargo install stylua`.

### Running from the CLI (outside Neovim)

```bash
# Validate that init.lua at least parses without errors
nvim --headless -c 'lua print("ok")' -c 'qa'

# Check a single Lua file for syntax errors
luac -p lua/jesse/lazy/lsp.lua
```

### Language-specific test commands (Elixir projects)

These keymaps are active in Elixir buffers (`languages/elixir.lua`):

| Keymap | Equivalent shell command | Description |
|--------|--------------------------|-------------|
| `<leader>bp` | `mix compile` | Compile project |
| `<leader>rf` | `mix run <file>` | Run current file |
| `<leader>rs` | `elixir <file>` | Run `.exs` script |
| `<leader>tp` | `mix test` | Run full test suite |
| `<leader>tf` | `mix test <file>` | Run single test file |

To run a single test by line number from the shell:
```bash
mix test path/to/test_file.exs:42
```

---

## Code Style Guidelines

### General Lua conventions

- **Indentation**: tabs, 1 tab = 4 spaces (enforced by `vim.opt.tabstop = 4`
  and `expandtab = true`; `stylua` normalises this on save).
- **Line length**: 120 characters maximum (`vim.opt.colorcolumn = "120"`).
- **Quotes**: double quotes for strings (consistent throughout the codebase).
- **Semicolons**: not used; Lua's implicit statement separation is preferred.

### Indentation style observed in the codebase

Most files (especially those in `lazy/`) use **hard tabs** rendered at 4
spaces. A few older files (`gitsigns.lua`, `themes.lua`, `lazy_init.lua`) use
**4-space soft indentation**. Prefer tabs in new files to match the majority.

### Module / file structure

- Each plugin gets its **own file** inside `lua/jesse/lazy/`.
- Files return a **lazy.nvim plugin spec table** (a `return { … }` at the top
  level). Use `config = function() … end` for non-trivial setup; use `opts =
  {}` for plugins that accept a single options table.
- Language-specific setup (autocmds, per-filetype keymaps) lives in
  `lua/jesse/languages/<lang>.lua`. The `languages_init.lua` loader
  automatically `require`s every file in that directory.

### Imports / requires

- Use `require("module.path")` everywhere; no `dofile` / `loadfile`.
- Prefer local assignment at the top of a `config` function:
  ```lua
  local builtin = require("telescope.builtin")
  ```
- Wrap potentially-missing requires in `pcall`:
  ```lua
  pcall(require("telescope").load_extension, "fzf")
  ```

### Keymaps

- Always supply a `desc` field:
  ```lua
  vim.keymap.set("n", "<leader>ff", fn, { desc = "Find Files" })
  ```
- Use the `<leader>` prefix hierarchy documented in `which-key.lua`:
  - `<leader>f` — Find
  - `<leader>h` — Harpoon
  - `<leader>e` — Explorer
  - `<leader>t` — Test
  - `<leader>r` — Run
  - `<leader>b` — Build
  - `<leader>l` — LSP (sub-groups: `lr` Refactor, `lg` Go-to)
  - `<leader>g` — Git (sub-groups: `gc` Commit, `gb` Branch)
  - `<leader>a` — AI (opencode)

### Autocmds

- Always create a named augroup with `{ clear = true }` to avoid duplicate
  registrations on re-source:
  ```lua
  local group = vim.api.nvim_create_augroup("MyGroup", { clear = true })
  vim.api.nvim_create_autocmd("FileType", { group = group, … })
  ```

### Naming conventions

- **Variables / locals**: `snake_case` (e.g. `languages_dir`, `highlight_augroup`).
- **Augroup names**: `kebab-case` strings (e.g. `"kickstart-lsp-attach"`).
- **Boolean guards**: prefer early-return style rather than deep nesting.
- **Helper functions**: define inline with `local function name() … end` inside
  `config` closures rather than at module level, to avoid polluting globals.

### Error handling

- Use `pcall` for operations that may fail (require, extension loading).
- Propagate LSP errors via `vim.notify(err.message, vim.log.levels.ERROR)`.
- Use `error(msg)` (not `assert`) when a fatal setup step fails (see
  `lazy_init.lua` git-clone guard).
- Do **not** silently swallow errors — log them with `vim.notify` at the
  appropriate level.

### Type annotations

- Use EmmyLua / LuaCATS annotations (`---@type`, `---@param`, `---@return`)
  for public-ish functions, especially LSP callbacks:
  ```lua
  ---@param client vim.lsp.Client
  ---@param method vim.lsp.protocol.Method
  ---@param bufnr? integer
  ---@return boolean
  local function client_supports_method(client, method, bufnr) … end
  ```

### Comments

- Use `--` for single-line comments, `--[[ … ]]` is uncommon — avoid it.
- Use `-- NOTE:`, `-- WARN:`, `-- TODO:` prefixes for actionable comments.
- Commented-out code blocks (disabled plugins, future ideas) are acceptable but
  should include a brief explanation.

---

## Plugin Management

- **Add a plugin**: create a new file `lua/jesse/lazy/<name>.lua` returning a
  lazy.nvim spec table. lazy.nvim discovers specs via `spec = "jesse.lazy"` in
  `lazy_init.lua`, which scans the entire `jesse.lazy` module namespace.
- **Update lockfile**: run `:Lazy update` in Neovim; commit the resulting
  `lazy-lock.json` diff.
- **Pinning**: use `version = "x.*"` (semver) or `tag = "vX.Y.Z"` inside the
  spec for stability-sensitive plugins.

---

## LSP / Tooling

Managed by Mason. Installed servers / tools:

- `lua_ls` — Lua
- `elixirls` — Elixir / HEEx
- `kotlin_language_server` — Kotlin
- `ts_ls` — TypeScript / JavaScript
- `tailwindcss` — CSS / HEEx
- `yamlls` — YAML
- `copilot` (copilot-language-server) — AI inline completions
- `stylua` — Lua formatter (run by conform.nvim on save)

To add a new server, append it to the `servers` table in
`lua/jesse/lazy/lsp.lua:210` and (if needed) add the tool name to
`ensure_installed` at `lsp.lua:383`.
