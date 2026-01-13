require('telescope').setup({
    defaults = {
        file_ignore_patterns = {
            "node_modules",
            ".git/",
            "%.lock",
            "pack/nvim/",
        }
    }
})

local builtin = require('telescope.builtin')

-- Finders
vim.keymap.set('n', '<leader>ff', builtin.find_files, {desc = "Find Files (Telescope)"})
vim.keymap.set('n', '<leader>fs', function()
	builtin.grep_string({ search = vim.fn.input("Search for: ") });
end, {desc = "Find with Search String (Telescope)"})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {desc = "Find Help Tags (Telescope)"})
vim.keymap.set('n', '<leader>ft', builtin.treesitter, {desc = "Find Treesitter Symbols (Telescope)"})
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, {desc = "Find old Files (Telescope)"})
vim.keymap.set('n', '<leader>fc', builtin.commands, {desc = "Find commands (Telescope)"})
vim.keymap.set('n', '<leader>fk', builtin.keymaps, {desc = "Find keymaps (Telescope)"})
vim.keymap.set('n', '<leader>fr', builtin.registers, {desc = "Find Registers (Telescope)"})
vim.keymap.set('n', '<leader>fm', builtin.marks, {desc = "Find Marks (Telescope)"})
vim.keymap.set('n', '<leader>fd', builtin.man_pages, {desc = "Find Man pages (Telescope)"})

-- Git Finders
vim.keymap.set('n', '<leader>gf', builtin.git_files, {desc = "Git Files (Telescope)"})
vim.keymap.set('n', '<leader>gc', builtin.git_commits, {desc = "Git Commits (Telescope)"})
vim.keymap.set('n', '<leader>gs', builtin.git_status, {desc = "Git Status (Telescope)"})
vim.keymap.set('n', '<leader>gb', builtin.git_branches, {desc = "Git Branches (Telescope)"})

-- LSP Finders
vim.keymap.set('n', '<leader>lr', builtin.lsp_references, {desc = "LSP References (Telescope)"})
vim.keymap.set('n', '<leader>lfd', function()
    builtin.diagnostics({bufnr = 0})
end
, {desc = "LSP Diagnostics (Telescope)"})
vim.keymap.set('n', '<leader>li', builtin.lsp_implementations, {desc = "LSP References (Telescope)"})
vim.keymap.set('n', '<leader>ld', builtin.lsp_definitions, {desc = "LSP Definitions (Telescope)"})

