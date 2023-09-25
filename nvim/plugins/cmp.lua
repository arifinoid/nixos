local status, cmp = pcall(require, "cmp")
local status_snip, luasnip = pcall(require, "luasnip")

if not status then
	return
end
if not status_snip then
	return
end

local lsp_symbols = {
	Class = "   Class",
	Color = "   Color",
	Constant = "   Constant",
	Constructor = "   Constructor",
	Enum = " ❐  Enum",
	EnumMember = "   EnumMember",
	Event = "   Event",
	Field = " ﴲ  Field",
	File = "   File",
	Folder = "   Folder",
	Function = "   Function",
	Interface = " ﰮ  Interface",
	Keyword = "   Keyword",
	Method = "   Method",
	Module = "   Module",
	Operator = "   Operator",
	Property = "   Property",
	Reference = "   Reference",
	Snippet = " ﬌  Snippet",
	Struct = " ﳤ  Struct",
	Text = "   Text",
	TypeParameter = "   TypeParameter",
	Unit = "   Unit",
	Value = "   Value",
	Variable = "[] Variable",
}

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = {
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{
			name = "buffer",
			option = {
				get_bufnrs = function()
					return vim.api.nvim_list_bufs()
				end,
			},
		},
		{ name = "path" },
		{ name = "nvim_lua" },
	}),
	formatting = {
		format = function(entry, item)
			item.kind = lsp_symbols[item.kind]
			item.menu = ({
				nvim_lsp = "[LSP]",
				path = "[F]",
				luasnip = "[S]",
				buffer = "[B]",
				nvim_lua = "[Lua]",
			})[entry.source.name]
			return item
		end,
	},
})

vim.cmd([[
  set completeopt=menuone,noinsert,noselect
  highlight! default link CmpItemKind CmpItemMenuDefault
]])
