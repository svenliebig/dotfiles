-- vim.keymap.set('n', '<leader>e', vim.cmd.Ex, { desc = 'Open the file explorer' })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = 'Move the current line down' })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = 'Move the current line up' })

vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = 'Scroll up half and also center the screen' })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = 'Scroll down half and also center the screen' })

vim.keymap.set("n", "<C-o>", "<C-o>zz", { desc = 'Go to last and center the screen.' })
vim.keymap.set("n", "<C-i>", "<C-i>zz", { desc = 'Go to next and center the screen.' })

vim.keymap.set("n", "n", "nzz", { desc = 'Search next and center the screen.' })
vim.keymap.set("n", "N", "Nzz", { desc = 'Search previous and center the screen.' })

vim.keymap.set("n", "<leader>r", require('substitute').operator, { noremap = true })
vim.keymap.set("n", "<leader>rr", require('substitute').line, { noremap = true })
vim.keymap.set("n", "<leader>R", require('substitute').eol, { noremap = true })
vim.keymap.set("x", "<leader>r", require('substitute').visual, { noremap = true })

vim.keymap.set('i', '<C-q>', '<Plug>(copilot-suggest)')
vim.keymap.set('i', '<C-a>', 'copilot#Accept()',
  { noremap = false, silent = true, expr = true, replace_keycodes = false }
)

vim.keymap.set('i', '‘', '<Plug>(copilot-next)')
vim.keymap.set('i', '“', '<Plug>(copilot-previous)')

-- vim.keymap.set('i', '<C-[>', '<Plug>(copilot-previous)')
-- vim.keymap.set('i', '<C-]>', '<Plug>(copilot-next)')

vim.keymap.set('i', '<C-f>', ':Ex<CR>', { desc = 'Open file explorer' })
vim.keymap.set('n', '<C-f>', ':Ex<CR>', { desc = 'Open file explorer' })
vim.keymap.set('v', '<C-f>', ':Ex<CR>', { desc = 'Open file explorer' })

-- substitude current selection in file
vim.keymap.set("v", "<leader>csf", "y:%s/<C-r>0/<C-r>0/gI<Left><Left><Left>",
  { desc = '[C]ode [S]ubstitude selection in [F]ile' })
vim.keymap.set("v", "<leader>csl", "y:s/<C-r>0/<C-r>0/gI<Left><Left><Left>",
  { desc = '[C]ode [S]ubstitude selection in [L]ile' })

-- vim.keymap.set('n', '<leader>rw', '"_dwP', { desc = 'Replace word with register' })
-- vim.keymap.set('n', '<leader>rW', '"_dWP', { desc = 'Replace WORD with register' })
-- vim.keymap.set('n', '<leader>re', '"_deP', { desc = 'Replace until next end of word with register' })
-- vim.keymap.set('n', '<leader>rE', '"_dEP', { desc = 'Replace until next end of WORD with register' })
--
-- vim.keymap.set('n', '<leader>riw', '"_diwP', { desc = 'Replace inner word with register' })
-- vim.keymap.set('n', '<leader>riW', '"_diWP', { desc = 'Replace inner WORD with register' })
-- vim.keymap.set('n', '<leader>ri\'', '"_di\'P', { desc = 'Replace inner \' quoted string with register' })
-- vim.keymap.set('n', '<leader>ra\'', '"_da\'P', { desc = 'Replace outer \' quoted string with register' })
--
-- vim.keymap.set('n', '<leader>ri"', '"_di"P', { desc = 'Replace inner \" quoted string with register' })
-- vim.keymap.set('n', '<leader>ra"', '"_da"P', { desc = 'Replace outer \" quoted string with register' })

-- tes2 tes2
--
