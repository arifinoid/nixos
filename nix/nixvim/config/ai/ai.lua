-- Disable cmp in neorepl buffers
return function()
  require("cmp").setup.buffer { enabled = false }
end


