-- vim: tabstop=2 shiftwidth=2 expandtab

-- We almost always start by importing the wezterm module
local wezterm = require 'wezterm'
-- Define a lua table to hold _our_ module's functions
local module = {}

-- Returns a bool based on whether the host operating system's
-- appearance is light or dark.
function module.is_dark()
  -- wezterm.gui is not always available, depending on what
  -- environment wezterm is operating in. Just return true
  -- if it's not defined.
  return true
end

return module