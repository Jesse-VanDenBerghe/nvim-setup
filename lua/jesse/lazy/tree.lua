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
			vim.keymap.set("n", k, a, { desc = "Explorer: " .. desc })
		end

		keymap("<leader>et", api.tree.toggle, "Toggle")
		keymap("<leader>ef", api.tree.focus, "Focus")
		keymap("<leader>eo", api.tree.open, "Open")
		keymap("<leader>ec", api.tree.close, "Close")
	end,
}
