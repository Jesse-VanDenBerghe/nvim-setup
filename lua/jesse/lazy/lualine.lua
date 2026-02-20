return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		-- sidekick provides the status API used in sections below
		{ "folke/sidekick.nvim", optional = true },
	},
	config = function()
		local lualine = require("lualine")

		-- Copilot LSP status component (colour reflects busy / error / ok)
		local copilot_status = {
			function()
				return " "
			end,
			color = function()
				local ok, status = pcall(require, "sidekick.status")
				if not ok then
					return
				end
				local s = status.get()
				if s then
					return s.kind == "Error" and "DiagnosticError" or s.busy and "DiagnosticWarn" or "Special"
				end
			end,
			cond = function()
				local ok, status = pcall(require, "sidekick.status")
				return ok and status.get() ~= nil
			end,
		}

		-- Active AI CLI session indicator
		local cli_status = {
			function()
				local ok, status = pcall(require, "sidekick.status")
				if not ok then
					return ""
				end
				local sessions = status.cli()
				return " " .. (#sessions > 1 and tostring(#sessions) or "")
			end,
			cond = function()
				local ok, status = pcall(require, "sidekick.status")
				return ok and #status.cli() > 0
			end,
			color = "Special",
		}

		lualine.setup({
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { "filename", copilot_status },
				lualine_x = { cli_status, "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		})
	end,
}
