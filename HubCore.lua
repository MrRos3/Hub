-- Salty Hub core loader
-- The complete v0-inspired Luau UI source is stored in ordered text chunks.

local BASE = "https://raw.githubusercontent.com/MrRos3/Hub/main/hubcore/source/"
local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))
local names = {
    "01.lua.txt", "02.lua.txt", "03.lua.txt", "04.lua.txt", "05.lua.txt",
    "06.lua.txt", "07.lua.txt", "08.lua.txt", "09.lua.txt", "10.lua.txt",
}

local parts = table.create(#names)
for i, name in ipairs(names) do
    local ok, body = pcall(function()
        return game:HttpGet(BASE .. name .. "?v=" .. cache)
    end)

    if not ok or type(body) ~= "string" or body == "" then
        error(("[Salty Hub] Failed to download UI source chunk %s."):format(name), 0)
    end

    parts[i] = body
end

local source = table.concat(parts)
local chunk, compileError = loadstring(source)
if not chunk then
    error("[Salty Hub] Failed to compile UI: " .. tostring(compileError), 0)
end

return chunk()
