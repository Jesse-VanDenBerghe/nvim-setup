return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"NickvanDyke/opencode.nvim",
	},
	config = function()
		require("lualine").setup({
			sections = {
				lualine_z = {
					require("opencode").statusline,
				},
			},
		})
	end,
}
