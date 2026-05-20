-- Show absolute line numbers; switch to relativenumber in normal mode of the
-- focused window, and back to absolute when leaving the buffer/window or
-- entering insert mode.
vim.o.number = true
vim.o.relativenumber = true

local group = vim.api.nvim_create_augroup('numbertoggle', { clear = true })

vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave' }, {
  group = group,
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = true
    end
  end,
})

vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter' }, {
  group = group,
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = false
    end
  end,
})

return {}
