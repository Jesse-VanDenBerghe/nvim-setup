return {
	-- onedark
	{
		"navarasu/onedark.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("onedark").setup({
				style = "warmer",
				transparent = true,
				highlights = {
					Comment = { fg = "#7a8194" },
				},
			})
			require("onedark").load()
		end,
	},
}
