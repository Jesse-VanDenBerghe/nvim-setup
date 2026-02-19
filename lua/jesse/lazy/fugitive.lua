return {
	{
		"tpope/vim-fugitive",
		config = function()
			local function gc_commit()
				local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
				local ticket = branch:match("([A-Z]+-%d+)")

				vim.ui.input({ prompt = "Commit message: " }, function(input)
					if input then
						local message = ticket and (ticket .. ": " .. input) or input
						vim.cmd("Git commit -m '" .. message:gsub("'", "'\\''") .. "'")
					end
				end)
			end

			local function gcp_commit_and_push()
				local result = vim.fn.system({ "git", "add", "-A" })
				if vim.v.shell_error ~= 0 then
					vim.notify("git add -A failed: " .. result, vim.log.levels.ERROR)
					return
				end
				local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
				local ticket = branch:match("([A-Z]+-%d+)")

				vim.ui.input({ prompt = "Commit message: " }, function(input)
					if input then
						local message = ticket and (ticket .. ": " .. input) or input
						vim.cmd("Git commit -m '" .. message:gsub("'", "'\\''") .. "'")
						vim.cmd("Git push")
					end
				end)
			end

			local function gbnd_new_branch_on_default()
				vim.ui.input({ prompt = "New branch name" }, function(input)
					if input then
						local ref = vim.fn.systemlist({ "git", "symbolic-ref", "refs/remotes/origin/HEAD" })[1]
						local default_branch = ref and ref:match("^refs/remotes/origin/(.+)$") or "main"
						vim.cmd("Git checkout " .. default_branch)
						vim.cmd("Git pull")
						vim.cmd("Git checkout -b " .. input)
					end
				end)
			end

			vim.keymap.set("n", "<leader>gg", vim.cmd.Git, { desc = "Git" })
			vim.keymap.set("n", "<leader>ga", ":Git add -A<CR>", { desc = "Git [A]dd" })
			vim.keymap.set("n", "<leader>gp", ":Git push<CR>", { desc = "Git [P]ush" })

			vim.keymap.set("n", "<leader>gcm", gc_commit, { desc = "Git Commit with [M]essage" })
			vim.keymap.set("n", "<leader>gcp", gcp_commit_and_push, { desc = "Git Commit and [P]ush" })

			vim.keymap.set("n", "<leader>gbnd", gbnd_new_branch_on_default, { desc = "New Branch on Default" })

			-- Git Finders
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>gf", builtin.git_files, { desc = "Git [F]iles" })
			vim.keymap.set("n", "<leader>gcl", builtin.git_commits, { desc = "Git Commit [L]ist" })
			vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Git Status" })
			vim.keymap.set("n", "<leader>gbl", builtin.git_branches, { desc = "Git Branches [L]ist" })
		end,
	},
}
