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
				local preferred_tool = "opencode"
				local State = require("sidekick.cli.state")
				local orig_get = State.get
				State.get = function()
					State.get = orig_get
					local tools = vim.tbl_filter(function(t)
						return t.installed and not t.external
					end, orig_get())
					table.sort(tools, function(a, b)
						if a.tool.name ~= b.tool.name then
							if a.tool.name == preferred_tool then return true end
							if b.tool.name == preferred_tool then return false end
						end
						return a.tool.name < b.tool.name
					end)
					return tools
				end
				require("sidekick.cli").select()
			end,
			desc = "AI Toggle CLI",
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
