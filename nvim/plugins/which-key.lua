local wk = require("which-key")
wk.setup({
	plugins = {
		marks = false,
		registers = false,
		spelling = { enabled = false, suggestions = 20 },
		presets = {
			operators = false,
			motions = false,
			text_objects = false,
			windows = false,
			nav = false,
			z = false,
			g = false,
		},
	},
})
local Terminal = require("toggleterm.terminal").Terminal
local toggle_float = function()
	local float = Terminal:new({ direction = "float" })
	return float:toggle()
end
local toggle_lazygit = function()
	local lazygit = Terminal:new({ cmd = "lazygit", direction = "float" })
	return lazygit:toggle()
end
local mappings = {
	q = { ":q<cr>", "Quit" },
	Q = { ":wq<cr>", "Save & Quit" },
	w = { ":w<cr>", "Save" },
	x = { ":bdelete<cr>", "Close" },
	E = { ":e ~/.config/nvim/init.lua<cr>", "Edit config" },
	r = { ":Telescope live_grep<cr>", "Telescope Live Grep" },
	-- s = { ":Telescope grep_string<cr>", "Telescope Search Text under cursor" },
	l = {
		name = "[l]sp",
		i = { ":LspInfo<cr>", "Connected Language Servers" },
		A = { "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", "[A]dd workspace folder" },
		R = { "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", "[R]emove workspace folder" },
		l = { "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", "[l]ist workspace folder" },
		D = { "<cmd>lua vim.lsp.buf.type_definition()<CR>", "Type [D]efinition" },
		r = { "<cmd>lua vim.lsp.buf.rename()<CR>", "[r]ename" },
		a = { "<cmd>lua vim.lsp.buf.code_action()<CR>", "Code [a]ctions" },
		e = { '<cmd>lua vim.diagnostic.open_float(0, {scope="line"})<CR>', "Show lin[e] diagnostics" },
		q = { "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", "Show loclist" },
	},
	d = {
		name = "[D]ebug",
		t = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "[t]oggle Breakpoint" },
		b = { "<cmd>lua require'dap'.step_back()<cr>", "Step [b]ack" },
		c = { "<cmd>lua require'dap'.continue()<cr>", "[c]ontinue" },
		C = { "<cmd>lua require'dap'.run_to_cursor()<cr>", "Run To [C]ursor" },
		d = { "<cmd>lua require'dap'.disconnect()<cr>", "[d]isconnect" },
		g = { "<cmd>lua require'dap'.session()<cr>", "[g]et Session" },
		i = { "<cmd>lua require'dap'.step_into()<cr>", "Step [i]nto" },
		o = { "<cmd>lua require'dap'.step_over()<cr>", "Step [o]ver" },
		u = { "<cmd>lua require'dap'.step_out()<cr>", "Step O[u]t" },
		p = { "<cmd>lua require'dap'.pause()<cr>", "[p]ause" },
		r = { "<cmd>lua require'dap'.repl.toggle()<cr>", "Toggle [r]epl" },
		s = { "<cmd>lua require'dap'.continue()<cr>", "[s]start" },
		q = { "<cmd>lua require'dap'.close()<cr>", "[q]uit" },
		U = { "<cmd>lua require'dapui'.toggle()<cr>", "Toggle [U]I" },
	},
	t = {
		name = "[t]erminal",
		t = { ":ToggleTerm<cr>", "Spli[t] Below" },
		f = { toggle_float, "[f]loating Terminal" },
		l = { toggle_lazygit, "[l]azyGit" },
	},
	g = {
		name = "[g]it",
		o = { "<cmd>GitConflictChooseOurs<cr>", "Git conflict choose [o]urs" },
		t = { "<cmd>GitConflictChooseTheirs<cr>", "Git conflict choose [t]heirs" },
		b = { "<cmd>GitConflictChooseBoth<cr>", "Git conflict choose [b]oth" },
		N = { "<cmd>GitConflictChooseNone<cr>", "Git conflict choose [N]one" },
		n = { "<cmd>GitConflictNextConflict<cr>", "Go to [n]ext conflict" },
		p = { "<cmd>GitConflictPrevConflict<cr>", "Go to [p]rev conflict" },
		l = { "<cmd>GitConflictListQf<cr>", "[l]ist all quickfix" },
	},
}

local opts = {
	prefix = "<leader>",
}
wk.register(mappings, opts)
