-- Install parsers
require'nvim-treesitter'.install { 'javascript', 'typescript', 'kotlin', 'swift', 'lua', 'rust', 'elixir' }

-- Enable highlighting for elixir (and other languages you want)
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'elixir', 'javascript', 'typescript', 'kotlin', 'swift', 'lua', 'rust' },
    callback = function() vim.treesitter.start() end,
})

