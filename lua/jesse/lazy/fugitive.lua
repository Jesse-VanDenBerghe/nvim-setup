return {
    {
        "tpope/vim-fugitive",
        config = function()
            vim.keymap.set("n", "<leader>gg", vim.cmd.Git, {desc = "Open Fugitive Git Status"})
            vim.keymap.set("n", "<leader>ga", ":!git add -A<CR>", {desc = "Git Stage"})
            vim.keymap.set("n", "<leader>gp", ":Git push<CR>", {desc = "Git Push"})

            local function gc_commit()
                local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
                local ticket = branch:match("([A-Z]+-%d+)")

                vim.ui.input({ prompt = "Commit message: " }, function(input)
                    if input then
                        local message = ticket and (ticket .. ": " .. input) or input
                        vim.cmd("Git commit -m '" .. message:gsub("'", "'\\''") .. "'")
                    end
                end)
            end

            local function gcp_commit_and_push()
                vim.fn.system("git add -A")
                gc_commit()
                vim.cmd("Git push")
            end

            vim.keymap.set("n", "<leader>gc", gc_commit, {desc = "Commit with Jira ticket prefix"})
            vim.keymap.set("n", "<leader>gf", gcp_commit_and_push, {desc = "Commit and Push with Jira ticket prefix"})
        end
    }
}
