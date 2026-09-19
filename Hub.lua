-- Velora Hub bootstrap v13
-- Compact premium cards + rounded game thumbnails with safe initial fallbacks.

local BASE_URL = "https://raw.githubusercontent.com/MrRos3/Hub/d1dbc49d32489c9b8b837c960654d46dee8ca4be/Hub.lua"
local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))

local ok, bootstrap = pcall(function()
    return game:HttpGet(BASE_URL .. "?v=" .. cache)
end)

if not ok or type(bootstrap) ~= "string" or bootstrap == "" then
    error("[Velora Hub] Failed to download stable v10 base.", 0)
end

local compileMarker = "\nlocal chunk, compileError = loadstring(source)"
local insertAt = string.find(bootstrap, compileMarker, 1, true)
if not insertAt then
    error("[Velora Hub] Could not locate v10 compile stage.", 0)
end

local compactPass = [=[

--==============================================================
-- V13 COMPACT CARD IMAGE PASS
--==============================================================

-- Card artwork. These URLs are cached locally when the executor supports files;
-- otherwise the existing first-letter tile remains as the fallback.
replaceExact(
    '        Url = "https://raw.githubusercontent.com/MrRos3/Velora/main/loader.lua",',
    '        Url = "https://raw.githubusercontent.com/MrRos3/Velora/main/loader.lua",\n'
        .. '        ImageUrl = "https://raw.githubusercontent.com/MrRos3/Hub/main/assets/cards/velora-piano.webp",',
    "Velora Piano card image"
)
replaceExact(
    '        Url = "https://raw.githubusercontent.com/MrRos3/Hub/main/scripts/ShadowNetwork.lua",',
    '        Url = "https://raw.githubusercontent.com/MrRos3/Hub/main/scripts/ShadowNetwork.lua",\n'
        .. '        ImageUrl = "https://raw.githubusercontent.com/MrRos3/Hub/main/assets/cards/shadow-network.webp",',
    "Shadow Network card image"
)
replaceExact(
    '        Url = "https://raw.githubusercontent.com/MrRos3/Hub/main/scripts/MM2.lua",',
    '        Url = "https://raw.githubusercontent.com/MrRos3/Hub/main/scripts/MM2.lua",\n'
        .. '        ImageUrl = "https://raw.githubusercontent.com/MrRos3/Hub/main/assets/cards/mm2.webp",',
    "MM2 card image"
)
replaceExact(
    '        Url = "https://raw.githubusercontent.com/MrRos3/Hub/main/scripts/Dances.lua",',
    '        Url = "https://raw.githubusercontent.com/MrRos3/Hub/main/scripts/Dances.lua",\n'
        .. '        ImageUrl = "https://raw.githubusercontent.com/MrRos3/Hub/main/assets/cards/alzzmys-dances.webp",',
    "Alzzmy's DANCES card image"
)

-- Smaller overall window so a four-script library does not leave a huge dead area.
replaceExact("Size = UDim2.fromScale(0.68, 0.56),", "Size = UDim2.fromScale(0.68, 0.49),", "compact window size")
replaceExact("MinSize = Vector2.new(820, 460),", "MinSize = Vector2.new(820, 420),", "compact minimum size")
replaceExact("MaxSize = Vector2.new(1080, 620),", "MaxSize = Vector2.new(1080, 540),", "compact maximum size")

-- Compact cards. Still roomy enough for a future game image tile.
replaceExact("CellSize = UDim2.fromOffset(360, 118),", "CellSize = UDim2.fromOffset(360, 108),", "compact initial card height")
replaceExact("gridLayout.CellSize = UDim2.fromOffset(cellWidth, 118)", "gridLayout.CellSize = UDim2.fromOffset(cellWidth, 108)", "compact responsive card height")

local polishStart = string.find(source, "--==============================================================\n-- CLEAN NEON POLISH", 1, true)
local polishTail = "refresh()\nupdateCardSelection()"
local polishEnd = polishStart and string.find(source, polishTail, polishStart, true)

if not polishStart or not polishEnd then
    error("[Velora Hub] Could not locate clean-neon card polish.", 0)
end

local compactPolish = [==[
--==============================================================
-- COMPACT PREMIUM CARD POLISH
--==============================================================

main.BackgroundColor3 = THEME.Panel
main.BackgroundTransparency = 0.02
main.GroupTransparency = 0

local mainStroke = main:FindFirstChildOfClass("UIStroke")
if mainStroke then
    mainStroke.Color = THEME.Neon
    mainStroke.Transparency = 0.34
    mainStroke.Thickness = 1
end

top.BackgroundColor3 = THEME.Dialog
top.BackgroundTransparency = 0.03

local brandStroke = brandIcon:FindFirstChildOfClass("UIStroke")
if brandStroke then
    brandStroke.Color = THEME.Neon
    brandStroke.Transparency = 0.32
end

local searchStroke = searchWrap:FindFirstChildOfClass("UIStroke")
if searchStroke then
    searchStroke.Color = THEME.Outline
    searchStroke.Transparency = 0.34

    searchBox.Focused:Connect(function()
        tween(searchStroke, 0.14, { Color = THEME.Neon, Transparency = 0.08 })
        tween(searchWrap, 0.14, { BackgroundColor3 = Color3.fromHex("#18131E") })
    end)

    searchBox.FocusLost:Connect(function()
        tween(searchStroke, 0.14, { Color = THEME.Outline, Transparency = 0.34 })
        tween(searchWrap, 0.14, { BackgroundColor3 = THEME.Element })
    end)
end

local function findCardLabels(card)
    local titleLabel
    local descLabel
    local tagsLabel

    for _, child in ipairs(card:GetChildren()) do
        if child:IsA("TextLabel") then
            local y = child.Position.Y.Offset
            if y == 11 then
                titleLabel = child
            elseif y == 33 then
                descLabel = child
            elseif y == 73 then
                tagsLabel = child
            end
        end
    end

    return titleLabel, descLabel, tagsLabel
end

local function applyCardImage(entry, initialBox, initialText)
    if not entry or not entry.ImageUrl or entry.ImageUrl == "" then
        return false
    end

    local path = "VeloraHub/assets/card_" .. tostring(entry.Id or "script") .. ".webp"
    local asset = cacheRemoteAsset(entry.ImageUrl, path, entry.Image or "")
    if asset == "" then
        return false
    end

    local cover = create("ImageLabel", {
        Name = "CardImage",
        Position = UDim2.fromOffset(3, 3),
        Size = UDim2.new(1, -6, 1, -6),
        BackgroundTransparency = 1,
        Image = asset,
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 4,
        Parent = initialBox,
    }, {
        corner(12),
    })

    local revealed = false
    local function revealLoadedImage()
        if revealed or not cover.IsLoaded then
            return
        end

        revealed = true
        cover.ImageTransparency = 0
        if initialText then
            initialText.Visible = false
        end
    end

    cover:GetPropertyChangedSignal("IsLoaded"):Connect(revealLoadedImage)
    task.defer(revealLoadedImage)

    return true
end

for id, data in pairs(cards) do
    local card = data.Card
    local cardStroke = data.Stroke
    local selectButton = data.Select
    local favorite = favoriteButtons[id]
    local entry = data.Entry
    local scale = create("UIScale", { Scale = 1, Parent = card })

    local cardCorner = card:FindFirstChildOfClass("UICorner")
    if cardCorner then
        cardCorner.CornerRadius = UDim.new(0, 12)
    end

    card.BackgroundColor3 = Color3.fromHex("#100D14")
    card.BackgroundTransparency = 0
    cardStroke.Color = Color3.fromHex("#5D4579")
    cardStroke.Transparency = 0.50
    cardStroke.Thickness = 1

    -- Soft background only. No decorative rails or random shapes.
    local surface = create("Frame", {
        Name = "CompactSurface",
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 1, -2),
        BackgroundColor3 = Color3.fromHex("#141019"),
        BorderSizePixel = 0,
        ZIndex = 0,
        Parent = card,
    }, {
        corner(11),
        create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHex("#17121D")),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#100E14")),
            }),
            Rotation = 10,
        }),
    })

    local initialBox = card:FindFirstChildWhichIsA("Frame")
    if initialBox and initialBox ~= surface then
        initialBox.Position = UDim2.fromOffset(12, 12)
        initialBox.Size = UDim2.fromOffset(58, 58)
        initialBox.BackgroundColor3 = Color3.fromHex("#1D1525")
        initialBox.BackgroundTransparency = 0
        initialBox.ClipsDescendants = true
        initialBox.ZIndex = 3

        local initialCorner = initialBox:FindFirstChildOfClass("UICorner")
        if initialCorner then
            initialCorner.CornerRadius = UDim.new(0, 14)
        end

        local initialStroke = initialBox:FindFirstChildOfClass("UIStroke")
        if initialStroke then
            initialStroke.Color = THEME.NeonSoft
            initialStroke.Transparency = 0.26
            initialStroke.Thickness = 1
        end

        local initialText = initialBox:FindFirstChildWhichIsA("TextLabel")
        if initialText then
            initialText.TextSize = 17
            initialText.TextColor3 = Color3.fromHex("#F8F5FC")
            initialText.ZIndex = 4
        end

        applyCardImage(entry, initialBox, initialText)
    end

    local titleLabel, descLabel, tagsLabel = findCardLabels(card)

    if titleLabel then
        titleLabel.Position = UDim2.fromOffset(82, 13)
        titleLabel.Size = UDim2.new(1, -132, 0, 20)
        titleLabel.TextSize = 13
        titleLabel.TextColor3 = Color3.fromHex("#FFFFFF")
        titleLabel.ZIndex = 3
    end

    if descLabel then
        descLabel.Position = UDim2.fromOffset(82, 35)
        descLabel.Size = UDim2.new(1, -142, 0, 16)
        descLabel.TextSize = 8
        descLabel.TextColor3 = Color3.fromHex("#B9B0C0")
        descLabel.ZIndex = 3
    end

    if tagsLabel then
        tagsLabel.Position = UDim2.fromOffset(82, 56)
        tagsLabel.Size = UDim2.new(1, -184, 0, 15)
        tagsLabel.TextSize = 7
        tagsLabel.TextColor3 = Color3.fromHex("#81788A")
        tagsLabel.ZIndex = 3
    end

    if favorite then
        favorite.Position = UDim2.new(1, -11, 0, 10)
        favorite.Size = UDim2.fromOffset(24, 24)
        favorite.ZIndex = 5
        favorite.ImageColor3 = favorites[id] and THEME.Pink or Color3.fromHex("#726B79")
        favorite.ImageTransparency = favorites[id] and 0 or 0.08

        favorite.MouseEnter:Connect(function()
            tween(favorite, 0.10, { ImageColor3 = THEME.Pink, ImageTransparency = 0 })
        end)

        favorite.MouseLeave:Connect(function()
            tween(favorite, 0.10, {
                ImageColor3 = favorites[id] and THEME.Pink or Color3.fromHex("#726B79"),
                ImageTransparency = favorites[id] and 0 or 0.08,
            })
        end)
    end

    selectButton.Position = UDim2.new(1, -12, 1, -11)
    selectButton.Size = UDim2.fromOffset(82, 27)
    selectButton.BackgroundColor3 = Color3.fromHex("#1C1424")
    selectButton.BackgroundTransparency = 0
    selectButton.TextSize = 8
    selectButton.TextColor3 = Color3.fromHex("#EEEAF2")
    selectButton.ZIndex = 4

    local selectCorner = selectButton:FindFirstChildOfClass("UICorner")
    if selectCorner then
        selectCorner.CornerRadius = UDim.new(0, 8)
    end

    local selectStroke = selectButton:FindFirstChildOfClass("UIStroke")
    if selectStroke then
        selectStroke.Color = THEME.NeonSoft
        selectStroke.Transparency = 0.34
        selectStroke.Thickness = 1
    end

    selectButton.MouseEnter:Connect(function()
        tween(selectButton, 0.12, {
            BackgroundColor3 = Color3.fromHex("#281B32"),
            TextColor3 = Color3.fromHex("#FFFFFF"),
        })
        if selectStroke then
            tween(selectStroke, 0.12, { Color = THEME.Neon, Transparency = 0.10 })
        end
    end)

    selectButton.MouseLeave:Connect(function()
        tween(selectButton, 0.14, {
            BackgroundColor3 = Color3.fromHex("#1C1424"),
            TextColor3 = Color3.fromHex("#EEEAF2"),
        })
        if selectStroke then
            tween(selectStroke, 0.14, { Color = THEME.NeonSoft, Transparency = 0.34 })
        end
    end)

    card.MouseEnter:Connect(function()
        tween(scale, 0.14, { Scale = 1.004 })
        tween(cardStroke, 0.14, { Color = THEME.Neon, Transparency = 0.12 })
    end)

    card.MouseLeave:Connect(function()
        tween(scale, 0.16, { Scale = 1 })
        tween(cardStroke, 0.16, {
            Color = selectedId == id and THEME.AccentBright or Color3.fromHex("#5D4579"),
            Transparency = selectedId == id and 0.14 or 0.50,
        })
    end)
end

for name, button in pairs(filterButtons) do
    local filterStroke = button:FindFirstChildOfClass("UIStroke")

    button.MouseEnter:Connect(function()
        if currentFilter ~= name then
            tween(button, 0.12, { BackgroundColor3 = Color3.fromHex("#1A1520") })
            if filterStroke then
                tween(filterStroke, 0.12, { Color = THEME.Neon, Transparency = 0.18 })
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

local openingScale = create("UIScale", { Scale = 0.993, Parent = main })
tween(openingScale, 0.18, { Scale = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

refresh()
updateCardSelection()
]==]

source = source:sub(1, polishStart - 1)
    .. compactPolish
    .. source:sub(polishEnd + #polishTail)
]=]

bootstrap = bootstrap:sub(1, insertAt - 1)
    .. compactPass
    .. bootstrap:sub(insertAt)

local chunk, compileError = loadstring(bootstrap)
if not chunk then
    error("[Velora Hub] Failed to compile v13 bootstrap: " .. tostring(compileError), 0)
end

return chunk()
