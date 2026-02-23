local util = require("jesse.util")

local M = {}

function M.open()
	local raw = vim.fn.systemlist("./gradlew tasks --all")
	local exit_code = vim.v.shell_error

	if exit_code ~= 0 then
		vim.notify(
			"Failed to get gradle tasks: " .. table.concat(raw, "\n"),
			vim.log.levels.ERROR,
			{ title = "gradle picker" }
		)
		return
	end

	local items = {}

	for _, line in ipairs(raw) do
		local match = line:match("^%s*(%S+)%s*%- (.+)$")
		if match then
			local task, description = line:match("^%s*(%S+)%s*%- (.+)$")
			table.insert(items, { label = task, description = description })
		end
	end

	Snacks.picker.select(items, {
		prompt = "Gradle tasks",
		format_item = function(item)
			return item.label .. " - " .. item.description or ""
		end,
	}, function(selected)
		if selected then
			local task = selected.label
			vim.notify("Running gradle task: " .. task, vim.log.levels.INFO, { title = "gradle picker" })
			util.run_notify({ "./gradlew", task }, task)
		end
	end)
end

return M
