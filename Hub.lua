-- Velora Hub
-- Minimal searchable script library UI.
-- Add real scripts later by replacing the demo entries in SCRIPT_LIBRARY.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LOCAL_PLAYER = Players.LocalPlayer

local CONFIG = {
    Title = "VELORA",
    Subtitle = "MY SCRIPTS",
    ToggleKey = Enum.KeyCode.RightShift,
    UseBackgroundBlur = true,
    DemoMode = true,
}

local THEME = {
    Background = Color3.fromRGB(14, 10, 16),
    Background2 = Color3.fromRGB(27, 16, 25),
    Surface = Color3.fromRGB(24, 18, 25),
    Surface2 = Color3.fromRGB(34, 24, 34),
    Surface3 = Color3.fromRGB(45, 31, 44),
    Text = Color3.fromRGB(246, 241, 246),
    Muted = Color3.fromRGB(177, 162, 176),
    Faint = Color3.fromRGB(113, 98, 112),
    Accent = Color3.fromRGB(255, 105, 194),
    Accent2 = Color3.fromRGB(151, 88, 255),
    Stroke = Color3.fromRGB(117, 74, 108),
    Success = Color3.fromRGB(139, 238, 190),
    Error = Color3.fromRGB(255, 124, 143),
}

local SCRIPT_LIBRARY = {
    {
        Id = "ghost-driver",
        Name = "Ghost Driver",
        Subtitle = "Roblox",
        Category = "Roblox",
        Tags = {"game specific", "vehicle", "automation"},
        Symbol = "GD",
        AccentA = Color3.fromRGB(255, 73, 162),
        AccentB = Color3.fromRGB(89, 46, 111),
        Demo = true,
    },
    {
        Id = "blox-fruits",
        Name = "Blox Fruits",
        Subtitle = "Roblox",
        Category = "Roblox",
        Tags = {"game specific", "farm"},
        Symbol = "BF",
        AccentA = Color3.fromRGB(77, 136, 255),
        AccentB = Color3.fromRGB(64, 55, 137),
        Demo = true,
    },
    {
        Id = "pet-simulator",
        Name = "Pet Simulator X",
        Subtitle = "Roblox",
        Category = "Roblox",
        Tags = {"game specific", "utility"},
        Symbol = "PX",
        AccentA = Color3.fromRGB(255, 92, 198),
        AccentB = Color3.fromRGB(92, 50, 112),
        Demo = true,
    },
    {
        Id = "blade-ball",
        Name = "Blade Ball",
        Subtitle = "Roblox",
        Category = "Roblox",
        Tags = {"game specific", "combat"},
        Symbol = "BB",
        AccentA = Color3.fromRGB(235, 68, 112),
        AccentB = Color3.fromRGB(86, 31, 69),
        Demo = true,
    },
    {
        Id = "arsenal",
        Name = "Arsenal",
        Subtitle = "Roblox",
        Category = "Roblox",
        Tags = {"game specific", "combat"},
        Symbol = "AR",
        AccentA = Color3.fromRGB(92, 88, 130),
        AccentB = Color3.fromRGB(35, 34, 50),
        Demo = true,
    },
    {
        Id = "da-hood",
        Name = "Da Hood",
        Subtitle = "Roblox",
        Category = "Roblox",
        Tags = {"game specific"},
        Symbol = "DH",
        AccentA = Color3.fromRGB(175, 55, 150),
        AccentB = Color3.fromRGB(75, 32, 91),
        Demo = true,
    },
    {
        Id = "doors",
        Name = "Doors",
        Subtitle = "Roblox",
        Category = "Roblox",
        Tags = {"game specific", "esp"},
        Symbol = "0013",
        AccentA = Color3.fromRGB(152, 58, 69),
        AccentB = Color3.fromRGB(34, 20, 27),
        Demo = true,
    },
    {
        Id = "mm2",
        Name = "MM2",
        Subtitle = "Roblox",
        Category = "Roblox",
        Tags = {"game specific", "combat"},
        Symbol = "M2",
        AccentA = Color3.fromRGB(255, 53, 123),
        AccentB = Color3.fromRGB(76, 28, 47),
        Demo = true,
    },
    {
        Id = "type-soul",
        Name = "Type Soul",
        Subtitle = "Roblox",
        Category = "Roblox",
        Tags = {"game specific"},
        Symbol = "TS",
        AccentA = Color3.fromRGB(179, 86, 255),
        AccentB = Color3.fromRGB(55, 32, 78),
        Demo = true,
    },
    {
        Id = "jailbreak",
        Name = "Jailbreak",
        Subtitle = "Roblox",
        Category = "Roblox",
        Tags = {"game specific", "vehicle"},
        Symbol = "JB",
        AccentA = Color3.fromRGB(194, 90, 255),
        AccentB = Color3.fromRGB(56, 40, 89),
        Demo = true,
    },
    {
        Id = "salty-universal",
        Name = "Salty Universal",
        Subtitle = "Universal",
        Category = "Universal",
        Tags = {"universal", "utility"},
        Symbol = "∞",
        AccentA = Color3.fromRGB(146, 121, 255),
        AccentB = Color3.fromRGB(49, 41, 85),
        Demo = true,
    },
    {
        Id = "salty-ui",
        Name = "Salty UI Library",
        Subtitle = "UI / Library",
        Category = "UI",
        Tags = {"ui", "library"},
        Symbol = "UI",
        AccentA = Color3.fromRGB(135, 126, 255),
        AccentB = Color3.fromRGB(45, 40, 80),
        Demo = true,
    },
    {
        Id = "remote-spy",
        Name = "Remote Spy",
        Subtitle = "Tools",
        Category = "Tools",
        Tags = {"tool", "remote"},
        Symbol = "RS",
        AccentA = Color3.fromRGB(186, 111, 255),
        AccentB = Color3.fromRGB(56, 39, 80),
        Demo = true,
    },
    {
        Id = "fe-scripts",
        Name = "FE Scripts",
        Subtitle = "Universal",
        Category = "Universal",
        Tags = {"universal"},
        Symbol = "</>",
        AccentA = Color3.fromRGB(175, 131, 255),
        AccentB = Color3.fromRGB(55, 43, 85),
        Demo = true,
    },
    {
        Id = "teleport-hub",
        Name = "Teleport Hub",
        Subtitle = "Tools",
        Category = "Tools",
        Tags = {"tool", "teleport"},
        Symbol = "TP",
        AccentA = Color3.fromRGB(190, 123, 255),
        AccentB = Color3.fromRGB(58, 39, 84),
        Demo = true,
    },
    {
        Id = "game-utilities",
        Name = "Game Utilities",
        Subtitle = "Tools",
        Category = "Tools",
        Tags = {"tool", "utility"},
        Symbol = "GU",
        AccentA = Color3.fromRGB(160, 127, 255),
        AccentB = Color3.fromRGB(45, 41, 80),
        Demo = true,
    },
    {
        Id = "auto-farm",
        Name = "Auto Farm",
        Subtitle = "Universal",
        Category = "Universal",
        Tags = {"universal", "automation"},
        Symbol = "AF",
        AccentA = Color3.fromRGB(122, 104, 255),
        AccentB = Color3.fromRGB(42, 39, 79),
        Demo = true,
    },
    {
        Id = "speed-hub",
        Name = "Speed Hub",
        Subtitle = "Tools",
        Category = "Tools",
        Tags = {"tool", "movement"},
        Symbol = "SP",
        AccentA = Color3.fromRGB(147, 123, 255),
        AccentB = Color3.fromRGB(45, 41, 80),
        Demo = true,
    },
}

local function getGuiParent()
    local ok, gui = pcall(function()
        if gethui then
            return gethui()
        end
        return CoreGui
    end)

    if ok and gui then
        return gui
    end

    return LOCAL_PLAYER:WaitForChild("PlayerGui")
end

local function create(className, props, children)
    local object = Instance.new(className)
    for property, value in pairs(props or {}) do
        object[property] = value
    end
    for _, child in ipairs(children or {}) do
        child.Parent = object
    end
    return object
end

local function corner(radius)
    return create("UICorner", {CornerRadius = UDim.new(0, radius)})
end

local function stroke(color, transparency, thickness)
    return create("UIStroke", {
        Color = color,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function tween(object, duration, properties, style, direction)
    local info = TweenInfo.new(
        duration or 0.2,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(object, info, properties)
    t:Play()
    return t
end

local function normalize(text)
    return string.lower(tostring(text or ""))
end

local function contains(haystack, needle)
    if needle == "" then
        return true
    end
    return string.find(normalize(haystack), needle, 1, true) ~= nil
end

local guiParent = getGuiParent()
local oldGui = guiParent:FindFirstChild("VeloraHub")
if oldGui then
    oldGui:Destroy()
end

local oldBlur = Lighting:FindFirstChild("VeloraHubBlur")
if oldBlur then
    oldBlur:Destroy()
end

local blur
if CONFIG.UseBackgroundBlur then
    blur = create("BlurEffect", {
        Name = "VeloraHubBlur",
        Size = 0,
        Parent = Lighting,
    })
    tween(blur, 0.3, {Size = 12})
end

local screen = create("ScreenGui", {
    Name = "VeloraHub",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999999,
    Parent = guiParent,
})

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(screen)
    end
end)

local backdrop = create("Frame", {
    Name = "Backdrop",
    BackgroundColor3 = Color3.fromRGB(6, 4, 7),
    BackgroundTransparency = 0.45,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    Parent = screen,
})

local ambientGlow = create("Frame", {
    Name = "AmbientGlow",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(0.88, 0.84),
    BackgroundColor3 = THEME.Accent,
    BackgroundTransparency = 0.92,
    BorderSizePixel = 0,
    Parent = backdrop,
}, {
    corner(30),
})

local main = create("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(0.88, 0.82),
    BackgroundColor3 = THEME.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = backdrop,
}, {
    corner(24),
    stroke(THEME.Accent, 0.55, 1),
    create("UISizeConstraint", {
        MinSize = Vector2.new(820, 520),
        MaxSize = Vector2.new(1460, 900),
    }),
    create("UIGradient", {
        Rotation = 22,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, THEME.Background2),
            ColorSequenceKeypoint.new(0.5, THEME.Background),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 9, 14)),
        }),
    }),
})

local topGlow = create("Frame", {
    Name = "TopGlow",
    Position = UDim2.fromOffset(0, 0),
    Size = UDim2.new(1, 0, 0, 2),
    BorderSizePixel = 0,
    BackgroundColor3 = THEME.Accent,
    BackgroundTransparency = 0.15,
    Parent = main,
}, {
    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(110, 72, 122)),
            ColorSequenceKeypoint.new(0.45, THEME.Accent),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(88, 70, 120)),
        }),
    }),
})

local header = create("Frame", {
    Name = "Header",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 112),
    Parent = main,
})

local brand = create("Frame", {
    Name = "Brand",
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(34, 24),
    Size = UDim2.fromOffset(215, 72),
    Parent = header,
})

create("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 34),
    Text = CONFIG.Title,
    TextColor3 = THEME.Text,
    TextSize = 26,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = brand,
})

create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(2, 36),
    Size = UDim2.new(1, 0, 0, 18),
    Text = CONFIG.Subtitle,
    TextColor3 = THEME.Muted,
    TextSize = 11,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = brand,
})

local searchWrap = create("Frame", {
    Name = "SearchWrap",
    Position = UDim2.new(0, 270, 0, 33),
    Size = UDim2.new(1, -500, 0, 50),
    BackgroundColor3 = THEME.Surface,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    Parent = header,
}, {
    corner(16),
    stroke(THEME.Stroke, 0.42, 1),
})

create("TextLabel", {
    Name = "SearchIcon",
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(17, 0),
    Size = UDim2.fromOffset(26, 50),
    Text = "⌕",
    TextColor3 = THEME.Text,
    TextSize = 28,
    Font = Enum.Font.Gotham,
    Parent = searchWrap,
})

local searchBox = create("TextBox", {
    Name = "SearchBox",
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(50, 0),
    Size = UDim2.new(1, -92, 1, 0),
    PlaceholderText = "Search your scripts...",
    PlaceholderColor3 = THEME.Muted,
    Text = "",
    TextColor3 = THEME.Text,
    TextSize = 15,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = searchWrap,
})

local clearSearch = create("TextButton", {
    Name = "Clear",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -12, 0.5, 0),
    Size = UDim2.fromOffset(28, 28),
    BackgroundColor3 = THEME.Surface3,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    Text = "×",
    TextColor3 = THEME.Muted,
    TextSize = 20,
    Font = Enum.Font.Gotham,
    Visible = false,
    AutoButtonColor = false,
    Parent = searchWrap,
}, {
    corner(8),
})

local controls = create("Frame", {
    Name = "Controls",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -24, 0, 22),
    Size = UDim2.fromOffset(150, 56),
    BackgroundTransparency = 1,
    Parent = header,
})

local function makeWindowButton(name, text, x)
    local button = create("TextButton", {
        Name = name,
        Position = UDim2.fromOffset(x, 0),
        Size = UDim2.fromOffset(42, 42),
        BackgroundColor3 = THEME.Surface,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = THEME.Text,
        TextSize = 20,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
        Parent = controls,
    }, {
        corner(12),
    })

    button.MouseEnter:Connect(function()
        tween(button, 0.16, {BackgroundTransparency = 0.18})
    end)
    button.MouseLeave:Connect(function()
        tween(button, 0.16, {BackgroundTransparency = 1})
    end)

    return button
end

local minimizeButton = makeWindowButton("Minimize", "−", 6)
local closeButton = makeWindowButton("Close", "×", 100)

local content = create("Frame", {
    Name = "Content",
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 106),
    Size = UDim2.new(1, 0, 1, -106),
    Parent = main,
})

local filtersClip = create("Frame", {
    Name = "FiltersClip",
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(270, 0),
    Size = UDim2.new(1, -315, 0, 54),
    ClipsDescendants = true,
    Parent = content,
})

local filters = create("ScrollingFrame", {
    Name = "Filters",
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.X,
    ScrollingDirection = Enum.ScrollingDirection.X,
    ScrollBarThickness = 0,
    BorderSizePixel = 0,
    Parent = filtersClip,
}, {
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }),
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 8),
    }),
})

local grid = create("ScrollingFrame", {
    Name = "Grid",
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(34, 58),
    Size = UDim2.new(1, -68, 1, -84),
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = THEME.Accent,
    ScrollBarImageTransparency = 0.2,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = content,
})

local gridLayout = create("UIGridLayout", {
    CellPadding = UDim2.fromOffset(13, 13),
    CellSize = UDim2.fromOffset(210, 172),
    SortOrder = Enum.SortOrder.LayoutOrder,
    FillDirection = Enum.FillDirection.Horizontal,
    FillDirectionMaxCells = 5,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    Parent = grid,
})

create("UIPadding", {
    PaddingTop = UDim.new(0, 2),
    PaddingBottom = UDim.new(0, 16),
    PaddingLeft = UDim.new(0, 1),
    PaddingRight = UDim.new(0, 6),
    Parent = grid,
})

local emptyState = create("Frame", {
    Name = "EmptyState",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.48),
    Size = UDim2.fromOffset(420, 160),
    BackgroundTransparency = 1,
    Visible = false,
    Parent = content,
})

create("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 48),
    Text = "No scripts found",
    TextColor3 = THEME.Text,
    TextSize = 24,
    Font = Enum.Font.GothamMedium,
    Parent = emptyState,
})

create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 50),
    Size = UDim2.new(1, 0, 0, 50),
    Text = "Try another search or filter.",
    TextColor3 = THEME.Muted,
    TextSize = 14,
    Font = Enum.Font.Gotham,
    Parent = emptyState,
})

local footer = create("TextLabel", {
    Name = "Footer",
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 35, 1, -12),
    Size = UDim2.new(1, -70, 0, 18),
    BackgroundTransparency = 1,
    Text = "READY WHEN YOU ARE.  ♡",
    TextColor3 = THEME.Faint,
    TextSize = 10,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = main,
})

local toastHolder = create("Frame", {
    Name = "ToastHolder",
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -22),
    Size = UDim2.fromOffset(430, 54),
    BackgroundTransparency = 1,
    Parent = main,
})

local activeToast
local function notify(message, kind)
    if activeToast then
        activeToast:Destroy()
        activeToast = nil
    end

    local accent = THEME.Accent
    if kind == "success" then
        accent = THEME.Success
    elseif kind == "error" then
        accent = THEME.Error
    end

    local toast = create("Frame", {
        Name = "Toast",
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, 15),
        Size = UDim2.fromOffset(390, 46),
        BackgroundColor3 = THEME.Surface2,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Parent = toastHolder,
    }, {
        corner(14),
        stroke(accent, 0.45, 1),
    })

    create("Frame", {
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(10, 12),
        Size = UDim2.fromOffset(4, 22),
        Parent = toast,
    }, {
        corner(4),
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Text = message,
        TextColor3 = THEME.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toast,
    })

    activeToast = toast
    tween(toast, 0.22, {Position = UDim2.new(0.5, 0, 1, 0)})

    task.delay(2.5, function()
        if toast and toast.Parent then
            tween(toast, 0.2, {Position = UDim2.new(0.5, 0, 1, 15), BackgroundTransparency = 1})
            task.wait(0.22)
            if toast then
                toast:Destroy()
            end
            if activeToast == toast then
                activeToast = nil
            end
        end
    end)
end

local favorites = {}
local cards = {}
local filterButtons = {}
local currentFilter = "All"

local function runEntry(entry)
    if entry.Demo then
        notify(entry.Name .. " is a demo card for now.", "success")
        return
    end

    if type(entry.Run) == "function" then
        local ok, err = pcall(entry.Run)
        if ok then
            notify("Opened " .. entry.Name .. ".", "success")
        else
            notify("Could not open " .. entry.Name .. ": " .. tostring(err), "error")
        end
        return
    end

    if type(entry.Source) == "string" and entry.Source ~= "" then
        local compiler = loadstring
        if not compiler then
            notify("This environment does not support loadstring.", "error")
            return
        end

        local chunk, compileError = compiler(entry.Source)
        if not chunk then
            notify("Compile error: " .. tostring(compileError), "error")
            return
        end

        local ok, runtimeError = pcall(chunk)
        if ok then
            notify("Opened " .. entry.Name .. ".", "success")
        else
            notify("Runtime error: " .. tostring(runtimeError), "error")
        end
        return
    end

    if type(entry.Url) == "string" and entry.Url ~= "" then
        if not game.HttpGet then
            notify("HTTP loading is unavailable here.", "error")
            return
        end

        local ok, result = pcall(function()
            local source = game:HttpGet(entry.Url)
            local compiler = loadstring
            if not compiler then
                error("loadstring is unavailable")
            end
            local chunk, compileError = compiler(source)
            if not chunk then
                error(compileError)
            end
            return chunk()
        end)

        if ok then
            notify("Opened " .. entry.Name .. ".", "success")
        else
            notify("Could not open " .. entry.Name .. ": " .. tostring(result), "error")
        end
        return
    end

    notify("No script is attached to " .. entry.Name .. " yet.")
end

local function setFavorite(entry, value)
    favorites[entry.Id] = value
    local cardData = cards[entry.Id]
    if cardData then
        cardData.FavoriteButton.Text = value and "★" or "☆"
        cardData.FavoriteButton.TextColor3 = value and THEME.Accent or THEME.Text
    end
end

local function createCard(entry, order)
    local card = create("Frame", {
        Name = entry.Id,
        LayoutOrder = order,
        BackgroundColor3 = THEME.Surface,
        BackgroundTransparency = 0.03,
        BorderSizePixel = 0,
        Parent = grid,
    }, {
        corner(14),
        stroke(THEME.Stroke, 0.62, 1),
    })

    local art = create("Frame", {
        Name = "Art",
        Size = UDim2.new(1, 0, 0, 88),
        BackgroundColor3 = entry.AccentA or THEME.Accent,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = card,
    }, {
        corner(14),
        create("UIGradient", {
            Rotation = 18,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, entry.AccentA or THEME.Accent),
                ColorSequenceKeypoint.new(1, entry.AccentB or THEME.Accent2),
            }),
        }),
    })

    create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 16, 0.52, 0),
        Size = UDim2.fromOffset(105, 105),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.92,
        BorderSizePixel = 0,
        Rotation = 22,
        Parent = art,
    }, {
        corner(26),
    })

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 10),
        Size = UDim2.new(1, -28, 1, -20),
        Text = entry.Symbol or string.sub(entry.Name, 1, 2),
        TextColor3 = Color3.fromRGB(255, 245, 255),
        TextTransparency = 0.04,
        TextSize = #tostring(entry.Symbol or "") > 3 and 22 or 31,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Bottom,
        Parent = art,
    })

    if entry.Image then
        create("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Image = entry.Image,
            ScaleType = Enum.ScaleType.Crop,
            Parent = art,
        }, {
            corner(14),
        })
    end

    create("Frame", {
        Position = UDim2.new(0, 0, 1, -12),
        Size = UDim2.new(1, 0, 0, 13),
        BackgroundColor3 = THEME.Surface,
        BorderSizePixel = 0,
        Parent = art,
    })

    create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 91),
        Size = UDim2.new(1, -24, 0, 22),
        Text = entry.Name,
        TextColor3 = THEME.Text,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    create("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 112),
        Size = UDim2.new(1, -24, 0, 17),
        Text = entry.Subtitle or entry.Category or "Script",
        TextColor3 = THEME.Muted,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    local favorite = create("TextButton", {
        Name = "Favorite",
        Position = UDim2.fromOffset(11, 136),
        Size = UDim2.fromOffset(30, 28),
        BackgroundTransparency = 1,
        Text = "☆",
        TextColor3 = THEME.Text,
        TextSize = 22,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
        Parent = card,
    })

    local open = create("TextButton", {
        Name = "Open",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -45, 1, -8),
        Size = UDim2.fromOffset(72, 28),
        BackgroundColor3 = Color3.fromRGB(74, 45, 67),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Text = "Open",
        TextColor3 = THEME.Text,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false,
        Parent = card,
    }, {
        corner(10),
        stroke(THEME.Accent, 0.62, 1),
    })

    local more = create("TextButton", {
        Name = "More",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -8, 1, -8),
        Size = UDim2.fromOffset(29, 28),
        BackgroundColor3 = THEME.Surface3,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Text = "•••",
        TextColor3 = THEME.Muted,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = card,
    }, {
        corner(9),
    })

    favorite.MouseButton1Click:Connect(function()
        setFavorite(entry, not favorites[entry.Id])
    end)

    open.MouseButton1Click:Connect(function()
        runEntry(entry)
    end)

    more.MouseButton1Click:Connect(function()
        notify(entry.Name .. " • " .. (entry.Category or "Script"))
    end)

    card.MouseEnter:Connect(function()
        tween(card, 0.18, {BackgroundColor3 = THEME.Surface2})
        tween(open, 0.18, {BackgroundColor3 = Color3.fromRGB(105, 54, 90)})
    end)

    card.MouseLeave:Connect(function()
        tween(card, 0.18, {BackgroundColor3 = THEME.Surface})
        tween(open, 0.18, {BackgroundColor3 = Color3.fromRGB(74, 45, 67)})
    end)

    cards[entry.Id] = {
        Frame = card,
        FavoriteButton = favorite,
        Entry = entry,
    }
end

for index, entry in ipairs(SCRIPT_LIBRARY) do
    createCard(entry, index)
end

local filterNames = {"All", "Roblox", "Universal", "Game Specific", "UI", "Tools", "Favorites"}

local function makeFilter(name, order)
    local width = math.max(66, 28 + (#name * 7))
    local button = create("TextButton", {
        Name = name,
        LayoutOrder = order,
        Size = UDim2.fromOffset(width, 36),
        BackgroundColor3 = THEME.Surface,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Text = name == "Favorites" and "♡  Favorites" or name,
        TextColor3 = THEME.Text,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false,
        Parent = filters,
    }, {
        corner(18),
        stroke(THEME.Stroke, 0.55, 1),
    })

    filterButtons[name] = button
    return button
end

for index, name in ipairs(filterNames) do
    makeFilter(name, index)
end

local function entryMatchesFilter(entry)
    if currentFilter == "All" then
        return true
    end

    if currentFilter == "Favorites" then
        return favorites[entry.Id] == true
    end

    if currentFilter == "Game Specific" then
        if normalize(entry.Category) == "game specific" then
            return true
        end
        for _, tag in ipairs(entry.Tags or {}) do
            if normalize(tag) == "game specific" then
                return true
            end
        end
        return false
    end

    return normalize(entry.Category) == normalize(currentFilter)
        or normalize(entry.Subtitle) == normalize(currentFilter)
end

local function entryMatchesSearch(entry, query)
    if query == "" then
        return true
    end

    if contains(entry.Name, query) or contains(entry.Subtitle, query) or contains(entry.Category, query) then
        return true
    end

    for _, tag in ipairs(entry.Tags or {}) do
        if contains(tag, query) then
            return true
        end
    end

    return false
end

local function refreshCards()
    local query = normalize(searchBox.Text)
    local visibleCount = 0

    for _, entry in ipairs(SCRIPT_LIBRARY) do
        local card = cards[entry.Id]
        local visible = entryMatchesFilter(entry) and entryMatchesSearch(entry, query)
        card.Frame.Visible = visible
        if visible then
            visibleCount += 1
        end
    end

    emptyState.Visible = visibleCount == 0
    clearSearch.Visible = searchBox.Text ~= ""
end

local function refreshFilterStyles()
    for name, button in pairs(filterButtons) do
        local selected = name == currentFilter
        tween(button, 0.18, {
            BackgroundColor3 = selected and THEME.Accent or THEME.Surface,
            TextColor3 = selected and Color3.fromRGB(27, 13, 24) or THEME.Text,
            BackgroundTransparency = selected and 0 or 0.08,
        })
    end
end

for name, button in pairs(filterButtons) do
    button.MouseButton1Click:Connect(function()
        currentFilter = name
        refreshFilterStyles()
        refreshCards()
    end)

    button.MouseEnter:Connect(function()
        if currentFilter ~= name then
            tween(button, 0.15, {BackgroundColor3 = THEME.Surface3})
        end
    end)

    button.MouseLeave:Connect(function()
        if currentFilter ~= name then
            tween(button, 0.15, {BackgroundColor3 = THEME.Surface})
        end
    end)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(refreshCards)

searchBox.Focused:Connect(function()
    tween(searchWrap, 0.18, {BackgroundColor3 = THEME.Surface2})
    local outline = searchWrap:FindFirstChildOfClass("UIStroke")
    if outline then
        tween(outline, 0.18, {Transparency = 0.18, Color = THEME.Accent})
    end
end)

searchBox.FocusLost:Connect(function()
    tween(searchWrap, 0.18, {BackgroundColor3 = THEME.Surface})
    local outline = searchWrap:FindFirstChildOfClass("UIStroke")
    if outline then
        tween(outline, 0.18, {Transparency = 0.42, Color = THEME.Stroke})
    end
end)

clearSearch.MouseButton1Click:Connect(function()
    searchBox.Text = ""
    searchBox:CaptureFocus()
end)

clearSearch.MouseEnter:Connect(function()
    tween(clearSearch, 0.15, {BackgroundColor3 = THEME.Accent, TextColor3 = Color3.fromRGB(25, 12, 23)})
end)

clearSearch.MouseLeave:Connect(function()
    tween(clearSearch, 0.15, {BackgroundColor3 = THEME.Surface3, TextColor3 = THEME.Muted})
end)

local minimized = false
local originalSize = main.Size

local function setMinimized(value)
    minimized = value
    content.Visible = not value
    footer.Visible = not value
    searchWrap.Visible = not value
    minimizeButton.Text = value and "+" or "−"

    if value then
        tween(main, 0.28, {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 92)})
    else
        tween(main, 0.28, {Size = originalSize})
    end
end

minimizeButton.MouseButton1Click:Connect(function()
    setMinimized(not minimized)
end)

local function setVisible(value)
    screen.Enabled = value
    if blur then
        tween(blur, 0.24, {Size = value and 12 or 0})
    end
end

closeButton.MouseButton1Click:Connect(function()
    setVisible(false)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == CONFIG.ToggleKey and not gameProcessed then
        setVisible(not screen.Enabled)
        return
    end

    if input.KeyCode == Enum.KeyCode.K and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if not screen.Enabled then
            setVisible(true)
        end
        if minimized then
            setMinimized(false)
        end
        task.defer(function()
            searchBox:CaptureFocus()
        end)
    end
end)

local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - dragStart
    main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end)

local function updateGridSize()
    local width = grid.AbsoluteSize.X
    if width <= 0 then
        return
    end

    local columns
    if width >= 1180 then
        columns = 6
    elseif width >= 950 then
        columns = 5
    elseif width >= 740 then
        columns = 4
    else
        columns = 3
    end

    local gap = 13
    local usable = width - (gap * (columns - 1)) - 8
    local cellWidth = math.floor(usable / columns)

    gridLayout.FillDirectionMaxCells = columns
    gridLayout.CellSize = UDim2.fromOffset(cellWidth, 172)
end

grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGridSize)
task.defer(updateGridSize)

refreshFilterStyles()
refreshCards()

main.Size = UDim2.fromScale(0.83, 0.76)
main.BackgroundTransparency = 0.12
ambientGlow.BackgroundTransparency = 1

tween(main, 0.36, {
    Size = originalSize,
    BackgroundTransparency = 0,
}, Enum.EasingStyle.Quint)

tween(ambientGlow, 0.5, {
    BackgroundTransparency = 0.92,
})

if CONFIG.DemoMode then
    task.delay(0.45, function()
        if screen and screen.Parent then
            notify("Velora Hub prototype loaded. Real scripts can be added next.", "success")
        end
    end)
end
