-- Salty Hub bootstrap
-- Latest UI and script library are loaded from HubCore.lua.

local URL = "https://raw.githubusercontent.com/MrRos3/Hub/main/HubCore.lua"
local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))

local ok, source = pcall(function()
    return game:HttpGet(URL .. "?v=" .. cache)
end)

if not ok or type(source) ~= "string" or source == "" then
    error("[Salty Hub] Failed to download HubCore.lua", 0)
end

local chunk, compileError = loadstring(source)
if not chunk then
    error("[Salty Hub] Failed to compile HubCore.lua: " .. tostring(compileError), 0)
end

return chunk()
