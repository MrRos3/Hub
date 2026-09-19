-- Velora Hub bootstrap
-- Keeps the approved Hub v7 core intact and injects additional real scripts.

local CORE_URL = "https://raw.githubusercontent.com/MrRos3/Hub/main/HubCore.lua"
local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))

local ok, source = pcall(function()
    return game:HttpGet(CORE_URL .. "?v=" .. cache)
end)

if not ok or type(source) ~= "string" or source == "" then
    error("[Velora Hub] Failed to download HubCore.lua", 0)
end

local marker = "\n}\n\nlocal function getGuiParent()"
local insertAt = string.find(source, marker, 1, true)
if not insertAt then
    error("[Velora Hub] Could not locate script library in HubCore.lua", 0)
end

local extraEntries = [=[
    {
        Id = "alzzmys-dances",
        Name = "Alzzmy's DANCES",
        Description = "Salty VantaUI AutoPlayer • Internal tryHit Edition",
        Tags = { "dances", "autoplayer", "music", "tryhit", "performance" },
        Url = "https://raw.githubusercontent.com/MrRos3/Hub/main/scripts/Dances.lua",
    },
]=]

source = source:sub(1, insertAt - 1) .. "\n" .. extraEntries .. source:sub(insertAt)

local chunk, compileError = loadstring(source)
if not chunk then
    error("[Velora Hub] Failed to compile HubCore: " .. tostring(compileError), 0)
end

return chunk()
