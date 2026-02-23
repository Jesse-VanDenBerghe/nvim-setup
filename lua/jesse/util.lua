local M = {}

---Run a shell command asynchronously and report output via vim.notify.
---@param cmd string[] Command and arguments.
---@param label string Short human-readable label shown in the notification title.
---@param opts? { timeout?: boolean } Optional settings. Set `timeout = false` to persist all notifications.
function M.run_notify(cmd, label, opts)
	opts = opts or {}
	local persist = opts.timeout == false
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
			local notify_opts = { title = title }
			if persist or level == vim.log.levels.ERROR then
				notify_opts.timeout = false
			end
			vim.notify(output ~= "" and output or "(no output)", level, notify_opts)
		end,
	})
end

---Run a shell command in a new native terminal buffer (full interactive, like <leader>rt).
---@param cmd string[] Command and arguments.
---@param label string Used as the buffer name shown in the status line.
function M.run_terminal(cmd, label)
	local shell_cmd = table.concat(
		vim.tbl_map(function(s)
			-- Quote any argument that contains whitespace
			return s:find("%s") and ('"' .. s .. '"') or s
		end, cmd),
		" "
	)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(buf, label)
	vim.api.nvim_set_current_buf(buf)
	vim.fn.termopen(shell_cmd)
	vim.cmd("startinsert")
end

---Generic task picker: fetch tasks, let the user pick one, prompt for extra args,
---then ask whether to run via notify or in a terminal.
---
---@class TaskPickerOpts
---@field prompt string                                           Picker prompt title.
---@field fetch fun(): string[]|nil                              Return raw lines, or nil on error (caller handles notify).
---@field parse fun(line: string): {label: string, description: string}|nil  Return a table or nil to skip the line.
---@field build_cmd fun(task: string, args: string): string[]   Build the final command table from the task and extra args string.
---@field args_prefix? fun(task: string): string                 Prompt prefix for the args input (default: task .. " ").

---@param opts TaskPickerOpts
function M.task_picker(opts)
	local raw = opts.fetch()
	if not raw then return end

	local items = {}
	for _, line in ipairs(raw) do
		local item = opts.parse(line)
		if item then
			table.insert(items, item)
		end
	end

	if #items == 0 then
		vim.notify("No tasks found", vim.log.levels.WARN, { title = opts.prompt })
		return
	end

	Snacks.picker.select(items, {
		prompt = opts.prompt,
		format_item = function(item)
			return item.label .. " - " .. (item.description or "")
		end,
	}, function(selected)
		if not selected then return end
		local task = selected.label

		local prefix = opts.args_prefix and opts.args_prefix(task) or (task .. " ")
		vim.ui.input({ prompt = prefix, default = "" }, function(extra)
			if extra == nil then return end

			local cmd = opts.build_cmd(task, extra)
			local label = prefix:gsub("%s+$", "") .. (extra ~= "" and (" " .. extra) or "")

			vim.ui.select({ "Notify", "Terminal" }, {
				prompt = "Run as:",
			}, function(mode)
				if not mode then return end
				if mode == "Terminal" then
					M.run_terminal(cmd, label)
				else
					M.run_notify(cmd, label, { timeout = false })
				end
			end)
		end)
	end)
end

return M
