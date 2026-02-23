return {
	{ -- Useful plugin to show you pending keybinds.
		"folke/which-key.nvim",
		event = "VimEnter", -- Sets the loading event to 'VimEnter'
		opts = {
			-- delay between pressing a key and opening which-key (milliseconds)
			-- this setting is independent of vim.o.timeoutlen
			delay = 0,
			icons = {
				-- set icon mappings to true if you have a Nerd Font
				mappings = vim.g.have_nerd_font,
				-- If you are using a Nerd Font: set icons.keys to an empty table which will use the
				-- default which-key.nvim defined Nerd Font icons, otherwise define a string table
				keys = vim.g.have_nerd_font and {} or {
					Up = "<Up> ",
					Down = "<Down> ",
					Left = "<Left> ",
					Right = "<Right> ",
					C = "<C-…> ",
					M = "<M-…> ",
					D = "<D-…> ",
					S = "<S-…> ",
					CR = "<CR> ",
					Esc = "<Esc> ",
					ScrollWheelDown = "<ScrollWheelDown> ",
					ScrollWheelUp = "<ScrollWheelUp> ",
					NL = "<NL> ",
					BS = "<BS> ",
					Space = "<Space> ",
					Tab = "<Tab> ",
					F1 = "<F1>",
					F2 = "<F2>",
					F3 = "<F3>",
					F4 = "<F4>",
					F5 = "<F5>",
					F6 = "<F6>",
					F7 = "<F7>",
					F8 = "<F8>",
					F9 = "<F9>",
					F10 = "<F10>",
					F11 = "<F11>",
					F12 = "<F12>",
				},
			},

		spec = {
			{ "<leader>f", group = "Find" },
			{ "<leader>h", group = "Harpoon" },
			{ "<leader>e", group = "Explorer" },
			{ "<leader>t", group = "Test" },
			{ "<leader>r", group = "Run" },
			{ "<leader>b", group = "Build / Buffer" },
			{ "<leader>s", group = "Search / Grep" },

			{ "<leader>p", group = "Project" },
			{ "<leader>pr", group = "Run" },
			{ "<leader>ps", group = "Search" },
			{ "<leader>pb", group = "Build" },
			{ "<leader>pt", group = "Test" },

			{ "<leader>l", group = "LSP" },
			{ "<leader>lr", group = "Refactor" },
			{ "<leader>lg", group = "Goto" },
			{ "<leader>lt", group = "Toggle" },

			{ "<leader>g", group = "Git" },
			{ "<leader>gc", group = "Commit" },
			{ "<leader>gb", group = "Branch" },
			{ "<leader>gP", group = "Pull Requests" },

			{ "<leader>a", group = "AI / Copilot" },

			{ "<leader>c", group = "Code" },
			{ "<leader>u", group = "UI Toggles" },
			{ "<leader>x", group = "Diagnostics / Trouble" },
		},
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Local keymaps",
			},
		},
	},
}
