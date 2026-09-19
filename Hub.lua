-- Velora Hub bootstrap v15
-- Fix local card thumbnails and use cleaner rounded-square card styling.

local BASE_URL = "https://raw.githubusercontent.com/MrRos3/Hub/ffa830605bb5b8edade0b87daa86be4ccf668aaa/Hub.lua"
local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))

local ok, source = pcall(function()
    return game:HttpGet(BASE_URL .. "?v=" .. cache)
end)

if not ok or type(source) ~= "string" or source == "" then
    error("[Velora Hub] Failed to download v13 base.", 0)
end

local function replaceExact(needle, replacement, label)
    local startAt, endAt = string.find(source, needle, 1, true)
    if not startAt then
        error("[Velora Hub] Missing patch target: " .. tostring(label), 0)
    end
    source = source:sub(1, startAt - 1) .. replacement .. source:sub(endAt + 1)
end

-- Use executor-friendly JPEG thumbnails instead of WebP.
source = source:gsub("assets/cards/velora%%-piano%%.webp", "assets/cards/velora-piano.jpg")
source = source:gsub("assets/cards/shadow%%-network%%.webp", "assets/cards/shadow-network.jpg")
source = source:gsub("assets/cards/mm2%%.webp", "assets/cards/mm2.jpg")
source = source:gsub("assets/cards/alzzmys%%-dances%%.webp", "assets/cards/alzzmys-dances.jpg")
source = source:gsub('card_" %%.%% tostring%(entry%%.Id or "script"%) %%.%% "%%.webp"', 'card_" .. tostring(entry.Id or "script") .. ".jpg"')

-- Custom/local assets often do not toggle ImageLabel.IsLoaded in executors.
-- Show the asset immediately and hide the letter fallback as soon as we have an asset path.
replaceExact(
    '        ImageTransparency = 1,',
    '        ImageTransparency = 0,',
    'card image immediate visibility'
)
replaceExact(
    '    local revealed = false\n    local function revealLoadedImage()\n        if revealed or not cover.IsLoaded then\n            return\n        end\n\n        revealed = true\n        cover.ImageTransparency = 0\n        if initialText then\n            initialText.Visible = false\n        end\n    end\n\n    cover:GetPropertyChangedSignal("IsLoaded"):Connect(revealLoadedImage)\n    task.defer(revealLoadedImage)\n\n    return true',
    '    if initialText then\n        initialText.Visible = false\n    end\n\n    return true',
    'remove IsLoaded dependency'
)

-- Make cards and image slots more rounded-square and compact.
replaceExact('        cardCorner.CornerRadius = UDim.new(0, 12)', '        cardCorner.CornerRadius = UDim.new(0, 16)', 'rounder card corner')
replaceExact('        initialBox.Size = UDim2.fromOffset(58, 58)', '        initialBox.Size = UDim2.fromOffset(60, 60)', 'slightly larger image tile')
replaceExact('            initialCorner.CornerRadius = UDim.new(0, 14)', '            initialCorner.CornerRadius = UDim.new(0, 16)', 'rounder image tile')
replaceExact('        corner(12),', '        corner(16),', 'rounder thumbnail crop')
replaceExact('        titleLabel.Position = UDim2.fromOffset(82, 13)', '        titleLabel.Position = UDim2.fromOffset(86, 14)', 'title x offset')
replaceExact('        descLabel.Position = UDim2.fromOffset(82, 35)', '        descLabel.Position = UDim2.fromOffset(86, 37)', 'desc x offset')
replaceExact('        tagsLabel.Position = UDim2.fromOffset(82, 56)', '        tagsLabel.Position = UDim2.fromOffset(86, 60)', 'tags x offset')
replaceExact('        selectButton.Size = UDim2.fromOffset(82, 27)', '        selectButton.Size = UDim2.fromOffset(84, 28)', 'select size')

local chunk, compileError = loadstring(source)
if not chunk then
    error("[Velora Hub] Failed to compile v15 bootstrap: " .. tostring(compileError), 0)
end

return chunk()
