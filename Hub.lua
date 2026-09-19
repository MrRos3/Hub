-- Velora Hub bootstrap v16
-- Robust card-image loader. No brittle cosmetic patch failures.

local BASE_URL = "https://raw.githubusercontent.com/MrRos3/Hub/ffa830605bb5b8edade0b87daa86be4ccf668aaa/Hub.lua"
local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))

local ok, bootstrap = pcall(function()
    return game:HttpGet(BASE_URL .. "?v=" .. cache)
end)

if not ok or type(bootstrap) ~= "string" or bootstrap == "" then
    error("[Velora Hub] Failed to download stable card base.", 0)
end

local function replacePlainAll(text, needle, replacement)
    local from = 1
    while true do
        local a, b = string.find(text, needle, from, true)
        if not a then
            break
        end
        text = text:sub(1, a - 1) .. replacement .. text:sub(b + 1)
        from = a + #replacement
    end
    return text
end

-- Use JPEG artwork. getcustomasset/getsynasset handles JPEG much more reliably.
bootstrap = replacePlainAll(bootstrap, "assets/cards/velora-piano.webp", "assets/cards/velora-piano.jpg")
bootstrap = replacePlainAll(bootstrap, "assets/cards/shadow-network.webp", "assets/cards/shadow-network.jpg")
bootstrap = replacePlainAll(bootstrap, "assets/cards/mm2.webp", "assets/cards/mm2.jpg")
bootstrap = replacePlainAll(bootstrap, "assets/cards/alzzmys-dances.webp", "assets/cards/alzzmys-dances.jpg")
bootstrap = replacePlainAll(
    bootstrap,
    'local path = "VeloraHub/assets/card_" .. tostring(entry.Id or "script") .. ".webp"',
    'local path = "VeloraHub/assets/card_" .. tostring(entry.Id or "script") .. ".jpg"'
)

-- Replace the old IsLoaded-based reveal logic completely. Executor local assets often
-- render correctly while ImageLabel.IsLoaded remains false, which kept the image invisible.
local imageFunctionStart = string.find(
    bootstrap,
    "local function applyCardImage(entry, initialBox, initialText)",
    1,
    true
)
local imageFunctionEnd = imageFunctionStart and string.find(
    bootstrap,
    "\nfor id, data in pairs(cards) do",
    imageFunctionStart,
    true
)

if not imageFunctionStart or not imageFunctionEnd then
    error("[Velora Hub] Could not locate card image renderer.", 0)
end

local fixedImageFunction = [=[local function applyCardImage(entry, initialBox, initialText)
    if not entry or not entry.ImageUrl or entry.ImageUrl == "" then
        return false
    end

    local path = "VeloraHub/assets/card_" .. tostring(entry.Id or "script") .. ".jpg"
    local asset = cacheRemoteAsset(entry.ImageUrl, path, entry.Image or "")
    if not asset or asset == "" then
        return false
    end

    local cover = create("ImageLabel", {
        Name = "CardImage",
        Position = UDim2.fromOffset(2, 2),
        Size = UDim2.new(1, -4, 1, -4),
        BackgroundTransparency = 1,
        Image = asset,
        ImageTransparency = 0,
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 5,
        Parent = initialBox,
    }, {
        corner(14),
    })

    if initialText then
        initialText.Visible = false
    end

    return true
end
]=]

bootstrap = bootstrap:sub(1, imageFunctionStart - 1)
    .. fixedImageFunction
    .. bootstrap:sub(imageFunctionEnd + 1)

-- Rounded-square thumbnail treatment. These are optional plain replacements so a small
-- upstream layout change can never stop the entire Hub from launching again.
bootstrap = replacePlainAll(bootstrap, "cardCorner.CornerRadius = UDim.new(0, 12)", "cardCorner.CornerRadius = UDim.new(0, 15)")
bootstrap = replacePlainAll(bootstrap, "initialBox.Size = UDim2.fromOffset(58, 58)", "initialBox.Size = UDim2.fromOffset(64, 64)")
bootstrap = replacePlainAll(bootstrap, "initialCorner.CornerRadius = UDim.new(0, 14)", "initialCorner.CornerRadius = UDim.new(0, 15)")
bootstrap = replacePlainAll(bootstrap, "titleLabel.Position = UDim2.fromOffset(82, 13)", "titleLabel.Position = UDim2.fromOffset(88, 13)")
bootstrap = replacePlainAll(bootstrap, "descLabel.Position = UDim2.fromOffset(82, 35)", "descLabel.Position = UDim2.fromOffset(88, 35)")
bootstrap = replacePlainAll(bootstrap, "tagsLabel.Position = UDim2.fromOffset(82, 56)", "tagsLabel.Position = UDim2.fromOffset(88, 58)")

local chunk, compileError = loadstring(bootstrap)
if not chunk then
    error("[Velora Hub] Failed to compile v16 bootstrap: " .. tostring(compileError), 0)
end

return chunk()
