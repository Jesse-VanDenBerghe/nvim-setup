return {
    { -- Highlight, edit, and navigate code
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            -- New nvim-treesitter API (main branch rewrite)
            require("nvim-treesitter").setup({
                install_dir = vim.fn.stdpath("data") .. "/site",
            })

            -- Install parsers (async, no-op if already installed)
            require("nvim-treesitter").install({
                "bash",
                "c",
                "diff",
                "html",
                "lua",
                "luadoc",
                "markdown",
                "query",
                "vim",
                "vimdoc",
                "elixir",
                "heex",
                "eex",
                "kotlin",
                "javascript",
                "typescript",
            })

            -- Enable treesitter highlighting for all filetypes with a parser
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("treesitter-highlight", { clear = true }),
                callback = function(args)
                    local ft = vim.bo[args.buf].filetype

                    if ft == "markdown" then
                        return
                    end

                    -- Only start if a parser exists for this filetype
                    if pcall(vim.treesitter.start, args.buf) then
                        -- Enable treesitter-based indentation
                        pcall(function()
                            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                        end)
                    end
                end,
            })
        end,
    },
}
