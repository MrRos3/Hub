-- Salty Hub bootstrap
-- Loads HubCore and applies the latest live UI fixes before execution.

local URL = "https://raw.githubusercontent.com/MrRos3/Hub/main/HubCore.lua"
local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))

local ok, coreSource = pcall(function()
    return game:HttpGet(URL .. "?v=" .. cache)
end)

if not ok or type(coreSource) ~= "string" or coreSource == "" then
    error("[Salty Hub] Failed to download HubCore.lua", 0)
end

local marker = "\nlocal chunk, compileError = loadstring(source)"
local insertAt = string.find(coreSource, marker, 1, true)
if not insertAt then
    error("[Salty Hub] Could not find HubCore patch insertion point", 0)
end

local liveFixes = [=[

-- Live polish fixes: dropdown layer/rounding, Visual Piano image refresh, and hard terminate X button.
replacePlain(
[==[local sortPopup = create("Frame", {
    Name = "SortPopup",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -72, 0, 34),
    Size = UDim2.fromOffset(145, 102),
    BackgroundColor3 = THEME.Surface2,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 40,
    Parent = toolbar,
}, { corner(7), stroke(Color3.fromRGB(44, 44, 51), 0.08, 1) })]==],
[==[local sortPopup = create("Frame", {
    Name = "SortPopup",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -94, 0, 169),
    Size = UDim2.fromOffset(145, 102),
    BackgroundColor3 = THEME.Surface2,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Visible = false,
    ZIndex = 200,
    Parent = main,
}, { corner(9), stroke(Color3.fromRGB(44, 44, 51), 0.04, 1) })]==],
    "sort popup overlay"
)

replacePlain(
[==[        ZIndex = 41,
        Parent = sortPopup,]==],
[==[        ZIndex = 201,
        Parent = sortPopup,]==],
    "sort option layer"
)

replacePlain(
[==[    Position = UDim2.new(1, -22, 0.5, 0),]==],
[==[    Position = UDim2.new(1, -58, 0.5, 0),]==],
    "status spacing for close button"
)

-- Persistent termination state lives inside the generated HubCore source.
replacePlain(
[==[local player = Players.LocalPlayer]==],
[==[local player = Players.LocalPlayer
local hubTerminated = false]==],
    "hub termination state"
)

-- Refresh the executor-side thumbnail cache so the newly supplied Visual Piano art is used.
replacePlain(
[==[        ImageUrl = BASE_RAW .. "assets/cards/velora-piano.jpg?v=visual-piano-v3",
        ImageCache = "card_velora-piano_visual_v3.jpg",]==],
[==[        ImageUrl = BASE_RAW .. "assets/cards/velora-piano.jpg?v=visual-piano-v4",
        ImageCache = "card_velora-piano_visual_v4.jpg",]==],
    "Visual Piano image refresh"
)

-- Once terminated, global input/viewport hooks become inert instead of touching destroyed UI.
replacePlain(
[==[local function updateScale()
    local camera = Workspace.CurrentCamera]==],
[==[local function updateScale()
    if hubTerminated then
        return
    end
    local camera = Workspace.CurrentCamera]==],
    "stop responsive scaling after termination"
)

replacePlain(
[==[UserInputService.InputBegan:Connect(function(input, processed)
    if processed then]==],
[==[UserInputService.InputBegan:Connect(function(input, processed)
    if hubTerminated or processed then]==],
    "stop keyboard shortcuts after termination"
)

replacePlain(
[==[    UserInputService.InputChanged:Connect(function(input)]==],
[==[    UserInputService.InputChanged:Connect(function(input)
        if hubTerminated then
            return
        end]==],
    "stop drag updates after termination"
)

replacePlain(
[==[    UserInputService.InputEnded:Connect(function(input)]==],
[==[    UserInputService.InputEnded:Connect(function(input)
        if hubTerminated then
            return
        end]==],
    "stop drag ending after termination"
)

replacePlain(
[==[toggleConnection = UserInputService.InputBegan:Connect(function(input, processed)
    if processed or input.KeyCode ~= TOGGLE_KEY then]==],
[==[toggleConnection = UserInputService.InputBegan:Connect(function(input, processed)
    if hubTerminated or processed or input.KeyCode ~= TOGGLE_KEY then]==],
    "disable toggle key after termination"
)

replacePlain(
[==[local renderContent
local openDetails
local shown = true

local function runRemote(entry)]==],
[==[local renderContent
local openDetails
local shown = true

local closeButton = create("TextButton", {
    Name = "CloseButton",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -16, 0.5, 0),
    Size = UDim2.fromOffset(28, 28),
    BackgroundColor3 = THEME.Surface2,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    Text = "×",
    TextColor3 = Color3.fromHex("#9A9AA4"),
    TextSize = 18,
    FontFace = font(Enum.FontWeight.Medium),
    AutoButtonColor = false,
    ZIndex = 210,
    Parent = header,
}, { corner(7), stroke(Color3.fromRGB(45, 45, 52), 0.12, 1) })

closeButton.MouseEnter:Connect(function()
    if hubTerminated then
        return
    end
    tween(closeButton, 0.12, { BackgroundTransparency = 0, TextColor3 = THEME.Text })
end)
closeButton.MouseLeave:Connect(function()
    if hubTerminated then
        return
    end
    tween(closeButton, 0.12, { BackgroundTransparency = 0.2, TextColor3 = Color3.fromHex("#9A9AA4") })
end)
closeButton.MouseButton1Click:Connect(function()
    if hubTerminated then
        return
    end

    hubTerminated = true
    shown = false

    pcall(function()
        tween(blur, 0.10, { Size = 0 })
        tween(main, 0.10, { GroupTransparency = 1 })
    end)

    task.delay(0.11, function()
        pcall(function()
            if gui and gui.Parent then
                gui:Destroy()
            end
        end)
        pcall(function()
            if blur and blur.Parent then
                blur:Destroy()
            end
        end)
    end)
end)

local function runRemote(entry)]==],
    "terminate close button"
)


-- Remove the extra tiny circle from the Loading label; keep the animated spinner only.
replacePlain(
[==[        Text = loading[entry.Id] and "◌  Loading..." or loaded[entry.Id] and "✓  Loaded" or "▶  Load Script",]==],
[==[        Text = loading[entry.Id] and "Loading..." or loaded[entry.Id] and "✓  Loaded" or "▶  Load Script",]==],
    "loading label cleanup"
)

-- Keep the Hub open while the script is loading.
replacePlain(
[==[    if loading[entry.Id] then
        return
    end
    shown = false
    gui.Enabled = false
    blur.Size = 0
    blur.Enabled = false
    loading[entry.Id] = true]==],
[==[    if loading[entry.Id] then
        return
    end
    loading[entry.Id] = true]==],
    "keep hub visible during script load"
)

-- Close the Hub only after the script finishes loading successfully.
replacePlain(
[==[        if ok then
            loaded[entry.Id] = true
            showToast(entry.Name .. " loaded", "Ready to use in your Roblox session.", "success")
            task.delay(1.6, function()
                loaded[entry.Id] = nil
                if renderContent then
                    renderContent()
                end
            end)
        else]==],
[==[        if ok then
            loaded[entry.Id] = true
            showToast(entry.Name .. " loaded", "Ready to use in your Roblox session.", "success")
            task.delay(0.1, function()
                if hubTerminated then
                    return
                end
                shown = false
                pcall(function()
                    tween(blur, 0.15, { Size = 0 })
                    tween(main, 0.15, { GroupTransparency = 1 })
                end)
                task.delay(0.16, function()
                    if not hubTerminated and gui and gui.Parent then
                        gui.Enabled = false
                    end
                    if not hubTerminated and blur and blur.Parent then
                        blur.Enabled = false
                    end
                end)
            end)
            task.delay(1.6, function()
                loaded[entry.Id] = nil
                if renderContent then
                    renderContent()
                end
            end)
        else]==],
    "close hub after successful script load"
)



-- Rebrand the header to match VantaUI instead of the salty-special image.
replacePlain(
[==[local brandWrap = create("Frame", {
    Name = "BrandWrap",
    Position = UDim2.fromOffset(22, 14),
    Size = UDim2.fromOffset(38, 38),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = header,
})

create("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "S",
    TextColor3 = Color3.fromHex("#B89AE8"),
    TextSize = 17,
    FontFace = font(Enum.FontWeight.Bold),
    Parent = brandWrap,
})

local brandLogo = create("ImageLabel", {
    Name = "BrandLogo",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Image = "",
    ImageTransparency = 1,
    ScaleType = Enum.ScaleType.Fit,
    Parent = brandWrap,
})
setRemoteImage(brandLogo, BRAND_LOGO_URL, "salty_brand_logo_v2.png")]==],
[==[local brandWrap = create("Frame", {
    Name = "BrandWrap",
    Position = UDim2.fromOffset(22, 14),
    Size = UDim2.fromOffset(38, 38),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = header,
})

create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromOffset(14, 18),
    Size = UDim2.fromOffset(4, 20),
    Rotation = 24,
    BackgroundColor3 = Color3.fromHex("#C7B3F0"),
    BorderSizePixel = 0,
    Parent = brandWrap,
}, { corner(99) })
create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromOffset(24, 18),
    Size = UDim2.fromOffset(4, 20),
    Rotation = -24,
    BackgroundColor3 = Color3.fromHex("#8C6BD1"),
    BorderSizePixel = 0,
    Parent = brandWrap,
}, { corner(99) })
create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromOffset(19, 26),
    Size = UDim2.fromOffset(12, 4),
    BackgroundColor3 = Color3.fromHex("#5C418F"),
    BorderSizePixel = 0,
    Parent = brandWrap,
}, { corner(99) })]==],
    "VantaUI brand mark"
)

replacePlain(
[==[    Text = "Salty Hub",]==],
[==[    Text = "VantaUI",]==],
    "header title brand"
)

replacePlain(
[==[    Text = "Script library  •  Online library",]==],
[==[    Text = "Premium script library  •  Online library",]==],
    "header subtitle brand"
)

-- Cleaner VantaUI-like notifications.
replacePlain(
[==[local function showToast(title, message, kind)
    toastToken += 1
    local token = toastToken
    local accent = kind == "error" and THEME.Danger or THEME.Success

    local toast = create("Frame", {
        Name = "Toast",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, 270, 1, -16),
        Size = UDim2.fromOffset(254, 58),
        BackgroundColor3 = THEME.Surface2,
        BorderSizePixel = 0,
        ZIndex = 80,
        Parent = main,
    }, { corner(9), stroke(Color3.fromRGB(45, 45, 52), 0.1, 1) })

    create("Frame", {
        Position = UDim2.fromOffset(10, 12),
        Size = UDim2.fromOffset(5, 34),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        ZIndex = 81,
        Parent = toast,
    }, { corner(99) })

    create("TextLabel", {
        Position = UDim2.fromOffset(25, 9),
        Size = UDim2.new(1, -34, 0, 18),
        BackgroundTransparency = 1,
        Text = truncate(title, 40),
        TextColor3 = THEME.Text,
        TextSize = 11,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 81,
        Parent = toast,
    })
    create("TextLabel", {
        Position = UDim2.fromOffset(25, 28),
        Size = UDim2.new(1, -34, 0, 18),
        BackgroundTransparency = 1,
        Text = truncate(message, 54),
        TextColor3 = THEME.Muted,
        TextSize = 9,
        FontFace = font(Enum.FontWeight.Regular),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 81,
        Parent = toast,
    })

    tween(toast, 0.24, { Position = UDim2.new(1, -16, 1, -16) })
    task.delay(2.7, function()
        if token <= toastToken and toast and toast.Parent then
            local out = tween(toast, 0.2, { Position = UDim2.new(1, 270, 1, -16) })
            task.delay(0.22, function()
                if toast and toast.Parent then
                    toast:Destroy()
                end
            end)
        end
    end)
end]==],
[==[local function showToast(title, message, kind)
    toastToken += 1
    local token = toastToken
    local accent = kind == "error" and THEME.Danger or THEME.Success

    local previous = main:FindFirstChild("Toast")
    if previous then
        previous:Destroy()
    end

    local toast = create("Frame", {
        Name = "Toast",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, 320, 1, -18),
        Size = UDim2.fromOffset(282, 72),
        BackgroundColor3 = THEME.Surface,
        BorderSizePixel = 0,
        ZIndex = 80,
        Parent = main,
    }, { corner(12), stroke(accent, 0.72, 1) })

    create("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#12131A")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#0C0D12")),
        }),
        Parent = toast,
    })

    local iconWrap = create("Frame", {
        Position = UDim2.fromOffset(14, 16),
        Size = UDim2.fromOffset(28, 28),
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.86,
        BorderSizePixel = 0,
        ZIndex = 81,
        Parent = toast,
    }, { corner(99), stroke(accent, 0.35, 1) })
    create("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = kind == "error" and "!" or "✓",
        TextColor3 = accent,
        TextSize = 14,
        FontFace = font(Enum.FontWeight.Bold),
        ZIndex = 82,
        Parent = iconWrap,
    })

    create("TextLabel", {
        Position = UDim2.fromOffset(52, 13),
        Size = UDim2.new(1, -64, 0, 18),
        BackgroundTransparency = 1,
        Text = truncate(title, 42),
        TextColor3 = THEME.Text,
        TextSize = 11,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 81,
        Parent = toast,
    })
    create("TextLabel", {
        Position = UDim2.fromOffset(52, 32),
        Size = UDim2.new(1, -64, 0, 18),
        BackgroundTransparency = 1,
        Text = truncate(message, 62),
        TextColor3 = THEME.Muted,
        TextSize = 9,
        FontFace = font(Enum.FontWeight.Regular),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 81,
        Parent = toast,
    })

    local progressTrack = create("Frame", {
        Position = UDim2.fromOffset(14, 60),
        Size = UDim2.new(1, -28, 0, 2),
        BackgroundColor3 = THEME.Surface2,
        BorderSizePixel = 0,
        ZIndex = 81,
        Parent = toast,
    }, { corner(99) })
    local progressFill = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        ZIndex = 82,
        Parent = progressTrack,
    }, { corner(99) })

    tween(toast, 0.24, { Position = UDim2.new(1, -16, 1, -18) })
    tween(progressFill, 2.65, { Size = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Linear)
    task.delay(2.7, function()
        if token <= toastToken and toast and toast.Parent then
            tween(toast, 0.2, { Position = UDim2.new(1, 320, 1, -18) })
            task.delay(0.22, function()
                if toast and toast.Parent then
                    toast:Destroy()
                end
            end)
        end
    end)
end]==],
    "VantaUI toast style"
)

-- Detect wrong-game loads before downloading and running the script.
replacePlain(
[==[local function runRemote(entry)]==],
[==[local cachedCurrentGameName

local function getCurrentGameName()
    if cachedCurrentGameName ~= nil then
        return cachedCurrentGameName
    end
    local success, info = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    end)
    cachedCurrentGameName = success and type(info) == "table" and tostring(info.Name or "") or ""
    return cachedCurrentGameName
end

local function isEntryCompatible(entry)
    if not entry then
        return true
    end
    if entry.Category == "UNIVERSAL" or normalize(entry.Game) == "multiple games" then
        return true
    end

    local currentGame = normalize(getCurrentGameName())
    if currentGame == "" then
        return true
    end

    local candidates = { entry.Game, entry.Name }
    for _, tag in ipairs(entry.Tags or {}) do
        table.insert(candidates, tag)
    end

    for _, candidate in ipairs(candidates) do
        local value = normalize(candidate)
        if value ~= "" and (currentGame == value or string.find(currentGame, value, 1, true) or string.find(value, currentGame, 1, true)) then
            return true
        end
    end

    return false
end

local function runRemote(entry)]==],
    "game compatibility helpers"
)

replacePlain(
[==[local function runRemote(entry)
    if loading[entry.Id] then
        return
    end]==],
[==[local function runRemote(entry)
    if loading[entry.Id] then
        return
    end
    if not isEntryCompatible(entry) then
        showToast("Wrong game", "Join " .. tostring(entry.Game or "the supported game") .. " to load " .. tostring(entry.Name or "this script") .. ".", "error")
        return
    end]==],
    "wrong game notification"
)

]=]

coreSource = coreSource:sub(1, insertAt - 1) .. liveFixes .. coreSource:sub(insertAt)

local chunk, compileError = loadstring(coreSource)
if not chunk then
    error("[Salty Hub] Failed to compile patched HubCore.lua: " .. tostring(compileError), 0)
end

local result = chunk()

-- Runtime polish layer. Keeps the source UI intact while enforcing the final presentation.
task.defer(function()
    local rootGui = type(result) == "table" and result.Gui or nil
    if not rootGui or not rootGui.Parent then
        return
    end

    local dim = rootGui:FindFirstChild("Dim")
    local main = dim and dim:FindFirstChild("Window")

    -- Make every cropped card/details image actually render with rounded corners.
    local function roundImage(object)
        if not object:IsA("ImageLabel") or object.ScaleType ~= Enum.ScaleType.Crop then
            return
        end
        local uiCorner = object:FindFirstChildOfClass("UICorner")
        if not uiCorner then
            uiCorner = Instance.new("UICorner")
            uiCorner.Parent = object
        end
        uiCorner.CornerRadius = UDim.new(0, 10)
    end

    if main then
        for _, object in ipairs(main:GetDescendants()) do
            roundImage(object)
        end
        main.DescendantAdded:Connect(function(object)
            task.defer(function()
                if object and object.Parent then
                    roundImage(object)
                end
            end)
        end)

        -- Lock the main window in place so the GUI cannot be dragged.
        local lockedPosition = main.Position
        local correctingPosition = false
        main:GetPropertyChangedSignal("Position"):Connect(function()
            if correctingPosition or main.Position == lockedPosition then
                return
            end
            correctingPosition = true
            main.Position = lockedPosition
            correctingPosition = false
        end)
    end

    -- Stronger background blur. Re-apply after RightShift brings the Hub back.
    local blur = game:GetService("Lighting"):FindFirstChild("SaltyHubBlur")
    if blur and blur:IsA("BlurEffect") then
        task.delay(0.25, function()
            if blur and blur.Parent and blur.Enabled then
                blur.Size = 14
            end
        end)
        blur:GetPropertyChangedSignal("Enabled"):Connect(function()
            if blur.Enabled then
                task.delay(0.25, function()
                    if blur and blur.Parent and blur.Enabled then
                        blur.Size = 14
                    end
                end)
            end
        end)
    end
end)

return result
