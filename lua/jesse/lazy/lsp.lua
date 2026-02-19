return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			{ "j-hui/fidget.nvim", opts = {} },

			"saghen/blink.cmp",
		},
		config = function()
			-- NOTE: vim.lsp.inline_completion is a Neovim nightly (0.12+) API.
			-- Guard against its absence on stable 0.11 so the block is a no-op there.
			if vim.lsp.inline_completion then
				vim.api.nvim_create_autocmd("LspAttach", {
					group = vim.api.nvim_create_augroup("copilot-inline-completion", { clear = false }),
					callback = function(args)
						local bufnr = args.buf
						local client = vim.lsp.get_client_by_id(args.data.client_id)

						if
							client
							and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, bufnr)
						then
							vim.lsp.inline_completion.enable(true, { bufnr = bufnr })

							-- Trigger / cycle through inline completions.
							vim.keymap.set("i", "<C-F>", vim.lsp.inline_completion.get, {
								desc = "LSP: trigger inline completion",
								buffer = bufnr,
							})
							vim.keymap.set("i", "<C-G>", vim.lsp.inline_completion.select, {
								desc = "LSP: cycle inline completion",
								buffer = bufnr,
							})

							-- Accept the currently shown inline completion suggestion.
							vim.keymap.set("i", "<Tab>", function()
								return vim.lsp.inline_completion.accept() or "<Tab>"
							end, {
								desc = "LSP: accept inline completion",
								buffer = bufnr,
								expr = true,
							})
							vim.keymap.set("i", "<Right>", function()
								return vim.lsp.inline_completion.accept() or "<Right>"
							end, {
								desc = "LSP: accept inline completion",
								buffer = bufnr,
								expr = true,
							})
						end
					end,
				})
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					-- NOTE: Remember that Lua is a real programming language, and as such it is possible
					-- to define small helper and utility functions so you don't have to repeat yourself.
					--
					-- In this case, we create a function that lets us more easily define mappings specific
					-- for LSP related items. It sets the mode, buffer and description for us each time.
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- Rename the variable under your cursor.
					--  Most Language Servers support renaming across files, etc.
					map("<leader>lrn", vim.lsp.buf.rename, "Refactor re[n]ame")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("<leader>la", vim.lsp.buf.code_action, "Code [A]ction", { "n", "x" })

					-- Find references for the word under your cursor.
					map("<leader>lgr", function() Snacks.picker.lsp_references() end, "[G]oto [R]eferences")

					-- Jump to the implementation of the word under your cursor.
					--  Useful when your language has ways of declaring types without an actual implementation.
					map("<leader>lgi", function() Snacks.picker.lsp_implementations() end, "[G]oto [I]mplementation")

					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					--  To jump back, press <C-t>.
					map("<leader>lgd", function() Snacks.picker.lsp_definitions() end, "[G]oto [D]efinition")

					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header.
					map("<leader>lgD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					map("<leader>lO", function() Snacks.picker.lsp_symbols() end, "Open Document Symbols")

					-- Fuzzy find all the symbols in your current workspace.
					--  Similar to document symbols, except searches over your entire project.
					map("<leader>lW", function() Snacks.picker.lsp_workspace_symbols() end, "Open Workspace Symbols")

					-- Jump to the type of the word under your cursor.
					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					map("<leader>lgt", function() Snacks.picker.lsp_type_definitions() end, "[G]oto [T]ype Definition")

					-- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
					---@param client vim.lsp.Client
					---@param method vim.lsp.protocol.Method
					---@param bufnr? integer some lsp support methods only in specific files
					---@return boolean
					local function client_supports_method(client, method, bufnr)
						if vim.fn.has("nvim-0.11") == 1 then
							return client:supports_method(method, bufnr)
						else
							return client.supports_method(method, { bufnr = bufnr })
						end
					end

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if
						client
						and client_supports_method(
							client,
							vim.lsp.protocol.Methods.textDocument_documentHighlight,
							event.buf
						)
					then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					-- The following code creates a keymap to toggle inlay hints in your
					-- code, if the language server you are using supports them
					--
					-- This may be unwanted, since they displace some of your code
					if
						client
						and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
					then
						map("<leader>lth", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			-- Diagnostic Config
			-- See :help vim.diagnostic.Opts
			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				signs = vim.g.have_nerd_font and {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚 ",
						[vim.diagnostic.severity.WARN] = "󰀪 ",
						[vim.diagnostic.severity.INFO] = "󰋽 ",
						[vim.diagnostic.severity.HINT] = "󰌶 ",
					},
				} or {},
				virtual_text = {
					source = "if_many",
					spacing = 2,
					format = function(diagnostic)
						local diagnostic_message = {
							[vim.diagnostic.severity.ERROR] = diagnostic.message,
							[vim.diagnostic.severity.WARN] = diagnostic.message,
							[vim.diagnostic.severity.INFO] = diagnostic.message,
							[vim.diagnostic.severity.HINT] = diagnostic.message,
						}
						return diagnostic_message[diagnostic.severity]
					end,
				},
			})

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- Enable the following language servers
			--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
			--
			--  Add any additional override configuration in the following tables. Available keys are:
			--  - cmd (table): Override the default command used to start the server
			--  - filetypes (table): Override the default list of associated filetypes for the server
			--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
			--  - settings (table): Override the default settings passed when initializing the server.
			--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
			local servers = {
				-- clangd = {},
				-- gopls = {},
				-- pyright = {},
				-- rust_analyzer = {},
				-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
				--
				-- Some languages (like typescript) have entire language plugins that can be useful:
				--    https://github.com/pmizio/typescript-tools.nvim
				--
				-- But for many setups, the LSP (`ts_ls`) will work just fine
				-- ts_ls = {},
				--

				yamlls = {},
				lua_ls = {
					-- cmd = { ... },
					-- filetypes = { ... },
					-- capabilities = {},
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
							diagnostics = { disable = { "missing-fields" } },
						},
					},
				},
				kotlin_language_server = {
					settings = {
						kotlin = {
							compiler = {
								jvm = {
									target = "17",
								},
							},
						},
					},
				},
				elixirls = {
					filetypes = { "elixir", "eelixir", "heex", "surface" },
				},
				tailwindcss = {
					filetypes = { "html", "heex", "elixir", "eelixir", "javascript", "typescript", "css" },
					init_options = {
						userLanguages = {
							elixir = "html-eex",
							eelixir = "html-eex",
							heex = "html-eex",
						},
					},
					settings = {
						tailwindCSS = {
							experimental = {
								classRegex = {
									'class[:]\\s*"([^"]*)',
								},
							},
						},
					},
				},
				ts_ls = {},
				copilot = {
					cmd = { "copilot-language-server", "--stdio" },
					filetypes = { "*" },
					root_dir = function(fname)
						return vim.fs.root(fname, { ".git" }) or vim.fn.getcwd()
					end,
					single_file_support = true,
					settings = {
						telemetry = { telemetryLevel = "all" },
					},
					init_options = {
						editorInfo = { name = "Neovim", version = tostring(vim.version()) },
						editorPluginInfo = { name = "Neovim", version = tostring(vim.version()) },
					},
					on_attach = function(client, bufnr)
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
									vim.notify(
										"Enter your one-time code "
											.. result.userCode
											.. " in "
											.. result.verificationUri
									)
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
					end,
				},
			}

			-- Copilot toggle command (session only)
			vim.api.nvim_create_user_command("CopilotToggle", function()
				local clients = vim.lsp.get_clients({ name = "copilot" })
				if #clients > 0 then
					vim.lsp.stop_client(clients)
					vim.lsp.enable("copilot", false)
					vim.g.copilot_disabled = true
					vim.notify("Copilot disabled for this session")
				else
					vim.g.copilot_disabled = false
					vim.lsp.enable("copilot")
					vim.notify("Copilot enabled")
				end
			end, { desc = "Toggle Copilot for this session" })

			vim.keymap.set("n", "<leader>lc", "<cmd>CopilotToggle<cr>", { desc = "Toggle Copilot" })

			-- Ensure the servers and tools above are installed.
			-- "copilot" is not a Mason package (binary: copilot-language-server) and is not a
			-- built-in lspconfig server, so configure it via the native vim.lsp API (nvim 0.11+)
			-- and exclude it from mason-tool-installer.
			local copilot_config = servers["copilot"]
			if copilot_config then
				copilot_config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, copilot_config.capabilities or {})
				vim.lsp.config("copilot", copilot_config)
				vim.lsp.enable("copilot")
			end

			local ensure_installed = vim.tbl_filter(function(name)
				return name ~= "copilot"
			end, vim.tbl_keys(servers or {}))
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
				"elixir-ls",
				"tailwindcss-language-server",
				"typescript-language-server",
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
				automatic_installation = false,
				handlers = {
					function(server_name)
						-- copilot is set up directly above; skip it here
						if server_name == "copilot" then
							return
						end
						local server = servers[server_name] or {}
						-- This handles overriding only values explicitly passed
						-- by the server configuration above. Useful when disabling
						-- certain features of an LSP (for example, turning off formatting for ts_ls)
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},
}
