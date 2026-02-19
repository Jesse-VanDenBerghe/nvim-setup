return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        input = { enabled = true },
        dashboard = {
            sections = {
                { section = "header" },
                { section = "keys", gap = 1 },
                { section = "startup" },
            },
        },
    },
}
