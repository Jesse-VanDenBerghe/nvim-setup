local ns_id = vim.api.nvim_create_namespace("opencode_status")

-- Use a unique name to avoid colliding with the global `print` when possible,
-- but keep the local name `print` since callers in this file expect it.
local function print(msg)
	local row = vim.api.nvim_win_get_cursor(0)[1] - 1
	vim.api.nvim_buf_set_extmark(0, ns_id, row, 0, {
		virt_lines = { { { "\t󱃳\t" .. msg, "@string.special" } } },
		virt_lines_above = true,
	})
end

local function clear_status()
	vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
end

return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
	},
	keys = {
		{
			"<leader>aa",
			function()
				local opencode = require("opencode")
				print("Asking opencode ...")
				opencode.ask("@this: ", { submit = true })
			end,
			mode = { "n", "x", "v" },
			desc = "Ask opencode…",
		},
		{
			"<leader>ax",
			function()
				require("opencode").select()
			end,
			mode = { "n", "x" },
			desc = "Execute opencode action…",
		},
		{
			"<leader>a.",
			function()
				require("opencode").toggle()
			end,
			mode = { "n", "t" },
			desc = "Toggle opencode",
		},
		{
			"<leader>ao",
			function()
				return require("opencode").operator("@this ")
			end,
			mode = { "n", "x" },
			desc = "Add range to opencode",
			expr = true,
		},
		{
			"<leader>an",
			function()
				require("opencode").command("session.new")
			end,
			mode = "n",
			desc = "New opencode session",
		},
		{
			"<leader>al",
			function()
				require("opencode").command("session.list")
			end,
			mode = "n",
			desc = "List opencode sessions",
		},
		{
			"<leader>ac",
			function()
				clear_status()
			end,
			mode = "n",
			desc = "Clear opencode status",
		},
	},
	config = function()
		---@type opencode.Opts
		vim.g.opencode_opts = {
			-- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on the type or field.
			provider = {
				enabled = "snacks", -- Use snacks to manage opencode sessions
				snacks = {
					-- Let snacks handle spawning opencode in a terminal
					win = {
						style = "terminal",
					},
				},
			},
		}

		-- Required for `opts.events.reload`.
		vim.o.autoread = true

		-- Create namespace for virtual lines

		vim.api.nvim_create_autocmd("User", {
			pattern = "OpencodeEvent:*", -- Optionally filter event types
			callback = function(args)
				---@type opencode.cli.client.Event
				local event = args.data and args.data.event

				-- If we have a session.status event and it's idle, clear and return early.
				if event and event.type == "session.status" then
					local status = event.properties and event.properties.status
					if type(status) == "table" and status.type == "idle" then
						vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
						return
					end
				else
					return
				end

				-- Clear previous status virtual lines before updating
				vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)

				local hl_group = "@string.special"

				if start_line >= 0 then
					vim.api.nvim_buf_set_extmark(bufnr, ns_id, start_line, 0, {
						virt_lines = { { { "\t󱃳\t" .. status_msg, hl_group } } },
						virt_lines_above = true,
					})
				end
			end,
		})

		-- Start opencode after startup to avoid blocking Neovim's startup time.
		-- We defer the call to VimEnter with a small timeout so the editor
		-- finishes initialization before `opencode.start()` runs.
		-- vim.api.nvim_create_autocmd("VimEnter", {
		-- 	callback = function()
		-- 		vim.defer_fn(function()
		-- 			require("opencode").start()
		-- 			require("opencode").toggle()
		-- 		end, 50) -- 50ms delay; adjust if needed
		-- 	end,
		-- })
	end,
}
