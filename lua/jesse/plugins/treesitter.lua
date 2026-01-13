require'nvim-treesitter'.install { 'javascript', 'typescript', 'kotlin', 'swift', 'lua', 'rust', 'elixir' }

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'elixir', 'javascript', 'typescript', 'kotlin', 'swift', 'lua', 'rust' },
    callback = function()
        vim.treesitter.start()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})

