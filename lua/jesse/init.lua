print("Setting up Profile: Jesse")
vim.g.mapleader = " "

print("\nMaking sure plugins are up to date...")
require("jesse.pack")

print("\nLoading Theme")
require("jesse.themes.onedark")

print("\nConfiguring plugins...")
require("jesse.plugins")

print("\nApplying remaps...")
require("jesse.remap")

print("\nEnabling LSP servers...")
require("jesse.lsp")

print("\nEnabling copilot servers...")
require("jesse.copilot")

vim.api.nvim_set_hl(0, "Normal", {bg = "none"})
vim.api.nvim_set_hl(0, "NormalFloat", {bg = "none"})

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "120"

vim.diagnostic.config({
  virtual_text = true,
  virtual_lines = { current_line = true },
})

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  pattern = { "*" },
  command = "silent! wall",
  nested = true,
})
