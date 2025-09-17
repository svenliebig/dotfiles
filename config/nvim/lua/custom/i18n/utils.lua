local log = require('custom.i18n.log')

--- @param bufnr buffer
--- @param ns_id number
--- @param node TSNode
local function highlight(bufnr, ns_id, node)
	local line, start, _, end_ = node:range()
	vim.api.nvim_buf_add_highlight(bufnr, ns_id, 'LspReferenceText', line, start, end_)
	-- log.debugf("used the ns '%s' to highlight", used_ns_id)
end

local function is_table(t)
	return type(t) == 'table'
end

local function merge_tables(t1, t2)
	for k, v in pairs(t2) do
		t1[k] = v
	end
	return t1
end

--- Recursively finds all JSON files in a directory.
--- @param directory string
--- @return table<string, boolean>
local function find_json_files_recursives(directory)
	---@type table<string, boolean>
	local results = {}
	local entries = vim.fn.readdir(directory)

	for _, entry in ipairs(entries) do
		local entry_path = directory .. "/" .. entry

		if vim.fn.isdirectory(entry_path) == 1 then
			results = merge_tables(results, find_json_files_recursives(entry_path))
		end

		if vim.fn.isdirectory(entry_path) == 0 and vim.fn.fnamemodify(entry, ":e") == "json" then
			results[entry_path] = true
		end
	end

	return results
end

--- Finds all JSON files that have been modified since a given timestamp.
--- @param directory string
--- @param last_timestamp number
local function find_new_json_files(directory, last_timestamp)
	local results = {}
	local entries = vim.fn.readdir(directory)

	for _, entry in ipairs(entries) do
		local entry_path = directory .. "/" .. entry

		if vim.fn.isdirectory(entry_path) == 1 then
			results = merge_tables(results, find_new_json_files(entry_path, last_timestamp))
		end

		if vim.fn.isdirectory(entry_path) == 0 and vim.fn.fnamemodify(entry, ":e") == "json" then
			local timestamp = vim.fn.getftime(entry_path)

			log.debugf("entry '%s' has timestamp '%s' (compare to %s)", entry_path, timestamp, last_timestamp)
			if timestamp > last_timestamp then
				results[entry_path] = true
			end
		end
	end

	return results
end

local function _flat_json(json, prefix)
	local result = {}

	for k, v in pairs(json) do
		if is_table(v) then
			result = merge_tables(result, _flat_json(v, prefix .. k .. "."))
		else
			result[prefix .. k] = v
		end
	end

	return result
end

--- Flattens a JSON object of translations.
--- @param json table
local function flat_json(json)
	return _flat_json(json, "")
end

return {
	highlight = highlight,
	is_table = is_table,
	merge_tables = merge_tables,
	flat_json = flat_json,
	find_json_files_recursives = find_json_files_recursives,
	find_new_json_files = find_new_json_files,
}
