-- Define missing Avante sign to avoid "Unknown sign" error
return function()
  local defined = vim.fn.sign_getdefined("AvanteInputPromptSign")
  if not defined or vim.tbl_isempty(defined) then
    vim.fn.sign_define("AvanteInputPromptSign", { text = ">", texthl = "Comment", numhl = "" })
  end
end


