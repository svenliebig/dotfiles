vim.api.nvim_create_user_command("WatchRun", function()
	local overseer = require("overseer")
	overseer.run_template({ name = "go test script" }, function(task)
		if task then
			task:add_component({ "restart_on_save", paths = { vim.fn.expand("%:p") } })
			local main_win = vim.api.nvim_get_current_win()
			overseer.run_action(task, "open vsplit")
			vim.api.nvim_set_current_win(main_win)
		else
			vim.notify("WatchRun not supported for filetype " .. vim.bo.filetype, vim.log.levels.ERROR)
		end
	end)
end, {})

return {
	name = "go test script",
	builder = function()
		local file = vim.fn.getcwd() -- vim.fn.expand("%:p")
		local cmd = { file }

		if vim.bo.filetype == "go" then
			cmd = { "go", "test", file }
		end

		return {
			cmd = cmd,
			components = {
				{ "on_output_quickfix", set_diagnostics = true },
				"on_result_diagnostics",
				"default",
			},
		}
	end,
	condition = {
		filetype = { "go" },
	},
}
