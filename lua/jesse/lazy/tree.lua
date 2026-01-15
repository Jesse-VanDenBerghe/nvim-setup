return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup({
			update_focused_file = {
				enable = true,
				update_root = true,
			},
		})

		local api = require("nvim-tree.api")

		local keymap = function(k, a, desc)
			vim.keymap.set("n", k, a, { desc = "[T]ree: " .. desc })
		end

		keymap("<leader>tt", api.tree.toggle, "Toggle")
		keymap("<leader>tf", api.tree.focus, "Focus")
		keymap("<leader>to", api.tree.open, "Open")
		keymap("<leader>tc", api.tree.close, "Close")
	end,
}
