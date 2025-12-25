return {
  'gbprod/substitute.nvim',
  config = function()
    require('substitute').setup {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }

    vim.keymap.set('n', '<leader>r', require('substitute').operator, { noremap = true })
    vim.keymap.set('n', '<leader>rr', require('substitute').line, { noremap = true, desc = '[R]eplace Line' })
    vim.keymap.set('n', '<leader>R', require('substitute').eol, { noremap = true, desc = '[R]eplace to the EOL' })
    vim.keymap.set('x', '<leader>r', require('substitute').visual, { noremap = true, desc = '[R]eplace Selection' })

    require('which-key').add {
      { '<leader>r', group = '[R]eplace', mode = 'n' },
    }
  end,
}
