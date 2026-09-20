-- Cure loader for SaltyHub
local BASE = "https://raw.githubusercontent.com/MrRos3/Hub/main/scripts/cure/"
local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))
local names = {"01.lua.txt", "02.lua.txt", "03.lua.txt", "04.lua.txt"}
local parts = table.create(#names)
for i, name in ipairs(names) do
    local ok, body = pcall(function()
        return game:HttpGet(BASE .. name .. "?v=" .. cache)
    end)
    if not ok or type(body) ~= "string" or body == "" then
        error(("[SaltyHub] Failed to download Cure chunk %s"):format(name), 0)
    end
    parts[i] = body
end
local source = table.concat(parts)
local chunk, err = loadstring(source)
if not chunk then
    error("[SaltyHub] Cure compile failed: " .. tostring(err), 0)
end
return chunk()
