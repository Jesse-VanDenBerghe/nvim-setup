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
		{ "<leader>gg", function() Snacks.lazygit() end, desc = "Git" },
		{ "<leader>gl", function() Snacks.lazygit.log() end, desc = "Git Log" },
		{ "<leader>glf", function() Snacks.lazygit.log_file() end, desc = "Git Log (file)" },
		{ "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
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
		-- Git Finders
		{ "<leader>gf", function() Snacks.picker.git_files() end, desc = "Git Files" },
		{ "<leader>gcl", function() Snacks.picker.git_log() end, desc = "Git Commit List" },
		{ "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
		{ "<leader>gbl", function() Snacks.picker.git_branches() end, desc = "Git Branches List" },
	},
}
