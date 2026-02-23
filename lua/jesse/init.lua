vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

require("jesse.lazy_init")
require("jesse.languages_init")

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

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<Esc><Esc>", "<C-w><C-q>", { desc = "Exit current window" })

vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<leader>rc", function()
	vim.ui.input({ prompt = "Command: " }, function(input)
		if not input or input == "" then
			return
		end
		local cmd = vim.split(input, "%s+")
		require("jesse.util").run_notify(cmd, input)
	end)
end, { desc = "[R]un [C]ommand" })

vim.keymap.set("n", "<leader>rt", function()
	vim.ui.input({ prompt = "Terminal command: " }, function(input)
		if not input or input == "" then
			return
		end
		vim.cmd("split")
		vim.cmd("wincmd J")
		vim.cmd("resize 15")
		local buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_set_current_buf(buf)
		vim.fn.termopen(input)
		vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>bd!<CR>", { noremap = true, silent = true, desc = "Close terminal" })
		vim.cmd("startinsert")
	end)
end, { desc = "[R]un [T]erminal command" })

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
