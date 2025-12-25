vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move the current line down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move the current line up' })

vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up half and also center the screen' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down half and also center the screen' })

vim.keymap.set('n', '<C-o>', '<C-o>zz', { desc = 'Go to last and center the screen.' })
vim.keymap.set('n', '<C-i>', '<C-i>zz', { desc = 'Go to next and center the screen.' })

-- substitude current selection in file
vim.keymap.set('v', '<leader>csf', 'y:%s/<C-r>0/<C-r>0/gI<Left><Left><Left>', { desc = '[C]ode [S]ubstitude selection in [F]ile' })
vim.keymap.set('v', '<leader>csl', 'y:s/<C-r>0/<C-r>0/gI<Left><Left><Left>', { desc = '[C]ode [S]ubstitude selection in [L]ile' })

require('which-key').add({
  { '<leader>c', group = '[C]ode', mode = 'v' },
  { '<leader>cs', group = '[C]ode [S]ubstitude', mode = 'v' },
}, { mode = 'v' })

return {}
