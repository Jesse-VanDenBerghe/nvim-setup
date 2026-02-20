return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		input = { enabled = true },
		debug = { enabled = true },
		explorer = { enabled = true },
		picker = { enabled = true },
		lazygit = { enabled = true },
		git = { enabled = true },
		gh = { enabled = true },
		gitbrowse = { enabled = true },
		image = { enabled = true },
		indent = { enabled = true },
		notify = { enabled = true },
		notifier = { enabled = true },
		quickfile = { enabled = true },
		rename = { enabled = true },
		scope = { enabled = true },
		scratch = { enabled = true },
		scroll = { enabled = true },
		statuscolumn = { enabled = true },
		styles = { enabled = true },
		terminal = { enabled = true },
		toggle = { enabled = true },
		util = { enabled = true },
		win = { enabled = true },
		words = { enabled = true },
		zen = { enabled = true },
		dashboard = require("jesse.lazy.snacks.dashboard"),
	},
	keys = {
		-- Top Pickers
		{ "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
		{ "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
		{ "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
		{ "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
		{ "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
		{ "<leader>e", function() Snacks.explorer() end, desc = "Explorer" },
		-- Find
		{ "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
		{ "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
		{ "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
		{ "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
		{ "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
		{ "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
		-- Git
		{ "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
		{ "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
		{ "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
		{ "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
		{ "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
		{ "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
		{ "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
		{ "<leader>gP", function() Snacks.picker.gh_pr() end, desc = "GitHub Pull Requests (open)" },
		{ "<leader>gPa", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "GitHub Pull Requests (all)" },
		{
			"<leader>ga",
			function()
				local result = vim.fn.system({ "git", "add", "-A" })
				if vim.v.shell_error ~= 0 then
					vim.notify("git add -A failed: " .. result, vim.log.levels.ERROR)
				else
					vim.notify("git add -A", vim.log.levels.INFO)
				end
			end,
			desc = "Git Add All",
		},
		{
			"<leader>gp",
			function()
				local result = vim.fn.system({ "git", "push" })
				if vim.v.shell_error ~= 0 then
					vim.notify("git push failed: " .. result, vim.log.levels.ERROR)
				else
					vim.notify("git push", vim.log.levels.INFO)
				end
			end,
			desc = "Git Push",
		},
		{
			"<leader>gcm",
			function()
				local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
				local ticket = branch:match("([A-Z]+-%d+)")
				vim.ui.input({ prompt = "Commit message: " }, function(input)
					if input then
						local message = ticket and (ticket .. ": " .. input) or input
						local result = vim.fn.system({ "git", "commit", "-m", message })
						if vim.v.shell_error ~= 0 then
							vim.notify("git commit failed: " .. result, vim.log.levels.ERROR)
						else
							vim.notify("Committed: " .. message, vim.log.levels.INFO)
						end
					end
				end)
			end,
			desc = "Git Commit with Message",
		},
		{
			"<leader>gcp",
			function()
				local add_result = vim.fn.system({ "git", "add", "-A" })
				if vim.v.shell_error ~= 0 then
					vim.notify("git add -A failed: " .. add_result, vim.log.levels.ERROR)
					return
				end
				local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
				local ticket = branch:match("([A-Z]+-%d+)")
				vim.ui.input({ prompt = "Commit message: " }, function(input)
					if input then
						local message = ticket and (ticket .. ": " .. input) or input
						local commit_result = vim.fn.system({ "git", "commit", "-m", message })
						if vim.v.shell_error ~= 0 then
							vim.notify("git commit failed: " .. commit_result, vim.log.levels.ERROR)
							return
						end
						local push_result = vim.fn.system({ "git", "push" })
						if vim.v.shell_error ~= 0 then
							vim.notify("git push failed: " .. push_result, vim.log.levels.ERROR)
						else
							vim.notify("Committed and pushed: " .. message, vim.log.levels.INFO)
						end
					end
				end)
			end,
			desc = "Git Commit and Push",
		},
		{
			"<leader>gbnd",
			function()
				vim.ui.input({ prompt = "New branch name: " }, function(input)
					if input then
						local ref = vim.fn.systemlist({ "git", "symbolic-ref", "refs/remotes/origin/HEAD" })[1]
						local default_branch = ref and ref:match("^refs/remotes/origin/(.+)$") or "main"
						vim.fn.system({ "git", "checkout", default_branch })
						vim.fn.system({ "git", "pull" })
						local result = vim.fn.system({ "git", "checkout", "-b", input })
						if vim.v.shell_error ~= 0 then
							vim.notify("git checkout -b failed: " .. result, vim.log.levels.ERROR)
						else
							vim.notify("Created branch: " .. input, vim.log.levels.INFO)
						end
					end
				end)
			end,
			desc = "New Branch on Default",
		},
		-- Grep
		{ "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
		{ "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
		{ "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
		{ "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
		-- Search
		{ '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
		{ '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
		{ "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
		{ "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
		{ "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
		{ "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
		{ "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
		{ "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
		{ "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
		{ "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
		{ "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
		{ "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
		{ "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
		{ "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
		{ "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
		{ "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
		{ "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
		{ "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
		{ "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
		{ "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },
		{ "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
		-- LSP
		{ "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
		{ "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
		{ "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
		{ "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
		{ "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
		{ "gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming" },
		{ "gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing" },
		{ "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
		{ "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
		-- Other
		{ "<leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
		{ "<leader>Z",  function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
		{ "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
		{ "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
		{ "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
		{ "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
		{ "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
		{ "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
		{ "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
		{ "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
		{ "<c-/>",      function() Snacks.terminal() end, desc = "Toggle Terminal" },
		{ "<c-_>",      function() Snacks.terminal() end, desc = "which_key_ignore" },
		{ "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
		{ "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference"},
	},
}
