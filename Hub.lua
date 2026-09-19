-- Velora Hub bootstrap v8
-- Keeps the script library modular while upgrading the live Hub UI.

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

-- Add real scripts that live outside the frozen core manifest.
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

-- Dark neon palette. Clean edges and controlled neon, no giant glow blobs.
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
    Background = Color3.fromHex("#010102"),
    Panel = Color3.fromHex("#060606"),
    Dialog = Color3.fromHex("#0B0810"),
    Element = Color3.fromHex("#100D15"),
    ElementHover = Color3.fromHex("#171020"),
    Button = Color3.fromHex("#211331"),
    Accent = Color3.fromHex("#8E5CFF"),
    AccentBright = Color3.fromHex("#D65CFF"),
    Outline = Color3.fromHex("#53377A"),
    Text = Color3.fromHex("#FCFAFF"),
    Muted = Color3.fromHex("#B0A6BC"),
    Faint = Color3.fromHex("#746B80"),
    NeonViolet = Color3.fromHex("#A76BFF"),
    NeonPink = Color3.fromHex("#FF5BAE"),
    NeonCyan = Color3.fromHex("#5CD9FF"),
}]=],
"theme"
)

-- Slightly clearer backdrop and tighter window proportions.
replaceExact("BackgroundTransparency = 0.66,", "BackgroundTransparency = 0.54,", "backdrop")
replaceExact("Size = UDim2.fromScale(0.74, 0.72),", "Size = UDim2.fromScale(0.72, 0.64),", "window size")
replaceExact("MinSize = Vector2.new(860, 530),", "MinSize = Vector2.new(860, 480),", "minimum size")
replaceExact("tween(blur, 0.2, { Size = 9 })", "tween(blur, 0.2, { Size = 7 })", "blur strength")
replaceExact("tween(blur, 0.16, { Size = value and 9 or 0 })", "tween(blur, 0.16, { Size = value and 7 or 0 })", "toggle blur")

-- Four scripts look much better as a balanced 2x2 library instead of a 3+1 row.
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
    if #SCRIPTS <= 6 and width >= 760 then
        columns = 2
    elseif width >= 1060 then
        columns = 3
    elseif width >= 760 then
        columns = 2
    else
        columns = 1
    end]=],
"responsive columns"
)
replaceExact("CellSize = UDim2.fromOffset(360, 104),", "CellSize = UDim2.fromOffset(360, 116),", "initial card height")
replaceExact("gridLayout.CellSize = UDim2.fromOffset(cellWidth, 104)", "gridLayout.CellSize = UDim2.fromOffset(cellWidth, 116)", "responsive card height")

-- Persistent favorites. Uses the executor filesystem when available, otherwise
-- gracefully falls back to the current session.
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
    if type(writefile) ~= "function" then
        return false
    end
    if not ensureFavoritesFolder() then
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

-- Make notifications easier to read against bright games.
replaceExact("Size = UDim2.fromOffset(350, 86),", "Size = UDim2.fromOffset(366, 92),", "notification size")
replaceExact("BackgroundTransparency = 0.03,", "BackgroundTransparency = 0.01,", "notification surface")
replaceExact(
[=[                ColorSequenceKeypoint.new(0, Color3.fromHex("#16090D")),
                ColorSequenceKeypoint.new(0.55, THEME.Dialog),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#080608")),]=],
[=[                ColorSequenceKeypoint.new(0, Color3.fromHex("#1A1028")),
                ColorSequenceKeypoint.new(0.55, Color3.fromHex("#0D0913")),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#08070C")),]=],
"notification gradient"
)

-- Neon polish layer. All effects are edge/gradient based so the UI stays crisp.
replaceExact(
[=[refresh()
updateCardSelection()]=],
[=[--==============================================================
-- NEON POLISH
--==============================================================

local function addGradient(target, colors, rotation, name)
    local gradient = create("UIGradient", {
        Name = name or "VeloraGradient",
        Color = ColorSequence.new(colors),
        Rotation = rotation or 0,
        Parent = target,
    })
    return gradient
end

local mainStroke = main:FindFirstChildOfClass("UIStroke")
if mainStroke then
    mainStroke.Color = THEME.NeonViolet
    mainStroke.Transparency = 0.26
    mainStroke.Thickness = 1.2
    addGradient(mainStroke, {
        ColorSequenceKeypoint.new(0, THEME.NeonPink),
        ColorSequenceKeypoint.new(0.45, THEME.NeonViolet),
        ColorSequenceKeypoint.new(1, THEME.NeonCyan),
    }, 0, "NeonStrokeGradient")
end

addGradient(main, {
    ColorSequenceKeypoint.new(0, Color3.fromHex("#070609")),
    ColorSequenceKeypoint.new(0.46, Color3.fromHex("#09070D")),
    ColorSequenceKeypoint.new(1, Color3.fromHex("#060608")),
}, 115, "PanelGradient")

addGradient(top, {
    ColorSequenceKeypoint.new(0, Color3.fromHex("#0C0912")),
    ColorSequenceKeypoint.new(0.50, Color3.fromHex("#120B1A")),
    ColorSequenceKeypoint.new(1, Color3.fromHex("#09080D")),
}, 0, "TopGradient")

local topRail = create("Frame", {
    Name = "NeonTopRail",
    Position = UDim2.fromOffset(16, 0),
    Size = UDim2.new(1, -32, 0, 2),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
    ZIndex = 30,
    Parent = main,
}, {
    corner(2),
})
addGradient(topRail, {
    ColorSequenceKeypoint.new(0, THEME.NeonPink),
    ColorSequenceKeypoint.new(0.52, THEME.NeonViolet),
    ColorSequenceKeypoint.new(1, THEME.NeonCyan),
}, 0, "RailGradient")

local bottomRail = create("Frame", {
    Name = "NeonBottomRail",
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 20, 1, 0),
    Size = UDim2.new(1, -40, 0, 1),
    BackgroundColor3 = THEME.NeonViolet,
    BackgroundTransparency = 0.52,
    BorderSizePixel = 0,
    ZIndex = 30,
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
    brandStroke.Transparency = 0.24
    TweenService:Create(
        brandStroke,
        TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        { Transparency = 0.52 }
    ):Play()
end

addGradient(brandIcon, {
    ColorSequenceKeypoint.new(0, Color3.fromHex("#2A123F")),
    ColorSequenceKeypoint.new(0.55, Color3.fromHex("#171020")),
    ColorSequenceKeypoint.new(1, Color3.fromHex("#102132")),
}, 35, "BrandGradient")

local searchStroke = searchWrap:FindFirstChildOfClass("UIStroke")
if searchStroke then
    searchStroke.Color = THEME.Outline
    searchBox.Focused:Connect(function()
        tween(searchStroke, 0.16, { Color = THEME.NeonViolet, Transparency = 0.10 })
        tween(searchWrap, 0.16, { BackgroundColor3 = Color3.fromHex("#15101E") })
    end)
    searchBox.FocusLost:Connect(function()
        tween(searchStroke, 0.16, { Color = THEME.Outline, Transparency = 0.46 })
        tween(searchWrap, 0.16, { BackgroundColor3 = THEME.Element })
    end)
end

addGradient(searchWrap, {
    ColorSequenceKeypoint.new(0, Color3.fromHex("#121017")),
    ColorSequenceKeypoint.new(0.58, Color3.fromHex("#161020")),
    ColorSequenceKeypoint.new(1, Color3.fromHex("#0E1118")),
}, 0, "SearchGradient")

addGradient(countLabel, {
    ColorSequenceKeypoint.new(0, Color3.fromHex("#17101F")),
    ColorSequenceKeypoint.new(1, Color3.fromHex("#10141B")),
}, 0, "CountGradient")

local accentPalette = { THEME.NeonViolet, THEME.NeonPink, THEME.NeonCyan }
local function accentFor(id)
    local score = 0
    for index = 1, #id do
        score = score + string.byte(id, index)
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

    card.BackgroundColor3 = Color3.fromHex("#0E0B12")
    cardStroke.Color = accent
    cardStroke.Transparency = 0.66

    addGradient(card, {
        ColorSequenceKeypoint.new(0, Color3.fromHex("#130E18")),
        ColorSequenceKeypoint.new(0.58, Color3.fromHex("#0E0B12")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("#0A0B10")),
    }, 12, "CardGradient")

    addGradient(cardStroke, {
        ColorSequenceKeypoint.new(0, accent),
        ColorSequenceKeypoint.new(0.55, THEME.NeonViolet),
        ColorSequenceKeypoint.new(1, THEME.NeonCyan),
    }, 0, "CardStrokeGradient")

    local initialBox = card:FindFirstChildWhichIsA("Frame")
    if initialBox then
        initialBox.BackgroundColor3 = Color3.fromHex("#21142F")
        addGradient(initialBox, {
            ColorSequenceKeypoint.new(0, accent),
            ColorSequenceKeypoint.new(0.48, Color3.fromHex("#2A1740")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#122033")),
        }, 35, "InitialGradient")
        local initialStroke = initialBox:FindFirstChildOfClass("UIStroke")
        if initialStroke then
            initialStroke.Color = accent
            initialStroke.Transparency = 0.34
        end
    end

    selectButton.BackgroundColor3 = Color3.fromHex("#1C1029")
    local selectStroke = selectButton:FindFirstChildOfClass("UIStroke")
    if selectStroke then
        selectStroke.Color = accent
        selectStroke.Transparency = 0.42
    end
    addGradient(selectButton, {
        ColorSequenceKeypoint.new(0, Color3.fromHex("#251336")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("#101726")),
    }, 0, "SelectGradient")

    if favorite then
        favorite.ImageColor3 = favorites[id] and THEME.NeonPink or THEME.Faint
        favorite.ImageTransparency = favorites[id] and 0 or 0.08
        favorite.MouseEnter:Connect(function()
            tween(favorite, 0.10, { ImageColor3 = THEME.NeonPink, ImageTransparency = 0 })
        end)
        favorite.MouseLeave:Connect(function()
            tween(favorite, 0.10, {
                ImageColor3 = favorites[id] and THEME.NeonPink or THEME.Faint,
                ImageTransparency = favorites[id] and 0 or 0.08,
            })
        end)
    end

    card.MouseEnter:Connect(function()
        tween(scale, 0.14, { Scale = 1.018 })
        tween(cardStroke, 0.14, { Transparency = 0.10, Color = accent })
        if selectStroke then
            tween(selectStroke, 0.14, { Transparency = 0.14 })
        end
    end)

    card.MouseLeave:Connect(function()
        tween(scale, 0.16, { Scale = 1 })
        tween(cardStroke, 0.16, {
            Transparency = selectedId == id and 0.16 or 0.66,
            Color = selectedId == id and THEME.AccentBright or accent,
        })
        if selectStroke then
            tween(selectStroke, 0.16, { Transparency = 0.42 })
        end
    end)
end

for name, button in pairs(filterButtons) do
    local filterStroke = button:FindFirstChildOfClass("UIStroke")
    button.MouseEnter:Connect(function()
        if currentFilter ~= name then
            tween(button, 0.12, { BackgroundColor3 = Color3.fromHex("#1A1224") })
            if filterStroke then
                tween(filterStroke, 0.12, { Color = THEME.NeonViolet, Transparency = 0.28 })
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

local openingScale = create("UIScale", { Scale = 0.975, Parent = main })
main.GroupTransparency = 0.10
tween(openingScale, 0.28, { Scale = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
tween(main, 0.24, { GroupTransparency = 0 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

refresh()
updateCardSelection()]=],
"neon polish"
)

local chunk, compileError = loadstring(source)
if not chunk then
    error("[Velora Hub] Failed to compile patched HubCore: " .. tostring(compileError), 0)
end

return chunk()