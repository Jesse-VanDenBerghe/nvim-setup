return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		-- Recommended for `ask()` and `select()`.
		-- Required for `snacks` provider.
		---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
		{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
	},
	config = function()
		---@type opencode.Opts
		vim.g.opencode_opts = {
			-- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on the type or field.
		}

		-- Required for `opts.events.reload`.
		vim.o.autoread = true

		vim.keymap.set({ "n", "x" }, "<leader>aa", function()
			require("opencode").ask("@this: ", { submit = true })
		end, { desc = "Ask opencode…" })
		vim.keymap.set({ "n", "x" }, "<leader>ax", function()
			require("opencode").select()
		end, { desc = "Execute opencode action…" })
		vim.keymap.set({ "n", "t" }, "<leader>a.", function()
			require("opencode").toggle()
		end, { desc = "Toggle opencode" })
		vim.keymap.set({ "n", "x" }, "<leader>ao", function()
			return require("opencode").operator("@this ")
		end, { desc = "Add range to opencode", expr = true })
		vim.keymap.set("n", "<leader>an", function()
			require("opencode").command("session.new")
		end, { desc = "New opencode session" })
		vim.keymap.set("n", "<leader>al", function()
			require("opencode").command("session.list")
		end, { desc = "List opencode sessions" })
		vim.keymap.set("n", "<leader>ac", function()
			require("opencode").command("agent.cycle")
		end, { desc = "Cycle opencode agent" })
	end,
}
