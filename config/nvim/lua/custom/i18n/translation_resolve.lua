local utils = require "custom.i18n.utils"
local log = require "custom.i18n.log"

---@class TranslationFile
---@field file_path string
---@field buffer buffer
---@field dirty boolean
local TranslationFile = {}

function TranslationFile:new(file_path, buffer)
	local o = {}

	setmetatable(o, self)
	self.__index = self

	o.file_path = file_path
	o.buffer = buffer

	vim.api.nvim_buf_attach(o.buffer, false, {
		on_lines = function()
			log.debugf("buffer '%s' changed", o.buffer)
			o.dirty = true
		end,
		on_detach = function()
			log.debugf("buffer '%s' detached", o.buffer)
			-- TODO maybe remove buffer ... should be done in add_buffer probably
		end,
	})

	return o
end

function TranslationFile:content()
	local content = vim.api.nvim_buf_get_lines(self.buffer, 0, -1, false)
	return content
end

---@class TranslationFiles
---@field root_path string
---@field buffers table<string, TranslationFile>
---@field dirty boolean if this flag is true, the index needs to be recreated
---@field last_update number timestamp of the last time when the translation files were loaded
---@field translations table<string, string>
local TranslationFiles = {}

function TranslationFiles:new(root_path)
	---@type TranslationFiles
	local o = {
		last_update = 0,
		dirty = false,
		buffers = {},
		root_path = root_path,
		translations = {},
	}

	setmetatable(o, self)
	self.__index = self

	o.root_path = root_path
	o.buffers = {}
	o.dirty = false
	o.translations = {}

	local files = utils.find_json_files_recursives(root_path)

	-- TODO need caching
	-- How do we know if the file has changed?
	for translation_file, _ in pairs(files) do
		o.add(o, translation_file)
	end

	o.last_update = os.time()
	o:create_index()

	return o
end

function TranslationFiles:update()
	for _, file in pairs(self.buffers) do
		if file.dirty then
			self.dirty = true
			file.dirty = false
		end
	end

	local files = utils.find_new_json_files(self.root_path, self.last_update)

	for translation_file, _ in pairs(files) do
		self.dirty = true
		self:add(translation_file)
	end

	self.last_update = os.time()

	if self.dirty then
		self:create_index()
	end
end

function TranslationFiles:create_index()
	log.debugf("creating index for translation")

	self.translations = {}

	for _, file in pairs(self.buffers) do
		local r = vim.fn.json_decode(file:content())
		local translations = utils.flat_json(r)

		for k, v in pairs(translations) do
			self.translations[k] = v
		end
	end

	self.dirty = false
end

---@param key string
---@return string
function TranslationFiles:resolve(key)
	log.debugf("resolving translation key '%s'", key)

	for k, v in pairs(self.translations) do
		-- log.debugf("comparing '%s' with '%s' on '%s'", k, key, v)
		if k == key then
			return v
		end
	end

	return "???"
end

function TranslationFiles:contains(name)
	for v, _ in pairs(self.buffers) do
		if v == name then
			return true
		end
	end

	return false
end

function TranslationFiles:add_buffer(file_path, buf)
	self.buffers[file_path] = TranslationFile:new(file_path, buf)
end

function TranslationFiles:get_buffer(file_path)
	return self.buffers[file_path]
end

function TranslationFiles:get_buffer_content(file_path)
	local buf = self:get_buffer(file_path)
	if not buf then
		return nil
	end

	return vim.api.nvim_buf_get_lines(buf.buffer, 0, -1, false)
end

function TranslationFiles:add(file_path)
	if self:contains(file_path) then
		log.debugf("translation file '%s' already exists", file_path)
		return
	end

	log.debugf("adding translation file '%s'", file_path)

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(buf) == file_path then
			if vim.api.nvim_buf_is_loaded(buf) then
				log.debugf("buffer for file '%s' already exists and is loaded", file_path)
			else
				log.debugf("buffer for file '%s' already exists and is not loaded", file_path)
				vim.fn.bufload(buf)
			end

			self:add_buffer(file_path, buf)
			self.dirty = true
			return
		end
	end

	if vim.fn.filereadable(file_path) == 0 then
		log.errorf("file '%s' does not exist", file_path)
		return
	end

	local buf = vim.fn.bufadd(file_path)
	vim.fn.bufload(buf)

	self:add_buffer(file_path, buf)
	self.dirty = true
end

---@type TranslationFiles
local instance = nil

local get_translation_files = function()
	if instance == nil then
		local project_root = vim.fn.getcwd()
		local translations_root = project_root .. "/src/locales"
		instance = TranslationFiles:new(translations_root)
	else
		log.debugf("translation files already found")
		instance:update()
	end

	return instance
end

---Resolves a translation key to a translation string.
---@param key string
---@return string
local function resolve_translation(key)
	local files = get_translation_files()
	return files:resolve(key)
end

return {
	get_translation_files = get_translation_files,
	resolve_translation = resolve_translation,
}
