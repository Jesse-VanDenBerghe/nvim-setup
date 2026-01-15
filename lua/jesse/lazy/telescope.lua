return {
	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ -- If encountering errors, see telescope-fzf-native README for installation instructions
				"nvim-telescope/telescope-fzf-native.nvim",

				-- `build` is used to run some command when the plugin is installed/updated.
				-- This is only run then, not every time Neovim starts up.
				build = "make",

				-- `cond` is a condition used to determine whether this plugin should be
				-- installed and loaded.
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },

			-- Useful for getting pretty icons, but requires a Nerd Font.
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			require("telescope").setup({
				-- You can put your default mappings / updates / etc. in here
				--  All the info you're looking for is in `:help telescope.setup()`
				--
				-- defaults = {
				--   mappings = {
				--     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
				--   },
				-- },
				-- pickers = {}
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
				defaults = {
					file_ignore_patterns = {
						"node_modules",
						".git/",
						"%.lock",
						"pack/",
						"lsp/",
					},
				},
			})

			-- Enable Telescope extensions if they are installed
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")
			pcall(require("telescope").load_extension("harpoon"))

			local builtin = require("telescope.builtin")

			-- Finders
			vim.keymap.set("n", "<leader>ff", function()
				builtin.find_files({ hidden = true, no_ignore = true })
			end, { desc = "Find Files" })
			vim.keymap.set("n", "<leader>fs", function()
				builtin.grep_string({ search = vim.fn.input("Search for: "), hidden = true, no_ignore = true })
			end, { desc = "Find with Search String" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find Help Tags" })
			vim.keymap.set("n", "<leader>ft", builtin.treesitter, { desc = "Find Treesitter Symbols" })
			vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Find old Files" })
			vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "Find commands" })
			vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Find keymaps" })
			vim.keymap.set("n", "<leader>fr", builtin.registers, { desc = "Find Registers" })
			vim.keymap.set("n", "<leader>fm", builtin.marks, { desc = "Find Marks" })
			vim.keymap.set("n", "<leader>fd", builtin.man_pages, { desc = "Find Man pages" })
		end,
	},
}
