return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = true,
			format_on_save = function(_)
				return {
					timeout_ms = 2000,
					lsp_format = "fallback",
				}
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				elixir = { "mix" },
				eelixir = { "mix" },
				heex = { "mix" },
			},
			formatters = {
				stylua = { prepend_args = { "--column-width", "120" } },
			},
		},
	},
}
