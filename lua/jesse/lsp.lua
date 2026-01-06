local cmp_nvim_lsp = require('cmp_nvim_lsp')
local capabilities = cmp_nvim_lsp.default_capabilities()

require("mason").setup()

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = args.buf })
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = args.buf })
        vim.keymap.set('n', '<leader>vws', vim.lsp.buf.workspace_symbol, { buffer = args.buf })
        vim.keymap.set('n', '<leader>vd', vim.diagnostic.open_float, { buffer = args.buf })
        vim.keymap.set('n', '[d', vim.diagnostic.goto_next, { buffer = args.buf })
        vim.keymap.set('n', ']d', vim.diagnostic.goto_prev, { buffer = args.buf })
        vim.keymap.set('n', '<leader>vca', vim.lsp.buf.code_action, { buffer = args.buf })
        vim.keymap.set('n', '<leader>vrr', vim.lsp.buf.references, { buffer = args.buf })
        vim.keymap.set('n', '<leader>vrn', vim.lsp.buf.rename, { buffer = args.buf })
        vim.keymap.set('i', '<C-h>', vim.lsp.buf.signature_help, { buffer = args.buf })
    end,
})

local lspconfig = require('lspconfig')

-- Lua
lspconfig.lua_ls.setup({
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' },
            },
        },
    },
})

-- Kotlin
lspconfig.kotlin_language_server.setup({ capabilities = capabilities })

-- Elixir
lspconfig.elixirls.setup {
    cmd = { vim.fn.stdpath("data") .. "/mason/bin/elixir-ls" },
}

-- Yaml
lspconfig.yamlls.setup {
    capabilities = capabilities
}

-- Python
lspconfig.pylsp.setup {
    capabilities = capabilities
}
