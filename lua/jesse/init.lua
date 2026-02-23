vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

require("jesse.lazy_init")
require("jesse.languages_init")
require("jesse.keymaps")

-- Configure HEEx filetype detection
vim.filetype.add({
	extension = {
		heex = "heex",
	},
	pattern = {
		[".*%.html%.heex"] = "heex",
	},
})

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"

vim.opt.breakindent = true

vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.o.inccommand = "split"

vim.opt.smartindent = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.o.cursorline = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "120"

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local auto_save_group = vim.api.nvim_create_augroup("auto-save", { clear = true })
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
	group = auto_save_group,
	callback = function()
		if vim.bo.buftype == "" and vim.bo.modifiable then
			vim.cmd("silent! wall")
		end
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})
