-- ~/.hammerspoon/init.lua
-- Automatic audio output switching.
--
-- Priority, highest first:
--   1. Headphones (AirPods, HyperX) — if connected, nothing else steals audio
--   2. Proxy Audio Device — only when one of the known monitors is attached
--   3. MacBook Pro Speakers
--
-- Note: "Proxy Audio Device" is a virtual device and is ALWAYS present in the
-- device list, whether or not the monitor is plugged in. So we never test for
-- the proxy itself — we test for the monitor and route to the proxy.

--------------------------------------------------------------------------------
-- Config
--------------------------------------------------------------------------------

local PROXY = "Proxy Audio Device"
local FALLBACK = "MacBook Pro Speakers"

-- Monitors whose presence means "route audio through the proxy". Exact device
-- names as they appear in the output list — check with `system_profiler
-- SPAudioDataType` if you add another. Order is irrelevant; only one of these
-- is ever plugged in at a time.
local MONITORS = {
	"DELL U2724DE", -- home
	"LG ULTRAFINE", -- office
}

-- Proxy Audio Device forwards audio to whichever real device it's configured
-- with in its own Settings app — that target is a separate, persisted
-- setting the OS output-device switch below has no effect on. This compiled
-- helper (see bin/proxy-set-output.swift) sets it the same way the Settings
-- app does, so the proxy always points at whichever monitor we just detected.
local PROXY_SET_OUTPUT = os.getenv("HOME") .. "/.hammerspoon/bin/proxy-set-output"

-- Lowercase substrings. Any output device matching one of these is treated as
-- headphones and wins over everything else.
--
-- Only put devices here whose *presence* means you're actually using them.
-- AirPods qualify: they leave the device list when you take them out. The
-- HyperX deliberately does NOT — its receiver lives in the KVM and advertises
-- itself whenever it has power, headset on your head or not. Select that one
-- by hand; manual choices stick until the next dock/undock.
local HEADPHONES = { "airpods" }

-- Seconds to wait after a device event before acting. Docking registers devices
-- in stages; acting immediately tends to catch a half-built device list.
local SETTLE = 1.5

-- Set to false to silence the banner on each switch.
local NOTIFY = true

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local function outputs()
	return hs.audiodevice.allOutputDevices() or {}
end

local function byExactName(target)
	for _, dev in ipairs(outputs()) do
		if dev:name() == target then
			return dev
		end
	end
	return nil
end

local function findHeadphones()
	for _, dev in ipairs(outputs()) do
		local name = (dev:name() or ""):lower()
		for _, pattern in ipairs(HEADPHONES) do
			if name:find(pattern, 1, true) then
				return dev
			end
		end
	end
	return nil
end

-- Name of the first known monitor currently attached, or nil.
local function findMonitor()
	for _, name in ipairs(MONITORS) do
		if byExactName(name) then
			return name
		end
	end
	return nil
end

-- Point Proxy Audio Device's internal target at `monitor`. Safe to call even
-- when it's already pointed there — the helper just rewrites the same
-- setting the GUI app would.
local function configureProxyTarget(monitor)
	local quoted = "'" .. monitor:gsub("'", "'\\''") .. "'"
	local output, ok = hs.execute(string.format("%q %s 2>&1", PROXY_SET_OUTPUT, quoted), true)
	if not ok then
		print(string.format("[audio] failed to point proxy at %s: %s", monitor, (output or ""):gsub("%s+$", "")))
	end
end

-- Which device *should* be active right now. Third return value is the
-- monitor name when the proxy path is chosen, nil otherwise.
local function desiredOutput()
	local headphones = findHeadphones()
	if headphones then
		return headphones, "headphones connected"
	end

	local monitor = findMonitor()
	if monitor then
		local proxy = byExactName(PROXY)
		if proxy then
			return proxy, monitor .. " docked", monitor
		end
	end

	return byExactName(FALLBACK), "no external output"
end

--------------------------------------------------------------------------------
-- Apply
--------------------------------------------------------------------------------

local function applyOutput()
	local target, reason, monitor = desiredOutput()
	if not target then
		print("[audio] no suitable output device found")
		return
	end

	-- Repoint the proxy whenever a known monitor is present, even if macOS's
	-- default output device is about to turn out unchanged below — that
	-- check only covers which *device* is selected, not what the proxy
	-- forwards to, and those can go stale independently (e.g. switching
	-- monitors without ever leaving "Proxy Audio Device" selected).
	if monitor then
		configureProxyTarget(monitor)
	end

	local current = hs.audiodevice.defaultOutputDevice()
	if current and current:name() == target:name() then
		return -- already correct; don't thrash
	end

	target:setDefaultOutputDevice()
	print(string.format("[audio] -> %s (%s)", target:name(), reason))

	if NOTIFY then
		hs.notify.show("Audio output", target:name(), reason)
	end
end

--------------------------------------------------------------------------------
-- Watcher
--------------------------------------------------------------------------------

local pending = nil

local function scheduleApply()
	if pending then
		pending:stop()
	end
	pending = hs.timer.doAfter(SETTLE, function()
		pending = nil
		applyOutput()
	end)
end

hs.audiodevice.watcher.setCallback(function(event)
	-- "dev#" = the set of available devices changed (dock, undock, BT connect).
	-- We deliberately ignore "dOut" so that manually picking a device in
	-- Control Center doesn't immediately get overridden.
	if event == "dev#" then
		scheduleApply()
	end
end)

hs.audiodevice.watcher.start()

--------------------------------------------------------------------------------
-- Manual trigger + config auto-reload
--------------------------------------------------------------------------------

-- Cmd-Alt-Ctrl-A forces a re-evaluation, e.g. after manually overriding.
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "A", applyOutput)

-- Hyper-O (Caps Lock via Karabiner = Cmd-Ctrl-Shift) opens a searchable
-- output picker with the current device marked. A pick here is a manual
-- choice, so it sticks until the next dock/undock like any other.
local picker = hs.chooser.new(function(choice)
	if not choice then
		return
	end
	local dev = hs.audiodevice.findDeviceByUID(choice.uid)
	if dev and dev:setDefaultOutputDevice() then
		print(string.format("[audio] -> %s (picked)", dev:name()))
	end
end)

hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "O", function()
	local current = hs.audiodevice.defaultOutputDevice()
	local currentUID = current and current:uid()
	local choices = {}
	for _, dev in ipairs(outputs()) do
		local isCurrent = dev:uid() == currentUID
		table.insert(choices, {
			text = (isCurrent and "✓ " or "    ") .. dev:name(),
			subText = isCurrent and "Current output" or nil,
			uid = dev:uid(),
		})
	end
	picker:choices(choices)
	picker:show()
end)

hs.pathwatcher
	.new(os.getenv("HOME") .. "/.hammerspoon/", function(files)
		for _, file in ipairs(files) do
			if file:sub(-4) == ".lua" then
				hs.reload()
				return
			end
		end
	end)
	:start()

-- Evaluate once at startup so a launch mid-dock lands in the right place.
applyOutput()

hs.notify.show("Hammerspoon", "Audio switcher loaded", "")
