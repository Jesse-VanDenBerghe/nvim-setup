local util = require("jesse.util")

local M = {}

function M.open()
	util.task_picker({
		prompt = "Mix tasks",
		fetch = function()
			local raw = vim.fn.systemlist("mix help")
			if vim.v.shell_error ~= 0 then
				vim.notify(table.concat(raw, "\n"), vim.log.levels.ERROR, { title = "mix picker" })
				return nil
			end
			return raw
		end,
		parse = function(line)
			local task, desc = line:match("^mix%s+(%S+)%s+# (.+)$")
			if task then return { label = task, description = desc } end
		end,
		build_cmd = function(task, args)
			local cmd = { "mix", task }
			for arg in args:gmatch("%S+") do
				table.insert(cmd, arg)
			end
			return cmd
		end,
		args_prefix = function(task) return "mix " .. task .. " " end,
	})
end

return M
