-- Salty Hub
-- Complete premium Roblox script-library UI.
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
    Surface = Color3.fromHex("#0C0B0F"),
    SurfaceRaised = Color3.fromHex("#111014"),
    SurfaceSoft = Color3.fromHex("#0D0C0F"),
    Border = Color3.fromHex("#211E26"),
    BorderStrong = Color3.fromHex("#4A3860"),
    Accent = Color3.fromHex("#36255C"),
    AccentSoft = Color3.fromHex("#211735"),
    AccentBright = Color3.fromHex("#BCA3EB"),
    AccentMuted = Color3.fromHex("#8C6BD1"),
    Text = Color3.fromHex("#F4F2F7"),
    TextSoft = Color3.fromHex("#E7E2EB"),
    Muted = Color3.fromHex("#837C89"),
    Faint = Color3.fromHex("#645E6D"),
    Success = Color3.fromHex("#6DCE9E"),
    Danger = Color3.fromHex("#D06D82"),
}

local SCRIPTS = {
    {
        Id = "velora-piano",
        Name = "Velora Piano",
        Category = "Universal",
        Game = "Universal",
        Description = "A polished piano player and song workstation built for expressive sessions.",
        Tags = { "piano", "music", "songs", "workstation" },
        Popular = true,
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
        Tags = { "items", "esp", "automation", "utilities" },
        Popular = true,
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
        Popular = true,
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
        Popular = false,
        Updated = 1,
        Url = "https://raw.githubusercontent.com/MrRos3/Hub/main/scripts/Dances.lua",
        ImageUrl = "https://raw.githubusercontent.com/MrRos3/Hub/main/assets/cards/alzzmys-dances.jpg",
    },
}

local function create(className, properties, children)
    local instance = Instance.new(className)
    for property, value in pairs(properties or {}) do
        instance[property] = value
    end
    for _, child in ipairs(children or {}) do
        child.Parent = instance
    end
    return instance
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

local function tween(instance, duration, properties, style, direction)
    local animation = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or 0.18,
            style or Enum.EasingStyle.Quint,
            direction or Enum.EasingDirection.Out
        ),
        properties
    )
    animation:Play()
    return animation
end

local function bindHover(instance, enterProperties, leaveProperties, duration)
    instance.MouseEnter:Connect(function()
        tween(instance, duration or 0.16, enterProperties)
    end)
    instance.MouseLeave:Connect(function()
        tween(instance, duration or 0.16, leaveProperties)
    end)
end

local function normalize(value)
    return string.lower(tostring(value or ""))
end

local function compactError(value)
    local message = tostring(value or "Unknown error")
    message = message:gsub("\r", " "):gsub("\n+", " "):gsub("%s+", " ")
    if #message > 190 then
        message = message:sub(1, 187) .. "..."
    end
    return message
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

local function scriptInitial(name)
    return string.upper((tostring(name):match("%a") or "?"))
end

local assetFunction = getcustomasset or getsynasset
local canUseFiles = type(writefile) == "function"
    and type(isfile) == "function"
    and type(makefolder) == "function"
    and type(isfolder) == "function"
local canCacheAssets = canUseFiles
    and type(assetFunction) == "function"

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

local function safeFileName(value)
    return tostring(value):gsub("[^%w%-_]", "-")
end

local function cachedAsset(entry)
    if not canCacheAssets or not entry.ImageUrl then
        return ""
    end
    if not ensureFolder("SaltyHub") or not ensureFolder("SaltyHub/assets") then
        return ""
    end

    local path = "SaltyHub/assets/" .. safeFileName(entry.Id) .. "_v18.jpg"
    if not isfile(path) then
        local ok, bytes = pcall(function()
            return game:HttpGet(entry.ImageUrl)
        end)
        if ok and type(bytes) == "string" and #bytes > 100 then
            pcall(writefile, path, bytes)
        end
    end

    if isfile(path) then
        local ok, asset = pcall(assetFunction, path)
        if ok and asset then
            return asset
        end
    end
    return ""
end

local favorites = {}
local favoritesPath = "SaltyHub/favorites.json"

local function loadFavorites()
    if type(readfile) ~= "function" or type(isfile) ~= "function" or not isfile(favoritesPath) then
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
    if type(writefile) ~= "function" then
        return
    end
    ensureFolder("SaltyHub")
    pcall(function()
        writefile(favoritesPath, HttpService:JSONEncode(favorites))
    end)
end

loadFavorites()

local parent = getGuiParent()
local oldGui = parent:FindFirstChild("SaltyHub")
if oldGui then
    oldGui:Destroy()
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
    Name = "Backdrop",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 0.68,
    BorderSizePixel = 0,
    Parent = gui,
})

-- Use a plain Frame here. Some executor renderers incorrectly preserve a
-- CanvasGroup's initial GroupTransparency and make every descendant almost black.
local main = create("Frame", {
    Name = "Window",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(1080, 680),
    BackgroundColor3 = THEME.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = backdrop,
}, {
    corner(12),
    stroke(THEME.Border, 0, 1),
})

local windowScale = create("UIScale", {
    Scale = 0.96,
    Parent = main,
})

create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("#09070D")),
        ColorSequenceKeypoint.new(0.38, THEME.Background),
        ColorSequenceKeypoint.new(1, Color3.fromHex("#050505")),
    }),
    Rotation = 18,
    Parent = main,
})

local topbar = create("Frame", {
    Name = "Topbar",
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundColor3 = THEME.Background,
    BackgroundTransparency = 0.03,
    BorderSizePixel = 0,
    Active = true,
    Parent = main,
})

create("Frame", {
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = Color3.fromHex("#17151B"),
    BorderSizePixel = 0,
    Parent = topbar,
})

local brand = create("Frame", {
    Position = UDim2.fromOffset(22, 14),
    Size = UDim2.fromOffset(190, 30),
    BackgroundTransparency = 1,
    Parent = topbar,
})

local brandMark = create("Frame", {
    Position = UDim2.fromOffset(0, 1),
    Size = UDim2.fromOffset(28, 28),
    BackgroundColor3 = Color3.fromHex("#1E1432"),
    BorderSizePixel = 0,
    Parent = brand,
}, {
    corner(7),
    stroke(Color3.fromHex("#5A3E8F"), 0, 1),
})

create("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "✦",
    TextColor3 = THEME.AccentBright,
    TextSize = 17,
    Font = Enum.Font.GothamBold,
    Parent = brandMark,
})

create("TextLabel", {
    Position = UDim2.fromOffset(38, 0),
    Size = UDim2.fromOffset(112, 30),
    BackgroundTransparency = 1,
    RichText = true,
    Text = '<font color="#F6F3FB"><b>salty</b></font><font color="#77717D">.hub</font>',
    TextSize = 15,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = brand,
})

local status = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(100, 24),
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
    TextSize = 9,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = status,
})

local topActions = create("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -14, 0.5, 0),
    Size = UDim2.fromOffset(158, 32),
    BackgroundTransparency = 1,
    Parent = topbar,
})

local shortcutButton = create("TextButton", {
    Position = UDim2.fromOffset(0, 1),
    Size = UDim2.fromOffset(88, 30),
    BackgroundColor3 = THEME.SurfaceSoft,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "⌘   CTRL K",
    TextColor3 = THEME.Faint,
    TextSize = 9,
    Font = Enum.Font.GothamMedium,
    Parent = topActions,
}, {
    corner(6),
    stroke(Color3.fromHex("#242128"), 0, 1),
})
bindHover(shortcutButton, { TextColor3 = THEME.TextSoft, BackgroundColor3 = THEME.SurfaceRaised }, { TextColor3 = THEME.Faint, BackgroundColor3 = THEME.SurfaceSoft })

local function topIcon(text, offset, hoverColor)
    local button = create("TextButton", {
        Position = UDim2.fromOffset(offset, 1),
        Size = UDim2.fromOffset(30, 30),
        BackgroundColor3 = THEME.SurfaceSoft,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = text,
        TextColor3 = THEME.Faint,
        TextSize = 16,
        Font = Enum.Font.GothamMedium,
        Parent = topActions,
    }, { corner(6) })
    bindHover(button, {
        BackgroundTransparency = 0,
        TextColor3 = hoverColor or THEME.TextSoft,
    }, {
        BackgroundTransparency = 1,
        TextColor3 = THEME.Faint,
    }, 0.12)
    return button
end

local minimizeButton = topIcon("—", 94)
local closeButton = topIcon("×", 128, THEME.Danger)

local content = create("Frame", {
    Position = UDim2.fromOffset(0, 58),
    Size = UDim2.new(1, 0, 1, -58),
    BackgroundTransparency = 1,
    Parent = main,
})

local searchWrap = create("Frame", {
    Name = "Search",
    Position = UDim2.fromOffset(22, 18),
    Size = UDim2.new(1, -44, 0, 52),
    BackgroundColor3 = THEME.SurfaceSoft,
    BorderSizePixel = 0,
    Parent = content,
}, {
    corner(9),
    stroke(Color3.fromHex("#2A2533"), 0, 1),
})

create("TextLabel", {
    Position = UDim2.fromOffset(16, 0),
    Size = UDim2.fromOffset(20, 52),
    BackgroundTransparency = 1,
    Text = "⌕",
    TextColor3 = Color3.fromHex("#817A8A"),
    TextSize = 22,
    Font = Enum.Font.Gotham,
    Parent = searchWrap,
})

local searchBox = create("TextBox", {
    Position = UDim2.fromOffset(47, 0),
    Size = UDim2.new(1, -100, 1, 0),
    BackgroundTransparency = 1,
    ClearTextOnFocus = false,
    PlaceholderText = "Search games or scripts...",
    PlaceholderColor3 = Color3.fromHex("#77707F"),
    Text = "",
    TextColor3 = Color3.fromHex("#EEEAF2"),
    TextSize = 13,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = searchWrap,
})

local searchShortcut = create("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -13, 0.5, 0),
    Size = UDim2.fromOffset(28, 24),
    BackgroundColor3 = Color3.fromHex("#100F12"),
    BorderSizePixel = 0,
    Text = "/",
    TextColor3 = Color3.fromHex("#77707F"),
    TextSize = 11,
    Font = Enum.Font.Code,
    AutoButtonColor = false,
    Parent = searchWrap,
}, {
    corner(4),
    stroke(Color3.fromHex("#29242D"), 0, 1),
})

local searchStroke = searchWrap:FindFirstChildOfClass("UIStroke")
searchBox.Focused:Connect(function()
    tween(searchWrap, 0.18, { BackgroundColor3 = Color3.fromHex("#100E13") })
    tween(searchStroke, 0.18, { Color = THEME.BorderStrong })
end)
searchBox.FocusLost:Connect(function()
    tween(searchWrap, 0.18, { BackgroundColor3 = THEME.SurfaceSoft })
    tween(searchStroke, 0.18, { Color = Color3.fromHex("#2A2533") })
end)

local toolbar = create("Frame", {
    Position = UDim2.fromOffset(22, 84),
    Size = UDim2.new(1, -44, 0, 38),
    BackgroundTransparency = 1,
    Parent = content,
})

local filterHolder = create("Frame", {
    Size = UDim2.new(0, 440, 1, 0),
    BackgroundTransparency = 1,
    Parent = toolbar,
}, {
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 5),
        VerticalAlignment = Enum.VerticalAlignment.Center,
    }),
})

local sortButton = create("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, 0, 0.5, 0),
    Size = UDim2.fromOffset(154, 30),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "≡   Recently updated   ⌄",
    TextColor3 = Color3.fromHex("#77717E"),
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Right,
    Parent = toolbar,
})
bindHover(sortButton, { TextColor3 = THEME.TextSoft }, { TextColor3 = Color3.fromHex("#77717E") }, 0.12)

create("Frame", {
    Position = UDim2.fromOffset(22, 126),
    Size = UDim2.new(1, -44, 0, 1),
    BackgroundColor3 = Color3.fromHex("#17151B"),
    BorderSizePixel = 0,
    Parent = content,
})

local heading = create("Frame", {
    Position = UDim2.fromOffset(22, 146),
    Size = UDim2.new(1, -44, 0, 50),
    BackgroundTransparency = 1,
    Parent = content,
})

create("TextLabel", {
    Size = UDim2.fromOffset(200, 14),
    BackgroundTransparency = 1,
    Text = "SCRIPT LIBRARY",
    TextColor3 = THEME.Faint,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = heading,
})

local titleLabel = create("TextLabel", {
    Position = UDim2.fromOffset(0, 20),
    Size = UDim2.fromOffset(320, 28),
    BackgroundTransparency = 1,
    RichText = true,
    Text = '<font color="#F4F2F7"><b>Browse scripts</b></font>  <font color="#6F6876">4</font>',
    TextSize = 20,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = heading,
})

local viewHolder = create("Frame", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, 0, 1, 0),
    Size = UDim2.fromOffset(65, 30),
    BackgroundTransparency = 1,
    Parent = heading,
})

local function viewButton(text, x)
    local button = create("TextButton", {
        Position = UDim2.fromOffset(x, 0),
        Size = UDim2.fromOffset(30, 28),
        BackgroundColor3 = THEME.AccentSoft,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = text,
        TextColor3 = THEME.Faint,
        TextSize = 14,
        Font = Enum.Font.Code,
        Parent = viewHolder,
    }, { corner(5) })
    local outline = stroke(THEME.Accent, 1, 1)
    outline.Parent = button
    return button, outline
end

local gridViewButton, gridViewStroke = viewButton("▦", 0)
local listViewButton, listViewStroke = viewButton("☷", 35)

local grid = create("ScrollingFrame", {
    Name = "ScriptLibrary",
    Position = UDim2.fromOffset(22, 210),
    Size = UDim2.new(1, -44, 1, -226),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = THEME.Accent,
    ScrollBarImageTransparency = 0.25,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(),
    Parent = content,
})

local gridLayout = create("UIGridLayout", {
    CellPadding = UDim2.fromOffset(14, 14),
    CellSize = UDim2.fromOffset(330, 248),
    FillDirectionMaxCells = 3,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = grid,
})

create("UIPadding", {
    PaddingBottom = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 4),
    Parent = grid,
})

local emptyState = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.62, 0),
    Size = UDim2.new(1, -44, 0, 180),
    BackgroundColor3 = THEME.Surface,
    BackgroundTransparency = 0.35,
    BorderSizePixel = 0,
    Visible = false,
    Parent = content,
}, {
    corner(9),
    stroke(Color3.fromHex("#28232E"), 0.15, 1),
})

create("TextLabel", {
    Position = UDim2.new(0, 0, 0.5, -37),
    Size = UDim2.new(1, 0, 0, 74),
    BackgroundTransparency = 1,
    RichText = true,
    Text = '<font size="26" color="#8C6BD1">⌕</font>\n<font color="#E7E2EB"><b>No scripts found</b></font>\n<font size="11" color="#69626F">Try another search or filter.</font>',
    TextColor3 = THEME.Muted,
    TextSize = 14,
    Font = Enum.Font.Gotham,
    Parent = emptyState,
})

local notificationHost = create("Frame", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -20, 1, -20),
    Size = UDim2.fromOffset(330, 260),
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

local noticeSequence = 0
local function notify(title, message, kind)
    noticeSequence = noticeSequence + 1
    local accent = kind == "error" and THEME.Danger or THEME.AccentMuted
    local notice = create("Frame", {
        LayoutOrder = -noticeSequence,
        Size = UDim2.fromOffset(320, 72),
        BackgroundColor3 = THEME.SurfaceRaised,
        BorderSizePixel = 0,
        BackgroundTransparency = 0.03,
        ZIndex = 51,
        Parent = notificationHost,
    }, {
        corner(9),
        stroke(kind == "error" and THEME.Danger or THEME.BorderStrong, 0.25, 1),
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
        Position = UDim2.fromOffset(17, 10),
        Size = UDim2.new(1, -34, 0, 19),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = THEME.TextSoft,
        TextSize = 11,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 52,
        Parent = notice,
    })

    create("TextLabel", {
        Position = UDim2.fromOffset(17, 31),
        Size = UDim2.new(1, -34, 0, 28),
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

    local noticeScale = create("UIScale", { Scale = 0.96, Parent = notice })
    tween(noticeScale, 0.2, { Scale = 1 })

    task.delay(kind == "error" and 5.5 or 2.8, function()
        if notice.Parent then
            tween(noticeScale, 0.16, { Scale = 0.97 })
            task.delay(0.17, function()
                if notice.Parent then
                    notice:Destroy()
                end
            end)
        end
    end)
end

local cards = {}
local filterButtons = {}
local currentFilter = "All Scripts"
local currentSort = "Recently updated"
local currentView = "Grid"
local shown = true
local closed = false
local toggleConnection

local function favoriteGlyph(isFavorite)
    return isFavorite and "♥" or "♡"
end

local function makeFilter(label, width)
    local button = create("TextButton", {
        Size = UDim2.fromOffset(width, 32),
        BackgroundColor3 = THEME.AccentSoft,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = label == "Favorites" and "♥  Favorites" or label,
        TextColor3 = Color3.fromHex("#756F7C"),
        TextSize = 10,
        Font = Enum.Font.Gotham,
        Parent = filterHolder,
    }, { corner(6) })
    local outline = stroke(THEME.BorderStrong, 1, 1)
    outline.Parent = button
    filterButtons[label] = { Button = button, Stroke = outline }
    return button
end

makeFilter("All Scripts", 82)
makeFilter("Games", 62)
makeFilter("Universal", 76)
makeFilter("Favorites", 90)

local function setFavoriteVisual(data)
    local active = favorites[data.Entry.Id] == true
    data.Favorite.Text = favoriteGlyph(active)
    data.Favorite.TextColor3 = active and Color3.fromHex("#BC91EB") or Color3.fromHex("#5E5865")
end

local function makeCard(entry, order)
    local card = create("Frame", {
        Name = entry.Id,
        LayoutOrder = order,
        BackgroundColor3 = THEME.Surface,
        BorderSizePixel = 0,
        Parent = grid,
    }, { corner(9) })

    local cardStroke = stroke(THEME.Border, 0, 1)
    cardStroke.Parent = card
    local cardScale = create("UIScale", { Scale = 1, Parent = card })

    local iconBox = create("Frame", {
        Position = UDim2.fromOffset(18, 18),
        Size = UDim2.fromOffset(44, 44),
        BackgroundColor3 = THEME.AccentSoft,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = card,
    }, {
        corner(11),
        stroke(Color3.fromHex("#513B78"), 0.2, 1),
    })

    local fallback = create("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = scriptInitial(entry.Name),
        TextColor3 = THEME.AccentBright,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = iconBox,
    })

    local image = cachedAsset(entry)
    if image ~= "" then
        create("ImageLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Image = image,
            ScaleType = Enum.ScaleType.Crop,
            ZIndex = 5,
            Parent = iconBox,
        })
    end

    local favorite = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 13),
        Size = UDim2.fromOffset(32, 32),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "♡",
        TextColor3 = Color3.fromHex("#5E5865"),
        TextSize = 22,
        Font = Enum.Font.Gotham,
        Parent = card,
    })

    local copy = create("Frame", {
        Position = UDim2.fromOffset(18, 78),
        Size = UDim2.new(1, -36, 1, -138),
        BackgroundTransparency = 1,
        Parent = card,
    })

    local titleWidth = entry.Popular and -82 or -4
    create("TextLabel", {
        Size = UDim2.new(1, titleWidth, 0, 21),
        BackgroundTransparency = 1,
        Text = entry.Name,
        TextColor3 = THEME.TextSoft,
        TextSize = 15,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = copy,
    })

    if entry.Popular then
        create("TextLabel", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, 0, 0, 1),
            Size = UDim2.fromOffset(70, 18),
            BackgroundColor3 = Color3.fromHex("#201633"),
            BorderSizePixel = 0,
            Text = "✦  POPULAR",
            TextColor3 = Color3.fromHex("#A28BCF"),
            TextSize = 8,
            Font = Enum.Font.GothamBold,
            Parent = copy,
        }, {
            corner(4),
            stroke(Color3.fromHex("#392855"), 0, 1),
        })
    end

    create("TextLabel", {
        Position = UDim2.fromOffset(0, 28),
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        RichText = true,
        Text = string.format('<font color="#716A78">%s</font>   <font color="#433C4B">/</font>   <font color="#716A78">%s</font>', string.upper(entry.Category), entry.Game),
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = copy,
    })

    local descriptionLabel = create("TextLabel", {
        Position = UDim2.fromOffset(0, 61),
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
        Text = entry.Description,
        TextColor3 = THEME.Muted,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = copy,
    })

    local loadButton = create("TextButton", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 18, 1, -18),
        Size = UDim2.new(1, -36, 0, 36),
        BackgroundColor3 = Color3.fromHex("#24183D"),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "▶   Load Script",
        TextColor3 = Color3.fromHex("#D0BDF2"),
        TextSize = 11,
        Font = Enum.Font.GothamSemibold,
        Parent = card,
    }, {
        corner(6),
        stroke(Color3.fromHex("#513B78"), 0, 1),
    })

    card.MouseEnter:Connect(function()
        tween(card, 0.2, { BackgroundColor3 = THEME.SurfaceRaised })
        tween(cardStroke, 0.2, { Color = THEME.BorderStrong })
        tween(cardScale, 0.2, { Scale = 1.006 })
    end)
    card.MouseLeave:Connect(function()
        tween(card, 0.2, { BackgroundColor3 = THEME.Surface })
        tween(cardStroke, 0.2, { Color = THEME.Border })
        tween(cardScale, 0.2, { Scale = 1 })
    end)

    bindHover(loadButton, {
        BackgroundColor3 = Color3.fromHex("#332253"),
        TextColor3 = THEME.Text,
    }, {
        BackgroundColor3 = Color3.fromHex("#24183D"),
        TextColor3 = Color3.fromHex("#D0BDF2"),
    }, 0.16)

    favorite.MouseEnter:Connect(function()
        tween(favorite, 0.12, { TextColor3 = Color3.fromHex("#BC91EB"), TextSize = 24 })
    end)
    favorite.MouseLeave:Connect(function()
        tween(favorite, 0.12, { TextSize = 22 })
        setFavoriteVisual({ Entry = entry, Favorite = favorite })
    end)

    local data = {
        Entry = entry,
        Card = card,
        Stroke = cardStroke,
        Scale = cardScale,
        Icon = iconBox,
        Copy = copy,
        Description = descriptionLabel,
        Favorite = favorite,
        Load = loadButton,
    }
    cards[entry.Id] = data
    setFavoriteVisual(data)
end

for index, entry in ipairs(SCRIPTS) do
    makeCard(entry, index)
end

local function setViewVisuals()
    local gridActive = currentView == "Grid"
    tween(gridViewButton, 0.14, {
        BackgroundTransparency = gridActive and 0 or 1,
        TextColor3 = gridActive and THEME.AccentBright or THEME.Faint,
    })
    tween(listViewButton, 0.14, {
        BackgroundTransparency = gridActive and 1 or 0,
        TextColor3 = gridActive and THEME.Faint or THEME.AccentBright,
    })
    gridViewStroke.Transparency = gridActive and 0 or 1
    listViewStroke.Transparency = gridActive and 1 or 0
end

local function applyCardMode(data)
    local listMode = currentView == "List"
    if listMode then
        data.Icon.Position = UDim2.fromOffset(16, 34)
        data.Copy.Position = UDim2.fromOffset(76, 16)
        data.Copy.Size = UDim2.new(1, -278, 1, -32)
        data.Description.Position = UDim2.fromOffset(0, 52)
        data.Description.Size = UDim2.new(1, 0, 0, 28)
        data.Description.TextSize = 9
        data.Load.AnchorPoint = Vector2.new(1, 0.5)
        data.Load.Position = UDim2.new(1, -16, 0.5, 0)
        data.Load.Size = UDim2.fromOffset(150, 36)
        data.Favorite.Position = UDim2.new(1, -178, 0, 39)
    else
        data.Icon.Position = UDim2.fromOffset(18, 18)
        data.Copy.Position = UDim2.fromOffset(18, 78)
        data.Copy.Size = UDim2.new(1, -36, 1, -138)
        data.Description.Position = UDim2.fromOffset(0, 61)
        data.Description.Size = UDim2.new(1, 0, 0, 52)
        data.Description.TextSize = 11
        data.Load.AnchorPoint = Vector2.new(0, 1)
        data.Load.Position = UDim2.new(0, 18, 1, -18)
        data.Load.Size = UDim2.new(1, -36, 0, 36)
        data.Favorite.Position = UDim2.new(1, -14, 0, 13)
    end
end

local function updateLayout()
    local width = grid.AbsoluteSize.X
    if width <= 0 then
        return
    end

    if currentView == "List" then
        gridLayout.FillDirectionMaxCells = 1
        gridLayout.CellSize = UDim2.new(1, -4, 0, 112)
        for _, data in pairs(cards) do
            applyCardMode(data)
        end
        return
    end

    local columns = 3
    if width < 850 then
        columns = 2
    end
    if width < 570 then
        columns = 1
    end

    local gap = 14
    local cellWidth = math.floor((width - 4 - (gap * (columns - 1))) / columns)
    gridLayout.FillDirectionMaxCells = columns
    gridLayout.CellSize = UDim2.fromOffset(cellWidth, 248)
    for _, data in pairs(cards) do
        applyCardMode(data)
    end
end

local function searchableText(entry)
    return normalize(
        entry.Name
            .. " "
            .. entry.Category
            .. " "
            .. entry.Game
            .. " "
            .. entry.Description
            .. " "
            .. table.concat(entry.Tags, " ")
    )
end

local function updateFilterVisuals()
    for name, data in pairs(filterButtons) do
        local active = currentFilter == name
        tween(data.Button, 0.14, {
            BackgroundTransparency = active and 0 or 1,
            TextColor3 = active and THEME.AccentBright or Color3.fromHex("#756F7C"),
        })
        data.Stroke.Transparency = active and 0 or 1
    end
end

local function sortCards(entries)
    table.sort(entries, function(a, b)
        if currentSort == "A–Z" then
            return string.lower(a.Name) < string.lower(b.Name)
        elseif currentSort == "Z–A" then
            return string.lower(a.Name) > string.lower(b.Name)
        end
        return a.Updated > b.Updated
    end)
end

local function refresh()
    local query = normalize(searchBox.Text)
    local visibleEntries = {}

    for _, entry in ipairs(SCRIPTS) do
        local matchesSearch = query == "" or string.find(searchableText(entry), query, 1, true) ~= nil
        local matchesFilter = currentFilter == "All Scripts"
            or currentFilter == entry.Category
            or (currentFilter == "Favorites" and favorites[entry.Id] == true)

        cards[entry.Id].Card.Visible = matchesSearch and matchesFilter
        if matchesSearch and matchesFilter then
            table.insert(visibleEntries, entry)
        end
        setFavoriteVisual(cards[entry.Id])
    end

    sortCards(visibleEntries)
    for index, entry in ipairs(visibleEntries) do
        cards[entry.Id].Card.LayoutOrder = index
    end

    local count = #visibleEntries
    titleLabel.Text = string.format(
        '<font color="#F4F2F7"><b>Browse scripts</b></font>  <font color="#6F6876">%d</font>',
        count
    )
    emptyState.Visible = count == 0
    grid.Visible = count > 0
    searchShortcut.Text = searchBox.Text == "" and "/" or "×"
    updateFilterVisuals()
end

local function runScript(entry, data)
    if data.Load:GetAttribute("Loading") then
        return
    end

    data.Load:SetAttribute("Loading", true)
    local oldText = data.Load.Text
    data.Load.Text = "•••   Loading"
    notify(entry.Name, "Fetching the latest build...", "info")

    task.spawn(function()
        local ok, result = pcall(function()
            local source = game:HttpGet(entry.Url)
            if type(source) ~= "string" or source == "" then
                error("The script returned no source.")
            end
            local chunk, compileError = loadstring(source)
            if not chunk then
                error(compileError or "The script could not be compiled.")
            end
            return chunk()
        end)

        task.defer(function()
            if not data.Load.Parent then
                return
            end
            data.Load:SetAttribute("Loading", false)
            data.Load.Text = oldText
            if ok then
                notify(entry.Name, "Loaded successfully.", "success")
            else
                notify(entry.Name .. " could not launch", compactError(result), "error")
            end
        end)
    end)
end

for label, data in pairs(filterButtons) do
    data.Button.MouseButton1Click:Connect(function()
        currentFilter = label
        refresh()
    end)
end

for _, data in pairs(cards) do
    data.Favorite.MouseButton1Click:Connect(function()
        favorites[data.Entry.Id] = not favorites[data.Entry.Id]
        saveFavorites()
        setFavoriteVisual(data)
        if currentFilter == "Favorites" then
            refresh()
        end
    end)
    data.Load.MouseButton1Click:Connect(function()
        runScript(data.Entry, data)
    end)
end

local sortModes = { "Recently updated", "A–Z", "Z–A" }
local sortIndex = 1
sortButton.MouseButton1Click:Connect(function()
    sortIndex = (sortIndex % #sortModes) + 1
    currentSort = sortModes[sortIndex]
    sortButton.Text = "≡   " .. currentSort .. "   ⌄"
    refresh()
end)

gridViewButton.MouseButton1Click:Connect(function()
    currentView = "Grid"
    setViewVisuals()
    updateLayout()
end)

listViewButton.MouseButton1Click:Connect(function()
    currentView = "List"
    setViewVisuals()
    updateLayout()
end)

searchBox:GetPropertyChangedSignal("Text"):Connect(refresh)
searchShortcut.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and searchBox.Text ~= "" then
        searchBox.Text = ""
        searchBox:CaptureFocus()
    end
end)

shortcutButton.MouseButton1Click:Connect(function()
    searchBox:CaptureFocus()
end)

local function setShown(value)
    shown = value
    if value then
        gui.Enabled = true
        local targetScale = windowScale:GetAttribute("TargetScale") or 1
        windowScale.Scale = targetScale * 0.97
        tween(windowScale, 0.2, { Scale = targetScale })
    else
        tween(windowScale, 0.16, { Scale = (windowScale:GetAttribute("TargetScale") or 1) * 0.98 })
        task.delay(0.17, function()
            if not shown and not closed then
                gui.Enabled = false
            end
        end)
    end
end

local function updateScale()
    local camera = Workspace.CurrentCamera
    if not camera then
        return
    end
    local viewport = camera.ViewportSize
    local target = math.min((viewport.X - 28) / 1080, (viewport.Y - 28) / 680, 1)
    target = math.max(target, 0.5)
    windowScale:SetAttribute("TargetScale", target)
    if shown then
        windowScale.Scale = target
    end
end

local cameraConnection
local function bindCamera()
    if cameraConnection then
        cameraConnection:Disconnect()
    end
    local camera = Workspace.CurrentCamera
    if camera then
        cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
    end
    updateScale()
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
bindCamera()

grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLayout)
task.defer(updateLayout)

local dragging = false
local dragStart
local startPosition

topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
    then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging
        and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch)
    then
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
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
    then
        dragging = false
    end
end)

minimizeButton.MouseButton1Click:Connect(function()
    setShown(false)
end)

local function closeHub()
    if closed then
        return
    end
    closed = true
    if toggleConnection then
        toggleConnection:Disconnect()
    end
    if cameraConnection then
        cameraConnection:Disconnect()
    end
    tween(windowScale, 0.16, { Scale = (windowScale:GetAttribute("TargetScale") or 1) * 0.96 })
    task.delay(0.17, function()
        if gui.Parent then
            gui:Destroy()
        end
    end)
end

closeButton.MouseButton1Click:Connect(closeHub)

toggleConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or closed then
        return
    end
    if input.KeyCode == Enum.KeyCode.RightShift then
        setShown(not shown)
    elseif input.KeyCode == Enum.KeyCode.K
        and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
            or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
            or UserInputService:IsKeyDown(Enum.KeyCode.LeftMeta)
            or UserInputService:IsKeyDown(Enum.KeyCode.RightMeta))
    then
        if not shown then
            setShown(true)
        end
        searchBox:CaptureFocus()
    elseif input.KeyCode == Enum.KeyCode.Slash and shown then
        searchBox:CaptureFocus()
    end
end)

refresh()
setViewVisuals()
updateScale()
local initialScale = windowScale:GetAttribute("TargetScale") or 1
windowScale.Scale = initialScale * 0.97
tween(windowScale, 0.24, { Scale = initialScale })
