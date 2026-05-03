return {
  'nvim-treesitter/nvim-treesitter-context',
  event = 'BufReadPost',
  opts = {
    mode = 'topline',
    max_lines = 3,
  },
}
