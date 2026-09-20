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
