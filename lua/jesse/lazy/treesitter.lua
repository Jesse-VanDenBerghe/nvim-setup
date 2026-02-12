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
				"markdown_inline",
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
				callback = function(args)
					-- Only start if a parser exists for this filetype
					if pcall(vim.treesitter.start, args.buf) then
						-- Enable treesitter-based indentation
						vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
		-- There are additional nvim-treesitter modules that you can use to interact
		-- with nvim-treesitter. You should go explore a few and see what interests you:
		--
		--    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
		--    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
		--    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
	},
}
