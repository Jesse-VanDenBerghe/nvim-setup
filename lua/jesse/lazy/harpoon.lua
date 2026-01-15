return {
	{
		"ThePrimeagen/harpoon",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("harpoon").setup({
				tabline = {
					enable = true,
				},
			})

			require("telescope").load_extension("harpoon")

			local mark = require("harpoon.mark")
			local ui = require("harpoon.ui")

			vim.keymap.set("n", "<leader>ha", mark.add_file, { desc = "[H]arpoon [A]dd file" })
			vim.keymap.set("n", "<leader>he", ui.toggle_quick_menu, { desc = "[H]arpoon [E]dit menu" })

			vim.keymap.set("n", "<leader>h1", function()
				ui.nav_file(1)
			end, { desc = "Harpoon 1" })
			vim.keymap.set("n", "<leader>h2", function()
				ui.nav_file(2)
			end, { desc = "Harpoon 2" })
			vim.keymap.set("n", "<leader>h3", function()
				ui.nav_file(3)
			end, { desc = "Harpoon 3" })
			vim.keymap.set("n", "<leader>h4", function()
				ui.nav_file(4)
			end, { desc = "Harpoon 4" })
			vim.keymap.set("n", "<leader>h5", function()
				ui.nav_file(5)
			end, { desc = "Harpoon 5" })
			vim.keymap.set("n", "<leader>h6", function()
				ui.nav_file(6)
			end, { desc = "Harpoon 6" })
			vim.keymap.set("n", "<leader>h7", function()
				ui.nav_file(7)
			end, { desc = "Harpoon 7" })
			vim.keymap.set("n", "<leader>h8", function()
				ui.nav_file(8)
			end, { desc = "Harpoon 8" })
			vim.keymap.set("n", "<leader>h9", function()
				ui.nav_file(9)
			end, { desc = "Harpoon 9" })
			vim.keymap.set("n", "<leader>h0", function()
				ui.nav_file(10)
			end, { desc = "Harpoon 10" })
		end,
	},
}
