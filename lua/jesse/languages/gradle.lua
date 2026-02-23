local gradlegroup = vim.api.nvim_create_augroup("GradleTools", { clear = true })
local gradle_picker = require("jesse.languages.gradle.picker")

local function setup_gradle()
	vim.keymap.set("n", "<leader>sg", gradle_picker.open, { desc = "Search Gradle task" })
end

vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
	group = gradlegroup,
	callback = function()
		local cwd = vim.fn.getcwd()
		if vim.fn.filereadable(cwd .. "/gradlew") == 1 then
			setup_gradle()
		end
	end,
})
