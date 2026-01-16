local uv = vim.uv or vim.loop
local languages_dir = vim.fn.stdpath("config") .. "/lua/jesse/languages"

local handle = uv.fs_scandir(languages_dir)
if handle then
	while true do
		local name, type = uv.fs_scandir_next(handle)
		if not name then
			break
		end

		if type == "file" and name:match("%.lua$") then
			local module = "jesse.languages." .. name:gsub("%.lua$", "")
			pcall(require, module)
		end
	end
else
end
