-- vim: tabstop=2 shiftwidth=2 expandtab

local wezterm = require("wezterm")
local config = wezterm.config_builder()
local projects = require("projects")
local act = wezterm.action
local default_keys = wezterm.gui.default_key_tables()

local is_windows = function()
	return wezterm.target_triple:find("windows") ~= nil
end

if is_windows() then
	local wsl_domains = wezterm.default_wsl_domains()

	for _, dom in ipairs(wsl_domains) do
		dom.default_cwd = "~"
	end

	config.wsl_domains = wsl_domains
	config.default_domain = "WSL:Ubuntu"
	config.default_prog = { "wsl.exe" }
end

config.set_environment_variables = {
	PATH = "/opt/homebrew/bin:" .. os.getenv("PATH"),
}

local scheme = "Catppuccin Mocha"
config.color_scheme = scheme
local scheme_def = wezterm.color.get_builtin_schemes()[scheme]
config.colors = {
	background = scheme_def.background,
	tab_bar = {
		background = scheme_def.background,
	},
}

local main_font = wezterm.font_with_fallback({
	{ family = "JetBrains Mono", weight = "Regular" },
	{ family = "JetBrainsMono Nerd Font Mono", weight = "Regular" },
	"codicons",
})

config.window_padding = { bottom = 0, top = 0, left = 0, right = 0 }
config.font = main_font
config.font_size = 12

-- Slightly transparent and blurred background
-- config.window_background_opacity = 0.9
-- config.macos_window_background_blur = 30
-- Removes the title bar, leaving only the tab bar. Keeps
-- the ability to resize by dragging the window's edges.
-- On macOS, 'RESIZE|INTEGRATED_BUTTONS' also looks nice if
-- you want to keep the window controls visible and integrate
-- them into the tab bar.
config.window_decorations = "RESIZE"
-- Sets the font for the window frame (tab bar)
config.window_frame = {
	font = main_font,
	font_size = 12,
}

local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "META" or "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "META" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

local function resize_pane(key, direction)
	return {
		key = key,
		action = wezterm.action.AdjustPaneSize({ direction, 3 }),
	}
end

local function bind_keys_in_nvim(key, mods)
	return function(window, pane)
		local is_nvim = pane:get_foreground_process_name():match(".*/([^/]+)$") == "nvim"

		if not is_nvim then
			return
		end

		window:perform_action({ SendKey = { key = key, mods = mods } }, pane)
	end
end

config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	-- JUMP TO PREVIOUS PROMPT COMMANDS
	{
		key = "UpArrow",
		mods = "SHIFT",
		action = wezterm.action.ScrollToPrompt(-1),
	},
	{
		key = "DownArrow",
		mods = "SHIFT",
		action = wezterm.action.ScrollToPrompt(1),
	},

	{
		key = "LeftArrow",
		mods = "SHIFT",
		action = wezterm.action.SendString("\x1bb"),
	},
	{
		key = "RightArrow",
		mods = "SHIFT",
		action = wezterm.action.SendString("\x1bf"),
	},

	-- JUMP TO START AND END OF LINE
	{
		key = "LeftArrow",
		mods = "SUPER",
		action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
	},
	{
		key = "RightArrow",
		mods = "SUPER",
		action = wezterm.action.SendKey({ key = "e", mods = "CTRL" }),
	},

	{
		key = ",",
		mods = "SUPER",
		action = wezterm.action.SpawnCommandInNewTab({
			cwd = wezterm.home_dir,
			args = { "nvim", wezterm.config_file },
		}),
	},

	{
		key = '"',
		mods = "LEADER|SHIFT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "%",
		mods = "LEADER|SHIFT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},

	{
		key = "a",
		mods = "LEADER|CTRL",
		action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
	},

	{
		key = "r",
		mods = "LEADER",
		action = wezterm.action.ActivateKeyTable({
			name = "resize_panes",
			one_shot = false,
			timeout_milliseconds = 1000,
		}),
	},

	{
		key = "p",
		mods = "LEADER",
		action = projects.choose_project(),
	},
	{
		key = "f",
		mods = "LEADER",
		action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
	},
	{
		key = "c",
		mods = "LEADER",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "x",
		mods = "LEADER",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},

	split_nav("move", "h"),
	split_nav("move", "j"),
	split_nav("move", "k"),
	split_nav("move", "l"),

	-- remapping the jk on osx
	{ key = "j", mods = "CMD", action = wezterm.action_callback(bind_keys_in_nvim("j", "CTRL")) },
	{ key = "k", mods = "CMD", action = wezterm.action_callback(bind_keys_in_nvim("k", "CTRL")) },
}
for i = 1, 8 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = wezterm.action.ActivateTab(i - 1),
	})
end

-- Merges `source` into `target`, with source entries overriding any existing
-- entries in target that share the same key+mods combination.
local function extend_keys(target, source)
	local result = {}
	-- index source overrides by "key|mods" for fast lookup
	local overrides = {}
	for _, binding in ipairs(source) do
		local k = (binding.key or "") .. "|" .. (binding.mods or "NONE")
		overrides[k] = binding
	end
	-- add target entries, skipping any that are overridden
	for _, binding in ipairs(target) do
		local k = (binding.key or "") .. "|" .. (binding.mods or "NONE")
		if not overrides[k] then
			table.insert(result, binding)
		end
	end
	-- append all source entries
	for _, binding in ipairs(source) do
		table.insert(result, binding)
	end
	return result
end

local function close_copy_mode()
	return act.Multiple({
		act.CopyMode("ClearSelectionMode"),
		act.CopyMode("ClearPattern"),
		act.CopyMode("Close"),
	})
end

local function copy_to()
	return act.Multiple({
		act.CopyTo("Clipboard"),
		act.CopyMode("ClearSelectionMode"),
	})
end

local function next_match(int)
	local m = act.CopyMode("NextMatch")
	if int == -1 then
		m = act.CopyMode("PriorMatch")
	end
	-- ClearSelectionMode after moving so n/N don't activate selection
	return act.Multiple({ m, act.CopyMode("ClearSelectionMode") })
end

-- Called when leaving search mode via Enter or Escape.
-- If should_clear is true (Escape), wipes the pattern so it doesn't
-- persist into the next search or cause the terminal to re-trigger searches
-- on new output. Uses a retry loop because ClearSelectionMode doesn't
-- reliably fire immediately after AcceptPattern due to WezTerm state mgmt.
local function complete_search(should_clear)
	return wezterm.action_callback(function(window, pane, _)
		if should_clear then
			window:perform_action(act.CopyMode("ClearPattern"), pane)
		end
		window:perform_action(act.CopyMode("AcceptPattern"), pane)

		for _ = 1, 3, 1 do
			wezterm.sleep_ms(100)
			window:perform_action(act.CopyMode("ClearSelectionMode"), pane)
		end
	end)
end

config.key_tables = {
	resize_panes = {
		resize_pane("j", "Down"),
		resize_pane("k", "Up"),
		resize_pane("h", "Left"),
		resize_pane("l", "Right"),
	},

	copy_mode = extend_keys(default_keys.copy_mode, {
		{ key = "c", mods = "CTRL", action = close_copy_mode() },
		{ key = "q", mods = "NONE", action = close_copy_mode() },
		{ key = "y", mods = "NONE", action = copy_to() },
		{ key = "Escape", mods = "NONE", action = close_copy_mode() },
		-- / to search forward (clears previous pattern)
		{
			key = "/",
			mods = "NONE",
			action = act.Multiple({
				act.CopyMode("ClearPattern"),
				act.Search({ CaseInSensitiveString = "" }),
			}),
		},
		-- ? to search backward (SHIFT+/ on most keyboards)
		{
			key = "?",
			mods = "NONE",
			action = act.Multiple({
				act.CopyMode("ClearPattern"),
				act.Search({ CaseInSensitiveString = "" }),
			}),
		},
		{ key = "p", mods = "CTRL", action = next_match(-1) },
		{ key = "n", mods = "CTRL", action = next_match(1) },
		{ key = "n", mods = "NONE", action = next_match(1) },
		{ key = "N", mods = "SHIFT", action = next_match(-1) },
	}),

	search_mode = extend_keys(default_keys.search_mode, {
		-- Escape cancels search and clears the pattern
		{ key = "Escape", mods = "NONE", action = complete_search(true) },
		-- Enter confirms search and returns to copy mode (no selection)
		{ key = "Enter", mods = "NONE", action = complete_search(false) },
	}),
}

config.tab_bar_at_bottom = true
config.tab_max_width = 32
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false

local function tab_title(tab_info)
	local title = tab_info.tab_title
	if title and #title > 0 then
		return title
	end
	return tab_info.active_pane.title
end

wezterm.on("format-tab-title", function(tab, _tabs, _panes, _config, _hover, _max_width)
	local tab_background = scheme_def.foreground
	local tab_foreground = scheme_def.background

	local title = tab_title(tab)

	local max = config.tab_max_width - 9
	if #title > max then
		title = wezterm.truncate_right(title, max) .. "…"
	end

	if tab.is_active then
		tab_background = scheme_def.tab_bar.active_tab.bg_color
		tab_foreground = scheme_def.tab_bar.active_tab.fg_color
	end

	return {
		{ Background = { Color = tab_background } },
		{ Foreground = { Color = tab_foreground } },
		{ Text = " " .. (tab.tab_index + 1) .. " " },
		{ Background = { Color = scheme_def.background } },
		{ Foreground = { Color = scheme_def.foreground } },
		{ Text = " " .. title .. " " },
	}
end)

return config
