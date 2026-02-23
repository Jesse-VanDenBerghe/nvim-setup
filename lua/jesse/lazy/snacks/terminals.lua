-- Terminal session picker for snacks.nvim.
-- Lists every terminal buffer in the current Neovim session; selecting one
-- switches the current window to that buffer.

local M = {}

function M.open()
	local items = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "terminal" then
			-- Buffer name has the form "term://~/path//PID:cmd" — extract just the command.
			local name = vim.api.nvim_buf_get_name(buf)
			local cmd = name:match("term://.-//[^:]+:(.+)$") or name
			table.insert(items, {
				text = cmd .. "  [buf " .. buf .. "]",
				buf = buf,
			})
		end
	end
	Snacks.picker.pick({
		title = "Terminal Sessions",
		items = items,
		format = "text",
		preview = "none",
		layout = { preset = "vscode" },
		confirm = function(picker, item)
			picker:close()
			if item then
				vim.api.nvim_set_current_buf(item.buf)
			end
		end,
	})
end

return M
