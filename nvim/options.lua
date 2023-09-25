local o = vim.opt
-- local wo = vim.wo
local bo = vim.bo

o.nu = true
o.relativenumber = true

o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.autoindent = true
o.expandtab = true

o.smartcase = true
o.smartindent = true

o.wrap = false

o.swapfile = false
o.backup = false
o.undodir = os.getenv("HOME") .. "/.vim/undodir"
o.undofile = true

o.hlsearch = false
o.incsearch = true

-- highlights
o.termguicolors = true
o.cursorline = true
o.winblend = 0
o.wildoptions = "pum"
o.pumblend = 5

o.scrolloff = 8
o.signcolumn = "yes"
o.isfname:append("@-@")

o.updatetime = 50
-- o.colorcolumn = "80"

o.shortmess = o.shortmess + "c"
o.hidden = true
o.whichwrap = "b,s,<,>,[,],h,l"
o.pumheight = 8
o.fileencoding = "utf-8"
o.cmdheight = 1
o.splitbelow = true
o.splitright = true
o.conceallevel = 0
o.showtabline = 2
o.showmode = false
o.backup = false
o.writebackup = false
o.timeoutlen = 100
o.clipboard = "unnamedplus"
o.ignorecase = true -- Case insensitive searching UNLESS /C or capital in search
o.sidescrolloff = 5
o.mouse = "a"
o.path:append({ "**" }) -- Finding files - Search down into subfolders
o.formatoptions:append({ "r" })

bo.expandtab = true
bo.shiftwidth = 2
bo.tabstop = 2
bo.autoindent = true
vim.opt.clipboard:append({ "unnamedplus" })
vim.notify = require("notify")
