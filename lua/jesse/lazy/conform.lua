return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>uf",
				function()
					vim.notify("Formatting...", vim.log.levels.TRACE)
					require("conform").format({ async = true, lsp_format = "fallback" }, function(err)
						if not err then
							vim.notify("Formatted", vim.log.levels.INFO)
						end
					end)
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = true,
			formatters_by_ft = {
				lua = { "stylua" },
				elixir = { "mix" },
				eelixir = { "mix" },
				heex = { "mix" },
			},
		},
	},
}
