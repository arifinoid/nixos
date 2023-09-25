local status, ts = pcall(require, "nvim-treesitter.configs")
if not status then
	return
end

ts.setup({
	context_commentstring = {
		enable = true,
		config = {
			typescript = { __default = "// %s", __multiline = "/* %s */" },
			css = "/* %s */",
			scss = { __default = "// %s", __multiline = "/* %s */" },
			php = { __default = "// %s", __multiline = "/* %s */" },
			html = "<!-- %s -->",
			svelte = "<!-- %s -->",
			vue = "<!-- %s -->",
			astro = "<!-- %s -->",
			handlebars = "{{! %s }}",
			glimmer = "{{! %s }}",
			graphql = "# %s",
			lua = { __default = "-- %s", __multiline = "--[[ %s ]]" },
			vim = '" %s',
			twig = "{# %s #}",
			tsx = {
				__default = "// %s",
				__multiline = "/* %s */",
				jsx_element = "{/* %s */}",
				jsx_fragment = "{/* %s */}",
				jsx_attribute = { __default = "// %s", __multiline = "/* %s */" },
				comment = { __default = "// %s", __multiline = "/* %s */" },
				call_expression = { __default = "// %s", __multiline = "/* %s */" },
				statement_block = { __default = "// %s", __multiline = "/* %s */" },
				spread_element = { __default = "// %s", __multiline = "/* %s */" },
			},
			jsx = {
				__default = "// %s",
				__multiline = "/* %s */",
				jsx_element = "{/* %s */}",
				jsx_fragment = "{/* %s */}",
				jsx_attribute = { __default = "// %s", __multiline = "/* %s */" },
				comment = { __default = "// %s", __multiline = "/* %s */" },
				call_expression = { __default = "// %s", __multiline = "/* %s */" },
				statement_block = { __default = "// %s", __multiline = "/* %s */" },
				spread_element = { __default = "// %s", __multiline = "/* %s */" },
			},
			javascript = {
				__default = "// %s",
				__multiline = "/* %s */",
				jsx_element = "{/* %s */}",
				jsx_fragment = "{/* %s */}",
				jsx_attribute = { __default = "// %s", __multiline = "/* %s */" },
				comment = { __default = "// %s", __multiline = "/* %s */" },
				call_expression = { __default = "// %s", __multiline = "/* %s */" },
				statement_block = { __default = "// %s", __multiline = "/* %s */" },
				spread_element = { __default = "// %s", __multiline = "/* %s */" },
			},
		},
	},
	highlight = {
		enable = true,
		disable = {},
		additional_vim_regex_highlighting = false,
	},
	sync_install = false,
	indent = {
		enable = true,
		disable = {},
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<c-space>",
			node_incremental = "<c-space>",
			scope_incremental = "<c-s>",
			node_decremental = "<c-backspace>",
		},
	},
	textobjects = {
		select = {
			enable = true,
			lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				["aa"] = "@parameter.outer",
				["ia"] = "@parameter.inner",
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			},
		},
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				["]m"] = "@function.outer",
				["]]"] = "@class.outer",
			},
			goto_next_end = {
				["]M"] = "@function.outer",
				["]["] = "@class.outer",
			},
			goto_previous_start = {
				["[m"] = "@function.outer",
				["[["] = "@class.outer",
			},
			goto_previous_end = {
				["[M"] = "@function.outer",
				["[]"] = "@class.outer",
			},
		},
		swap = {
			enable = true,
			swap_next = {
				["<leader>a"] = "@parameter.inner",
			},
			swap_previous = {
				["<leader>A"] = "@parameter.inner",
			},
		},
	},
})
