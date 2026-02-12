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

			require("mini.animate").setup({
				cursor = { timing = require("mini.animate").gen_timing.linear({ duration = 50, unit = "total" }) },
				scroll = { timing = require("mini.animate").gen_timing.linear({ duration = 50, unit = "total" }) },
			})
		end,
	},
}
