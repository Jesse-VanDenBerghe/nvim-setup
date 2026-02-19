local elixirgroup = vim.api.nvim_create_augroup("ElixirTools", { clear = true })

-- Detach copilot from elixir buffers; pattern avoids filetype timing issues
vim.api.nvim_create_autocmd("LspAttach", {
	group = elixirgroup,
	pattern = { "*.ex", "*.exs", "*.heex" },
	callback = function(event)
		local copilot_client = vim.lsp.get_client_by_id(event.data.client_id)
		if copilot_client and copilot_client.name == "copilot" then
			vim.lsp.buf_detach_client(event.buf, event.data.client_id)
		end
	end,
})

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
				vim.cmd("!mix compile")
			end,
			{ buffer = true, desc = "Build project (mix compile)" }
		)

		-- Run keymaps
		vim.keymap.set(
			"n",
			"<leader>rf",
			function()
				vim.cmd("!mix run " .. vim.fn.expand("%"))
			end,
			{ buffer = true, desc = "Run file (mix run)" }
		)

		if filename:match("%.exs$") then
			vim.keymap.set(
				"n",
				"<leader>rs",
				function()
					vim.cmd("!elixir " .. vim.fn.expand("%"))
				end,
				{ buffer = true, desc = "Run script (elixir)" }
			)
		end

		-- Test keymaps
		vim.keymap.set(
			"n",
			"<leader>tp",
			function()
				vim.cmd("!mix test")
			end,
			{ buffer = true, desc = "Test project (mix test)" }
		)

		vim.keymap.set(
			"n",
			"<leader>tf",
			function()
				vim.cmd("!mix test " .. vim.fn.expand("%"))
			end,
			{ buffer = true, desc = "Test file (mix test)" }
		)
	end,
})
