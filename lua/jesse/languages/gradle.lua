local gradlegroup = vim.api.nvim_create_augroup("GradleTools", { clear = true })
local gradle_picker = require("jesse.languages.gradle.picker")

local function update_gradle_setup()
	local cwd = vim.fn.getcwd()
	if vim.fn.filereadable(cwd .. "/gradlew") == 1 then
		vim.keymap.set("n", "<leader>sg", gradle_picker.open, { desc = "Search Gradle task" })
	else
		pcall(vim.keymap.del, "n", "<leader>fg")
	end
end

vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
	group = gradlegroup,
	callback = update_gradle_setup,
})
