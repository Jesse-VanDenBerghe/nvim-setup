# Neovim Configuration — Comprehensive Audit Report

## Executive Summary

The configuration is functional and well-structured for a personal setup. The primary concerns are: a hard crash bug in `opencode.lua`, Copilot globally disabled in `elixir.lua`, several critical plugin configuration issues, missing LSP hover keybinding, and various style inconsistencies.

---

## Critical Bugs


### 2. `languages/elixir.lua` — Copilot Disabled Globally (line 1)

**Severity:** CRITICAL

```lua
vim.g.copilot_disabled = true  -- ❌ line 1, MODULE TOP LEVEL
```

When `languages_init.lua` requires this file at startup, it sets this global *before any buffer is opened*. The `lsp.lua:280` check `autostart = not vim.g.copilot_disabled` sees this and **disables Copilot for every filetype**, not just Elixir.

**Impact:** Copilot doesn't work on any file.

---

## High Priority Issues

### 3. `telescope.lua:55` — Broken `pcall` Wrapping

**Severity:** HIGH

```lua
-- WRONG (line 55)
pcall(require("telescope").load_extension("harpoon"))

-- CORRECT
pcall(require("telescope").load_extension, "harpoon")
```

The return value of `load_extension` is passed to `pcall`, not the function itself. Any error from the harpoon extension load is **unprotected**.

---

### 4. `lsp.lua` — `copilot` in Mason's `ensure_installed`

**Severity:** HIGH

```lua
servers = {
  copilot = { ... },   -- ❌ Not a Mason package
  elixirls = { ... },
  ...
}

-- Later (line 382)
ensure_installed = vim.tbl_keys(servers)  -- Includes "copilot"!
```

There is no Mason package called `"copilot"` — it should be `"copilot-language-server"` or excluded entirely. This causes mason-tool-installer to emit warnings/errors on every startup.

---

### 5. `lsp.lua:24` — Augroup `{ clear = true }` on Per-Buffer Autocmd

**Severity:** HIGH

```lua
-- Line 23-24
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("copilot-inline-completion", { clear = true }),
  -- ❌ clear = true wipes ALL previous handlers in this augroup every LspAttach!
```

Clearing the augroup on every `LspAttach` event wipes the inline completion handler for previously-opened buffers. Should be `{ clear = false }` or restructured to use a single global augroup without clearing.

---

### 6. `mini.lua` — LSP Hover (`K`) Lost with No Replacement

**Severity:** HIGH

```lua
-- mini.lua lines 11-14
vim.keymap.set("n", "K", move_up, { desc = "Move up" })   -- ❌ overwrites LSP hover
```

`mini.move` remaps `K` (normally LSP hover) to move up. **No file rebinds `K` to `vim.lsp.buf.hover()`.**

**Impact:** LSP hover is inaccessible via keyboard; must use mouse or find another method.

---

### 7. `lualine.lua` — Opencode Forced to Load Eagerly

**Severity:** HIGH

```lua
-- lualine.lua line 5
dependencies = { "NickvanDyke/opencode.nvim" },  -- ❌ Forces eager load

-- lualine.lua line 11
lualine_z = { require("opencode").statusline },  -- ❌ Requires at config time
```

Listing opencode as a *dependency* forces it to load at startup, defeating the lazy-loading configured in `opencode.lua` with `keys = {}`. The `require()` call at config time compounds this.

**Fix:** Wrap in a function: `lualine_z = { function() return require("opencode").statusline() end }`

---

### 8. `themes.lua` — Missing `priority = 1000`

**Severity:** HIGH

```lua
return {
  "folke/onedark.nvim",
  lazy = false,
  -- ❌ Missing: priority = 1000
  ...
}
```

Colorscheme plugins must set `priority = 1000` to load before other UI plugins. Without it, other eagerly-loaded plugins may render with wrong colors before the theme is applied.

---

### 9. `telescope.lua:55` + `harpoon.lua:14` — Harpoon Extension Loaded Twice

**Severity:** HIGH (Code smell)

- `harpoon.lua:14` — correctly loads harpoon telescope extension
- `telescope.lua:55` — incorrectly loads it again with broken `pcall`

The extension is loaded twice, and the second load is unprotected.

---

### 10. `lazy/init.lua:4` — Plenary Installed Twice

**Severity:** HIGH

```lua
{
  "nvim-lua/plenary.nvim",
  name = "plenary",  -- ❌ Causes duplication!
},
```

The `name = "plenary"` override makes lazy.nvim treat this as a separate plugin from `"plenary.nvim"` (the slug used by dependencies in other files). Result: lockfile has both `"plenary"` and `"plenary.nvim"` entries — **plenary is installed twice**.

**Fix:** Remove the `name` field.

---

## Medium Priority Issues

### 11. `init.lua` — Auto-Save Autocmd Has No Augroup

**Severity:** MEDIUM

```lua
-- Lines 81-85
vim.api.nvim_create_autocmd("InsertLeave", {
  -- ❌ Missing: group = vim.api.nvim_create_augroup("auto-save", { clear = true })
  pattern = { "*" },
  callback = function() vim.cmd("silent! wall") end,
})
```

Issues:
1. No `group` field → duplicates on config re-source
2. `pattern = { "*" }` fires on *every* buffer, including fugitive, NvimTree, terminals, scratch buffers
3. No buffer-type guard → attempts to write special buffers

**Fix:**
```lua
local group = vim.api.nvim_create_augroup("auto-save", { clear = true })
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  group = group,
  callback = function()
    if vim.bo.buftype == "" and vim.bo.modifiable then
      vim.cmd("silent! wall")
    end
  end,
})
```

---

### 12. `init.lua` — `vim.g.have_nerd_font` Set After `lazy_init`

**Severity:** MEDIUM

```lua
-- Line 4: lazy_init loaded FIRST
require("jesse.lazy_init")

-- Line 7: have_nerd_font set AFTER
vim.g.have_nerd_font = true
```

Plugins that reference `vim.g.have_nerd_font` in their spec (telescope, which-key) evaluate it during spec construction, which happens before this line. They see `nil`.

**Fix:** Move `vim.g.have_nerd_font = true` to line 1, before `lazy_init`.

---

### 13. `languages/elixir.lua` — All Keymaps Use Wrong API, No Descriptions

**Severity:** MEDIUM

```lua
-- Lines 12-42: All use nvim_buf_set_keymap with no desc
vim.api.nvim_buf_set_keymap(0, "n", "<leader>bp", ":!mix compile<CR>", { noremap = true })
-- ❌ Should be:
vim.keymap.set("n", "<leader>bp", function() vim.cmd("!mix compile") end, { 
  buffer = true, 
  desc = "Build project (mix compile)" 
})
```

**Issues:**
1. Uses deprecated `nvim_buf_set_keymap` instead of `vim.keymap.set`
2. None of the ~10 keymaps have a `desc` field
3. Makes keymaps invisible to which-key

---

### 14. `languages/elixir.lua` — `filepath` Captured at Wrong Time

**Severity:** MEDIUM

```lua
-- Line 9: Captured when buffer opens
local filepath = vim.fn.expand("%")

-- Lines used later in callbacks
vim.api.nvim_buf_set_keymap(0, "n", "<leader>rf", ":!mix run " .. filepath .. "<CR>", ...)
```

If the file is renamed or moved, the cached path is stale. Capture inside each keymap callback:

```lua
vim.keymap.set("n", "<leader>rf", function()
  local fp = vim.fn.expand("%")
  vim.cmd("!mix run " .. fp)
end, { buffer = true, desc = "Run file" })
```

---

### 15. `treesitter.lua:33` — FileType Autocmd Has No Augroup

**Severity:** MEDIUM

```lua
-- Line 33
vim.api.nvim_create_autocmd("FileType", {
  -- ❌ Missing: group = vim.api.nvim_create_augroup("treesitter-highlight", { clear = true })
  ...
})
```

Will duplicate on config re-source.

---

### 16. `which-key.lua` — `<leader>a` Group Missing

**Severity:** MEDIUM

```lua
-- which-key.lua lines 46-61
-- All other groups documented, but <leader>a is missing:
-- ❌ { "<leader>a", group = "[A]I" }
```

All opencode keymaps (`<leader>aa`, `<leader>ax`, etc.) appear without a group label in which-key.

---

### 17. `lsp.lua` — `copilot` Server Should Be Configured Separately

**Severity:** MEDIUM

```lua
-- Lines 394-403: Handler loops over servers
for server, config in pairs(servers) do
  require("lspconfig")[server].setup(config)  -- ❌ Tries to call lspconfig["copilot"].setup()
end
```

`copilot` is not an LSP server managed by `lspconfig` or `mason-lspconfig`. It should be set up explicitly outside this loop, or excluded from the servers table.

---

### 18. `conform.lua` — No Elixir Formatter; Silent Errors

**Severity:** MEDIUM

```lua
-- Lines 30: Only Lua
formatters_by_ft = { lua = { "stylua" } }

-- ❌ No entry for elixir, typescript, kotlin, yaml
-- Falls back to LSP formatter silently

-- Line 17: notify_on_error = false
-- ❌ Format failures are completely silent
```

**Issues:**
1. No `elixir = { "mix" }` entry (falls back to LSP, undocumented)
2. `timeout_ms = 500` is too short for `mix format` on larger files
3. `notify_on_error = false` means failures are invisible

---

### 19. `fugitive.lua` — `git add -A` Unguarded and Bypasses Fugitive

**Severity:** MEDIUM

```lua
-- Lines 18, 45: Unguarded git operations
vim.fn.system("git add -A")  -- ❌ No error check; stages everything blindly

-- Line 45: Uses raw shell command instead of fugitive
map("<leader>ga", ":!git add -A<CR>", "Add all")
-- ❌ Should be: ":Git add -A<CR>" to refresh fugitive status
```

---

### 20. `lsp.lua:125-130` — Inline Completion Block Is Dead Code

**Severity:** MEDIUM

```lua
-- Lines 121-130: After the early return for non-session.status events
-- The entire block has undefined variable references
```

Either complete the implementation or remove it entirely.

---

### 21. `themes.lua:5-6` — `lazy = false` + `event` Contradictory

**Severity:** MEDIUM

```lua
lazy = false,
event = "VimEnter",  -- ❌ Redundant; ignored when lazy = false
```

Remove the `event` field.

---

### 22. `lazy/init.lua:6` — `guess-indent.nvim` Never Configured

**Severity:** MEDIUM

```lua
{
  "nmac427/guess-indent.nvim",
  -- ❌ Missing: opts = {} or config = true
},
```

The plugin loads but never calls `setup()`. Add `opts = {}` or `config = true`.

---

## Low Priority Issues

### 23. `harpoon.lua` — Harpoon v1 (Unmaintained)

The config uses harpoon v1 (`master` branch), which is no longer actively maintained. v2 is available (`harpoon2` branch). Consider upgrading or add a comment explaining the v1 choice.

---

### 24. `harpoon.lua:9-11` — Tabline Conflict

```lua
tabline = { enable = true }
```

Enabling harpoon's tabline can conflict with `lualine` if lualine also has a tabline section. Consider disabling or clarifying the intent.

---

### 25. `harpoon.lua:22-51` — Repetitive Keymap Registration

10 nearly-identical lines could be generated by a loop:

```lua
for i = 1, 9 do
  vim.keymap.set("n", "<leader>h" .. i, function() ui.nav_file(i) end, 
    { desc = "Harpoon " .. i })
end
vim.keymap.set("n", "<leader>h0", function() ui.nav_file(10) end, 
  { desc = "Harpoon 10" })
```

---

### 26. `lsp.lua` — K Hover Lost (Duplicate of #6)

No rebinding of `K` to `vim.lsp.buf.hover()` after mini.move overwrites it.

---

### 27. `lsp.lua` — Deprecated Inline Completion API

```lua
-- Lines 35-42
map("<C-F>", "Accept inline completion", { require("copilot.client").inline_completion_get() })
```

The inline completion UX is incomplete — there's no "accept" binding mapped to `<Tab>` or `<Right>`.

---

### 28. `tree.lua` — `lazy = false` Unnecessary

```lua
lazy = false,  -- ❌ Forces eager load; could be lazy on <leader>et keypress
```

nvim-tree could be lazy-loaded on demand:

```lua
keys = { { "<leader>et", "<cmd>NvimTreeToggle<cr>", desc = "Explorer" } },
event = { "BufRead", "BufNewFile" },  -- or just keys
```

---

### 29. `opencode.lua` — Top-Level Side Effects

```lua
-- Lines 1-15: Executed at require time (during spec scan)
vim.api.nvim_create_namespace("opencode-status")
local function print(msg)  -- ❌ Shadows global print within module
  ...
end
```

Module-level side effects run before the plugin is even loaded. The `print` shadowing is unusual and runs before loading.

---

### 30. `opencode.lua` — Commented Block (line 137-144)

```lua
-- Commented: Start opencode after startup
-- vim.api.nvim_create_autocmd(...)
```

Per AGENTS.md: commented-out code should include an explanation. Add a comment explaining why this is disabled.

---

### 31. `lazy_init.lua` — Network Checker on Every Startup

```lua
checker = { enabled = true, notify = false }
```

Background HTTP request on every startup. Consider `checker = { enabled = false }` or `frequency = 86400` (once per day).

---

### 32. `lazy_init.lua` + `languages_init.lua` — `vim.loop` Deprecation

Both files use `vim.uv or vim.loop`. Fine as a fallback (Neovim 0.9+ support), but can be removed once 0.10+ is the minimum. Low priority.

---

### 33. `lazy_init.lua` — Style: Single-Quoted Strings

```lua
-- Uses 'single' quotes throughout
-- AGENTS.md: use "double" quotes
```

Also uses 4-space soft indent (legacy). Consider updating to tabs + double quotes.

---

### 34. `languages_init.lua` — Silent Error Swallowing

```lua
-- Line 14
pcall(require, module)
-- ❌ Errors silently; should notify on failure
```

Log errors with `vim.notify` at WARN level.

---

### 35. `languages_init.lua` — Empty `else` Block

```lua
-- Lines 17-18
else
end  -- ❌ Dead code
```

Should either be removed or contain a warning notification.

---

### 36. `blink.lua` — Lua Fuzzy Matching (Suboptimal)

```lua
fuzzy = { implementation = "lua" }
-- ❌ Slower than Rust; rust binary auto-downloads
-- Consider: implementation = "prefer_rust_with_warning"
```

---

### 37. `conform.lua` — Dead Code

```lua
-- Lines 19-20
disable_filetypes = { "c", "cpp" }
-- ❌ No C/C++ LSP/formatters configured; leftover from kickstart.nvim
```

---

### 38. `telescope.lua` — Broad Ignore Patterns

```lua
-- Lines 44-48
file_ignore_patterns = { "pack/", "lsp/" }
-- ❌ "pack/" hides any path containing "pack" (e.g. "backpack/")
-- Use anchored patterns: "^pack/", "^lsp/"
```

---

### 39. `telescope.lua` — `live_grep` Preferred Over `grep_string`

```lua
-- Line 64
builtin.grep_string(...)  -- ❌ Static search, no live results
-- Consider: builtin.live_grep()  -- Live results as you type
```

---

### 40. `gitsigns.lua` — No Hunk Navigation Keymaps

Common gitsigns keymaps missing:
- `]c` / `[c` — next/prev hunk
- `<leader>hs` — stage hunk
- `<leader>hr` — reset hunk
- `<leader>hp` — preview hunk

---

### 41. `alpha-vim.lua` — Dead `header` Variable

```lua
-- Lines 9-21: Defined but never used
local header = { ... }

-- Line 74: Uses elixir_header instead
...elixir_header...
```

---

### 42. `mini.lua` — `delay = 0` on which-key

```lua
delay = 0  -- ❌ Pops up instantly; can be noisy during typing
-- Recommended: 300ms
```

---

### 43. `mini.lua` — `mini.animate` Cursor Latency

```lua
-- Line 23
timing_fn = ... 50ms ...  -- May feel laggy on fast j/k navigation
```

---

### 44. `mini.lua` — `mini.move` Overwrites Standard Motions

- `H`, `L` — go to screen line start/end
- `J` — join lines (now overwritten to move down)
- `K` — lookup keyword / LSP hover (now overwritten, not rebound)

---

### 45. `fugitive.lua` — Shell Injection Risk

```lua
-- Line 12, 25
"Git commit -m '" .. message:gsub("'", "'\\''") .. "'"
-- ❌ Manual shell escaping is fragile
-- Prefer: vim.fn.system({"git", "commit", "-m", message})
```

---

### 46. `fugitive.lua` — `sed` in Shell (Non-Portable)

```lua
-- Line 35
systemlist("git symbolic-ref refs/remotes/origin/HEAD | sed '...'")
-- ❌ Doesn't work on Windows; sed dialect varies
```

Replace with pure Lua or git API.

---

### 47. `lsp.lua` — `require("telescope.builtin")` on Every LspAttach

```lua
-- Lines 69-99
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function()
    require("telescope.builtin")  -- ❌ Called on every buffer attach
```

Wrap in lazy functions to avoid repeated requires.

---

### 48. `lsp.lua` — `virtual_text.format` Is a No-Op

```lua
-- Lines 182-191
format = function(diagnostic_message)
  return diagnostic_message[diagnostic.severity]  -- ❌ Always returns message; no-op
end
```

Simplify to `format = function(d) return d.message end` or remove entirely.

---

### 49. `lsp.lua` — `copilot.filetypes = { "*" }` Attaches to Special Buffers

```lua
filetypes = { "*" }  -- ❌ Includes NvimTree, terminal, help, etc.
```

Use a more targeted list or filter special buffers.

---

### 50. `init.lua` — `softtabstop = 4` Redundant

```lua
vim.opt.expandtab = true
vim.opt.softtabstop = 4  -- ❌ Largely redundant with expandtab
```

`softtabstop` mainly affects `<BS>` behavior, which `shiftwidth` already covers.

---

## Summary Table

| File | Critical | High | Medium | Low |
|------|----------|------|--------|-----|
| `jesse/init.lua` | — | — | auto-save augroup, have_nerd_font order | softtabstop redundant |
| `lazy_init.lua` | — | — | — | style, network checker, vim.loop |
| `languages_init.lua` | — | — | silent errors, empty else | non-deterministic order |
| `lazy/init.lua` | — | plenary duplication | guess-indent unconfigured | style |
| `lazy/lsp.lua` | — | copilot in Mason, augroup bug | copilot server, no-op format, K hover | helpers re-defined |
| `lazy/conform.lua` | — | — | no Elixir formatter, silent errors | timeout, dead code |
| `lazy/treesitter.lua` | — | — | no augroup, markdown conflict | vim.loop, query parser |
| `lazy/telescope.lua` | — | broken pcall | double harpoon load, grep_string | ignore patterns, fd naming |
| `lazy/blink.lua` | — | — | lua fuzzy, no buffer source | LuaSnip opts |
| `lazy/mini.lua` | — | K hover lost | — | cmdline conflict, animate, delay |
| `lazy/which-key.lua` | — | — | missing `<leader>a`, `<leader>lt`/`lc` | delay = 0 |
| `lazy/gitsigns.lua` | — | — | no hunk keymaps | changedelete visual, style |
| `lazy/fugitive.lua` | — | — | git add unguarded, shell injection | sed non-portable, deprecated |
| `lazy/harpoon.lua` | — | double load | v1 unmaintained, tabline | 10-keymap loop |
| `lazy/lualine.lua` | — | opencode eager load | statusline require | undocumented defaults |
| `lazy/alpha-vim.lua` | — | — | dead header variable | button mismatch, datetime |
| `lazy/tree.lua` | — | — | lazy = false | update_root, version = "*" |
| `lazy/opencode.lua` | **crash** | — | top-level side effects | commented block |
| `lazy/render-markdown.lua` | — | — | treesitter interaction | no customisation |
| `lazy/themes.lua` | — | missing priority | lazy + event contradiction | style, hard-coded color |
| `languages/elixir.lua` | **Copilot disabled** | — | wrong API, no desc, filepath | double space |

---

## Recommended Fix Order

1. **Critical (Break Things):**
   - Fix `opencode.lua` crash (lines 125–130)
   - Fix `languages/elixir.lua` Copilot bug (line 1)

2. **High (Core Functionality):**
   - Fix `telescope.lua` broken `pcall` (line 55)
   - Fix `lsp.lua` `copilot` Mason issue (lines 382–403)
   - Fix `lsp.lua` augroup clear bug (line 24)
   - Rebind `K` to LSP hover in `lsp.lua` (after mini.move overrides)
   - Fix `lualine.lua` opencode eager load
   - Add `priority = 1000` to `themes.lua`
   - Remove plenary duplication in `lazy/init.lua`

3. **Medium (Correctness & UX):**
   - Fix `init.lua` auto-save augroup + buffer-type guard
   - Fix `init.lua` `have_nerd_font` order
   - Fix `treesitter.lua` FileType augroup
   - Fix `languages/elixir.lua` keymaps (API, desc, filepath)
   - Fix `which-key.lua` missing `<leader>a`
   - Fix `conform.lua` Elixir formatter + errors
   - Fix `lazy/init.lua` `guess-indent` setup
   - Clean up other augroup issues

4. **Low (Polish & Style):**
   - Update style inconsistencies
   - Remove dead code
   - Add comments
   - Optimize non-critical configs
