-- Dashboard configuration for snacks.nvim
-- Kept in a separate file to keep snacks.lua lean.

local header = [[
     ██╗███████╗███████╗███████╗███████╗
     ██║██╔════╝██╔════╝██╔════╝██╔════╝
     ██║█████╗  ███████╗███████╗█████╗
██   ██║██╔══╝  ╚════██║╚════██║██╔══╝
╚█████╔╝███████╗███████║███████║███████╗
 ╚════╝ ╚══════╝╚══════╝╚══════╝╚══════╝]]

-- Static project shortcuts (shown in pane 1 below keymaps)
local pinned = {
	{ name = "Neovim Config", path = "~/.config/nvim", icon = " " },
}

---Generator: yields a title row then one item per pinned project.
---@return snacks.dashboard.Section
local function pinned_projects()
	local items = {
		{
			text = { { "  Pinned Projects", hl = "SnacksDashboardTitle" } },
			indent = 0,
			padding = { 0, 1 },
		},
	}
	for _, p in ipairs(pinned) do
		table.insert(items, {
			icon = p.icon,
			desc = p.name,
			indent = 2,
			action = function()
				vim.cmd("cd " .. vim.fn.expand(p.path))
				Snacks.dashboard.pick("files")
			end,
			autokey = true,
		})
	end
	return items
end

return {
	width = 60,
	pane_gap = 6,
	preset = {
		keys = {
				{ icon = "󰍉 ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
			{ icon = "󰺮 ", key = "g", desc = "Live Grep", action = ":lua Snacks.dashboard.pick('live_grep')" },
			{ icon = "󱋡 ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
			{ icon = "󰒓 ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
			{ icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
			{ icon = "󰩈 ", key = "q", desc = "Quit", action = ":qa" },
		},
		header = header,
	},
	sections = {
		-- ── Pane 1 (left) ───────────────────────────────────────────────────
		{ section = "header" },
		{ section = "keys", gap = 1, padding = 1 },
		pinned_projects,
		{ section = "startup", padding = { 2, 1 } },

		-- ── Pane 2 (right) ──────────────────────────────────────────────────
		{
			pane = 2,
			icon = " ",
			title = "Recent Files",
			section = "recent_files",
			limit = 6,
			indent = 2,
			padding = 1,
		},
		{
			pane = 2,
			icon = " ",
			title = "Projects",
			section = "projects",
			indent = 2,
			padding = 1,
			limit = 5,
		},
		{
			pane = 2,
			icon = " ",
			title = "Git Status",
			section = "terminal",
			enabled = function()
				return Snacks.git.get_root() ~= nil
			end,
			cmd = "git --no-pager diff --stat -B -M -C 2>/dev/null || echo '  nothing to diff'",
			height = 5,
			padding = 1,
			ttl = 2 * 60,
			indent = 3,
		},
		{
			pane = 2,
			icon = " ",
			title = "Open PRs",
			section = "terminal",
			enabled = function()
				return vim.fn.executable("gh") == 1 and Snacks.git.get_root() ~= nil
			end,
			cmd = "gh pr list -L 5 2>/dev/null || echo '  no open PRs'",
			height = 5,
			padding = 1,
			ttl = 5 * 60,
			indent = 3,
			action = function()
				vim.fn.jobstart("gh pr list --web", { detach = true })
			end,
			key = "P",
		},
	},
}
