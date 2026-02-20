local M = {}

---@param client vim.lsp.Client
---@param bufnr integer
local function on_attach(client, bufnr)
	local function sign_in()
		client:request("signIn", vim.empty_dict(), function(err, result)
			if err then
				vim.notify(err.message, vim.log.levels.ERROR)
				return
			end
			if result.command then
				local code = result.userCode
				vim.fn.setreg("+", code)
				vim.fn.setreg("*", code)
				local continue = vim.fn.confirm(
					"Copied your one-time code to clipboard.\nOpen the browser to complete the sign-in process?",
					"&Yes\n&No"
				)
				if continue == 1 then
					client:exec_cmd(result.command, { bufnr = bufnr }, function(cmd_err, cmd_result)
						if cmd_err then
							vim.notify(cmd_err.message, vim.log.levels.ERROR)
							return
						end
						if cmd_result.status == "OK" then
							vim.notify("Signed in as " .. cmd_result.user .. ".")
						end
					end)
				end
			end
			if result.status == "PromptUserDeviceFlow" then
				vim.notify("Enter your one-time code " .. result.userCode .. " in " .. result.verificationUri)
			elseif result.status == "AlreadySignedIn" then
				vim.notify("Already signed in as " .. result.user .. ".")
			end
		end)
	end

	local function sign_out()
		client:request("signOut", vim.empty_dict(), function(err, result)
			if err then
				vim.notify(err.message, vim.log.levels.ERROR)
				return
			end
			if result.status == "NotSignedIn" then
				vim.notify("Not signed in.")
			end
		end)
	end

	vim.api.nvim_buf_create_user_command(bufnr, "LspCopilotSignIn", sign_in, {
		desc = "Sign in Copilot with GitHub",
	})
	vim.api.nvim_buf_create_user_command(bufnr, "LspCopilotSignOut", sign_out, {
		desc = "Sign out Copilot with GitHub",
	})
end

--- Enable Copilot LSP.
function M.enable()
	vim.lsp.enable("copilot")
	vim.notify("Copilot enabled", vim.log.levels.INFO)
end

--- Disable Copilot LSP.
function M.disable()
	vim.lsp.enable("copilot", false)
	vim.notify("Copilot disabled", vim.log.levels.INFO)
end

--- Toggle Copilot LSP on/off.
function M.toggle()
	if vim.lsp.is_enabled("copilot") then
		M.disable()
	else
		M.enable()
	end
end

--- Register the Copilot LSP config and perform the initial enable.
--- Must be called once during startup, after capabilities are built.
---@param capabilities table LSP capabilities (merged with blink.cmp)
function M.setup(capabilities)
	local config = {
		cmd = { "copilot-language-server", "--stdio" },
		root_markers = { ".git" },
		single_file_support = true,
		settings = {
			telemetry = { telemetryLevel = "all" },
		},
		init_options = {
			editorInfo = { name = "Neovim", version = tostring(vim.version()) },
			editorPluginInfo = { name = "Neovim", version = tostring(vim.version()) },
		},
		on_attach = on_attach,
	}

	config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
	vim.lsp.config("copilot", config)
	vim.lsp.enable("copilot")

	-- User command: CopilotToggle [true|false|1|0]
	vim.api.nvim_create_user_command("CopilotToggle", function(opts)
		local arg = opts.args ~= "" and opts.args or nil
		if arg == "true" or arg == "1" then
			M.enable()
		elseif arg == "false" or arg == "0" then
			M.disable()
		else
			M.toggle()
		end
	end, { desc = "Toggle Copilot (optional: true/false)", nargs = "?" })

	vim.keymap.set("n", "<leader>act", M.toggle, { desc = "[A]I Cop[i]lot Toggle" })
end

return M
