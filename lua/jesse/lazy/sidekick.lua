return {
	"folke/sidekick.nvim",
	opts = {
		nes = { enabled = true },
		cli = {
			mux = { enabled = false },
		},
	},
	keys = {
		-- NES: jump to / apply next edit suggestion (normal mode)
		{
			"<tab>",
			function()
				if not require("sidekick").nes_jump_or_apply() then
					return "<Tab>"
				end
			end,
			expr = true,
			desc = "Goto/Apply Next Edit Suggestion",
		},
		-- AI CLI toggle (global)
		{
			"<c-.>",
			function()
				require("sidekick.cli").toggle()
			end,
			mode = { "n", "t", "i", "x" },
			desc = "Sidekick Toggle",
		},
		-- <leader>a group
		{
			"<leader>aa",
			function()
				require("sidekick.cli").toggle()
			end,
			desc = "AI Toggle CLI",
		},
		{
			"<leader>ac",
			function()
				require("sidekick.cli").toggle({ name = "opencode", focus = true })
			end,
			desc = "AI Toggle OpenCode",
		},
		{
			"<leader>as",
			function()
				vim.ui.input({ prompt = "Prompt AI:" }, function(input)
					if input then
						require("sidekick.cli").send({ msg = input })
					end
				end)
			end,
			desc = "AI Send prompt to CLI",
		},
		{
			"<leader>ad",
			function()
				require("sidekick.cli").close()
			end,
			desc = "AI Detach Session",
		},
		{
			"<leader>at",
			function()
				require("sidekick.cli").send({ msg = "{this}" })
			end,
			mode = { "n", "x" },
			desc = "AI Send This",
		},
		{
			"<leader>af",
			function()
				require("sidekick.cli").send({ msg = "{file}" })
			end,
			desc = "AI Send File",
		},
		{
			"<leader>av",
			function()
				require("sidekick.cli").send({ msg = "{selection}" })
			end,
			mode = { "x" },
			desc = "AI Send Selection",
		},
		{
			"<leader>ap",
			function()
				require("sidekick.cli").prompt()
			end,
			mode = { "n", "x" },
			desc = "AI Select Prompt",
		},
	},
}
