local M = {}

---Run a shell command asynchronously and report output via vim.notify.
---@param cmd string[] Command and arguments.
---@param label string Short human-readable label shown in the notification title.
function M.run_notify(cmd, label)
	local lines = {}
	vim.notify("Running: " .. table.concat(cmd, " "), vim.log.levels.TRACE, { title = label })
	vim.fn.jobstart(cmd, {
		detach = false,
		stdout_buffered = false,
		stderr_buffered = false,
		on_stdout = function(_, data)
			for _, line in ipairs(data) do
				if line ~= "" then
					table.insert(lines, line)
				end
			end
		end,
		on_stderr = function(_, data)
			for _, line in ipairs(data) do
				if line ~= "" then
					table.insert(lines, line)
				end
			end
		end,
		on_exit = function(_, code)
			local output = table.concat(lines, "\n")
			local level = code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
			local title = code == 0 and (label .. " succeeded") or (label .. " failed (exit " .. code .. ")")
			local opts = { title = title }
			if level == vim.log.levels.ERROR then
				opts.timeout = false
			end
			vim.notify(output ~= "" and output or "(no output)", level, opts)
		end,
	})
end

return M
