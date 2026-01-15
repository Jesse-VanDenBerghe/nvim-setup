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
            }
            require('onedark').load()
        end
    }

}
