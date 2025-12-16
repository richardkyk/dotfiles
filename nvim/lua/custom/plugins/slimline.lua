return {
  -- Calls `require('slimline').setup({})`
  'sschleemilch/slimline.nvim',
  event = 'VimEnter',
  config = function()
    require('slimline').setup {
      style = 'bg',
      spaces = {
        components = ' ',
        left = '',
        right = '',
      },
      sep = {
        hide = {
          first = true,
          last = true,
        },
        left = '',
        right = '',
      },
    }
    vim.cmd 'hi Slimline guibg=#313244'
    vim.cmd 'hi SlimlinePrimarySep guibg=#313244'
    vim.cmd 'hi SlimlineSecondarySep guibg=#313244'

    vim.cmd 'hi SlimlinePrimary guibg=#cdd6f4'
    vim.cmd 'hi SlimlineSecondary guibg=#585b70 guifg=#cdd6f4'
  end,
}
