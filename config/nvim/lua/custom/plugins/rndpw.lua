-- :rndpw inserts a random password (default length 16) at the cursor
do
  local function gen_password(len)
    local charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%&*_-+?'
    local out = {}

    -- Prefer /dev/urandom (strong randomness)
    local ok = pcall(function()
      local f = assert(io.open('/dev/urandom', 'rb'))
      local bytes = f:read(len)
      f:close()
      assert(bytes and #bytes == len)

      for i = 1, len do
        local b = bytes:byte(i)
        local idx = (b % #charset) + 1
        out[i] = charset:sub(idx, idx)
      end
    end)

    if not ok then
      -- Fallback (not crypto-strong)
      math.randomseed(vim.loop.hrtime())
      for i = 1, len do
        local idx = math.random(1, #charset)
        out[i] = charset:sub(idx, idx)
      end
    end

    return table.concat(out)
  end

  local function insert_text_at_cursor(text)
    -- If we're in Insert/Replace mode, "type" the text
    local mode = vim.api.nvim_get_mode().mode
    if mode:match '^[iR]' then
      vim.api.nvim_put({ text }, 'c', true, true)
      return
    end

    -- Normal/Visual/etc: insert at cursor position without entering insert mode
    local row, col = unpack(vim.api.nvim_win_get_cursor(0)) -- row is 1-based
    local line = vim.api.nvim_get_current_line()
    local before = line:sub(1, col)
    local after = line:sub(col + 1)
    vim.api.nvim_set_current_line(before .. text .. after)
    vim.api.nvim_win_set_cursor(0, { row, col + #text })
  end

  vim.api.nvim_create_user_command('RndPw', function(opts)
    local len = tonumber(opts.args) or 16
    if len < 1 then
      vim.notify('Password length must be >= 1', vim.log.levels.ERROR)
      return
    end
    insert_text_at_cursor(gen_password(len))
  end, { nargs = '?', desc = 'Insert random password at cursor (default length 16)' })
end

return {}
