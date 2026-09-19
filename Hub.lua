-- Velora Hub
-- Premium Vanta-style script library.
-- RightShift toggles the window. Ctrl/Cmd + K focuses search.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local THEME = {
    Background = Color3.fromHex("#060606"),
    Surface = Color3.fromHex("#0B0A0D"),
    SurfaceRaised = Color3.fromHex("#111014"),
    SurfaceHover = Color3.fromHex("#141218"),
    Border = Color3.fromHex("#242129"),
    BorderHover = Color3.fromHex("#3D3349"),
    Accent = Color3.fromHex("#36255C"),
    AccentSoft = Color3.fromHex("#1C1529"),
    AccentBright = Color3.fromHex("#9D7ED9"),
    Text = Color3.fromHex("#F6F3FA"),
    TextSoft = Color3.fromHex("#DFDAE7"),
    Muted = Color3.fromHex("#8B8491"),
    Faint = Color3.fromHex("#5E5864"),
    Success = Color3.fromHex("#69C99A"),
    Danger = Color3.fromHex("#D06D82"),
}

local ICON_BASE = "https://raw.githubusercontent.com/MrRos3/SaltyIcons/main/icons/png/96/"
local BRAND_URL = "https://raw.githubusercontent.com/MrRos3/VantaUI/main/assets/vanta-brand-v2.jpeg"

local SCRIPTS = {
    {
        Id = "velora-piano",
        Name = "Velora Piano",
        Category = "Universal",
        Game = "Universal",
        Description = "A polished piano player and song workstation built for expressive sessions.",
        Tags = { "piano", "music", "songs", "workstation" },
        Updated = 4,
        Url = "https://raw.githubusercontent.com/MrRos3/Velora/main/loader.lua",
        ImageUrl = "https://raw.githubusercontent.com/MrRos3/Hub/main/assets/cards/velora-piano.jpg",
    },
    {
        Id = "shadow-network",
        Name = "Shadow Network",
        Category = "Games",
        Game = "Shadow Network",
        Description = "Focused utilities, ESP, item tools, and automation in one lightweight build.",
        Tags = { "shadow network", "items", "esp", "automation" },
        Updated = 3,
        Url = "https://raw.githubusercontent.com/MrRos3/Hub/main/scripts/ShadowNetwork.lua",
        ImageUrl = "https://raw.githubusercontent.com/MrRos3/Hub/main/assets/cards/shadow-network.jpg",
    },
    {
        Id = "salty-mm2",
        Name = "Salty MM2",
        Category = "Games",
        Game = "Murder Mystery 2",
        Description = "Performance-first role tools, ESP, coins, and sheriff utilities for MM2.",
        Tags = { "murder mystery 2", "roles", "esp", "coins", "sheriff" },
        Updated = 2,
        Url = "https://raw.githubusercontent.com/MrRos3/Hub/main/scripts/MM2.lua",
        ImageUrl = "https://raw.githubusercontent.com/MrRos3/Hub/main/assets/cards/mm2.jpg",
    },
    {
        Id = "alzzmys-dances",
        Name = "Alzzmy's DANCES",
        Category = "Universal",
        Game = "Universal",
        Description = "A clean dance and animation library that stays quick, simple, and fun.",
        Tags = { "dance", "animations", "emotes", "universal" },
        Updated = 1,
        Url = "https://raw.githubusercontent.com/MrRos3/Hub/main/scripts/Dances.lua",
        ImageUrl = "https://raw.githubusercontent.com/MrRos3/Hub/main/assets/cards/alzzmys-dances.jpg",
    },
}

local function create(className, props, children)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

local function corner(radius)
    return create("UICorner", { CornerRadius = UDim.new(0, radius) })
end

local function stroke(color, transparency, thickness)
    return create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = color,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
    })
end

local function tween(obj, duration, props)
    local t = TweenService:Create(obj, TweenInfo.new(duration or 0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function normalize(value)
    return string.lower(tostring(value or ""))
end

local function compactError(value)
    local msg = tostring(value or "Unknown error")
    msg = msg:gsub("\r", " "):gsub("\n+", " "):gsub("%s+", " ")
    if #msg > 180 then
        msg = msg:sub(1, 177) .. "..."
    end
    return msg
end

local function getGuiParent()
    local ok, result = pcall(function()
        if type(gethui) == "function" then
            return gethui()
        end
        return CoreGui
    end)
    if ok and result then
        return result
    end
    return player:WaitForChild("PlayerGui")
end

local assetFunction = getcustomasset or getsynasset
local canUseFiles = type(writefile) == "function"
    and type(readfile) == "function"
    and type(isfile) == "function"
    and type(makefolder) == "function"
    and type(isfolder) == "function"
local canCacheAssets = canUseFiles and type(assetFunction) == "function"

local function ensureFolder(path)
    if not canUseFiles then
        return false
    end
    if not isfolder(path) then
        local ok = pcall(makefolder, path)
        if not ok then
            return false
        end
    end
    return true
end

local function cacheRemoteAsset(url, path, fallback)
    if canCacheAssets then
        ensureFolder("SaltyHub")
        ensureFolder("SaltyHub/assets")
        if not isfile(path) then
            local ok, bytes = pcall(function()
                return game:HttpGet(url)
            end)
            if ok and type(bytes) == "string" and #bytes > 100 then
                pcall(writefile, path, bytes)
            end
        end
        if isfile(path) then
            local ok, asset = pcall(assetFunction, path)
            if ok and asset and asset ~= "" then
                return asset
            end
        end
    end
    return fallback or ""
end

local ICONS = {
    search = { "misc/search.png", "rbxassetid://100557104978626" },
    close = { "status/x.png", "rbxassetid://104564513546348" },
    minus = { "status/minus.png", "rbxassetid://123173530093622" },
    star = { "misc/star.png", "rbxassetid://130603316912957" },
}

local iconCache = {}
local function icon(name)
    if iconCache[name] then
        return iconCache[name]
    end
    local item = ICONS[name]
    if not item then
        return ""
    end
    local path = "SaltyHub/assets/icon_" .. name .. ".png"
    local asset = cacheRemoteAsset(ICON_BASE .. item[1], path, item[2])
    iconCache[name] = asset
    return asset
end

local brandAsset = cacheRemoteAsset(BRAND_URL, "SaltyHub/assets/velora_brand.jpeg", "")

local function cachedCardAsset(entry)
    if not entry.ImageUrl then
        return ""
    end
    local path = "SaltyHub/assets/card_" .. tostring(entry.Id) .. "_v20.jpg"
    return cacheRemoteAsset(entry.ImageUrl, path, "")
end

local favorites = {}
local favoritesPath = "SaltyHub/favorites.json"

local function loadFavorites()
    if not canUseFiles or not isfile(favoritesPath) then
        return
    end
    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(favoritesPath))
    end)
    if ok and type(decoded) == "table" then
        for id, value in pairs(decoded) do
            favorites[id] = value == true
        end
    end
end

local function saveFavorites()
    if not canUseFiles then
        return
    end
    ensureFolder("SaltyHub")
    pcall(function()
        writefile(favoritesPath, HttpService:JSONEncode(favorites))
    end)
end

loadFavorites()

local parent = getGuiParent()
local old = parent:FindFirstChild("SaltyHub")
if old then
    old:Destroy()
end

local gui = create("ScreenGui", {
    Name = "SaltyHub",
    DisplayOrder = 999999,
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = parent,
})

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
    end
end)

local backdrop = create("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 0.68,
    BorderSizePixel = 0,
    Parent = gui,
})

local main = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(980, 610),
    BackgroundColor3 = THEME.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = backdrop,
}, {
    corner(12),
    stroke(Color3.fromHex("#2D2932"), 0.1, 1),
})

local mainScale = create("UIScale", { Scale = 1, Parent = main })

local topbar = create("Frame", {
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundColor3 = Color3.fromHex("#080709"),
    BorderSizePixel = 0,
    Active = true,
    Parent = main,
})

create("Frame", {
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = Color3.fromHex("#1A171E"),
    BorderSizePixel = 0,
    Parent = topbar,
})

local brand = create("Frame", {
    Position = UDim2.fromOffset(16, 9),
    Size = UDim2.fromOffset(220, 40),
    BackgroundTransparency = 1,
    Parent = topbar,
})

local brandIcon = create("Frame", {
    Position = UDim2.fromOffset(0, 2),
    Size = UDim2.fromOffset(36, 36),
    BackgroundColor3 = THEME.SurfaceRaised,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = brand,
}, {
    corner(9),
    stroke(Color3.fromHex("#4A3A64"), 0.2, 1),
})

if brandAsset ~= "" then
    create("ImageLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Image = brandAsset,
        ScaleType = Enum.ScaleType.Crop,
        Parent = brandIcon,
    })
else
    create("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "V",
        TextColor3 = THEME.Text,
        TextSize = 17,
        Font = Enum.Font.GothamBold,
        Parent = brandIcon,
    })
end

create("TextLabel", {
    Position = UDim2.fromOffset(48, 1),
    Size = UDim2.fromOffset(150, 20),
    BackgroundTransparency = 1,
    Text = "VELORA",
    TextColor3 = THEME.Text,
    TextSize = 14,
    Font = Enum.Font.GothamSemibold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = brand,
})

create("TextLabel", {
    Position = UDim2.fromOffset(48, 21),
    Size = UDim2.fromOffset(150, 14),
    BackgroundTransparency = 1,
    Text = "SCRIPT HUB",
    TextColor3 = THEME.Muted,
    TextSize = 8,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = brand,
})

local status = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.fromOffset(110, 22),
    BackgroundTransparency = 1,
    Parent = topbar,
})

create("Frame", {
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 0, 0.5, 0),
    Size = UDim2.fromOffset(5, 5),
    BackgroundColor3 = THEME.Success,
    BorderSizePixel = 0,
    Parent = status,
}, { corner(5) })

create("TextLabel", {
    Position = UDim2.fromOffset(12, 0),
    Size = UDim2.new(1, -12, 1, 0),
    BackgroundTransparency = 1,
    Text = "LIBRARY ONLINE",
    TextColor3 = THEME.Faint,
    TextSize = 8,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = status,
})

local topActions = create("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -12, 0.5, 0),
    Size = UDim2.fromOffset(156, 32),
    BackgroundTransparency = 1,
    Parent = topbar,
})

local shortcut = create("TextButton", {
    Position = UDim2.fromOffset(0, 1),
    Size = UDim2.fromOffset(82, 30),
    BackgroundColor3 = THEME.Surface,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "CTRL K",
    TextColor3 = THEME.Faint,
    TextSize = 8,
    Font = Enum.Font.GothamMedium,
    Parent = topActions,
}, {
    corner(7),
    stroke(THEME.Border, 0.1, 1),
})

local function topIcon(name, offset, hoverTint)
    local button = create("ImageButton", {
        Position = UDim2.fromOffset(offset, 2),
        Size = UDim2.fromOffset(28, 28),
        BackgroundColor3 = THEME.Surface,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Image = icon(name),
        ImageColor3 = THEME.Muted,
        ScaleType = Enum.ScaleType.Fit,
        Parent = topActions,
    }, {
        corner(7),
        create("UIPadding", {
            PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7),
            PaddingTop = UDim.new(0, 7), PaddingBottom = UDim.new(0, 7),
        }),
    })
    button.MouseEnter:Connect(function()
        tween(button, 0.12, { BackgroundTransparency = 0, ImageColor3 = hoverTint or THEME.TextSoft })
    end)
    button.MouseLeave:Connect(function()
        tween(button, 0.12, { BackgroundTransparency = 1, ImageColor3 = THEME.Muted })
    end)
    return button
end

local minimizeButton = topIcon("minus", 94)
local closeButton = topIcon("close", 128, THEME.Danger)

local content = create("Frame", {
    Position = UDim2.fromOffset(0, 58),
    Size = UDim2.new(1, 0, 1, -58),
    BackgroundTransparency = 1,
    Parent = main,
})

local searchWrap = create("Frame", {
    Position = UDim2.fromOffset(18, 16),
    Size = UDim2.new(1, -36, 0, 46),
    BackgroundColor3 = THEME.Surface,
    BorderSizePixel = 0,
    Parent = content,
}, {
    corner(9),
    stroke(THEME.Border, 0, 1),
})

create("ImageLabel", {
    Position = UDim2.fromOffset(14, 13),
    Size = UDim2.fromOffset(20, 20),
    BackgroundTransparency = 1,
    Image = icon("search"),
    ImageColor3 = THEME.Muted,
    ScaleType = Enum.ScaleType.Fit,
    Parent = searchWrap,
})

local searchBox = create("TextBox", {
    Position = UDim2.fromOffset(44, 0),
    Size = UDim2.new(1, -92, 1, 0),
    BackgroundTransparency = 1,
    ClearTextOnFocus = false,
    PlaceholderText = "Search games or scripts...",
    PlaceholderColor3 = THEME.Faint,
    Text = "",
    TextColor3 = THEME.TextSoft,
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = searchWrap,
})

local searchShortcut = create("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -10, 0.5, 0),
    Size = UDim2.fromOffset(26, 24),
    BackgroundColor3 = Color3.fromHex("#100F12"),
    BorderSizePixel = 0,
    Text = "/",
    TextColor3 = THEME.Faint,
    TextSize = 10,
    Font = Enum.Font.Code,
    AutoButtonColor = false,
    Parent = searchWrap,
}, {
    corner(5),
    stroke(THEME.Border, 0.1, 1),
})

local searchStroke = searchWrap:FindFirstChildOfClass("UIStroke")
searchBox.Focused:Connect(function()
    tween(searchStroke, 0.15, { Color = THEME.BorderHover })
end)
searchBox.FocusLost:Connect(function()
    tween(searchStroke, 0.15, { Color = THEME.Border })
end)

local toolbar = create("Frame", {
    Position = UDim2.fromOffset(18, 72),
    Size = UDim2.new(1, -36, 0, 34),
    BackgroundTransparency = 1,
    Parent = content,
})

local filterHolder = create("Frame", {
    Size = UDim2.new(0, 420, 1, 0),
    BackgroundTransparency = 1,
    Parent = toolbar,
}, {
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 6),
        VerticalAlignment = Enum.VerticalAlignment.Center,
    }),
})

local countLabel = create("TextLabel", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, 0, 0.5, 0),
    Size = UDim2.fromOffset(88, 28),
    BackgroundColor3 = THEME.Surface,
    BorderSizePixel = 0,
    Text = "4 scripts",
    TextColor3 = THEME.Muted,
    TextSize = 8,
    Font = Enum.Font.GothamMedium,
    Parent = toolbar,
}, {
    corner(7),
    stroke(THEME.Border, 0.1, 1),
})

create("Frame", {
    Position = UDim2.fromOffset(18, 113),
    Size = UDim2.new(1, -36, 0, 1),
    BackgroundColor3 = Color3.fromHex("#17151B"),
    BorderSizePixel = 0,
    Parent = content,
})

local heading = create("Frame", {
    Position = UDim2.fromOffset(18, 132),
    Size = UDim2.new(1, -36, 0, 50),
    BackgroundTransparency = 1,
    Parent = content,
})

create("TextLabel", {
    Size = UDim2.fromOffset(180, 13),
    BackgroundTransparency = 1,
    Text = "SCRIPT LIBRARY",
    TextColor3 = THEME.Faint,
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = heading,
})

local headingTitle = create("TextLabel", {
    Position = UDim2.fromOffset(0, 18),
    Size = UDim2.fromOffset(320, 27),
    BackgroundTransparency = 1,
    RichText = true,
    Text = '<font color="#F6F3FA"><b>Browse scripts</b></font>  <font color="#67616D">4</font>',
    TextSize = 19,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = heading,
})

create("TextLabel", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, 0, 1, -4),
    Size = UDim2.fromOffset(150, 24),
    BackgroundTransparency = 1,
    Text = "Recently updated",
    TextColor3 = THEME.Faint,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Right,
    Parent = heading,
})

local grid = create("ScrollingFrame", {
    Position = UDim2.fromOffset(18, 190),
    Size = UDim2.new(1, -36, 1, -206),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = THEME.Accent,
    ScrollBarImageTransparency = 0.35,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(),
    Parent = content,
})

local gridLayout = create("UIGridLayout", {
    CellPadding = UDim2.fromOffset(10, 10),
    CellSize = UDim2.fromOffset(304, 214),
    FillDirectionMaxCells = 3,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = grid,
})

create("UIPadding", {
    PaddingBottom = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 4),
    Parent = grid,
})

local emptyLabel = create("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.60, 0),
    Size = UDim2.fromOffset(320, 70),
    BackgroundTransparency = 1,
    Text = "No scripts found\nTry another search or filter.",
    TextColor3 = THEME.Muted,
    TextSize = 12,
    Font = Enum.Font.GothamMedium,
    TextWrapped = true,
    Visible = false,
    Parent = content,
})

local notificationHost = create("Frame", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -18, 1, -18),
    Size = UDim2.fromOffset(320, 250),
    BackgroundTransparency = 1,
    ZIndex = 50,
    Parent = backdrop,
}, {
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 8),
    }),
})

local notificationId = 0
local function notify(title, message, kind)
    notificationId += 1
    local accent = kind == "error" and THEME.Danger or THEME.AccentBright
    local notice = create("Frame", {
        LayoutOrder = -notificationId,
        Size = UDim2.fromOffset(310, 70),
        BackgroundColor3 = THEME.SurfaceRaised,
        BorderSizePixel = 0,
        ZIndex = 51,
        Parent = notificationHost,
    }, {
        corner(10),
        stroke(kind == "error" and THEME.Danger or THEME.BorderHover, 0.25, 1),
    })

    create("Frame", {
        Position = UDim2.fromOffset(0, 10),
        Size = UDim2.new(0, 3, 1, -20),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        ZIndex = 52,
        Parent = notice,
    }, { corner(3) })

    create("TextLabel", {
        Position = UDim2.fromOffset(16, 9),
        Size = UDim2.new(1, -32, 0, 20),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = THEME.TextSoft,
        TextSize = 11,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 52,
        Parent = notice,
    })

    create("TextLabel", {
        Position = UDim2.fromOffset(16, 31),
        Size = UDim2.new(1, -32, 0, 28),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = THEME.Muted,
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 52,
        Parent = notice,
    })

    task.delay(kind == "error" and 5.5 or 2.8, function()
        if notice.Parent then
            notice:Destroy()
        end
    end)
end

local currentFilter = "All Scripts"
local filterButtons = {}
local cards = {}
local shown = true
local closed = false
local toggleConnection

local function makeFilter(label, width)
    local button = create("TextButton", {
        Size = UDim2.fromOffset(width, 30),
        BackgroundColor3 = THEME.AccentSoft,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = label,
        TextColor3 = THEME.Muted,
        TextSize = 9,
        Font = Enum.Font.GothamMedium,
        Parent = filterHolder,
    }, { corner(7) })
    local outline = stroke(THEME.BorderHover, 1, 1)
    outline.Parent = button
    filterButtons[label] = { Button = button, Stroke = outline }
    return button
end

makeFilter("All Scripts", 76)
makeFilter("Games", 58)
makeFilter("Universal", 70)
makeFilter("Favorites", 70)

local function updateFilters()
    for label, data in pairs(filterButtons) do
        local active = currentFilter == label
        tween(data.Button, 0.12, {
            BackgroundTransparency = active and 0 or 1,
            TextColor3 = active and THEME.TextSoft or THEME.Muted,
        })
        data.Stroke.Transparency = active and 0.35 or 1
    end
end

local function updateFavoriteVisual(data)
    local active = favorites[data.Entry.Id] == true
    data.Favorite.ImageColor3 = active and THEME.AccentBright or THEME.Faint
    data.Favorite.ImageTransparency = active and 0 or 0.1
end

local function makeCard(entry, order)
    local card = create("Frame", {
        Name = entry.Id,
        LayoutOrder = order,
        BackgroundColor3 = THEME.Surface,
        BorderSizePixel = 0,
        Parent = grid,
    }, { corner(9) })

    local cardStroke = stroke(THEME.Border, 0.12, 1)
    cardStroke.Parent = card
    local cardScale = create("UIScale", { Scale = 1, Parent = card })

    local iconBox = create("Frame", {
        Position = UDim2.fromOffset(14, 14),
        Size = UDim2.fromOffset(44, 44),
        BackgroundColor3 = THEME.AccentSoft,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = card,
    }, {
        corner(10),
        stroke(Color3.fromHex("#4B3A63"), 0.35, 1),
    })

    local fallback = create("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = string.upper((entry.Name:match("%a") or "?")),
        TextColor3 = THEME.AccentBright,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        Parent = iconBox,
    })

    local image = cachedCardAsset(entry)
    if image ~= "" then
        fallback.Visible = false
        create("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Image = image,
            ScaleType = Enum.ScaleType.Crop,
            ZIndex = 4,
            Parent = iconBox,
        }, { corner(10) })
    end

    local favorite = create("ImageButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 12),
        Size = UDim2.fromOffset(28, 28),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Image = icon("star"),
        ImageColor3 = THEME.Faint,
        ScaleType = Enum.ScaleType.Fit,
        Parent = card,
    }, {
        create("UIPadding", {
            PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5),
        }),
    })

    create("TextLabel", {
        Position = UDim2.fromOffset(14, 69),
        Size = UDim2.new(1, -28, 0, 22),
        BackgroundTransparency = 1,
        Text = entry.Name,
        TextColor3 = THEME.TextSoft,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = card,
    })

    create("TextLabel", {
        Position = UDim2.fromOffset(14, 91),
        Size = UDim2.new(1, -28, 0, 17),
        BackgroundTransparency = 1,
        Text = string.upper(entry.Category) .. "  /  " .. entry.Game,
        TextColor3 = THEME.Faint,
        TextSize = 7,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = card,
    })

    create("TextLabel", {
        Position = UDim2.fromOffset(14, 119),
        Size = UDim2.new(1, -28, 0, 42),
        BackgroundTransparency = 1,
        Text = entry.Description,
        TextColor3 = THEME.Muted,
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = card,
    })

    local loadButton = create("TextButton", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 14, 1, -14),
        Size = UDim2.new(1, -28, 0, 32),
        BackgroundColor3 = THEME.Accent,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "Load Script",
        TextColor3 = THEME.TextSoft,
        TextSize = 9,
        Font = Enum.Font.GothamMedium,
        Parent = card,
    }, {
        corner(6),
        stroke(Color3.fromHex("#574274"), 0.25, 1),
    })

    card.MouseEnter:Connect(function()
        tween(card, 0.14, { BackgroundColor3 = THEME.SurfaceHover })
        tween(cardScale, 0.14, { Scale = 1.008 })
        cardStroke.Color = THEME.BorderHover
        cardStroke.Transparency = 0.04
    end)
    card.MouseLeave:Connect(function()
        tween(card, 0.14, { BackgroundColor3 = THEME.Surface })
        tween(cardScale, 0.14, { Scale = 1 })
        cardStroke.Color = THEME.Border
        cardStroke.Transparency = 0.12
    end)

    loadButton.MouseEnter:Connect(function()
        tween(loadButton, 0.12, { BackgroundColor3 = Color3.fromHex("#463273") })
    end)
    loadButton.MouseLeave:Connect(function()
        tween(loadButton, 0.12, { BackgroundColor3 = THEME.Accent })
    end)

    favorite.MouseButton1Click:Connect(function()
        favorites[entry.Id] = not favorites[entry.Id]
        saveFavorites()
        updateFavoriteVisual(cards[entry.Id])
    end)

    loadButton.MouseButton1Click:Connect(function()
        notify(entry.Name, "Loading latest build...", "info")
        gui.Enabled = false
        shown = false
        task.spawn(function()
            local ok, err = pcall(function()
                local source = game:HttpGet(entry.Url)
                local chunk, compileError = loadstring(source)
                if not chunk then
                    error(compileError or "Failed to compile script")
                end
                chunk()
            end)
            if not ok then
                gui.Enabled = true
                shown = true
                notify(entry.Name .. " could not launch", compactError(err), "error")
            end
        end)
    end)

    cards[entry.Id] = {
        Entry = entry,
        Card = card,
        Favorite = favorite,
    }
    updateFavoriteVisual(cards[entry.Id])
end

for i, entry in ipairs(SCRIPTS) do
    makeCard(entry, i)
end

local function refresh()
    local query = normalize(searchBox.Text)
    local visible = 0

    for _, entry in ipairs(SCRIPTS) do
        local searchable = normalize(entry.Name .. " " .. entry.Game .. " " .. entry.Category .. " " .. entry.Description .. " " .. table.concat(entry.Tags, " "))
        local searchMatch = query == "" or string.find(searchable, query, 1, true) ~= nil
        local filterMatch = currentFilter == "All Scripts"
            or (currentFilter == "Games" and entry.Category == "Games")
            or (currentFilter == "Universal" and entry.Category == "Universal")
            or (currentFilter == "Favorites" and favorites[entry.Id] == true)

        local isVisible = searchMatch and filterMatch
        cards[entry.Id].Card.Visible = isVisible
        if isVisible then
            visible += 1
        end
    end

    countLabel.Text = tostring(visible) .. (visible == 1 and " script" or " scripts")
    headingTitle.Text = '<font color="#F6F3FA"><b>Browse scripts</b></font>  <font color="#67616D">' .. tostring(visible) .. '</font>'
    emptyLabel.Visible = visible == 0
    updateFilters()
end

for label, data in pairs(filterButtons) do
    data.Button.MouseButton1Click:Connect(function()
        currentFilter = label
        refresh()
    end)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(refresh)
searchShortcut.MouseButton1Click:Connect(function()
    searchBox:CaptureFocus()
end)
shortcut.MouseButton1Click:Connect(function()
    searchBox:CaptureFocus()
end)

local function updateGrid()
    local width = grid.AbsoluteSize.X
    if width <= 0 then
        return
    end
    local columns = width >= 890 and 3 or (width >= 590 and 2 or 1)
    local gap = 10
    local usable = width - 4 - gap * (columns - 1)
    gridLayout.FillDirectionMaxCells = columns
    gridLayout.CellSize = UDim2.fromOffset(math.floor(usable / columns), 214)
end

grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGrid)

local function updateScale()
    local camera = Workspace.CurrentCamera
    if not camera then
        return
    end
    local viewport = camera.ViewportSize
    local sx = math.clamp((viewport.X - 48) / 980, 0.66, 1)
    local sy = math.clamp((viewport.Y - 48) / 610, 0.66, 1)
    mainScale.Scale = math.min(sx, sy)
end

if Workspace.CurrentCamera then
    Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end
updateScale()
task.defer(updateGrid)

local function setShown(value)
    shown = value
    gui.Enabled = value
end

minimizeButton.MouseButton1Click:Connect(function()
    setShown(false)
end)

closeButton.MouseButton1Click:Connect(function()
    closed = true
    if toggleConnection then
        toggleConnection:Disconnect()
    end
    gui:Destroy()
end)

toggleConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or closed then
        return
    end
    if input.KeyCode == Enum.KeyCode.RightShift then
        setShown(not shown)
    elseif input.KeyCode == Enum.KeyCode.K and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
        if not shown then
            setShown(true)
        end
        searchBox:CaptureFocus()
    end
end)

local dragging = false
local dragStart
local startPosition

topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

refresh()
