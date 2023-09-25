local status, git = pcall(require, "git")
local ok, git_conflict = pcall(require, "git-conflict")
if not status then
	return
end
if not ok then
	return
end

git.setup({
	keymaps = {
		-- Open blame window
		blame = "<Leader>gb",
		-- Open file/folder in git repository
		browse = "<Leader>go",
	},
})

git_conflict.setup({
	default_mappings = true, -- disable buffer local mapping created by this plugin
	default_commands = true, -- disable commands created by this plugin
	disable_diagnostics = false, -- This will disable the diagnostics in a buffer whilst it is conflicted
	highlights = { -- They must have background color, otherwise the default color will be used
		incoming = "DiffAdd",
		current = "DiffText",
	},
})
