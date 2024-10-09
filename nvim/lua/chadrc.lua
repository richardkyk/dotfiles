local M = {}

M.base46 = {
  theme = 'Catppuccin',
}

M.ui = {
  statusline = { enabled = false },
  cmp = {
    style = 'atom',
    format_colors = {
      tailwind = true, -- will work for css lsp too
      icon = '󱓻',
    },
  },
  tabufline = {
    enabled = false,
  },
}

return M
