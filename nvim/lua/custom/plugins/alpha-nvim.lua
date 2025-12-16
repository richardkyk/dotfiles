return {
  'goolord/alpha-nvim',
  event = 'VimEnter',
  dependencies = { 'RchrdAriza/nvim-web-devicons' },
  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    local v = vim.version()
    local version = 'v' .. v.major .. '.' .. v.minor .. '.' .. v.patch

    -- Set header
    dashboard.section.header.val = {
      [[███    ██ ███████  ██████  ██    ██ ██ ███    ███]],
      [[████   ██ ██      ██    ██ ██    ██ ██ ████  ████]],
      [[██ ██  ██ █████   ██    ██ ██    ██ ██ ██ ████ ██]],
      [[██  ██ ██ ██      ██    ██  ██  ██  ██ ██  ██  ██]],
      [[██   ████ ███████  ██████    ████   ██ ██      ██]],
    }

    dashboard.section.buttons.val = {
      dashboard.button('n', '   New file', ':ene <BAR> startinsert <CR>'),
      dashboard.button('f', '󰮗   Find file', ':Telescope find_files<CR>'),
      dashboard.button('e', '   File Explorer', ':Neotree<CR>'),
      dashboard.button('r', '   Recent', ':Telescope oldfiles<CR>'),
      dashboard.button('c', '   Configuration', ':e ~/.config/nvim/init.lua<CR>'),
      dashboard.button('l', '   Lazy', ':Lazy<CR>'),
      dashboard.button('g', '   LazyGit', ':LazyGit<CR>'),
      dashboard.button('R', '󱘞   Ripgrep', ':Telescope live_grep<CR>'),
      dashboard.button('q', '󰗼   Quit', ':qa<CR>'),
    }

    local function centerText(text, width)
      local totalPadding = width - #text
      local leftPadding = math.floor(totalPadding / 4)
      return string.rep(' ', leftPadding) .. text
    end

    local quote = '過而不改，是謂過矣。'

    dashboard.section.footer.val = {
      ' ',
      quote,
      centerText(version, #quote),
    }

    dashboard.section.footer.opts = {
      position = 'center',
      hl = 'Comment',
    }

    -- Send config to alpha
    alpha.setup(dashboard.opts)

    -- Disable folding on alpha buffer
    vim.cmd [[autocmd FileType alpha setlocal nofoldenable]]
  end,
}
