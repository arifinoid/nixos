local status, lualine = pcall(require, "lualine")

if not status then
    return
end


local toggle = function()
    if vim.g.unhide_lualine == nil then
        vim.g.unhide_lualine = true
    end
    vim.g.unhide_lualine = not vim.g.unhide_lualine
    return vim.g.unhide_lualine
end

lualine.hide({ unhide = toggle() })
