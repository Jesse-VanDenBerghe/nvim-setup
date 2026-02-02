return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		-- Recommended for `ask()` and `select()`.
		-- Required for `snacks` provider.
		---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
		{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
	},
	keys = {
		{
			"<leader>aa",
			function()
				local opencode = require("opencode")
				-- Ensure a session exists before asking
				local session = opencode.state and opencode.state.session or nil
				if not session or not session.id then
					-- Start a new session first
					opencode.command("session.new")
					-- Give it a moment to initialize
					vim.defer_fn(function()
						opencode.ask("@this: ", { submit = true })
					end, 1000)
				else
					opencode.ask("@this: ", { submit = true })
				end
			end,
			mode = { "n", "x" },
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
				require("opencode").command("agent.cycle")
			end,
			mode = "n",
			desc = "Cycle opencode agent",
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

		-- Auto-create session on VimEnter if desired
		-- Uncomment this if you want a session ready immediately on startup:
		-- vim.api.nvim_create_autocmd("VimEnter", {
		-- 	callback = function()
		-- 		vim.defer_fn(function()
		-- 			require("opencode").command("session.new")
		-- 		end, 100)
		-- 	end,
		-- })

		-- Create namespace for virtual lines
		local ns_id = vim.api.nvim_create_namespace("opencode_status")

		vim.api.nvim_create_autocmd("User", {
			pattern = "OpencodeEvent:*", -- Optionally filter event types
			callback = function(args)
				---@type opencode.cli.client.Event
				local event = args.data.event
				---@type number
				local port = args.data.port

				-- Get the current buffer and window
				local bufnr = vim.api.nvim_get_current_buf()

				-- Get visual selection range if in visual mode, otherwise use cursor position
				local mode = vim.fn.mode()
				local start_line
				if mode:match("[vV\22]") then -- Visual, Visual-Line, or Visual-Block mode
					start_line = vim.fn.line("'<") - 1 -- Convert to 0-indexed
				else
					-- No visual selection, use current cursor position
					start_line = vim.fn.line(".") - 1 -- Convert to 0-indexed
				end

				-- Determine status message based on event type
				local status_msg = ""
				local hl_group = "Comment"

				-- Tool Events
				if event.type == "session.status" then
					local status = event.properties.status
					if type(status) == "table" then
						-- Handle idle status
						if status.type == "idle" then
							-- Clear the virtual line when idle
							vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
							return
						end
						return
					else
						return
					end
				elseif event.type == "message.part.updated" then
					if event.properties.part.type == "text" then
						local text = event.properties.part.text or "<empty message>"
						-- Elliptisize from the start if message is too long
						local max_width = vim.o.columns - 10 -- Leave some margin
						if #text > max_width then
							text = "..." .. text:sub(-(max_width - 3))
						end
						status_msg = text
					elseif event.properties.part.type == "tool" then
						local part = event.properties.part
						local status = part.state and part.state.status or "unknown"
						local tool = part.tool or "unknown"
						local description = part.state and part.state.input and part.state.input.description or ""

						-- Capitalize first letter of status and tool
						local capitalize = function(str)
							return str:sub(1, 1):upper() .. str:sub(2)
						end

						status_msg = capitalize(status) .. ": " .. capitalize(tool)
						if description ~= "" then
							status_msg = status_msg .. ": " .. description
						end
					end
					hl_group = "SessionInfo"
				elseif event.type == "server.heartbeat" then
					-- Clear virtual line on heartbeat
					vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
					return
				elseif event.type == "server.conencted" then
					status_msg = "Opencode connected on port " .. tostring(port)
				else
					-- nop - keep existing virtual line
					return
				end

				-- Clear previous status virtual lines only when updating
				vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

				-- Only show virtual line if we have a valid selection or cursor position
				if start_line >= 0 and vim.api.nvim_buf_is_valid(bufnr) then
					-- Set virtual line above the selection start
					vim.api.nvim_buf_set_extmark(bufnr, ns_id, start_line, 0, {
						virt_lines = { { { status_msg, hl_group } } },
						virt_lines_above = true,
					})
				end
			end,
		})
	end,
}
