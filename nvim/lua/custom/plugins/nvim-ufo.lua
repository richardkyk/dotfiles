return {
  'kevinhwang91/nvim-ufo',
  dependencies = {
    'kevinhwang91/promise-async',
    {
      'luukvbaal/statuscol.nvim',
      config = function()
        local builtin = require 'statuscol.builtin'
        require('statuscol').setup {
          relculright = true,
          bt_ignore = { 'terminal' },
          segments = {
            { text = { '%s' }, click = 'v:lua.ScSa' },
            { text = { builtin.lnumfunc, ' ' }, click = 'v:lua.ScLa' },
            {
              sign = { namespace = { 'gitsigns' }, colwidth = 1, wrap = true },
              click = 'v:lua.ScSa',
            },
            { text = { builtin.foldfunc }, click = 'v:lua.ScFa' },
            { text = { '  ' } },
          },
        }
      end,
    },
  },
  event = 'BufReadPost',
  opts = {
    provider_selector = function(_, _, buftype)
      -- No folds in terminals: recomputing them on streaming output can peg the CPU
      if buftype == 'terminal' then return '' end
      return { 'treesitter', 'indent' }
    end,
  },
}
