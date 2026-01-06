require('telescope').setup({
    defaults = {
        file_ignore_patterns = {
            "node_modules",
            ".git/",
            "%.lock",
            "pack/nvim/"
        }
    }
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'Telescope git files' })
vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({ seach = vim.fn.input("Grep > ") });
end
, { desc = 'Telescope find files' })
