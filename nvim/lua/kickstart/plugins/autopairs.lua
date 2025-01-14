-- autopairs
-- https://github.com/windwp/nvim-autopairs

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  -- Optional dependency
  dependencies = { 'hrsh7th/nvim-cmp' },
  config = function()
    require('nvim-autopairs').setup {}
    -- If you want to automatically add `(` after selecting a function or method
    local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
    local cmp = require 'cmp'
    cmp.event:on('confirm_done', function(event)
      local entry = event.entry
      local word = entry:get_insert_text()

      -- Check if the completion is for a React component
      local is_react_component = word:match '^[A-Z]' -- React components typically start with an uppercase letter

      -- Call the default behavior only if not a React component
      if not is_react_component then
        cmp_autopairs.on_confirm_done()(event)
      end
    end)
  end,
}
