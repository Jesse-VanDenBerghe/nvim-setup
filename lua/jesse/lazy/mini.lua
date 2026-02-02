return {
	{
		"echasnovski/mini.nvim",
		config = function()
			require("mini.ai").setup({ n_lines = 500 })

		require("mini.surround").setup()

		require("mini.move").setup({
				mappings = {
					left = "H",
					right = "L",
					down = "J",
					up = "K",
				},
			})

            require("mini.pairs").setup()

			require("mini.cmdline").setup()
		end,
	},
}
