-- Velora Hub bootstrap v10
-- Clean neon edition: persistent favorites, no decorative rails, no glow blobs.

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

-- Inject additional real scripts.
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

-- Clean black / purple neon palette.
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
    Panel = Color3.fromHex("#070708"),
    Dialog = Color3.fromHex("#0C0A0F"),
    Element = Color3.fromHex("#141119"),
    ElementHover = Color3.fromHex("#1A1621"),
    Button = Color3.fromHex("#1C1426"),
    Accent = Color3.fromHex("#8B63D9"),
    AccentBright = Color3.fromHex("#C08AFF"),
    Outline = Color3.fromHex("#49365F"),
    Text = Color3.fromHex("#FFFFFF"),
    Muted = Color3.fromHex("#B8AFBF"),
    Faint = Color3.fromHex("#756C7D"),
    Neon = Color3.fromHex("#A778FF"),
    NeonSoft = Color3.fromHex("#7650B5"),
    Pink = Color3.fromHex("#FF68B0"),
}]=],
"theme"
)

-- Tighter window and softer backdrop.
replaceExact("BackgroundTransparency = 0.66,", "BackgroundTransparency = 0.52,", "backdrop")
replaceExact("Size = UDim2.fromScale(0.74, 0.72),", "Size = UDim2.fromScale(0.68, 0.56),", "window size")
replaceExact("MinSize = Vector2.new(860, 530),", "MinSize = Vector2.new(820, 460),", "minimum size")
replaceExact("MaxSize = Vector2.new(1220, 760),", "MaxSize = Vector2.new(1080, 620),", "maximum size")
replaceExact("tween(blur, 0.2, { Size = 9 })", "tween(blur, 0.2, { Size = 6 })", "blur strength")
replaceExact("tween(blur, 0.16, { Size = value and 9 or 0 })", "tween(blur, 0.16, { Size = value and 6 or 0 })", "toggle blur")

-- Keep small libraries balanced as 2x2.
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
            ImageColor3 = favorites[entry.Id] and THEME.Pink or THEME.Faint,
            ImageTransparency = favorites[entry.Id] and 0 or 0.06,
        })
    end)]=],
"favorite save handler"
)

-- Slightly roomier notifications without changing their structure.
replaceExact("Size = UDim2.fromOffset(350, 86),", "Size = UDim2.fromOffset(366, 92),", "notification size")

-- Clean neon polish. No rails, no blobs, no multi-color border streaks.
replaceExact(
[=[refresh()
updateCardSelection()]=],
[=[--==============================================================
-- CLEAN NEON POLISH
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

-- Keep the topbar clean and slightly separated from the body.
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

for id, data in pairs(cards) do
    local card = data.Card
    local cardStroke = data.Stroke
    local selectButton = data.Select
    local favorite = favoriteButtons[id]
    local scale = create("UIScale", { Scale = 1, Parent = card })

    card.BackgroundColor3 = Color3.fromHex("#15111A")
    card.BackgroundTransparency = 0.02
    cardStroke.Color = THEME.NeonSoft
    cardStroke.Transparency = 0.42
    cardStroke.Thickness = 1

    local initialBox = card:FindFirstChildWhichIsA("Frame")
    if initialBox then
        initialBox.BackgroundColor3 = Color3.fromHex("#211729")
        initialBox.BackgroundTransparency = 0.02
        local initialStroke = initialBox:FindFirstChildOfClass("UIStroke")
        if initialStroke then
            initialStroke.Color = THEME.NeonSoft
            initialStroke.Transparency = 0.34
        end
    end

    selectButton.BackgroundColor3 = Color3.fromHex("#1D1624")
    selectButton.BackgroundTransparency = 0.02
    local selectStroke = selectButton:FindFirstChildOfClass("UIStroke")
    if selectStroke then
        selectStroke.Color = THEME.NeonSoft
        selectStroke.Transparency = 0.36
    end

    if favorite then
        favorite.ImageColor3 = favorites[id] and THEME.Pink or THEME.Faint
        favorite.ImageTransparency = favorites[id] and 0 or 0.06

        favorite.MouseEnter:Connect(function()
            tween(favorite, 0.10, { ImageColor3 = THEME.Pink, ImageTransparency = 0 })
        end)

        favorite.MouseLeave:Connect(function()
            tween(favorite, 0.10, {
                ImageColor3 = favorites[id] and THEME.Pink or THEME.Faint,
                ImageTransparency = favorites[id] and 0 or 0.06,
            })
        end)
    end

    card.MouseEnter:Connect(function()
        tween(scale, 0.12, { Scale = 1.009 })
        tween(card, 0.12, { BackgroundColor3 = Color3.fromHex("#1A1520") })
        tween(cardStroke, 0.12, { Color = THEME.Neon, Transparency = 0.10 })
        if selectStroke then
            tween(selectStroke, 0.12, { Color = THEME.Neon, Transparency = 0.14 })
        end
    end)

    card.MouseLeave:Connect(function()
        tween(scale, 0.14, { Scale = 1 })
        tween(card, 0.14, {
            BackgroundColor3 = selectedId == id and THEME.Button or Color3.fromHex("#15111A")
        })
        tween(cardStroke, 0.14, {
            Color = selectedId == id and THEME.AccentBright or THEME.NeonSoft,
            Transparency = selectedId == id and 0.16 or 0.42,
        })
        if selectStroke then
            tween(selectStroke, 0.14, { Color = THEME.NeonSoft, Transparency = 0.36 })
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

local openingScale = create("UIScale", { Scale = 0.99, Parent = main })
tween(openingScale, 0.18, { Scale = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

refresh()
updateCardSelection()]=],
"clean neon polish"
)

local chunk, compileError = loadstring(source)
if not chunk then
    error("[Velora Hub] Failed to compile patched HubCore: " .. tostring(compileError), 0)
end

return chunk()