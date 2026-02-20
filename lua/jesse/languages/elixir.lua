local util = require("jesse.util")
local run_notify = util.run_notify

local elixirgroup = vim.api.nvim_create_augroup("ElixirTools", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "elixir",
	group = elixirgroup,
	callback = function()
		local filename = vim.fn.expand("%:t")

		-- Build keymaps
		vim.keymap.set(
			"n",
			"<leader>bp",
			function()
				run_notify({ "mix", "compile" }, "mix compile")
			end,
			{ buffer = true, desc = "Build project (mix compile)" }
		)

		-- Run keymaps
		vim.keymap.set(
			"n",
			"<leader>rf",
			function()
				run_notify({ "mix", "run", vim.fn.expand("%") }, "mix run")
			end,
			{ buffer = true, desc = "Run file (mix run)" }
		)

		if filename:match("%.exs$") then
			vim.keymap.set(
				"n",
				"<leader>rs",
				function()
					run_notify({ "elixir", vim.fn.expand("%") }, "elixir script")
				end,
				{ buffer = true, desc = "Run script (elixir)" }
			)
		end

		-- Test keymaps
		vim.keymap.set(
			"n",
			"<leader>tp",
			function()
				run_notify({ "mix", "test" }, "mix test")
			end,
			{ buffer = true, desc = "Test project (mix test)" }
		)

		vim.keymap.set(
			"n",
			"<leader>tf",
			function()
				run_notify({ "mix", "test", vim.fn.expand("%") }, "mix test file")
			end,
			{ buffer = true, desc = "Test file (mix test)" }
		)
	end,
})
