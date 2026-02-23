local util = require("jesse.util")

local M = {}

function M.open()
	local raw = vim.fn.systemlist("mix help")
	local exit_code = vim.v.shell_error

	if exit_code ~= 0 then
		vim.notify(
			"Failed to get mix tasks: " .. table.concat(raw, "\n"),
			vim.log.levels.ERROR,
			{ title = "mix picker" }
		)
		return
	end

	local items = {}
	for _, line in ipairs(raw) do
		local task, description = line:match("^mix%s+(%S+)%s+# (.+)$")
		if task then
			table.insert(items, { label = task, description = description })
		end
	end

	Snacks.picker.select(items, {
		prompt = "Mix tasks",
		format_item = function(item)
			return item.label .. " - " .. item.description
		end,
	}, function(selected)
		if not selected then return end
		local task = selected.label
		vim.ui.input({ prompt = "mix " .. task .. " ", default = "" }, function(extra)
			if extra == nil then return end
			local cmd = { "mix", task }
			for arg in extra:gmatch("%S+") do
				table.insert(cmd, arg)
			end
			local label = "mix " .. task .. (extra ~= "" and (" " .. extra) or "")
			util.run_notify(cmd, label, { timeout = false })
		end)
	end)
end

return M
