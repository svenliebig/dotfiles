local os = require('os')

local logfile = vim.fn.expand('~/.local/state/nvim/i18n.log')
local loglevel = os.getenv('NVIM_I18N_LOGLEVEL') or 'debug'

local function loglevel_to_number(level)
	if level == 'debug' then
		return 0
	elseif level == 'info' then
		return 1
	elseif level == 'warn' then
		return 2
	elseif level == 'error' then
		return 3
	else
		return 1
	end
end

local loglevel_number = loglevel_to_number(loglevel)

local function should_log(level)
	return loglevel_to_number(level) >= loglevel_number
end

local function log(message)
	local timestamp = os.date('%Y-%m-%d %H:%M:%S')
	local logline = string.format("[%s] %s\n", timestamp, message)

	local file = io.open(logfile, 'a') -- 'a' opens the file for appending
	if file then
		file:write(logline)
		file:close()
	else
		print("Error opening log file")
	end
end

--- Log a debug message
--- @param message string
--- @return nil
local function debug(message)
	if should_log('debug') then
		log(string.format("[DEBUG] %s", message))
	end
end

--- Log a formatted debug message
--- @param message string
--- @param ... any
--- @return nil
local function debugf(message, ...)
	if should_log('debug') then
		debug(string.format(message, ...))
	end
end

--- Log an info message
--- @param message string
--- @return nil
local function info(message)
	if should_log('info') then
		log(string.format("[INFO] %s", message))
	end
end

--- Log a formatted info message
--- @param message string
--- @param ... any
--- @return nil
local function infof(message, ...)
	if should_log('info') then
		info(string.format(message, ...))
	end
end

--- Log a warning message
--- @param message string
--- @return nil
local function warn(message)
	if should_log('warn') then
		log(string.format("[WARN] %s", message))
	end
end

--- Log an error message
--- @param message string
--- @return nil
local function error(message)
	if should_log('error') then
		log(string.format("[ERROR] %s", message))
	end
end

--- Log a formatted error message
--- @param message string
--- @param ... any
--- @return nil
local function errorf(message, ...)
	if should_log('error') then
		error(string.format(message, ...))
	end
end

return {
	log = log,
	debug = debug,
	debugf = debugf,
	info = info,
	infof = infof,
	warn = warn,
	error = error,
	errorf = errorf,
}
