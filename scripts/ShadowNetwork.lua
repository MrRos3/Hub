-- Shadow Network v1.3.7 exact-source loader for Velora Hub.
-- The source is split only for repository transport. No compression/reconstruction is used.

local BASE = "https://raw.githubusercontent.com/MrRos3/Hub/main/scripts/shadow_network/source/"
local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))
local parts = table.create(8)

for i = 1, 8 do
    local url = BASE .. string.format("%02d.lua.txt?v=%s", i, cache)
    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok or type(body) ~= "string" or body == "" then
        error(("[Shadow Network] Failed to download source chunk %d."):format(i), 0)
    end

    parts[i] = body
end

local source = table.concat(parts)
local chunk, compileError = loadstring(source)

if not chunk then
    error("[Shadow Network] Failed to compile exact source: " .. tostring(compileError), 0)
end

return chunk()
