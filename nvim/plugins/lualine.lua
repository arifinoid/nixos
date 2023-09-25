local status_ok, lualine = pcall(require, "lualine")
local null_ls = require("null-ls")

if not status_ok then
	return
end

local hide_in_width = function()
	return vim.fn.winwidth(0) > 80
end

local alternative_methods = {
	null_ls.methods.DIAGNOSTICS,
	null_ls.methods.DIAGNOSTICS_ON_OPEN,
	null_ls.methods.DIAGNOSTICS_ON_SAVE,
}

local list_registered_providers_names = function(filetype)
	local s = require("null-ls.sources")
	local available_sources = s.get_available(filetype)
	local registered = {}
	for _, source in ipairs(available_sources) do
		for method in pairs(source.methods) do
			registered[method] = registered[method] or {}
			table.insert(registered[method], source.name)
		end
	end
	return registered
end

local list_registered = function(filetype)
	local registered_providers = list_registered_providers_names(filetype)
	return registered_providers[null_ls.methods.FORMATTING] or {}
end

local linterListRegistered = function(filetype)
	local registered_providers = list_registered_providers_names(filetype)
	local providers_for_methods = vim.tbl_flatten(vim.tbl_map(function(m)
		return registered_providers[m] or {}
	end, alternative_methods))

	return providers_for_methods
end

local treesitter = {
	function()
		return ""
	end,
	color = function()
		local buf = vim.api.nvim_get_current_buf()
		local ts = vim.treesitter.highlighter.active[buf]
		return { fg = ts and not vim.tbl_isempty(ts) and "#98be65" or "#ec5f67" }
	end,
	cond = hide_in_width,
}

local lsp = {
	function(msg)
		msg = msg or "LS Inactive"
		local buf_clients = vim.lsp.buf_get_clients()
		if next(buf_clients) == nil then
			-- TODO: clean up this if statement
			if type(msg) == "boolean" or #msg == 0 then
				return "LS Inactive"
			end
			return msg
		end
		local buf_ft = vim.bo.filetype
		local buf_client_names = {}

		-- add client
		for _, client in pairs(buf_clients) do
			if client.name ~= "null-ls" then
				table.insert(buf_client_names, client.name)
			end
		end

		-- add formatter
		local supported_formatters = list_registered(buf_ft)
		vim.list_extend(buf_client_names, supported_formatters)

		-- add linter
		local supported_linters = linterListRegistered(buf_ft)
		vim.list_extend(buf_client_names, supported_linters)

		local unique_client_names = vim.fn.uniq(buf_client_names)
		return "[" .. table.concat(unique_client_names, ", ") .. "]"
	end,
	color = { gui = "bold" },
	cond = hide_in_width,
}

local diagnostics = {
	"diagnostics",
	sources = { "nvim_diagnostic" },
	sections = { "error", "warn" },
	symbols = { error = " ", warn = " " },
	colored = false,
	update_in_insert = false,
	always_visible = true,
}

local diff = {
	"diff",
	colored = false,
	symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
	cond = hide_in_width,
}

local mode = {
	"mode",
	fmt = function(str)
		return "-- " .. str .. " --"
	end,
}

local filetype = {
	"filetype",
	icons_enabled = true,
}

local branch = {
	"branch",
	icons_enabled = true,
	icon = "",
}

-- local location = {
--   "location",
--   padding = 0,
-- }

-- local spaces = {
--   function()
--     local shiftwidth = vim.api.nvim_buf_get_option(0, "shiftwidth")
--     return " " .. shiftwidth
--   end,
--   padding = 1,
-- }

-- cool function for progress
local progress = function()
	local current_line = vim.fn.line(".")
	local total_lines = vim.fn.line("$")
	local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
	local line_ratio = current_line / total_lines
	local index = math.ceil(line_ratio * #chars)
	return chars[index]
end

lualine.setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = { "alpha", "dashboard", "NvimTree", "Outline" },
		always_divide_middle = true,
	},
	sections = {
		lualine_a = { branch, diagnostics },
		lualine_b = { mode },
		lualine_c = {},
		-- lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_x = { diff },
		lualine_y = { treesitter, lsp, filetype },
		lualine_z = { progress },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	extensions = {},
})
