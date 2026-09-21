-- SaltyHub loader: Villa Control
local BASE = "https://raw.githubusercontent.com/MrRos3/Hub/main/scripts/villa-control/"
local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))
local parts = table.create(5)
for i = 1, 5 do
    local name = string.format("%02d.lua.txt", i)
    local ok, body = pcall(function()
        return game:HttpGet(BASE .. name .. "?v=" .. cache)
    end)
    if not ok or type(body) ~= "string" or body == "" then
        error(("[SaltyHub] Failed to load Villa Control chunk %s"):format(name), 0)
    end
    parts[i] = body
end
local source = table.concat(parts)
local chunk, err = loadstring(source)
if not chunk then
    error("[SaltyHub] Villa Control compile failed: " .. tostring(err), 0)
end
return chunk()
