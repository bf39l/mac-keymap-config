-- print("Loading modules...")  -- Debugging print statement
local winResize = require("modules.window.resize")
local monitor = require("modules.window.monitor")
local winUtils = require("modules.window.utils")
local apps = require("modules.applications.apps")

-- Define Hotkeys
-- ### window management ###
-- hs.window.animationDuration = 0.1 → almost instant but still smooth
-- hs.window.animationDuration = 0.25 → default animation speed
-- hs.window.animationDuration = 0 → no animation (snaps instantly)
hs.window.animationDuration = 0.03
hs.hotkey.bind({"ctrl", "alt", "shift"}, "left", function()
    winResize.toHalf(winUtils.Direction.LEFT)
end)

hs.hotkey.bind({"ctrl", "alt", "shift"}, "right", function()
    winResize.toHalf(winUtils.Direction.RIGHT)
end)

hs.hotkey.bind({"ctrl", "alt", "shift"}, "up", function()
    winResize.toHalf(winUtils.Direction.UPPER)
end)

hs.hotkey.bind({"ctrl", "alt", "shift"}, "down", function()
    winResize.toHalf(winUtils.Direction.LOWER)
end)

hs.hotkey.bind({"ctrl", "alt", "shift"}, "return", function()
    local win = hs.window.frontmostWindow()
    if win then
        winResize.toggleMax(win)
    end
end)

hs.hotkey.bind({"ctrl", "alt", "shift"}, "=", function()
    winResize.by(30)
end)

hs.hotkey.bind({"ctrl", "alt", "shift"}, "-", function()
    winResize.by(-30, 430, 400, 10)
end)

hs.hotkey.bind({"ctrl", "alt", "shift"}, "[", function()
    winMonitor.Cycle(winUtils.Direction.LEFT)
end)

hs.hotkey.bind({"ctrl", "alt", "shift"}, "]", function()
    winMonitor.Cycle(winUtils.Direction.RIGHT)
end)

hs.hotkey.bind({"ctrl", "alt"}, "[", function()
    winMonitor.CycleMouse(winUtils.Direction.LEFT)
end)

hs.hotkey.bind({"ctrl", "alt"}, "]", function()
    winMonitor.CycleMouse(winUtils.Direction.RIGHT)
end)

-- hs.hotkey.bind({"ctrl", "alt", "shift"}, "[", function()
--     winMonitor.To(winUtils.Direction.LEFT)
-- end)

-- hs.hotkey.bind({"ctrl", "alt", "shift"}, "]", function()
--     winMonitor.To(winUtils.Direction.RIGHT)
-- end)

-- hs.hotkey.bind({"ctrl", "alt"}, "[", function()
--     winMonitor.MoveMouse(winUtils.Direction.LEFT)
-- end)

-- hs.hotkey.bind({"ctrl", "alt"}, "]", function()
--     winMonitor.MoveMouse(winUtils.Direction.RIGHT)
-- end)

--- ### Simulate typing text ###
hs.hotkey.bind({"ctrl", "alt"}, "V", function()
    hs.eventtap.keyStrokes("hello world")
end)

--- ### applications management ###
hs.application.enableSpotlightForNameSearches(true)
hs.hotkey.bind({"ctrl", "alt", "shift"}, "t", function()
    apps.launchOrFocus("/Applications/iTerm.app")
end)

hs.hotkey.bind({"ctrl", "alt", "shift"}, "b", function()
    apps.launchOrFocus("/Applications/Firefox.app")
end)