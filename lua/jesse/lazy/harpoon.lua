return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local harpoon = require("harpoon")

			-- REQUIRED for harpoon2
			harpoon:setup()

			vim.keymap.set("n", "<leader>ha", function()
				harpoon:list():add()
			end, { desc = "[H]arpoon [A]dd file" })

			vim.keymap.set("n", "<leader>he", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "[H]arpoon [E]dit menu" })

			for i = 1, 9 do
				vim.keymap.set("n", "<leader>h" .. i, function()
					harpoon:list():select(i)
				end, { desc = "Harpoon " .. i })
			end
			vim.keymap.set("n", "<leader>h0", function()
				harpoon:list():select(10)
			end, { desc = "Harpoon 10" })
		end,
	},
}
