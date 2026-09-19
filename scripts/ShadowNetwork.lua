-- Shadow Network v1.3.7 exact-source loader for Velora Hub.
-- The source is split only for repository transport. No compression/reconstruction is used.

local BASE = "https://raw.githubusercontent.com/MrRos3/Hub/main/scripts/shadow_network/source/"
local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))
local names = {
    "01.lua.txt",
    "02.lua.txt",
    "03.lua.txt",
    "04.lua.txt",
    "05.lua.txt",
    "06.lua.txt",
    "07.lua.txt",
    "08a.lua.txt",
    "08b.lua.txt",
}

local parts = table.create(#names)
for i, name in ipairs(names) do
    local url = BASE .. name .. "?v=" .. cache
    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok or type(body) ~= "string" or body == "" then
        error(("[Shadow Network] Failed to download source chunk %s."):format(name), 0)
    end

    parts[i] = body
end

local source = table.concat(parts)
local chunk, compileError = loadstring(source)

if not chunk then
    error("[Shadow Network] Failed to compile exact source: " .. tostring(compileError), 0)
end

return chunk()
