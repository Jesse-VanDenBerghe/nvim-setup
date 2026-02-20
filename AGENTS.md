# Neovim Config — Agent Guidelines

This repository is a personal Neovim configuration written entirely in Lua,
using [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager.
There is no build system, test suite, or CI pipeline — changes are validated
by launching Neovim and observing runtime behaviour.

---

## Repository Layout

```
~/.config/nvim/
├── init.lua                        # Entry point — just: require("jesse")
├── lazy-lock.json                  # Plugin lockfile (commit this on updates)
└── lua/jesse/
    ├── init.lua                    # ALL core options, autocmds, global keymaps
    ├── lazy_init.lua               # Bootstraps lazy.nvim, calls lazy.setup{}
    ├── languages_init.lua          # Auto-requires every *.lua in languages/
    ├── lazy/                       # One file per plugin (or plugin group)
    │   ├── init.lua                # Minimal plugins (plenary, guess-indent)
    │   ├── lsp.lua                 # nvim-lspconfig + Mason + Copilot wiring
    │   ├── conform.lua             # Auto-formatting (stylua for Lua, mix for Elixir)
    │   ├── treesitter.lua          # nvim-treesitter setup & parser list
    │   ├── harpoon.lua             # File navigation (harpoon2 branch)
    │   ├── gitsigns.lua            # Git decorations in the sign column
    │   ├── blink.lua               # Completion engine (blink.cmp + LuaSnip)
    │   ├── mini.lua                # mini.nvim: ai, surround, move, pairs, cmdline
    │   ├── which-key.lua           # Keymap discovery & group labels
    │   ├── lualine.lua             # Status line
    │   ├── render-markdown.lua     # Markdown rendering (ft-loaded)
    │   ├── themes.lua              # Colorscheme (onedark, warmer, transparent)
    │   ├── snacks.lua              # folke/snacks.nvim — picker, explorer, git, …
    │   └── snacks/
    │       └── dashboard.lua       # Dashboard config, required by snacks.lua
    └── languages/                  # Per-language autocmds & keymaps
        └── elixir.lua              # Elixir build/run/test keymaps + Copilot detach
```

**Important**: All vim options, autocmds, and global keymaps live in
`lua/jesse/init.lua`, not the root `init.lua`. The root file is a single
`require("jesse")` call.

---

## "Build / Lint / Test" Commands

There is no Makefile or shell script. Validation happens inside Neovim.

### Lua linting & formatting

| Tool | Command |
|------|---------|
| Format current buffer | `<leader>f` (calls `conform.nvim` → `stylua`) |
| Format from CLI | `stylua --column-width 120 lua/jesse/**/*.lua` |
| Lua type-check (lazydev) | Errors surface in the editor via `lua_ls` |

Stylua is the sole Lua formatter. Column width is **120 characters**. Install
with Mason (`:Mason`) or `cargo install stylua`.

### CLI validation (outside Neovim)

```bash
# Validate that init.lua at least parses without errors
nvim --headless -c 'lua print("ok")' -c 'qa'

# Check a single Lua file for syntax errors
luac -p lua/jesse/lazy/lsp.lua
```

### Language-specific test commands (Elixir projects)

These keymaps are active in Elixir buffers (`languages/elixir.lua`):

| Keymap | Shell equivalent | Description |
|--------|-----------------|-------------|
| `<leader>bp` | `mix compile` | Compile project |
| `<leader>rf` | `mix run <file>` | Run current file |
| `<leader>rs` | `elixir <file>` | Run `.exs` script |
| `<leader>tp` | `mix test` | Run full test suite |
| `<leader>tf` | `mix test <file>` | Run single test file |

Run a single test by line number from the shell:
```bash
mix test path/to/test_file.exs:42
```

---

## Code Style Guidelines

### General Lua conventions

- **Indentation**: hard tabs rendered at 4 spaces (`vim.opt.tabstop = 4`,
  `expandtab = true`; stylua normalises on save).
- **Line length**: 120 characters maximum.
- **Quotes**: double quotes for strings throughout.
- **Semicolons**: not used.

Note: `lazy_init.lua` and `treesitter.lua` use 4-space soft-indent — an
inconsistency tolerated in existing files. Prefer tabs in new files.

### Module / file structure

- Each plugin gets its **own file** inside `lua/jesse/lazy/`.
- Sub-directories under `lazy/` are allowed when a plugin needs multiple files
  (e.g. `snacks/dashboard.lua` is `require`d by `snacks.lua`).
- Files return a **lazy.nvim plugin spec table** (`return { … }`). Use
  `config = function() … end` for non-trivial setup; use `opts = {}` for
  plugins that accept a single options table.
- Language-specific setup lives in `lua/jesse/languages/<lang>.lua`.

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
- **Exception**: `Snacks` (capital S) is an intentional implicit global
  injected by `snacks.nvim`. Do not `require` it locally — use `Snacks.*`
  directly. This is the only sanctioned implicit global.

### Keymaps

- Always supply a `desc` field:
  ```lua
  vim.keymap.set("n", "<leader>ff", fn, { desc = "Find Files" })
  ```
- For lazy-loaded plugins, declare keymaps in the `keys = {}` field of the
  plugin spec (lazy.nvim form) rather than in `config`:
  ```lua
  keys = { { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" } }
  ```
- Both `vim.g.mapleader` and `vim.g.maplocalleader` are `" "` (space).
- Use the `<leader>` prefix hierarchy from `which-key.lua`:
  - `<leader>f` — Find
  - `<leader>h` — Harpoon
  - `<leader>e` — Explorer
  - `<leader>s` — Search
  - `<leader>t` — Test
  - `<leader>r` — Run
  - `<leader>b` — Build
  - `<leader>l` — LSP (`lr` Refactor, `lg` Go)
  - `<leader>g` — Git (`gc` Commit, `gb` Branch)

### Autocmds

- Always create a named augroup with `{ clear = true }` to avoid duplicate
  registrations on re-source:
  ```lua
  local group = vim.api.nvim_create_augroup("MyGroup", { clear = true })
  vim.api.nvim_create_autocmd("FileType", { group = group, … })
  ```
- **Auto-save is active globally**: `lua/jesse/init.lua` registers an
  `InsertLeave` + `TextChanged` autocmd (group `"auto-save"`) that runs
  `silent! wall` on every change. Any agent-generated file with `buftype == ""`
  and `modifiable == true` will be silently written to disk immediately.

### Buffer-local user commands

Use `vim.api.nvim_buf_create_user_command` for commands that only make sense
in a specific buffer context (e.g. Copilot's `:LspCopilotSignIn`):
```lua
vim.api.nvim_buf_create_user_command(bufnr, "LspCopilotSignIn", function() … end, {})
```

### Naming conventions

- **Variables / locals**: `snake_case` (e.g. `languages_dir`).
- **Augroup names**: `kebab-case` strings (e.g. `"kickstart-lsp-attach"`).
- **Boolean guards**: prefer early-return style rather than deep nesting.
- **Helper functions**: define inline with `local function name() … end` inside
  `config` closures rather than at module level.

### Error handling

- Use `pcall` for operations that may fail (require, extension loading).
- Propagate LSP errors via `vim.notify(err.message, vim.log.levels.ERROR)`.
- Use `error(msg)` (not `assert`) for fatal setup steps.
- Do **not** silently swallow errors — log them with `vim.notify`.

### Shell calls from keymaps

Simple one-shot git operations use `vim.fn.system` / `vim.fn.systemlist`
synchronously (not `vim.fn.jobstart`). A recurring pattern is branch-name
ticket extraction for commit messages:
```lua
local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
local ticket = branch:match("([A-Z]+-%d+)")
local message = ticket and (ticket .. ": " .. input) or input
```

### Type annotations

Use EmmyLua / LuaCATS annotations for public-ish functions, especially LSP
callbacks:
```lua
---@param client vim.lsp.Client
---@param bufnr? integer
---@return boolean
local function client_supports_method(client, bufnr) … end
```

### Comments

- Use `--` for single-line comments; avoid `--[[ … ]]`.
- Use `-- NOTE:`, `-- WARN:`, `-- TODO:` for actionable comments.
- Commented-out code is acceptable but should include a brief explanation.

---

## Plugin Management

- **Add a plugin**: create `lua/jesse/lazy/<name>.lua` returning a lazy.nvim
  spec. lazy.nvim discovers specs via `spec = "jesse.lazy"` in `lazy_init.lua`.
- **Update lockfile**: run `:Lazy update` in Neovim; commit `lazy-lock.json`.
- **Pinning**: use `version = "x.*"` or `tag = "vX.Y.Z"` for stability.

---

## LSP / Tooling

Managed by Mason (`mason-org/mason.nvim` + `mason-org/mason-lspconfig.nvim` +
`mason-tool-installer.nvim`). Installed servers / tools:

- `lua_ls` — Lua
- `elixirls` — Elixir / HEEx
- `kotlin_language_server` — Kotlin
- `ts_ls` — TypeScript / JavaScript
- `tailwindcss` — CSS / HEEx
- `yamlls` — YAML
- `stylua` — Lua formatter
- `copilot` — AI inline completions (see below)

To add a new server, append it to the `servers` table in
`lua/jesse/lazy/lsp.lua:227`. The `ensure_installed` list is built dynamically
from that table at `lsp.lua:394`.

### Copilot (native LSP, nvim 0.11+)

Copilot is wired as a **native LSP client** using the `vim.lsp.config` /
`vim.lsp.enable` API (nvim 0.11+), not a plugin like `copilot.lua`. It
exposes `:CopilotToggle`, `:LspCopilotSignIn`, and `:LspCopilotSignOut`
commands. Inline completion via `vim.lsp.inline_completion` is guarded for
nvim 0.12 nightly.

**Copilot is intentionally detached from Elixir buffers**: `languages/elixir.lua`
has an `LspAttach` autocmd that calls `vim.lsp.buf_detach_client()` for any
client named `"copilot"` on `*.ex`, `*.exs`, and `*.heex` files.

### Treesitter API

`treesitter.lua` uses the `main`-branch rewrite API
(`require("nvim-treesitter").setup(…)`) — not the legacy
`require("nvim-treesitter.configs").setup{}` form. Markdown highlighting is
skipped (handled by `render-markdown.nvim`).
