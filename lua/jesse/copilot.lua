-- Enable copilot lsp

local cmp_nvim_lsp = require('cmp_nvim_lsp')
local capabilities = cmp_nvim_lsp.default_capabilities()

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, bufnr) then
      vim.lsp.inline_completion.enable(true, { bufnr = bufnr })

      vim.keymap.set(
        'i',
        '<C-F>',
        vim.lsp.inline_completion.get,
        { desc = 'LSP: accept inline completion', buffer = bufnr }
      )
      vim.keymap.set(
        'i',
        '<C-G>',
        vim.lsp.inline_completion.select,
        { desc = 'LSP: switch inline completion', buffer = bufnr }
      )
    end
  end
})

-- Sign in/out functions
local function sign_in(bufnr, client)
  client:request(
    'signIn',
    vim.empty_dict(),
    function(err, result)
      if err then
        vim.notify(err.message, vim.log.levels.ERROR)
        return
      end
      if result.command then
        local code = result.userCode
        local command = result.command
        vim.fn.setreg('+', code)
        vim.fn.setreg('*', code)
        local continue = vim.fn.confirm(
          'Copied your one-time code to clipboard.\n' .. 'Open the browser to complete the sign-in process?',
          '&Yes\n&No'
        )
        if continue == 1 then
          client:exec_cmd(command, { bufnr = bufnr }, function(cmd_err, cmd_result)
            if cmd_err then
              vim.notify(cmd_err.message, vim.log.levels.ERROR)
              return
            end
            if cmd_result.status == 'OK' then
              vim.notify('Signed in as ' .. cmd_result.user .. '.')
            end
          end)
        end
      end

      if result.status == 'PromptUserDeviceFlow' then
        vim.notify('Enter your one-time code ' .. result.userCode .. ' in ' .. result.verificationUri)
      elseif result.status == 'AlreadySignedIn' then
        vim.notify('Already signed in as ' .. result.user .. '.')
      end
    end
  )
end

local function sign_out(_, client)
  client:request(
    'signOut',
    vim.empty_dict(),
    function(err, result)
      if err then
        vim.notify(err.message, vim.log.levels.ERROR)
        return
      end
      if result.status == 'NotSignedIn' then
        vim.notify('Not signed in.')
      end
    end
  )
end

-- Add copilot config to lspconfig
local lspconfig = require('lspconfig')
local configs = require('lspconfig.configs')

if not configs.copilot then
  configs.copilot = {
    default_config = {
      cmd = { 'copilot-language-server', '--stdio' },
      filetypes = { '*' },
      root_dir = lspconfig.util.root_pattern('.git', '.'),
      single_file_support = true,
      settings = {
        telemetry = {
          telemetryLevel = 'all',
        },
      },
    },
  }
end

lspconfig.copilot.setup {
    capabilities = capabilities,
    init_options = {
      editorInfo = {
        name = 'Neovim',
        version = tostring(vim.version()),
      },
      editorPluginInfo = {
        name = 'Neovim',
        version = tostring(vim.version()),
      },
    },
    on_attach = function(client, bufnr)
      vim.api.nvim_buf_create_user_command(bufnr, 'LspCopilotSignIn', function()
        sign_in(bufnr, client)
      end, { desc = 'Sign in Copilot with GitHub' })
      vim.api.nvim_buf_create_user_command(bufnr, 'LspCopilotSignOut', function()
        sign_out(bufnr, client)
      end, { desc = 'Sign out Copilot with GitHub' })
    end,
}

