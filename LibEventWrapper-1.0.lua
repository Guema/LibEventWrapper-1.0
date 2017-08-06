
-- Declaring used globals as local.

local LibStub = LibStub
local CreateFrame = CreateFrame
local pairs = pairs

-- Creating lib

local MAJOR, MINOR = "LibEventWrapper-1.0", 1
local Library = LibStub:NewLibrary(MAJOR, MINOR)

if not Library then return end -- If exists and doesn't require update, do nothing

local methods = {"CreateWrappedFrame"}

function Library:WrapFrame(frame) 
    if(type(frame) ~= "table" and type(frame.GetFrameType) ~= "function") then
        error("Usage : " .. MAJOR .. ":WrapFrame(frame) : Wrong type for argument 'frame'", 2)
    end
    local base = getmetatable(frame).__index or {}
    local callbacks = {}

    local function fire(self, event, ...)
        callbacks[event](self, event, ...)
    end

    frame:HookScript("OnEvent", fire)

    hooksecurefunc(frame, "SetScript", function(tb, handler)
        if handler == "OnEvent" then 
            tb:HookScript("OnEvent", fire)
        end
    end)

    function frame:UnregisterAllEvents()
        base.UnregisterAllEvents(self)
        callbacks = {}
    end

    function frame:UnregisterEvent(event)
        base.UnregisterEvent(self, event)
        callbacks[event] = nil
    end

    function frame:RegisterEvent(event, callback)
        if(base.IsEventRegistered(self, event)) then return end
        if (type(callback) ~= "function") then
            error("Usage: RegisterEvent(event, callback): incorrect argument(s) type(s)", 2)
        end
        base.RegisterEvent(self, event)
        if(base.IsEventRegistered(self, event)) then 
            callbacks[event] = callback 
        else
            error("Usage: RegisterEvent(event, callback): Event could not be registered. Please check event name", 2)
        end
    end

    function frame:RegisterUnitEvent(event, unit, unit2, callback)
        if(base.IsEventRegistered(self, event)) then return end
        if(type(callback) ~= "function") then
            if(type(unit2) ~= "function") then
                error("Usage: RegisterEvent(event, unit[, unit2], callback): incorrect argument(s) type(s)", 2)
            else
                callback = unit2
                unit2 = nil
            end
        end 
        base.RegisterUnitEvent(self, event, unit, unit2)
        if(base.IsEventRegistered(self, event)) then 
            callbacks[event] = callback 
        else
            error("Usage: RegisterEvent(event, unit[, unit2], callback): Event could not be registered. Please check event name", 2)
        end
    end

    return frame
end

function Library:CreateWrappedFrame(frametype, framename, frameparent, ...)
    return Library:WrapFrame(CreateFrame(frametype, framename, frameparent, ...))
end

function Library:Embed(addon)
    for k in #methods do
        addon[k] = self[methods[k]]
    end
end