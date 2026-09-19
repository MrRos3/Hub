-- Velora Hub bootstrap v11
-- Premium card edition. Builds on the stable clean-neon v10 base.

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

local premiumPass = [=[

--==============================================================
-- V11 PREMIUM CARD PASS
--==============================================================

-- Give the new cards a little more breathing room.
replaceExact("CellSize = UDim2.fromOffset(360, 118),", "CellSize = UDim2.fromOffset(360, 132),", "premium initial card height")
replaceExact("gridLayout.CellSize = UDim2.fromOffset(cellWidth, 118)", "gridLayout.CellSize = UDim2.fromOffset(cellWidth, 132)", "premium responsive card height")

local polishStart = string.find(source, "--==============================================================\n-- CLEAN NEON POLISH", 1, true)
local polishTail = "refresh()\nupdateCardSelection()"
local polishEnd = polishStart and string.find(source, polishTail, polishStart, true)

if not polishStart or not polishEnd then
    error("[Velora Hub] Could not locate clean-neon card polish.", 0)
end

local premiumPolish = [==[
--==============================================================
-- PREMIUM CARD POLISH
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

for id, data in pairs(cards) do
    local card = data.Card
    local cardStroke = data.Stroke
    local selectButton = data.Select
    local favorite = favoriteButtons[id]
    local scale = create("UIScale", { Scale = 1, Parent = card })
    local cardCorner = card:FindFirstChildOfClass("UICorner")

    if cardCorner then
        cardCorner.CornerRadius = UDim.new(0, 13)
    end

    card.BackgroundColor3 = Color3.fromHex("#0F0D13")
    card.BackgroundTransparency = 0
    cardStroke.Color = Color3.fromHex("#654984")
    cardStroke.Transparency = 0.46
    cardStroke.Thickness = 1

    -- Background-only gradient surface. No lines, rails or blobs.
    local surface = create("Frame", {
        Name = "PremiumSurface",
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 1, -2),
        BackgroundColor3 = Color3.fromHex("#15111A"),
        BorderSizePixel = 0,
        ZIndex = 0,
        Parent = card,
    }, {
        corner(12),
        create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHex("#19131F")),
                ColorSequenceKeypoint.new(0.55, Color3.fromHex("#131018")),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#0F0E13")),
            }),
            Rotation = 12,
        }),
    })

    local initialBox = card:FindFirstChildWhichIsA("Frame")
    if initialBox and initialBox ~= surface then
        initialBox.Position = UDim2.fromOffset(14, 15)
        initialBox.Size = UDim2.fromOffset(52, 52)
        initialBox.BackgroundColor3 = Color3.fromHex("#21172A")
        initialBox.BackgroundTransparency = 0

        local initialCorner = initialBox:FindFirstChildOfClass("UICorner")
        if initialCorner then
            initialCorner.CornerRadius = UDim.new(0, 12)
        end

        local initialStroke = initialBox:FindFirstChildOfClass("UIStroke")
        if initialStroke then
            initialStroke.Color = THEME.NeonSoft
            initialStroke.Transparency = 0.24
            initialStroke.Thickness = 1
        end

        local initialText = initialBox:FindFirstChildWhichIsA("TextLabel")
        if initialText then
            initialText.TextSize = 18
            initialText.TextColor3 = Color3.fromHex("#F7F2FF")
        end

        create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHex("#2A1D36")),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#17101E")),
            }),
            Rotation = 35,
            Parent = initialBox,
        })
    end

    local titleLabel, descLabel, tagsLabel = findCardLabels(card)

    if titleLabel then
        titleLabel.Position = UDim2.fromOffset(78, 15)
        titleLabel.Size = UDim2.new(1, -132, 0, 24)
        titleLabel.TextSize = 14
        titleLabel.TextColor3 = Color3.fromHex("#FFFFFF")
    end

    if descLabel then
        descLabel.Position = UDim2.fromOffset(78, 40)
        descLabel.Size = UDim2.new(1, -140, 0, 20)
        descLabel.TextSize = 9
        descLabel.TextColor3 = Color3.fromHex("#BDB4C5")
    end

    if tagsLabel then
        tagsLabel.Position = UDim2.fromOffset(15, 94)
        tagsLabel.Size = UDim2.new(1, -132, 0, 20)
        tagsLabel.TextSize = 8
        tagsLabel.TextColor3 = Color3.fromHex("#8B8193")
    end

    if favorite then
        favorite.Position = UDim2.new(1, -12, 0, 11)
        favorite.Size = UDim2.fromOffset(26, 26)
        favorite.ImageColor3 = favorites[id] and THEME.Pink or Color3.fromHex("#736B79")
        favorite.ImageTransparency = favorites[id] and 0 or 0.08

        favorite.MouseEnter:Connect(function()
            tween(favorite, 0.10, {
                ImageColor3 = THEME.Pink,
                ImageTransparency = 0,
            })
        end)

        favorite.MouseLeave:Connect(function()
            tween(favorite, 0.10, {
                ImageColor3 = favorites[id] and THEME.Pink or Color3.fromHex("#736B79"),
                ImageTransparency = favorites[id] and 0 or 0.08,
            })
        end)
    end

    selectButton.Position = UDim2.new(1, -14, 1, -14)
    selectButton.Size = UDim2.fromOffset(96, 32)
    selectButton.BackgroundColor3 = Color3.fromHex("#21172A")
    selectButton.BackgroundTransparency = 0
    selectButton.TextSize = 9
    selectButton.TextColor3 = Color3.fromHex("#EEE8F4")

    local selectCorner = selectButton:FindFirstChildOfClass("UICorner")
    if selectCorner then
        selectCorner.CornerRadius = UDim.new(0, 9)
    end

    local selectStroke = selectButton:FindFirstChildOfClass("UIStroke")
    if selectStroke then
        selectStroke.Color = THEME.NeonSoft
        selectStroke.Transparency = 0.30
        selectStroke.Thickness = 1
    end

    selectButton.MouseEnter:Connect(function()
        tween(selectButton, 0.12, {
            BackgroundColor3 = Color3.fromHex("#2B1D37"),
            TextColor3 = Color3.fromHex("#FFFFFF"),
        })
        if selectStroke then
            tween(selectStroke, 0.12, {
                Color = THEME.Neon,
                Transparency = 0.08,
            })
        end
    end)

    selectButton.MouseLeave:Connect(function()
        tween(selectButton, 0.14, {
            BackgroundColor3 = Color3.fromHex("#21172A"),
            TextColor3 = Color3.fromHex("#EEE8F4"),
        })
        if selectStroke then
            tween(selectStroke, 0.14, {
                Color = THEME.NeonSoft,
                Transparency = 0.30,
            })
        end
    end)

    card.MouseEnter:Connect(function()
        tween(scale, 0.14, { Scale = 1.006 })
        tween(cardStroke, 0.14, {
            Color = THEME.Neon,
            Transparency = 0.12,
        })

        if initialBox and initialBox ~= surface then
            local initialStroke = initialBox:FindFirstChildOfClass("UIStroke")
            if initialStroke then
                tween(initialStroke, 0.14, {
                    Color = THEME.Neon,
                    Transparency = 0.10,
                })
            end
        end
    end)

    card.MouseLeave:Connect(function()
        tween(scale, 0.16, { Scale = 1 })
        tween(cardStroke, 0.16, {
            Color = selectedId == id and THEME.AccentBright or Color3.fromHex("#654984"),
            Transparency = selectedId == id and 0.14 or 0.46,
        })

        if initialBox and initialBox ~= surface then
            local initialStroke = initialBox:FindFirstChildOfClass("UIStroke")
            if initialStroke then
                tween(initialStroke, 0.16, {
                    Color = THEME.NeonSoft,
                    Transparency = 0.24,
                })
            end
        end
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

local openingScale = create("UIScale", { Scale = 0.992, Parent = main })
tween(openingScale, 0.18, { Scale = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

refresh()
updateCardSelection()
]==]

source = source:sub(1, polishStart - 1)
    .. premiumPolish
    .. source:sub(polishEnd + #polishTail)
]=]

bootstrap = bootstrap:sub(1, insertAt - 1)
    .. premiumPass
    .. bootstrap:sub(insertAt)

local chunk, compileError = loadstring(bootstrap)
if not chunk then
    error("[Velora Hub] Failed to compile v11 bootstrap: " .. tostring(compileError), 0)
end

return chunk()
