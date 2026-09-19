-- Salty MM2 v1.1 exact-source loader for Velora Hub.
-- The original source is split into plain-text chunks only for repository transport.

local BASE = "https://raw.githubusercontent.com/MrRos3/Hub/main/scripts/mm2/source/"
local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))

local names = {
    "01.lua.txt", "02.lua.txt", "03.lua.txt", "04.lua.txt",
    "05.lua.txt", "06.lua.txt", "07.lua.txt", "08.lua.txt",
    "09.lua.txt", "10.lua.txt", "11.lua.txt", "12.lua.txt",
    "13.lua.txt", "14.lua.txt", "15.lua.txt", "16.lua.txt",
}

local parts = table.create(#names)
for i, name in ipairs(names) do
    local ok, body = pcall(function()
        return game:HttpGet(BASE .. name .. "?v=" .. cache)
    end)

    if not ok or type(body) ~= "string" or body == "" then
        error(("[Salty MM2] Failed to download source chunk %s."):format(name), 0)
    end

    parts[i] = body
end

local source = table.concat(parts)
local chunk, compileError = loadstring(source)

if not chunk then
    error("[Salty MM2] Failed to compile exact source: " .. tostring(compileError), 0)
end

return chunk()
