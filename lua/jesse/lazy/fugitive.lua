return {
	{
		"tpope/vim-fugitive",
		config = function()
			vim.keymap.set("n", "<leader>gg", vim.cmd.Git, { desc = "Git" })
			vim.keymap.set("n", "<leader>ga", ":!git add -A<CR>", { desc = "Git [A]dd" })
			vim.keymap.set("n", "<leader>gp", ":Git push<CR>", { desc = "Git [P]ush" })

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
				vim.fn.system("git add -A")
				gc_commit()
				vim.cmd("Git push")
			end

			vim.keymap.set("n", "<leader>gcm", gc_commit, { desc = "Git Commit with [M]essage" })
			vim.keymap.set("n", "<leader>gcp", gcp_commit_and_push, { desc = "Git Commit and [P]ush" })

			-- Git Finders
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>gf", builtin.git_files, { desc = "Git [F]iles" })
			vim.keymap.set("n", "<leader>gcl", builtin.git_commits, { desc = "Git Commit [L]ist" })
			vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Git Status" })
			vim.keymap.set("n", "<leader>gbl", builtin.git_branches, { desc = "Git Branches [L]ist" })
		end,
	},
}
