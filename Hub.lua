-- SaltyHub bootstrap wrapper
-- Loads the last full Hub bootstrap from an immutable commit, then injects the latest Villa Control image-cache fix.

local BASE_HUB = "https://raw.githubusercontent.com/MrRos3/Hub/9d703784570d597222c57fbcd6dd166a185c6ef6/Hub.lua"
local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))

local ok, source = pcall(function()
    return game:HttpGet(BASE_HUB .. "?v=" .. cache)
end)

if not ok or type(source) ~= "string" or source == "" then
    error("[SaltyHub] Failed to download base Hub bootstrap.", 0)
end

local anchor = "-- Once terminated, global input/viewport hooks become inert instead of touching destroyed UI."
local insertAt = string.find(source, anchor, 1, true)
if not insertAt then
    error("[SaltyHub] Villa image patch anchor was not found.", 0)
end

local villaImageFix = [=[
-- Villa Control image refresh: use the exact same JPEG encoding/cache path as Stop the Timer.
replacePlain(
[==[        ImageUrl = BASE_RAW .. "assets/cards/villa-control-v1.jpg?v=villa-control-v1",
        ImageCache = "card_villa_control_v1.jpg",]==],
[==[        ImageUrl = BASE_RAW .. "assets/cards/villa-control-v4.jpg?v=villa-control-v4",
        ImageCache = "card_villa_control_v4.jpg",]==],
    "Villa Control image refresh"
)

]=]

source = source:sub(1, insertAt - 1) .. villaImageFix .. source:sub(insertAt)

local chunk, compileError = loadstring(source)
if not chunk then
    error("[SaltyHub] Failed to compile patched Hub bootstrap: " .. tostring(compileError), 0)
end

return chunk()
