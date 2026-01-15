return {
    -- onedark
    {
        'navarasu/onedark.nvim',
        lazy = false,
        event = "VimEnter",
        config = function()
            require('onedark').setup {
                style = 'warmer',
                transparent = true,
                highlights = {
                    Comment = { fg = '#7a8194' }
                }
            }
            require('onedark').load()
        end
    }

}
