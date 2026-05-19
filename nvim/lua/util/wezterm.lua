local M = {}

local function set_user_var(key, value)
  local b64 = vim.base64.encode(tostring(value))
  io.write(string.format('\027]1337;SetUserVar=%s=%s\007', key, b64))
  io.flush()
end

local nav = {
  h = 'Left',
  j = 'Down',
  k = 'Up',
  l = 'Right',
}

local function navigate(dir)
  return function()
    local win = vim.api.nvim_get_current_win()
    vim.cmd.wincmd(dir)
    local pane = vim.env.WEZTERM_PANE
    if vim.system and pane and win == vim.api.nvim_get_current_win() then
      local pane_dir = nav[dir]
      vim.system({ 'wezterm', 'cli', 'activate-pane-direction', pane_dir }, { text = true }, function(p)
        if p.code ~= 0 then
          vim.notify('Failed to move to pane ' .. pane_dir, vim.log.levels.ERROR)
        end
      end)
    end
  end
end

function M.setup()
  set_user_var('IS_NVIM', true)
  -- Clear IS_NVIM when nvim exits so WezTerm stops treating the pane as nvim
  vim.api.nvim_create_autocmd('ExitPre', {
    callback = function() set_user_var('IS_NVIM', false) end,
  })
  for key, dir in pairs(nav) do
    vim.keymap.set('n', '<' .. dir .. '>', navigate(key), { desc = 'Go to ' .. dir .. ' window' })
    vim.keymap.set('n', '<C-' .. key .. '>', navigate(key), { desc = 'Go to ' .. dir .. ' window' })
  end
end

return M
