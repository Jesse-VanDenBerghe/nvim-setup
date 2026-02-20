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
    │   ├── flash.lua               # folke/flash.nvim motion (s, S)
    │   ├── render-markdown.lua     # Markdown rendering (ft-loaded)
    │   ├── sidekick.lua            # folke/sidekick.nvim — NES, AI CLI (<c-.>)
    │   ├── themes.lua              # Colorscheme (onedark, warmer, transparent)
    │   ├── todo-comments.lua       # folke/todo-comments.nvim
    │   ├── trouble.lua             # folke/trouble.nvim diagnostics UI
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
# Validate that the config loads without errors
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

- **Indentation**: hard tabs rendered at 4 spaces; stylua normalises on save.
- **Line length**: 120 characters maximum.
- **Quotes**: double quotes for all strings throughout.
- **Semicolons**: never used.

Note: `lazy_init.lua`, `treesitter.lua`, `gitsigns.lua`, `flash.lua`,
`trouble.lua`, and `todo-comments.lua` use 4-space soft-indent — a tolerated
inconsistency in existing files. Prefer hard tabs in all new files.

### Module / file structure

- Each plugin gets its **own file** inside `lua/jesse/lazy/`.
- Sub-directories under `lazy/` are allowed when a plugin needs multiple files
  (e.g. `snacks/dashboard.lua` is `require`d by `snacks.lua`).
- Files return a **lazy.nvim plugin spec table** (`return { … }`).
  - Use `opts = {}` for plugins accepting a single options table.
  - Use `config = function() … end` for non-trivial setup.
- Language-specific setup lives in `lua/jesse/languages/<lang>.lua` and is
  auto-discovered — no manual registration needed.

### Imports / requires

- Use `require("module.path")` everywhere; no `dofile` / `loadfile`.
- Prefer a local alias at the top of a `config` function:
  ```lua
  local harpoon = require("harpoon")
  ```
- Wrap potentially-missing requires in `pcall`:
  ```lua
  local ok, status = pcall(require, "sidekick.status")
  if not ok then return end
  ```
- **Exception**: `Snacks` (capital S) is an intentional implicit global
  injected by `snacks.nvim`. Never `require` it locally — use `Snacks.*`
  directly. This is the only sanctioned implicit global.

### Keymaps

- Always supply a `desc` field using bracket notation for the mnemonic key:
  ```lua
  vim.keymap.set("n", "<leader>ha", fn, { desc = "[H]arpoon [A]dd file" })
  ```
- LSP keymaps use a local `map` helper that prepends `"LSP: "` to the desc.
- For lazy-loaded plugins, declare keymaps in the `keys = {}` spec field rather
  than inside `config`:
  ```lua
  keys = { { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" } }
  ```
- Both `vim.g.mapleader` and `vim.g.maplocalleader` are `" "` (space), set at
  the very top of `lua/jesse/init.lua` before any `require`.
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
  - `<leader>a` — AI / Copilot / Sidekick

### Autocmds

- Always create a named augroup with `{ clear = true }` to prevent duplicate
  registrations on re-source:
  ```lua
  local group = vim.api.nvim_create_augroup("my-group", { clear = true })
  vim.api.nvim_create_autocmd("FileType", { group = group, … })
  ```
- Use `{ clear = false }` only for augroups that accumulate per-buffer entries
  (e.g. `"kickstart-lsp-highlight"`, `"copilot-inline-completion"`).
- **Augroup naming**: `kebab-case` for core / LSP groups; `PascalCase` for
  per-language groups (e.g. `"ElixirTools"`).
- **Auto-save is active globally**: `lua/jesse/init.lua` registers an
  `InsertLeave` + `TextChanged` autocmd (`"auto-save"` group) that runs
  `silent! wall` on every change. Any modifiable buffer will be written to disk
  immediately — be aware when creating temporary buffers.

### Language files (`languages/<lang>.lua`)

- Create one augroup per file (PascalCase, e.g. `"KotlinTools"`).
- Use `LspAttach` with `pattern = { "*.ext" }` for LSP-level operations (like
  Copilot detach) to avoid filetype timing issues.
- Use `FileType` autocmds with `buffer = true` for per-buffer keymaps:
  ```lua
  vim.api.nvim_create_autocmd("FileType", {
      pattern = "elixir",
      group = elixirgroup,
      callback = function()
          vim.keymap.set("n", "<leader>tp", fn, { buffer = true, desc = "Test project" })
      end,
  })
  ```

### Naming conventions

- **Variables / locals**: `snake_case` (e.g. `languages_dir`, `copilot_config`).
- **Augroup names**: `kebab-case` strings (e.g. `"kickstart-lsp-attach"`).
- **Language augroup names**: `PascalCase` (e.g. `"ElixirTools"`).
- **Boolean guards**: prefer early-return style rather than deep nesting.
- **Helper functions**: define inline with `local function name() … end` inside
  `config` closures rather than at module level.

### Error handling

- Use `pcall` for operations that may fail (require, extension loading).
- Check `vim.v.shell_error` after `vim.fn.system()` calls; use early return:
  ```lua
  local result = vim.fn.system({ "git", "add", "-A" })
  if vim.v.shell_error ~= 0 then
      vim.notify("git add failed: " .. result, vim.log.levels.ERROR)
      return
  end
  ```
- Propagate LSP errors via `vim.notify(err.message, vim.log.levels.ERROR)`.
- Use `error(msg)` (not `assert`) for fatal bootstrap/setup failures.
- Do **not** silently swallow errors — log them with `vim.notify`. Exception:
  `languages_init.lua` uses bare `pcall(require, module)` — intentional since
  missing language files are non-fatal.

### Shell calls from keymaps

Use `vim.fn.system` / `vim.fn.systemlist` synchronously (not `vim.fn.jobstart`).
A recurring pattern is branch-name ticket extraction for commit messages:
```lua
local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
local ticket = branch:match("([A-Z]+-%d+)")
local message = ticket and (ticket .. ": " .. input) or input
```

### Buffer-local user commands

Use `vim.api.nvim_buf_create_user_command` for commands scoped to a buffer:
```lua
vim.api.nvim_buf_create_user_command(bufnr, "LspCopilotSignIn", function() … end, {})
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
`lua/jesse/lazy/lsp.lua`. The `ensure_installed` list is built dynamically
from that same table (Copilot is excluded — it uses a different API).

### Copilot (native LSP, nvim 0.11+)

Copilot is wired as a **native LSP client** using the `vim.lsp.config` /
`vim.lsp.enable` API (nvim 0.11+), not a plugin like `copilot.lua`. It
exposes `:CopilotToggle`, `:LspCopilotSignIn`, and `:LspCopilotSignOut`
commands. Inline completion via `vim.lsp.inline_completion` is guarded for
nvim 0.12+ nightly.

**Copilot is intentionally detached from Elixir buffers**: `languages/elixir.lua`
has an `LspAttach` autocmd that calls `vim.lsp.buf_detach_client()` for any
client named `"copilot"` on `*.ex`, `*.exs`, and `*.heex` files.

### Treesitter API

`treesitter.lua` uses the `main`-branch rewrite API
(`require("nvim-treesitter").setup(…)`) — not the legacy
`require("nvim-treesitter.configs").setup{}` form. Markdown highlighting is
skipped (handled by `render-markdown.nvim`).
