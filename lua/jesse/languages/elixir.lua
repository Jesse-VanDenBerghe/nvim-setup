local util = require("jesse.util")
local run_notify = util.run_notify
local mix_picker = require("jesse.languages.elixir.picker")

local elixirgroup = vim.api.nvim_create_augroup("ElixirTools", { clear = true })

local function setup_elixir()
	-- Build keymaps
	vim.keymap.set("n", "<leader>bp", function()
		run_notify({ "mix", "compile" }, "mix compile")
	end, { desc = "[B]uild [P]roject (mix compile)" })

	-- Run keymaps
	vim.keymap.set("n", "<leader>rf", function()
		run_notify({ "mix", "run", vim.fn.expand("%") }, "mix run")
	end, { desc = "[R]un [F]ile (mix run)" })

	-- Test keymaps
	vim.keymap.set("n", "<leader>tp", function()
		run_notify({ "mix", "test" }, "mix test")
	end, { desc = "[T]est [P]roject (mix test)" })

	vim.keymap.set("n", "<leader>tf", function()
		run_notify({ "mix", "test", vim.fn.expand("%") }, "mix test file")
	end, { desc = "[T]est [F]ile (mix test)" })

	-- Search keymaps
	vim.keymap.set("n", "<leader>sm", mix_picker.open, { desc = "[S]earch [M]ix task" })
end

vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
	group = elixirgroup,
	callback = function()
		local cwd = vim.fn.getcwd()
		if vim.fn.filereadable(cwd .. "/mix.exs") == 1 then
			setup_elixir()
		end
	end,
})

-- .exs-only: run as a standalone script (buffer-local, only relevant for script files)
vim.api.nvim_create_autocmd("FileType", {
	pattern = "elixir",
	group = elixirgroup,
	callback = function()
		local filename = vim.fn.expand("%:t")
		if filename:match("%.exs$") then
			vim.keymap.set("n", "<leader>rs", function()
				run_notify({ "elixir", vim.fn.expand("%") }, "elixir script")
			end, { buffer = true, desc = "[R]un [S]cript (elixir)" })
		end
	end,
})
