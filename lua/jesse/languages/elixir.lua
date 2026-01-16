local elixirgroup = vim.api.nvim_create_augroup("ElixirTools", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	pattern = "elixir",
	group = elixirgroup,
	callback = function()
		local filename = vim.fn.expand("%:t")
		local filepath = vim.fn.expand("%")

		-- Build keymaps
		vim.api.nvim_buf_set_keymap(0, "n", "<leader>bp", ":!mix compile <CR>", { noremap = true, silent = true })

		-- Run keymaps
		vim.api.nvim_buf_set_keymap(
			0,
			"n",
			"<leader>rf",
			":!mix run " .. filepath .. "<CR>",
			{ noremap = true, silent = true }
		)

		if filename:match("%.exs$") then
			vim.api.nvim_buf_set_keymap(
				0,
				"n",
				"<leader>rs",
				":!elixir  " .. filepath .. "<CR>",
				{ noremap = true, silent = true }
			)
		end

		-- Test keymaps
		vim.api.nvim_buf_set_keymap(0, "n", "<leader>tp", ":!mix test <CR>", { noremap = true, silent = true })

		vim.api.nvim_buf_set_keymap(
			0,
			"n",
			"<leader>tf",
			":!mix test " .. filepath .. "<CR>",
			{ noremap = true, silent = true }
		)
	end,
})
