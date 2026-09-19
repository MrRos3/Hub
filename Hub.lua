-- Velora Hub bootstrap v9
-- Crisp neon edition: persistent favorites, readable surfaces, no glow blobs.

local CORE_URL = "https://raw.githubusercontent.com/MrRos3/Hub/main/HubCore.lua"
local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))

local ok, source = pcall(function()
    return game:HttpGet(CORE_URL .. "?v=" .. cache)
end)

if not ok or type(source) ~= "string" or source == "" then
    error("[Velora Hub] Failed to download HubCore.lua", 0)
end

local function replaceExact(needle, replacement, label)
    local startAt, endAt = string.find(source, needle, 1, true)
    if not startAt then
        error("[Velora Hub] Patch failed: " .. tostring(label or needle), 0)
    end
    source = source:sub(1, startAt - 1) .. replacement .. source:sub(endAt + 1)
end

-- Inject real scripts that live outside the frozen core manifest.
local marker = "\n}\n\nlocal function getGuiParent()"
local insertAt = string.find(source, marker, 1, true)
if not insertAt then
    error("[Velora Hub] Could not locate script library in HubCore.lua", 0)
end

local extraEntries = [=[
    {
        Id = "alzzmys-dances",
        Name = "Alzzmy's DANCES",
        Description = "Salty VantaUI AutoPlayer • Internal tryHit Edition",
        Tags = { "dances", "autoplayer", "music", "tryhit", "performance" },
        Url = "https://raw.githubusercontent.com/MrRos3/Hub/main/scripts/Dances.lua",
    },
]=]

source = source:sub(1, insertAt - 1) .. "\n" .. extraEntries .. source:sub(insertAt)

-- Brighter dark-neon palette. Still black-first, but actually readable.
replaceExact(
[=[local THEME = {
    Background = Color3.fromHex("#000000"),
    Panel = Color3.fromHex("#050406"),
    Dialog = Color3.fromHex("#0A0709"),
    Element = Color3.fromHex("#151116"),
    ElementHover = Color3.fromHex("#1D161B"),
    Button = Color3.fromHex("#251016"),
    Accent = Color3.fromHex("#A1162F"),
    AccentBright = Color3.fromHex("#D23A57"),
    Outline = Color3.fromHex("#5A1824"),
    Text = Color3.fromHex("#FFFFFF"),
    Muted = Color3.fromHex("#9A9AA3"),
    Faint = Color3.fromHex("#68636B"),
}]=],
[=[local THEME = {
    Background = Color3.fromHex("#020203"),
    Panel = Color3.fromHex("#08070A"),
    Dialog = Color3.fromHex("#0E0B12"),
    Element = Color3.fromHex("#15111C"),
    ElementHover = Color3.fromHex("#1D1728"),
    Button = Color3.fromHex("#241632"),
    Accent = Color3.fromHex("#9A6BFF"),
    AccentBright = Color3.fromHex("#DA70FF"),
    Outline = Color3.fromHex("#5D3E86"),
    Text = Color3.fromHex("#FFFFFF"),
    Muted = Color3.fromHex("#C1B7CC"),
    Faint = Color3.fromHex("#81778D"),
    NeonViolet = Color3.fromHex("#A96FFF"),
    NeonPink = Color3.fromHex("#FF62B2"),
    NeonCyan = Color3.fromHex("#63DDFF"),
}]=],
"theme"
)

-- Tighter window and clearer game backdrop.
replaceExact("BackgroundTransparency = 0.66,", "BackgroundTransparency = 0.50,", "backdrop")
replaceExact("Size = UDim2.fromScale(0.74, 0.72),", "Size = UDim2.fromScale(0.68, 0.56),", "window size")
replaceExact("MinSize = Vector2.new(860, 530),", "MinSize = Vector2.new(820, 460),", "minimum size")
replaceExact("MaxSize = Vector2.new(1220, 760),", "MaxSize = Vector2.new(1080, 620),", "maximum size")
replaceExact("tween(blur, 0.2, { Size = 9 })", "tween(blur, 0.2, { Size = 6 })", "blur strength")
replaceExact("tween(blur, 0.16, { Size = value and 9 or 0 })", "tween(blur, 0.16, { Size = value and 6 or 0 })", "toggle blur")

-- Four scripts stay balanced as 2x2.
replaceExact(
[=[    local columns
    if width >= 1060 then
        columns = 3
    elseif width >= 760 then
        columns = 2
    else
        columns = 1
    end]=],
[=[    local columns
    if #SCRIPTS <= 6 and width >= 720 then
        columns = 2
    elseif width >= 1060 then
        columns = 3
    elseif width >= 720 then
        columns = 2
    else
        columns = 1
    end]=],
"responsive columns"
)
replaceExact("CellSize = UDim2.fromOffset(360, 104),", "CellSize = UDim2.fromOffset(360, 118),", "initial card height")
replaceExact("gridLayout.CellSize = UDim2.fromOffset(cellWidth, 104)", "gridLayout.CellSize = UDim2.fromOffset(cellWidth, 118)", "responsive card height")

-- Persistent favorites.
replaceExact(
[=[local favorites = {}
local cards = {}]=],
[=[local HttpService = game:GetService("HttpService")
local FAVORITES_FILE = "VeloraHub/favorites.json"
local favorites = {}

local function ensureFavoritesFolder()
    if type(makefolder) ~= "function" or type(isfolder) ~= "function" then
        return false
    end
    if not isfolder("VeloraHub") then
        pcall(makefolder, "VeloraHub")
    end
    return isfolder("VeloraHub")
end

local function loadFavorites()
    if type(readfile) ~= "function" or type(isfile) ~= "function" then
        return
    end
    ensureFavoritesFolder()
    if not isfile(FAVORITES_FILE) then
        return
    end

    local success, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(FAVORITES_FILE))
    end)

    if success and type(decoded) == "table" then
        for id, value in pairs(decoded) do
            if value == true then
                favorites[tostring(id)] = true
            end
        end
    end
end

local function saveFavorites()
    if type(writefile) ~= "function" or not ensureFavoritesFolder() then
        return false
    end

    local clean = {}
    for id, value in pairs(favorites) do
        if value == true then
            clean[id] = true
        end
    end

    local success, encoded = pcall(function()
        return HttpService:JSONEncode(clean)
    end)
    if not success then
        return false
    end

    return pcall(writefile, FAVORITES_FILE, encoded)
end

loadFavorites()

local cards = {}]=],
"persistent favorites"
)

replaceExact(
[=[    favorite.MouseButton1Click:Connect(function()
        favorites[entry.Id] = not favorites[entry.Id]
        favorite.ImageColor3 = favorites[entry.Id] and THEME.AccentBright or THEME.Faint
        favorite.ImageTransparency = favorites[entry.Id] and 0 or 0.04
    end)]=],
[=[    favorite.MouseButton1Click:Connect(function()
        if favorites[entry.Id] then
            favorites[entry.Id] = nil
        else
            favorites[entry.Id] = true
        end

        saveFavorites()
        tween(favorite, 0.12, {
            ImageColor3 = favorites[entry.Id] and THEME.NeonPink or THEME.Faint,
            ImageTransparency = favorites[entry.Id] and 0 or 0.08,
        })
    end)]=],
"favorite save handler"
)

-- Readable notification cards.
replaceExact("Size = UDim2.fromOffset(350, 86),", "Size = UDim2.fromOffset(366, 92),", "notification size")
replaceExact(
[=[                ColorSequenceKeypoint.new(0, Color3.fromHex("#16090D")),
                ColorSequenceKeypoint.new(0.55, THEME.Dialog),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#080608")),]=],
[=[                ColorSequenceKeypoint.new(0, Color3.fromHex("#1A1225")),
                ColorSequenceKeypoint.new(0.55, Color3.fromHex("#100C16")),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#09080D")),]=],
"notification gradient"
)

-- Crisp neon polish. IMPORTANT: no UIGradient on CanvasGroup 'main'.
-- That darkened the entire rendered group on some executors.
replaceExact(
[=[refresh()
updateCardSelection()]=],
[=[--==============================================================
-- CRISP NEON POLISH
--==============================================================

local function addGradient(target, colors, rotation, name)
    return create("UIGradient", {
        Name = name or "VeloraGradient",
        Color = ColorSequence.new(colors),
        Rotation = rotation or 0,
        Parent = target,
    })
end

-- Keep the CanvasGroup itself flat and readable.
main.BackgroundColor3 = THEME.Panel
main.BackgroundTransparency = 0.02
main.GroupTransparency = 0

local mainStroke = main:FindFirstChildOfClass("UIStroke")
if mainStroke then
    mainStroke.Color = THEME.NeonViolet
    mainStroke.Transparency = 0.12
    mainStroke.Thickness = 1.25
    addGradient(mainStroke, {
        ColorSequenceKeypoint.new(0, THEME.NeonPink),
        ColorSequenceKeypoint.new(0.48, THEME.NeonViolet),
        ColorSequenceKeypoint.new(1, THEME.NeonCyan),
    }, 0, "NeonBorder")
end

-- Background-only surface so gradients never tint text/content.
local surface = create("Frame", {
    Name = "Surface",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromHex("#0B0910"),
    BorderSizePixel = 0,
    ZIndex = 0,
    Parent = main,
}, {
    corner(13),
})
addGradient(surface, {
    ColorSequenceKeypoint.new(0, Color3.fromHex("#0E0A13")),
    ColorSequenceKeypoint.new(0.52, Color3.fromHex("#09080D")),
    ColorSequenceKeypoint.new(1, Color3.fromHex("#081016")),
}, 115, "SurfaceGradient")

local topSurface = create("Frame", {
    Name = "TopSurface",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromHex("#120D18"),
    BorderSizePixel = 0,
    ZIndex = 0,
    Parent = top,
})
addGradient(topSurface, {
    ColorSequenceKeypoint.new(0, Color3.fromHex("#171020")),
    ColorSequenceKeypoint.new(0.55, Color3.fromHex("#100C16")),
    ColorSequenceKeypoint.new(1, Color3.fromHex("#0B1118")),
}, 0, "TopSurfaceGradient")

local topRail = create("Frame", {
    Name = "NeonTopRail",
    Position = UDim2.fromOffset(14, 0),
    Size = UDim2.new(1, -28, 0, 2),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
    ZIndex = 50,
    Parent = main,
}, { corner(2) })
addGradient(topRail, {
    ColorSequenceKeypoint.new(0, THEME.NeonPink),
    ColorSequenceKeypoint.new(0.5, THEME.NeonViolet),
    ColorSequenceKeypoint.new(1, THEME.NeonCyan),
}, 0, "TopRailGradient")

local bottomRail = create("Frame", {
    Name = "NeonBottomRail",
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 22, 1, 0),
    Size = UDim2.new(1, -44, 0, 1),
    BackgroundColor3 = THEME.NeonViolet,
    BackgroundTransparency = 0.38,
    BorderSizePixel = 0,
    ZIndex = 50,
    Parent = main,
})
addGradient(bottomRail, {
    ColorSequenceKeypoint.new(0, THEME.NeonPink),
    ColorSequenceKeypoint.new(0.5, THEME.NeonViolet),
    ColorSequenceKeypoint.new(1, THEME.NeonCyan),
}, 0, "BottomRailGradient")

local brandStroke = brandIcon:FindFirstChildOfClass("UIStroke")
if brandStroke then
    brandStroke.Color = THEME.NeonViolet
    brandStroke.Transparency = 0.16
    TweenService:Create(
        brandStroke,
        TweenInfo.new(2.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        { Transparency = 0.48 }
    ):Play()
end

local searchStroke = searchWrap:FindFirstChildOfClass("UIStroke")
if searchStroke then
    searchStroke.Color = THEME.Outline
    searchStroke.Transparency = 0.28
    searchBox.Focused:Connect(function()
        tween(searchStroke, 0.16, { Color = THEME.NeonViolet, Transparency = 0.02 })
        tween(searchWrap, 0.16, { BackgroundColor3 = Color3.fromHex("#1A1422") })
    end)
    searchBox.FocusLost:Connect(function()
        tween(searchStroke, 0.16, { Color = THEME.Outline, Transparency = 0.28 })
        tween(searchWrap, 0.16, { BackgroundColor3 = THEME.Element })
    end)
end

local accentPalette = { THEME.NeonViolet, THEME.NeonPink, THEME.NeonCyan }
local function accentFor(id)
    local score = 0
    for i = 1, #id do
        score = score + string.byte(id, i)
    end
    return accentPalette[(score % #accentPalette) + 1]
end

for id, data in pairs(cards) do
    local accent = accentFor(id)
    local card = data.Card
    local cardStroke = data.Stroke
    local selectButton = data.Select
    local favorite = favoriteButtons[id]
    local scale = create("UIScale", { Scale = 1, Parent = card })

    card.BackgroundColor3 = Color3.fromHex("#15111A")
    card.BackgroundTransparency = 0.02
    cardStroke.Color = accent
    cardStroke.Transparency = 0.46
    cardStroke.Thickness = 1

    -- Thin neon rail, not a blob.
    local rail = create("Frame", {
        Name = "AccentRail",
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -20, 0, 2),
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.18,
        BorderSizePixel = 0,
        ZIndex = 8,
        Parent = card,
    }, { corner(2) })

    local initialBox = card:FindFirstChildWhichIsA("Frame")
    if initialBox then
        initialBox.BackgroundColor3 = Color3.fromHex("#23182E")
        initialBox.BackgroundTransparency = 0.02
        local initialStroke = initialBox:FindFirstChildOfClass("UIStroke")
        if initialStroke then
            initialStroke.Color = accent
            initialStroke.Transparency = 0.22
        end
    end

    selectButton.BackgroundColor3 = Color3.fromHex("#21172C")
    selectButton.BackgroundTransparency = 0.02
    local selectStroke = selectButton:FindFirstChildOfClass("UIStroke")
    if selectStroke then
        selectStroke.Color = accent
        selectStroke.Transparency = 0.28
    end

    if favorite then
        favorite.ImageColor3 = favorites[id] and THEME.NeonPink or THEME.Faint
        favorite.ImageTransparency = favorites[id] and 0 or 0.04
        favorite.MouseEnter:Connect(function()
            tween(favorite, 0.10, { ImageColor3 = THEME.NeonPink, ImageTransparency = 0 })
        end)
        favorite.MouseLeave:Connect(function()
            tween(favorite, 0.10, {
                ImageColor3 = favorites[id] and THEME.NeonPink or THEME.Faint,
                ImageTransparency = favorites[id] and 0 or 0.04,
            })
        end)
    end

    card.MouseEnter:Connect(function()
        tween(scale, 0.14, { Scale = 1.012 })
        tween(card, 0.14, { BackgroundColor3 = Color3.fromHex("#1B1522") })
        tween(cardStroke, 0.14, { Transparency = 0.04, Color = accent })
        tween(rail, 0.14, { BackgroundTransparency = 0 })
        if selectStroke then
            tween(selectStroke, 0.14, { Transparency = 0.04 })
        end
    end)

    card.MouseLeave:Connect(function()
        tween(scale, 0.16, { Scale = 1 })
        tween(card, 0.16, { BackgroundColor3 = selectedId == id and THEME.Button or Color3.fromHex("#15111A") })
        tween(cardStroke, 0.16, {
            Transparency = selectedId == id and 0.12 or 0.46,
            Color = selectedId == id and THEME.AccentBright or accent,
        })
        tween(rail, 0.16, { BackgroundTransparency = 0.18 })
        if selectStroke then
            tween(selectStroke, 0.16, { Transparency = 0.28 })
        end
    end)
end

for name, button in pairs(filterButtons) do
    local filterStroke = button:FindFirstChildOfClass("UIStroke")
    button.MouseEnter:Connect(function()
        if currentFilter ~= name then
            tween(button, 0.12, { BackgroundColor3 = Color3.fromHex("#1D1626") })
            if filterStroke then
                tween(filterStroke, 0.12, { Color = THEME.NeonViolet, Transparency = 0.12 })
            end
        end
    end)
    button.MouseLeave:Connect(function()
        if currentFilter ~= name then
            tween(button, 0.12, { BackgroundColor3 = THEME.Element })
            if filterStroke then
                tween(filterStroke, 0.12, { Color = THEME.Outline, Transparency = 0.56 })
            end
        end
    end)
end

-- Scale-only entrance. No group fade, so text never renders nearly black.
local openingScale = create("UIScale", { Scale = 0.985, Parent = main })
tween(openingScale, 0.22, { Scale = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

refresh()
updateCardSelection()]=],
"crisp neon polish"
)

local chunk, compileError = loadstring(source)
if not chunk then
    error("[Velora Hub] Failed to compile patched HubCore: " .. tostring(compileError), 0)
end

return chunk()