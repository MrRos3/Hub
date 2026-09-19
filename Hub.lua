-- Velora Hub v5
-- VantaUI-inspired searchable script library
-- Showcase content removed. Real scripts only.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

local THEME = {
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
}

local FONT_ID = "rbxassetid://12187365364"
local BRAND_URL = "https://raw.githubusercontent.com/MrRos3/VantaUI/main/assets/vanta-brand-v2.jpeg"
local ICON_BASE = "https://raw.githubusercontent.com/MrRos3/SaltyIcons/main/icons/png/96/"
local TOGGLE_KEY = Enum.KeyCode.RightShift

local function font(weight)
    return Font.new(FONT_ID, weight or Enum.FontWeight.Regular, Enum.FontStyle.Normal)
end

local function create(className, props, children)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do
        object[key] = value
    end
    for _, child in ipairs(children or {}) do
        child.Parent = object
    end
    return object
end

local function corner(radius)
    return create("UICorner", { CornerRadius = UDim.new(0, radius) })
end

local function stroke(color, transparency, thickness)
    return create("UIStroke", {
        Color = color,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function tween(object, duration, props)
    local animation = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        props
    )
    animation:Play()
    return animation
end

local function normalize(value)
    return string.lower(tostring(value or ""))
end

local function contains(value, query)
    return query == "" or string.find(normalize(value), query, 1, true) ~= nil
end

local customAsset = getcustomasset or getsynasset
local canCache = type(writefile) == "function"
    and type(isfile) == "function"
    and type(makefolder) == "function"
    and type(isfolder) == "function"
    and type(customAsset) == "function"

local function ensureFolder(path)
    if not canCache then
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
    if canCache and ensureFolder("VeloraHub") and ensureFolder("VeloraHub/assets") then
        if not isfile(path) then
            local ok, bytes = pcall(function()
                return game:HttpGet(url)
            end)
            if ok and type(bytes) == "string" and #bytes > 100 then
                pcall(writefile, path, bytes)
            end
        end
        if isfile(path) then
            local ok, asset = pcall(customAsset, path)
            if ok and asset and asset ~= "" then
                return asset
            end
        end
    end
    return fallback or ""
end

local ICONS = {
    search = { "misc", "search", "rbxassetid://100557104978626" },
    close = { "status", "x", "rbxassetid://104564513546348" },
    minus = { "status", "minus", "rbxassetid://123173530093622" },
    star = { "misc", "star", "rbxassetid://130603316912957" },
}

local iconCache = {}
local function icon(name)
    if iconCache[name] then
        return iconCache[name]
    end

    local info = ICONS[name]
    if not info then
        return ""
    end

    local url = ICON_BASE .. info[1] .. "/" .. info[2] .. ".png"
    local path = "VeloraHub/assets/icon_" .. info[1] .. "_" .. info[2] .. ".png"
    local asset = cacheRemoteAsset(url, path, info[3])
    iconCache[name] = asset
    return asset
end

local brandAsset = cacheRemoteAsset(BRAND_URL, "VeloraHub/assets/vanta-brand-v2.jpeg", "")

-- Real script library. Add future scripts here.
local SCRIPTS = {
    {
        Id = "velora-piano",
        Name = "Velora Piano",
        Description = "Premium piano player and song workstation",
        Tags = { "piano", "music", "songs", "workstation" },
        Url = "https://raw.githubusercontent.com/MrRos3/Velora/main/loader.lua",
    },
    {
        Id = "shadow-network",
        Name = "Shadow Network",
        Description = "Salty Shadow Network v1.3.7",
        Tags = { "shadow network", "items", "esp", "automation" },
        Url = "https://raw.githubusercontent.com/MrRos3/Hub/main/scripts/ShadowNetwork.lua",
    },
}

local function getGuiParent()
    local ok, result = pcall(function()
        if gethui then
            return gethui()
        end
        return CoreGui
    end)
    if ok and result then
        return result
    end
    return player:WaitForChild("PlayerGui")
end

local parent = getGuiParent()

local oldGui = parent:FindFirstChild("VeloraHub")
if oldGui then
    oldGui:Destroy()
end

local oldBlur = Lighting:FindFirstChild("VeloraHubBlur")
if oldBlur then
    oldBlur:Destroy()
end

local blur = create("BlurEffect", {
    Name = "VeloraHubBlur",
    Size = 0,
    Parent = Lighting,
})
tween(blur, 0.2, { Size = 9 })

local gui = create("ScreenGui", {
    Name = "VeloraHub",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = parent,
})

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
    end
end)

local dim = create("Frame", {
    Name = "Dim",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = THEME.Background,
    BackgroundTransparency = 0.66,
    BorderSizePixel = 0,
    Parent = gui,
})

local main = create("CanvasGroup", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(0.74, 0.72),
    BackgroundColor3 = THEME.Panel,
    BackgroundTransparency = 0.06,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    GroupTransparency = 0,
    Parent = dim,
}, {
    corner(13),
    stroke(THEME.Outline, 0.20, 1),
    create("UISizeConstraint", {
        MinSize = Vector2.new(860, 530),
        MaxSize = Vector2.new(1220, 760),
    }),
})

local top = create("Frame", {
    Name = "Topbar",
    Size = UDim2.new(1, 0, 0, 62),
    BackgroundColor3 = THEME.Dialog,
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    Parent = main,
})

create("Frame", {
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = THEME.Outline,
    BackgroundTransparency = 0.34,
    BorderSizePixel = 0,
    Parent = top,
})

local brand = create("Frame", {
    Name = "Brand",
    Position = UDim2.fromOffset(14, 9),
    Size = UDim2.fromOffset(236, 44),
    BackgroundTransparency = 1,
    Parent = top,
})

local brandIcon = create("Frame", {
    Position = UDim2.fromOffset(0, 2),
    Size = UDim2.fromOffset(40, 40),
    BackgroundColor3 = THEME.Button,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    Parent = brand,
}, {
    corner(10),
    stroke(THEME.Outline, 0.34, 1),
})

if brandAsset ~= "" then
    create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(30, 30),
        BackgroundTransparency = 1,
        Image = brandAsset,
        ScaleType = Enum.ScaleType.Crop,
        Parent = brandIcon,
    }, {
        corner(8),
    })
else
    create("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "V",
        TextColor3 = THEME.Text,
        TextSize = 18,
        FontFace = font(Enum.FontWeight.Bold),
        Parent = brandIcon,
    })
end

create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(52, 3),
    Size = UDim2.fromOffset(165, 20),
    Text = "VELORA",
    TextColor3 = THEME.Text,
    TextSize = 15,
    FontFace = font(Enum.FontWeight.SemiBold),
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = brand,
})

create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(53, 23),
    Size = UDim2.fromOffset(165, 15),
    Text = "SCRIPT HUB",
    TextColor3 = THEME.Muted,
    TextSize = 9,
    FontFace = font(Enum.FontWeight.Medium),
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = brand,
})

local searchWrap = create("Frame", {
    Name = "Search",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 18, 0.5, 0),
    Size = UDim2.new(0.44, 0, 0, 36),
    BackgroundColor3 = THEME.Element,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    Parent = top,
}, {
    corner(9),
    stroke(THEME.Outline, 0.46, 1),
})

create("ImageLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(11, 9),
    Size = UDim2.fromOffset(18, 18),
    Image = icon("search"),
    ImageColor3 = THEME.Muted,
    ScaleType = Enum.ScaleType.Fit,
    Parent = searchWrap,
})

local searchBox = create("TextBox", {
    Name = "SearchBox",
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(38, 0),
    Size = UDim2.new(1, -68, 1, 0),
    Text = "",
    PlaceholderText = "Search scripts...",
    PlaceholderColor3 = THEME.Muted,
    TextColor3 = THEME.Text,
    TextSize = 11,
    FontFace = font(),
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    Parent = searchWrap,
})

local clearSearch = create("ImageButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -7, 0.5, 0),
    Size = UDim2.fromOffset(22, 22),
    BackgroundTransparency = 1,
    Image = icon("close"),
    ImageColor3 = THEME.Muted,
    ScaleType = Enum.ScaleType.Fit,
    Visible = false,
    AutoButtonColor = false,
    Parent = searchWrap,
})

local controls = create("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -12, 0.5, 0),
    Size = UDim2.fromOffset(68, 30),
    BackgroundTransparency = 1,
    Parent = top,
})

local function windowButton(image, x)
    local button = create("ImageButton", {
        Position = UDim2.fromOffset(x, 1),
        Size = UDim2.fromOffset(29, 28),
        BackgroundColor3 = THEME.Button,
        BackgroundTransparency = 1,
        Image = icon(image),
        ImageColor3 = THEME.Muted,
        ScaleType = Enum.ScaleType.Fit,
        AutoButtonColor = false,
        Parent = controls,
    }, {
        corner(8),
        create("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 7),
            PaddingBottom = UDim.new(0, 7),
        }),
    })

    button.MouseEnter:Connect(function()
        tween(button, 0.10, { BackgroundTransparency = 0.18, ImageColor3 = THEME.Text })
    end)
    button.MouseLeave:Connect(function()
        tween(button, 0.10, { BackgroundTransparency = 1, ImageColor3 = THEME.Muted })
    end)

    return button
end

local minimizeButton = windowButton("minus", 0)
local closeButton = windowButton("close", 38)

local filterBar = create("Frame", {
    Position = UDim2.fromOffset(16, 73),
    Size = UDim2.new(1, -32, 0, 32),
    BackgroundTransparency = 1,
    Parent = main,
})

local filterHolder = create("Frame", {
    Size = UDim2.new(1, -120, 1, 0),
    BackgroundTransparency = 1,
    Parent = filterBar,
}, {
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 7),
    }),
})

local countLabel = create("TextLabel", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, 0, 0.5, 0),
    Size = UDim2.fromOffset(104, 28),
    BackgroundColor3 = THEME.Element,
    BackgroundTransparency = 0.14,
    Text = "2 scripts",
    TextColor3 = THEME.Muted,
    TextSize = 9,
    FontFace = font(Enum.FontWeight.Medium),
    Parent = filterBar,
}, {
    corner(8),
    stroke(THEME.Outline, 0.58, 1),
})

local grid = create("ScrollingFrame", {
    Name = "Grid",
    Position = UDim2.fromOffset(16, 114),
    Size = UDim2.new(1, -32, 1, -147),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = THEME.Outline,
    ScrollBarImageTransparency = 0.18,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(),
    Parent = main,
})

local gridLayout = create("UIGridLayout", {
    CellPadding = UDim2.fromOffset(9, 9),
    CellSize = UDim2.fromOffset(360, 104),
    FillDirectionMaxCells = 3,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = grid,
})

create("UIPadding", {
    PaddingTop = UDim.new(0, 2),
    PaddingBottom = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 4),
    Parent = grid,
})

local emptyLabel = create("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.55),
    Size = UDim2.fromOffset(320, 60),
    BackgroundTransparency = 1,
    Text = "No scripts found\nTry another search.",
    TextColor3 = THEME.Muted,
    TextSize = 12,
    FontFace = font(Enum.FontWeight.Medium),
    Visible = false,
    Parent = main,
})

local favorites = {}
local cards = {}
local favoriteButtons = {}
local currentFilter = "All"
local selectedId = nil
local shown = true
local closed = false
local toggleConnection

local function scriptInitial(name)
    local first = string.match(tostring(name or ""), "%a")
    return string.upper(first or "?")
end

local function scriptMeta(entry)
    return entry.Description or table.concat(entry.Tags or {}, "  •  ")
end

local function setShown(value)
    shown = value
    if gui.Parent then
        gui.Enabled = value
    end
    if blur.Parent then
        tween(blur, 0.16, { Size = value and 9 or 0 })
    end
end

local function toast(text)
    local existing = main:FindFirstChild("Toast")
    if existing then
        existing:Destroy()
    end

    local label = create("TextLabel", {
        Name = "Toast",
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, 10),
        Size = UDim2.fromOffset(320, 38),
        BackgroundColor3 = THEME.Dialog,
        BackgroundTransparency = 0.02,
        Text = text,
        TextColor3 = THEME.Text,
        TextSize = 10,
        FontFace = font(Enum.FontWeight.Medium),
        Parent = main,
    }, {
        corner(9),
        stroke(THEME.Outline, 0.30, 1),
    })

    tween(label, 0.14, { Position = UDim2.new(0.5, 0, 1, -24) })

    task.delay(1.8, function()
        if label.Parent then
            tween(label, 0.12, {
                Position = UDim2.new(0.5, 0, 1, 10),
                TextTransparency = 1,
                BackgroundTransparency = 1,
            })
            task.wait(0.13)
            if label.Parent then
                label:Destroy()
            end
        end
    end)
end

local function runScript(entry)
    if type(entry.Run) == "function" then
        local ok, err = pcall(entry.Run)
        if not ok then
            setShown(true)
            toast(tostring(err))
        end
        return
    end

    if entry.Url then
        setShown(false)
        task.spawn(function()
            local ok, err = pcall(function()
                local source = game:HttpGet(entry.Url)
                local chunk, compileError = loadstring(source)
                if not chunk then
                    error(compileError or "Failed to compile script")
                end
                return chunk()
            end)
            if not ok then
                setShown(true)
                toast(entry.Name .. " failed: " .. tostring(err))
            end
        end)
    end
end

local function updateCardSelection()
    for id, data in pairs(cards) do
        local active = id == selectedId
        tween(data.Card, 0.12, {
            BackgroundColor3 = active and THEME.Button or THEME.Element,
        })
        data.Stroke.Color = active and THEME.AccentBright or THEME.Outline
        data.Stroke.Transparency = active and 0.18 or 0.58
        data.Select.BackgroundTransparency = active and 0.02 or 0.12
        data.Select.TextColor3 = active and THEME.Text or Color3.fromRGB(220, 211, 216)
    end
end

local function makeCard(entry, order)
    local card = create("Frame", {
        Name = entry.Id,
        LayoutOrder = order,
        BackgroundColor3 = THEME.Element,
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        Parent = grid,
    }, {
        corner(10),
    })

    local cardStroke = stroke(THEME.Outline, 0.58, 1)
    cardStroke.Parent = card

    local initialBox = create("Frame", {
        Position = UDim2.fromOffset(11, 11),
        Size = UDim2.fromOffset(44, 44),
        BackgroundColor3 = THEME.Button,
        BackgroundTransparency = 0.03,
        BorderSizePixel = 0,
        Parent = card,
    }, {
        corner(10),
        stroke(THEME.Outline, 0.45, 1),
    })

    create("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = scriptInitial(entry.Name),
        TextColor3 = THEME.Text,
        TextSize = 18,
        FontFace = font(Enum.FontWeight.SemiBold),
        Parent = initialBox,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(67, 11),
        Size = UDim2.new(1, -112, 0, 21),
        Text = entry.Name,
        TextColor3 = THEME.Text,
        TextSize = 13,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = card,
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(67, 33),
        Size = UDim2.new(1, -118, 0, 18),
        Text = scriptMeta(entry),
        TextColor3 = THEME.Muted,
        TextSize = 8,
        FontFace = font(Enum.FontWeight.Medium),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = card,
    })

    local tagText = table.concat(entry.Tags or {}, "  •  ")
    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 73),
        Size = UDim2.new(1, -116, 0, 18),
        Text = tagText,
        TextColor3 = THEME.Faint,
        TextSize = 8,
        FontFace = font(Enum.FontWeight.Medium),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = card,
    })

    local favorite = create("ImageButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -9, 0, 9),
        Size = UDim2.fromOffset(22, 22),
        BackgroundTransparency = 1,
        Image = icon("star"),
        ImageColor3 = THEME.Faint,
        ScaleType = Enum.ScaleType.Fit,
        AutoButtonColor = false,
        Parent = card,
    }, {
        create("UIPadding", {
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4),
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 4),
        }),
    })

    local selectButton = create("TextButton", {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -11, 1, -11),
        Size = UDim2.fromOffset(86, 29),
        BackgroundColor3 = THEME.Button,
        BackgroundTransparency = 0.12,
        Text = "Select",
        TextColor3 = Color3.fromRGB(220, 211, 216),
        TextSize = 9,
        FontFace = font(Enum.FontWeight.Medium),
        AutoButtonColor = false,
        Parent = card,
    }, {
        corner(8),
        stroke(THEME.Outline, 0.44, 1),
    })

    card.MouseEnter:Connect(function()
        if selectedId ~= entry.Id then
            tween(card, 0.12, { BackgroundColor3 = THEME.ElementHover })
            cardStroke.Transparency = 0.42
        end
    end)

    card.MouseLeave:Connect(function()
        if selectedId ~= entry.Id then
            tween(card, 0.12, { BackgroundColor3 = THEME.Element })
            cardStroke.Transparency = 0.58
        end
    end)

    selectButton.MouseEnter:Connect(function()
        tween(selectButton, 0.10, { BackgroundTransparency = 0.02 })
    end)

    selectButton.MouseLeave:Connect(function()
        tween(selectButton, 0.10, {
            BackgroundTransparency = selectedId == entry.Id and 0.02 or 0.12,
        })
    end)

    selectButton.MouseButton1Click:Connect(function()
        selectedId = entry.Id
        updateCardSelection()
        runScript(entry)
    end)

    favorite.MouseButton1Click:Connect(function()
        favorites[entry.Id] = not favorites[entry.Id]
        favorite.ImageColor3 = favorites[entry.Id] and THEME.AccentBright or THEME.Faint
        favorite.ImageTransparency = favorites[entry.Id] and 0 or 0.04
    end)

    cards[entry.Id] = {
        Card = card,
        Stroke = cardStroke,
        Select = selectButton,
        Entry = entry,
    }
    favoriteButtons[entry.Id] = favorite
end

for index, entry in ipairs(SCRIPTS) do
    makeCard(entry, index)
end

local filterButtons = {}

local function makeFilter(name)
    local button = create("TextButton", {
        Size = UDim2.fromOffset(name == "Favorites" and 72 or 48, 30),
        BackgroundColor3 = THEME.Element,
        BackgroundTransparency = 0.18,
        Text = name,
        TextColor3 = THEME.Muted,
        TextSize = 9,
        FontFace = font(Enum.FontWeight.Medium),
        AutoButtonColor = false,
        Parent = filterHolder,
    }, {
        corner(8),
        stroke(THEME.Outline, 0.56, 1),
    })

    filterButtons[name] = button
    return button
end

local allButton = makeFilter("All")
local favoritesButton = makeFilter("Favorites")

local function updateFilters()
    for name, button in pairs(filterButtons) do
        local active = currentFilter == name
        tween(button, 0.10, {
            BackgroundColor3 = active and THEME.Button or THEME.Element,
            BackgroundTransparency = active and 0.02 or 0.18,
            TextColor3 = active and THEME.Text or THEME.Muted,
        })
        local buttonStroke = button:FindFirstChildOfClass("UIStroke")
        if buttonStroke then
            buttonStroke.Color = active and THEME.AccentBright or THEME.Outline
            buttonStroke.Transparency = active and 0.20 or 0.56
        end
    end
end

local function refresh()
    local query = normalize(searchBox.Text)
    local visibleCount = 0

    for _, entry in ipairs(SCRIPTS) do
        local searchable = entry.Name
            .. " "
            .. tostring(entry.Description or "")
            .. " "
            .. table.concat(entry.Tags or {}, " ")

        local matchesSearch = contains(searchable, query)
        local matchesFilter = currentFilter == "All" or favorites[entry.Id] == true
        local visible = matchesSearch and matchesFilter

        cards[entry.Id].Card.Visible = visible
        if visible then
            visibleCount += 1
        end
    end

    countLabel.Text = tostring(visibleCount) .. (visibleCount == 1 and " script" or " scripts")
    emptyLabel.Visible = visibleCount == 0
    clearSearch.Visible = searchBox.Text ~= ""
    updateFilters()
end

allButton.MouseButton1Click:Connect(function()
    currentFilter = "All"
    refresh()
end)

favoritesButton.MouseButton1Click:Connect(function()
    currentFilter = "Favorites"
    refresh()
end)

for _, button in pairs(favoriteButtons) do
    button.MouseButton1Click:Connect(function()
        if currentFilter == "Favorites" then
            task.defer(refresh)
        end
    end)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(refresh)
clearSearch.MouseButton1Click:Connect(function()
    searchBox.Text = ""
    searchBox:CaptureFocus()
end)

local function updateGrid()
    local width = grid.AbsoluteSize.X
    if width <= 0 then
        return
    end

    local columns
    if width >= 1060 then
        columns = 3
    elseif width >= 760 then
        columns = 2
    else
        columns = 1
    end

    local gap = 9
    local usable = width - 4 - (gap * (columns - 1))
    local cellWidth = math.floor(usable / columns)
    gridLayout.FillDirectionMaxCells = columns
    gridLayout.CellSize = UDim2.fromOffset(cellWidth, 104)
end

grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGrid)
task.defer(updateGrid)

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
    if blur.Parent then
        blur:Destroy()
    end
    if gui.Parent then
        gui:Destroy()
    end
end

closeButton.MouseButton1Click:Connect(closeHub)

toggleConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or closed then
        return
    end
    if input.KeyCode == TOGGLE_KEY then
        setShown(not shown)
    elseif input.KeyCode == Enum.KeyCode.K and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if shown then
            searchBox:CaptureFocus()
        end
    end
end)

local dragging = false
local dragStart
local startPosition

brand.InputBegan:Connect(function(input)
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
updateCardSelection()
