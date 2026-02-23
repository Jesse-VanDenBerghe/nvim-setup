-- Terminal management: native keymaps, autocmds, and ad-hoc terminal launcher.
-- Snacks-specific terminal keymaps (<C-/>, <leader>se) live in snacks.lua.

return {
	-- Virtual spec — no plugin to download, just configuration.
	dir = vim.fn.stdpath("config"),
	name = "terminal",
	lazy = false,
	config = function()
		-- Exit terminal insert mode with <Esc><Esc>
		vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

		-- On every terminal buffer open: install buffer-local keymaps
		local group = vim.api.nvim_create_augroup("terminal-management", { clear = true })
		vim.api.nvim_create_autocmd("TermOpen", {
			group = group,
			callback = function(ev)
				-- Force-close the terminal buffer (overrides the global <leader>q diagnostic list)
				vim.keymap.set("n", "<leader>q", "<cmd>bd!<CR>", {
					buffer = ev.buf,
					noremap = true,
					silent = true,
					desc = "Close terminal",
				})
				-- Send the terminal to the background without killing it
				vim.keymap.set("n", "<leader>rb", function()
					local alt = vim.fn.bufnr("#")
					if alt ~= -1 and alt ~= ev.buf then
						vim.api.nvim_set_current_buf(alt)
					else
						vim.cmd("enew")
					end
				end, { buffer = ev.buf, desc = "[R]un: send terminal to [B]ackground" })
			end,
		})

		-- Prompt for a shell command and open it in a new native terminal buffer
		vim.keymap.set("n", "<leader>rt", function()
			vim.ui.input({ prompt = "Terminal command: " }, function(input)
				if not input or input == "" then
					return
				end
				local buf = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_set_current_buf(buf)
				vim.fn.termopen(input)
				vim.cmd("startinsert")
			end)
		end, { desc = "Run [T]erminal command" })
	end,
}
