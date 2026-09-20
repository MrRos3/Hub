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

            -- Successful load means the Hub is finished. Terminate it completely.
            hubTerminated = true
            shown = false

            task.defer(function()
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
        else]==],
    "terminate hub after successful script load"
)



-- Use VantaUI's actual production brand artwork, not the salty-special wallpaper or a hand-built icon.
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
    ClipsDescendants = true,
    Parent = header,
}, { corner(8) })

create("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "V",
    TextColor3 = Color3.fromHex("#A98AE3"),
    TextSize = 16,
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
setRemoteImage(
    brandLogo,
    "https://raw.githubusercontent.com/MrRos3/VantaUI/main/assets/vanta-brand-v2.jpeg?v=vanta-hub-brand-v1",
    "vanta_brand_v2_hub.jpeg"
)]==],
    "official Vanta brand artwork"
)

replacePlain(
[==[    Text = "Salty Hub",]==],
[==[    Text = "VantaUI",]==],
    "header title brand"
)

replacePlain(
[==[    Text = "Script library  •  Online library",]==],
[==[    Text = "Script library  •  Online library",]==],
    "header subtitle brand"
)

-- Use VantaUI's actual notification renderer instead of imitating its appearance.
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
[==[local vantaNotifier
local vantaNotifierAttempted = false

local function getVantaNotifier()
    if vantaNotifier then
        return vantaNotifier
    end
    if vantaNotifierAttempted then
        return nil
    end
    vantaNotifierAttempted = true

    local ok, result = pcall(function()
        if type(loadstring) ~= "function" then
            return nil
        end
        local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))
        local source = game:HttpGet(
            "https://raw.githubusercontent.com/MrRos3/VantaUI/main/main.lua?v=" .. cache
        )
        local chunk, compileError = loadstring(source)
        if not chunk then
            error(compileError or "VantaUI compile failed")
        end
        return chunk()
    end)

    if ok and type(result) == "table" and type(result.Notify) == "function" then
        vantaNotifier = result
    end
    return vantaNotifier
end

local function showToast(title, message, kind)
    toastToken += 1

    local notifier = getVantaNotifier()
    if notifier then
        local ok = pcall(function()
            notifier:Notify({
                Title = tostring(title or "Notification"),
                Content = tostring(message or ""),
                Icon = kind == "error" and "triangle-alert" or "check",
                Duration = 3.5,
                CanClose = true,
            })
        end)
        if ok then
            return
        end
    end

    -- Small fallback only if VantaUI itself cannot load in the executor.
    local toast = create("Frame", {
        Name = "ToastFallback",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, 320, 1, -76),
        Size = UDim2.fromOffset(300, 72),
        BackgroundColor3 = Color3.fromHex("#101010"),
        BorderSizePixel = 0,
        ZIndex = 1000,
        Parent = gui,
    }, { corner(18) })

    create("TextLabel", {
        Position = UDim2.fromOffset(14, 12),
        Size = UDim2.new(1, -44, 0, 20),
        BackgroundTransparency = 1,
        Text = truncate(title, 42),
        TextColor3 = THEME.Text,
        TextSize = 14,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 1001,
        Parent = toast,
    })
    create("TextLabel", {
        Position = UDim2.fromOffset(14, 36),
        Size = UDim2.new(1, -28, 0, 20),
        BackgroundTransparency = 1,
        Text = truncate(message, 68),
        TextColor3 = THEME.Muted,
        TextSize = 11,
        FontFace = font(Enum.FontWeight.Medium),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 1001,
        Parent = toast,
    })

    tween(toast, 0.45, { Position = UDim2.new(1, -29, 1, -76) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    task.delay(3.5, function()
        if toast and toast.Parent then
            tween(toast, 0.45, { Position = UDim2.new(1, 320, 1, -76) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            task.delay(0.46, function()
                if toast and toast.Parent then
                    toast:Destroy()
                end
            end)
        end
    end)
end]==],
    "actual VantaUI notification renderer"
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
