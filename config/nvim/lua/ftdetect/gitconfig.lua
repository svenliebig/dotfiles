vim.api.nvim_create_autocmd('BufRead', {
	group = vim.api.nvim_create_augroup('detect_gitconfig', { clear = true }),
	pattern = { '*.gitconfig*' }, -- Adjust the pattern to match your custom file extension
	callback = function()
		vim.cmd('set filetype=gitconfig')
	end,
})
