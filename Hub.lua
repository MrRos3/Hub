-- Velora Hub bootstrap v14
-- Executor-compatible card artwork: use JPEG card assets instead of WebP.

local BASE_URL = "https://raw.githubusercontent.com/MrRos3/Hub/ffa830605bb5b8edade0b87daa86be4ccf668aaa/Hub.lua"
local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))

local ok, source = pcall(function()
    return game:HttpGet(BASE_URL .. "?v=" .. cache)
end)

if not ok or type(source) ~= "string" or source == "" then
    error("[Velora Hub] Failed to download v13 base.", 0)
end

-- Many executors expose getcustomasset/getsynasset but do not decode WebP reliably.
-- Point the exact same four card thumbnails at JPEG files and cache them as .jpg.
source = source:gsub("assets/cards/velora%-piano%.webp", "assets/cards/velora-piano.jpg")
source = source:gsub("assets/cards/shadow%-network%.webp", "assets/cards/shadow-network.jpg")
source = source:gsub("assets/cards/mm2%.webp", "assets/cards/mm2.jpg")
source = source:gsub("assets/cards/alzzmys%-dances%.webp", "assets/cards/alzzmys-dances.jpg")
source = source:gsub('card_" %.%. tostring%(entry%.Id or "script"%) %.%. "%.webp"', 'card_" .. tostring(entry.Id or "script") .. ".jpg"')

local chunk, compileError = loadstring(source)
if not chunk then
    error("[Velora Hub] Failed to compile v14 bootstrap: " .. tostring(compileError), 0)
end

return chunk()
