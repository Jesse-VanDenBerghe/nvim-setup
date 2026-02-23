local util = require("jesse.util")

local M = {}

function M.open()
	util.task_picker({
		prompt = "Gradle tasks",
		fetch = function()
			local raw = vim.fn.systemlist("./gradlew tasks --all")
			if vim.v.shell_error ~= 0 then
				vim.notify(table.concat(raw, "\n"), vim.log.levels.ERROR, { title = "gradle picker" })
				return nil
			end
			return raw
		end,
		parse = function(line)
			local task, desc = line:match("^%s*(%S+)%s*%- (.+)$")
			if task then return { label = task, description = desc } end
		end,
		build_cmd = function(task, args)
			local cmd = { "./gradlew", task }
			for arg in args:gmatch("%S+") do
				table.insert(cmd, arg)
			end
			return cmd
		end,
		args_prefix = function(task) return "./gradlew " .. task .. " " end,
	})
end

return M
