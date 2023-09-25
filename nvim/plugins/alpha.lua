local status_ok, alpha = pcall(require, "alpha")
if not status_ok then
	return
end

local dashboard = require("alpha.themes.dashboard")

-- generated from https://patorjk.com/software/taag/#p=testall&f=3D%20Diagonal&t=arifinoid
dashboard.section.header.val = {
	[[              _ _____             _     __]],
	[[  ____ ______(_) __(_)___  ____  (_)___/ /]],
	[[ / __ `/ ___/ / /_/ / __ \/ __ \/ / __  / ]],
	[[/ /_/ / /  / / __/ / / / / /_/ / / /_/ /  ]],
	[[\__,_/_/  /_/_/ /_/_/ /_/\____/_/\__,_/   ]],
}

dashboard.section.buttons.val = {
	dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
	dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
	dashboard.button("p", "  Find project", ":Telescope projects <CR>"),
	dashboard.button("r", "  Recently used files", ":Telescope oldfiles <CR>"),
	dashboard.button("t", "  Find text", ":Telescope live_grep <CR>"),
	dashboard.button("c", "  Configuration", ":e ~/.config/nvim/init.lua <CR>"),
	dashboard.button("q", "  Quit Neovim", ":qa<CR>"),
}

local function footer()
	local stats = require("lazy").stats()
	local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

	local time = "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
	local name = "Arifinoid "

	return name .. time
end

dashboard.section.footer.val = footer()
dashboard.section.footer.opts.hl = "Type"
dashboard.section.header.opts.hl = "Include"
dashboard.section.buttons.opts.hl = "Keyword"
dashboard.opts.opts.noautocmd = true

alpha.setup(dashboard.opts)
