return { -- You can easily change to a different colorscheme.
  -- Change the name of the colorscheme plugin below, and then
  -- change the command in the config to whatever the name of that colorscheme is.
  --
  -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000, -- Make sure to load this before all the other start plugins.
  config = function()
    require('catppuccin').setup {
      flavour = 'mocha',
      integrations = {
        blink_cmp = true,
      },
      custom_highlights = function(colors)
        return {
          -- Blink
          BlinkCmpMenu = { bg = colors.base },
          BlinkCmpMenuBorder = { bg = colors.base, fg = colors.blue },
          BlinkCmpDoc = { bg = colors.base },
          BlinkCmpDocBorder = { bg = colors.base, fg = colors.blue },
        }
      end,
    }
    -- setup must be called before loading
    vim.cmd.colorscheme 'catppuccin'
  end,
}
