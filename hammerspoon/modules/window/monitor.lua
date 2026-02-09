local monitor = {}
local utils = require("modules.window.utils")

-- Helper to sort by direction
local function compareScreens(a, b, direction)
    local af = a:frame()
    local bf = b:frame()

    if direction == utils.Direction.LEFT then
        return af.x > bf.x
    elseif direction == utils.Direction.RIGHT then
        return af.x < bf.x
    elseif direction == utils.Direction.UPPER then
        return af.y > bf.y
    elseif direction == utils.Direction.LOWER then
        return af.y < bf.y
    end

    return false
end

-- Flash the mouse cursor to get attention
local function flashMouse()
    local pos = hs.mouse.absolutePosition()
    local offset = 15

    -- Flash with movement
    for i = 1, 2 do
        hs.mouse.absolutePosition({x = pos.x + offset, y = pos.y})
        hs.timer.usleep(100000) -- 0.1 seconds

        hs.mouse.absolutePosition({x = pos.x - offset, y = pos.y})
        hs.timer.usleep(100000) -- 0.1 seconds
    end

    -- Return to original position
    hs.mouse.absolutePosition(pos)
end

-- Move current window to the monitor in the given direction
function monitor.To(direction)
    local win = hs.window.focusedWindow()
    if not win then
        hs.alert("No focused window")
        return
    end

    local currentScreen = win:screen()
    local currentFrame = currentScreen:frame()

    local targetScreens = {}

    for _, screen in ipairs(hs.screen.allScreens()) do
        if screen:id() ~= currentScreen:id() then
            local frame = screen:frame()

            if direction == utils.Direction.LEFT and frame.x + frame.w <= currentFrame.x then
                table.insert(targetScreens, screen)
            elseif direction == utils.Direction.RIGHT and frame.x >= currentFrame.x + currentFrame.w then
                table.insert(targetScreens, screen)
            elseif direction == utils.Direction.UPPER and frame.y + frame.h <= currentFrame.y then
                table.insert(targetScreens, screen)
            elseif direction == utils.Direction.LOWER and frame.y >= currentFrame.y + currentFrame.h then
                table.insert(targetScreens, screen)
            end
        end
    end

    local targetScreen

    if #targetScreens > 0 then
        table.sort(targetScreens, function(a, b)
            return compareScreens(a, b, direction)
        end)
        targetScreen = targetScreens[1]
    else
        -- Round robin fallback
        local all = hs.screen.allScreens()
        table.sort(all, function(a, b)
            return compareScreens(a, b, direction)
        end)

        -- Find index of current screen
        local idx = hs.fnutils.indexOf(all, currentScreen)
        local nextIdx = idx % #all + 1 -- wrap around
        targetScreen = all[nextIdx]
    end

    -- Move the window to the target screen, maintaining relative position and size
    local targetFrame = targetScreen:frame()
    local winFrame = win:frame()

    local relativeX = (winFrame.x - currentFrame.x) / currentFrame.w
    local relativeY = (winFrame.y - currentFrame.y) / currentFrame.h
    local relativeW = winFrame.w / currentFrame.w
    local relativeH = winFrame.h / currentFrame.h

    win:setFrame({
        x = targetFrame.x + targetFrame.w * relativeX,
        y = targetFrame.y + targetFrame.h * relativeY,
        w = targetFrame.w * relativeW,
        h = targetFrame.h * relativeH
    })
end

-- Cycle current window through monitors (left = previous, right = next)
function monitor.Cycle(direction)
    local win = hs.window.focusedWindow()
    if not win then
        hs.alert("No focused window")
        return
    end

    local currentScreen = win:screen()
    local currentScreenIdx = nil
    local allScreens = hs.screen.allScreens()

    for idx, screen in ipairs(allScreens) do
        if screen:id() == currentScreen:id() then
            currentScreenIdx = idx
            break
        end
    end

    if not currentScreenIdx then
        hs.alert("Could not determine current screen")
        return
    end

    local nextScreenIdx
    local screenCount = #allScreens

    if direction == utils.Direction.LEFT then
        -- Go to next monitor (wrap around)
        nextScreenIdx = (currentScreenIdx % screenCount) + 1
    elseif direction == utils.Direction.RIGHT then
        -- Go to previous monitor (wrap around)
        nextScreenIdx = ((currentScreenIdx - 2) % screenCount) + 1
    else
        hs.alert("Invalid direction. Use LEFT or RIGHT.")
        return
    end

    local targetScreen = allScreens[nextScreenIdx]
    local targetFrame = targetScreen:frame()
    local currentFrame = currentScreen:frame()
    local winFrame = win:frame()

    -- Maintain relative position and size when moving to target screen
    local relativeX = (winFrame.x - currentFrame.x) / currentFrame.w
    local relativeY = (winFrame.y - currentFrame.y) / currentFrame.h
    local relativeW = winFrame.w / currentFrame.w
    local relativeH = winFrame.h / currentFrame.h

    win:setFrame({
        x = targetFrame.x + targetFrame.w * relativeX,
        y = targetFrame.y + targetFrame.h * relativeY,
        w = targetFrame.w * relativeW,
        h = targetFrame.h * relativeH
    })
end

-- Move mouse cursor to the monitor in the given direction
function monitor.MoveMouse(direction)
    local mousePos = hs.mouse.absolutePosition()

    -- Find the screen containing the mouse cursor
    local currentScreen = nil
    for _, screen in ipairs(hs.screen.allScreens()) do
        local frame = screen:frame()
        if mousePos.x >= frame.x and mousePos.x < frame.x + frame.w and
           mousePos.y >= frame.y and mousePos.y < frame.y + frame.h then
            currentScreen = screen
            break
        end
    end

    if not currentScreen then
        hs.alert("Could not determine current screen")
        return
    end

    local currentFrame = currentScreen:frame()
    local targetScreens = {}

    for _, screen in ipairs(hs.screen.allScreens()) do
        if screen:id() ~= currentScreen:id() then
            local frame = screen:frame()

            if direction == utils.Direction.LEFT and frame.x + frame.w <= currentFrame.x then
                table.insert(targetScreens, screen)
            elseif direction == utils.Direction.RIGHT and frame.x >= currentFrame.x + currentFrame.w then
                table.insert(targetScreens, screen)
            elseif direction == utils.Direction.UPPER and frame.y + frame.h <= currentFrame.y then
                table.insert(targetScreens, screen)
            elseif direction == utils.Direction.LOWER and frame.y >= currentFrame.y + currentFrame.h then
                table.insert(targetScreens, screen)
            end
        end
    end

    local targetScreen

    if #targetScreens > 0 then
        table.sort(targetScreens, function(a, b)
            return compareScreens(a, b, direction)
        end)
        targetScreen = targetScreens[1]
    else
        -- Round robin fallback
        local all = hs.screen.allScreens()
        table.sort(all, function(a, b)
            return compareScreens(a, b, direction)
        end)

        -- Find index of current screen
        local idx = hs.fnutils.indexOf(all, currentScreen)
        local nextIdx = idx % #all + 1 -- wrap around
        targetScreen = all[nextIdx]
    end

    -- Move mouse to the center of the target screen
    local targetFrame = targetScreen:frame()
    local newMousePos = {
        x = targetFrame.x + targetFrame.w / 2,
        y = targetFrame.y + targetFrame.h / 2
    }

    hs.mouse.absolutePosition(newMousePos)
end

-- Cycle mouse cursor through monitors (left = previous, right = next)
function monitor.CycleMouse(direction)
    local mousePos = hs.mouse.absolutePosition()

    -- Find the screen containing the mouse cursor
    local currentScreen = nil
    local currentScreenIdx = nil
    local allScreens = hs.screen.allScreens()

    for idx, screen in ipairs(allScreens) do
        local frame = screen:frame()
        if mousePos.x >= frame.x and mousePos.x < frame.x + frame.w and
           mousePos.y >= frame.y and mousePos.y < frame.y + frame.h then
            currentScreen = screen
            currentScreenIdx = idx
            break
        end
    end

    if not currentScreen or not currentScreenIdx then
        hs.alert("Could not determine current screen")
        return
    end

    local nextScreenIdx
    local screenCount = #allScreens

    if direction == utils.Direction.LEFT then
        -- Go to next monitor (wrap around)
        nextScreenIdx = (currentScreenIdx % screenCount) + 1
    elseif direction == utils.Direction.RIGHT then
        -- Go to previous monitor (wrap around)
        nextScreenIdx = ((currentScreenIdx - 2) % screenCount) + 1
    else
        hs.alert("Invalid direction. Use LEFT or RIGHT.")
        return
    end

    local targetScreen = allScreens[nextScreenIdx]
    local targetFrame = targetScreen:frame()

    -- Move mouse to the center of the target screen
    local newMousePos = {
        x = targetFrame.x + targetFrame.w / 2,
        y = targetFrame.y + targetFrame.h / 2
    }

    hs.mouse.absolutePosition(newMousePos)
end

return monitor
