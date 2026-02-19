return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		input = { enabled = true },
		dashboard = require("jesse.lazy.snacks.dashboard"),
	},
}
