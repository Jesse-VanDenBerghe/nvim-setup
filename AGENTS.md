# Neovim Config — Agent Guidelines

This repository is a personal Neovim configuration written entirely in Lua,
using [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager.
There is no build system, test suite, or CI pipeline — changes are validated
by launching Neovim and observing runtime behaviour.

---

## Repository Layout

```
~/.config/nvim/
├── .stylua.toml                        # Stylua formatter config (canonical style authority)
├── init.lua                            # Entry point — just: require("jesse")
├── lazy-lock.json                      # Plugin lockfile (commit this on updates)
└── lua/jesse/
    ├── init.lua                        # ALL core options, autocmds, global keymaps
    ├── lazy_init.lua                   # Bootstraps lazy.nvim, calls lazy.setup{}
    ├── languages_init.lua              # Auto-requires every *.lua in languages/
    ├── copilot.lua                     # Copilot module (M = {} pattern; required by lsp.lua)
    ├── lazy/                           # One file per plugin (or plugin group)
    │   ├── init.lua                    # Minimal plugins (plenary, guess-indent)
    │   ├── lsp.lua                     # nvim-lspconfig + Mason + Copilot wiring
    │   ├── conform.lua                 # Auto-formatting (stylua for Lua, mix for Elixir)
    │   ├── treesitter.lua              # nvim-treesitter setup & parser list
    │   ├── harpoon.lua                 # File navigation (harpoon2 branch)
    │   ├── gitsigns.lua                # Git decorations in the sign column
    │   ├── blink.lua                   # Completion engine (blink.cmp + LuaSnip)
    │   ├── mini.lua                    # mini.nvim: ai, surround, move, pairs, cmdline
    │   ├── which-key.lua               # Keymap discovery & group labels
    │   ├── lualine.lua                 # Status line (with dynamic Copilot/Sidekick components)
    │   ├── flash.lua                   # folke/flash.nvim motion (s, S)
    │   ├── render-markdown.lua         # Markdown rendering (ft-loaded)
    │   ├── sidekick.lua                # folke/sidekick.nvim — NES, AI CLI (<c-.>)
    │   ├── themes.lua                  # Colorscheme (onedark, warmer, transparent)
    │   ├── todo-comments.lua           # folke/todo-comments.nvim
    │   ├── trouble.lua                 # folke/trouble.nvim diagnostics UI
    │   ├── snacks.lua                  # folke/snacks.nvim — picker, explorer, git, …
    │   └── snacks/
    │       └── dashboard.lua           # Dashboard config, required by snacks.lua
    └── languages/                      # Per-language autocmds & keymaps
        └── elixir.lua                  # Elixir build/run/test keymaps + Copilot detach
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
| Format current buffer | `<leader>uf` (calls `conform.nvim` → `stylua`, mode `""` = all modes) |
| Format from CLI | `stylua lua/jesse/**/*.lua` (reads `.stylua.toml` automatically) |
| Lua type-check (lazydev) | Errors surface in the editor via `lua_ls` |

Stylua is the sole Lua formatter. `.stylua.toml` is the canonical authority:
`column_width = 120`, `indent_type = "Tabs"`, `indent_width = 4`.

> **Note**: `lazy_init.lua`, `treesitter.lua`, `gitsigns.lua`, `flash.lua`,
> `trouble.lua`, and `todo-comments.lua` use 4-space soft-indent — a tolerated
> legacy inconsistency. Prefer hard tabs in all **new** files.

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

### Module / file structure

Three shapes for `lua/jesse/lazy/<name>.lua` files:

1. **`opts = {}`** — for plugins accepting a single options table with no side effects.
2. **`config = function() … end`** — for non-trivial setup requiring local variables or
   side effects (e.g. keymaps registered inside `config`).
3. **`keys = { … }`** in spec — for lazy-loaded plugins whose primary trigger is keymaps;
   declare keymaps here rather than inside `config` so lazy.nvim can display them.

Plain Lua modules (non-plugin) use the **`M = {}` pattern**:
```lua
local M = {}
function M.setup(capabilities) … end
function M.toggle() … end
return M
```
`lua/jesse/copilot.lua` is the only such module. It is `require`d explicitly inside
`lsp.lua`'s `config` function: `require("jesse.copilot").setup(capabilities)`.

Language-specific setup lives in `lua/jesse/languages/<lang>.lua` and is auto-discovered
by `languages_init.lua` — no manual registration needed.

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
- **Exception**: `Snacks` (capital S) is an intentional implicit global injected by
  `snacks.nvim`. Never `require` it locally — use `Snacks.*` directly. This is the
  only sanctioned implicit global in the codebase.

### Keymaps

- Always supply a `desc` field using bracket notation for the mnemonic key:
  ```lua
  vim.keymap.set("n", "<leader>ha", fn, { desc = "[H]arpoon [A]dd file" })
  ```
- LSP keymaps use a local `map` helper (defined inside the `LspAttach` callback) that
  prepends `"LSP: "` to the desc and defaults to `mode = "n"`.
- For lazy-loaded plugins, declare keymaps in the `keys = {}` spec field rather than
  inside `config`.
- Both `vim.g.mapleader` and `vim.g.maplocalleader` are `" "` (space), set at the very
  top of `lua/jesse/init.lua` before any `require`.
- Use the `<leader>` prefix hierarchy declared in `which-key.lua`:
  - `<leader>f` — Find (files, buffers, git files, recent, …)
  - `<leader>h` — Harpoon
  - `<leader>e` — Explorer (Snacks)
  - `<leader>s` — Search / grep
  - `<leader>t` — Test
  - `<leader>r` — Run
  - `<leader>b` — Build
  - `<leader>l` — LSP (`lr` Refactor, `lg` Go-to)
  - `<leader>g` — Git (`gc` Commit, `gb` Branch)
  - `<leader>a` — AI / Copilot / Sidekick
  - `<leader>u` — UI toggles (format, colorscheme, dismiss notifications)
  - `<leader>x` — Diagnostics / Trouble lists

### Autocmds

- Always create a named augroup with `{ clear = true }` to prevent duplicate
  registrations on re-source:
  ```lua
  local group = vim.api.nvim_create_augroup("my-group", { clear = true })
  vim.api.nvim_create_autocmd("FileType", { group = group, … })
  ```
- Use `{ clear = false }` only for augroups that accumulate per-buffer entries
  (e.g. `"kickstart-lsp-highlight"`, `"copilot-inline-completion"`).
- **Augroup naming**: `kebab-case` for core / LSP groups; `PascalCase` for per-language
  groups (e.g. `"ElixirTools"`).
- **Auto-save is active globally**: `lua/jesse/init.lua` registers an `InsertLeave` +
  `TextChanged` autocmd (`"auto-save"` group) that runs `silent! wall` whenever
  `vim.bo.buftype == ""` and `vim.bo.modifiable`. Any normal file buffer will be written
  to disk immediately — be aware when creating temporary or scratch buffers.

### Language files (`languages/<lang>.lua`)

- Create one augroup per file (PascalCase, e.g. `"KotlinTools"`).
- Use `LspAttach` with `pattern = { "*.ext" }` for LSP-level operations (like Copilot
  detach) to avoid filetype timing issues.
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
- Language keymaps that run shell commands use `vim.cmd("!mix compile")` style
  (blocking Neovim bang-command), **not** `vim.fn.system`. No `vim.v.shell_error`
  check is required for these interactive commands since output streams to the terminal.

### Naming conventions

- **Variables / locals**: `snake_case` (e.g. `languages_dir`, `copilot_config`).
- **Augroup names**: `kebab-case` strings (e.g. `"kickstart-lsp-attach"`).
- **Language augroup names**: `PascalCase` (e.g. `"ElixirTools"`).
- **Boolean guards**: prefer early-return style rather than deep nesting.
- **Helper functions**: define inline with `local function name() … end` inside `config`
  closures rather than at module level.

### Error handling

- Use `pcall` for operations that may fail (require, extension loading).
- Check `vim.v.shell_error` after `vim.fn.system()` calls in non-language-keymap
  contexts; use early return:
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
  `languages_init.lua` uses bare `pcall(require, module)` — intentional since missing
  language files are non-fatal.

### Shell calls from keymaps (non-language contexts)

Use `vim.fn.system` / `vim.fn.systemlist` synchronously (not `vim.fn.jobstart`).
A recurring pattern is branch-name ticket extraction for commit messages:
```lua
local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
local ticket = branch:match("([A-Z]+-%d+)")
local message = ticket and (ticket .. ": " .. input) or input
```
Jira-style ticket codes (e.g. `PROJ-123`) from the branch name are automatically
prepended to commit messages when found.

The **only** sanctioned use of `vim.fn.jobstart` is in `snacks/dashboard.lua` for
detached browser-opening: `vim.fn.jobstart("gh pr list --web", { detach = true })`.
All other async work uses Neovim's built-in async APIs or synchronous `vim.fn.system`.

### Buffer-local user commands

Use `vim.api.nvim_buf_create_user_command` for commands scoped to a buffer:
```lua
vim.api.nvim_buf_create_user_command(bufnr, "LspCopilotSignIn", function() … end, {})
```

### Type annotations

Use EmmyLua / LuaCATS annotations for public-ish functions, especially LSP callbacks:
```lua
---@param client vim.lsp.Client
---@param bufnr? integer
---@return boolean
local function client_supports_method(client, bufnr) … end
```

### Nvim version compatibility guards

Use `vim.fn.has("nvim-0.11")` for API version branching, and nil-check new API tables
before using them:
```lua
-- API that changed signature between 0.10 and 0.11
if vim.fn.has("nvim-0.11") == 1 then
    return client:supports_method(method, bufnr)
else
    return client.supports_method(method, { bufnr = bufnr })
end

-- Feature only available on 0.12+ nightly
local ic = vim.lsp.inline_completion
if ic and ic.enable and ic.get then … end
```

### Cross-plugin integration via `specs`

Use lazy.nvim's `specs` field (not `dependencies`) when a plugin needs to inject opts
into another plugin's spec from its own file. `flash.lua` uses this to register its
picker keybinding inside `snacks.nvim`'s picker config:
```lua
specs = {
    { "folke/snacks.nvim", opts = { picker = { win = { input = { keys = {
        ["<a-s>"] = { "flash", mode = { "n", "i" } }
    } } } } } }
}
```

### Comments

- Use `--` for single-line comments; avoid `--[[ … ]]`.
- Use `-- NOTE:`, `-- WARN:`, `-- TODO:` for actionable comments.
- Commented-out code is acceptable but should include a brief explanation.

---

## Plugin Management

- **Add a plugin**: create `lua/jesse/lazy/<name>.lua` returning a lazy.nvim spec.
  lazy.nvim discovers specs via `spec = "jesse.lazy"` in `lazy_init.lua`.
- **Update lockfile**: run `:Lazy update` in Neovim; commit `lazy-lock.json`.
- **Pinning**: use `version = "x.*"` or `tag = "vX.Y.Z"` for stability.
- **Optional dependencies**: use `optional = true` so the dependent plugin loads
  regardless of whether the optional one is installed (e.g. `lualine.lua` → `sidekick.nvim`).
- **Conditional build steps**: use an IIFE to compute the `build` field:
  ```lua
  build = (function()
      if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then return end
      return "make install_jsregexp"
  end)(),
  ```

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

To add a new server, append it to the `servers` table in `lua/jesse/lazy/lsp.lua`.
The `ensure_installed` list is built dynamically from that same table.

### Copilot (native LSP, nvim 0.11+)

Copilot is wired as a **native LSP client** using the `vim.lsp.config` / `vim.lsp.enable`
API (nvim 0.11+), implemented in `lua/jesse/copilot.lua` (the `M = {}` module pattern).
`lsp.lua` calls `require("jesse.copilot").setup(capabilities)` inside its `config`
function. It exposes `:CopilotToggle`, `:LspCopilotSignIn`, and `:LspCopilotSignOut`
commands. The `<leader>ai` keymap for toggle is registered inside `M.setup()`.
Inline completion via `vim.lsp.inline_completion` is guarded for nvim 0.12+ nightly.

**Copilot is intentionally detached from Elixir buffers**: `languages/elixir.lua` has an
`LspAttach` autocmd that calls `vim.lsp.buf_detach_client()` for any client named
`"copilot"` on `*.ex`, `*.exs`, and `*.heex` files.

### Treesitter API

`treesitter.lua` uses the `main`-branch rewrite API (`require("nvim-treesitter").setup(…)`)
— not the legacy `require("nvim-treesitter.configs").setup{}` form. Markdown highlighting
is skipped (handled by `render-markdown.nvim`).

### netrw

netrw is fully disabled via `vim.g.loaded_netrw = 1` and `vim.g.loaded_netrwPlugin = 1`
in `jesse/init.lua`. File exploration is handled entirely by `Snacks.explorer`.
