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

-- Live polish fixes: dropdown layer/rounding, guaranteed Velora Piano visual, and close button.
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

local pianoCardNeedle = [==[    if entry.Id == "velora-piano" then
        local fallback = addVeloraPianoFallback(imageWrap, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), image.ZIndex)
        bindThumbnailFallback(image, fallback)
    end
    setRemoteImage(image, entry.ImageUrl, entry.ImageCache)]==]

local pianoCardReplacement = [==[    if entry.Id == "velora-piano" then
        image.Visible = false
        addVeloraPianoFallback(imageWrap, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), image.ZIndex)
    else
        setRemoteImage(image, entry.ImageUrl, entry.ImageCache)
    end]==]

replacePlain(pianoCardNeedle, pianoCardReplacement, "Velora Piano grid visual")
replacePlain(pianoCardNeedle, pianoCardReplacement, "Velora Piano list visual")

replacePlain(
[==[    if entry.Id == "velora-piano" then
        local fallback = addVeloraPianoFallback(imageWrap, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), 56)
        bindThumbnailFallback(image, fallback)
    end
    setRemoteImage(image, entry.ImageUrl, entry.ImageCache)]==],
[==[    if entry.Id == "velora-piano" then
        image.Visible = false
        addVeloraPianoFallback(imageWrap, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), 56)
    else
        setRemoteImage(image, entry.ImageUrl, entry.ImageCache)
    end]==],
    "Velora Piano detail visual"
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
    tween(closeButton, 0.12, { BackgroundTransparency = 0, TextColor3 = THEME.Text })
end)
closeButton.MouseLeave:Connect(function()
    tween(closeButton, 0.12, { BackgroundTransparency = 0.2, TextColor3 = Color3.fromHex("#9A9AA4") })
end)
closeButton.MouseButton1Click:Connect(function()
    shown = false
    tween(blur, 0.14, { Size = 0 })
    tween(main, 0.14, { GroupTransparency = 1 })
    task.delay(0.15, function()
        if not shown and gui and gui.Parent then
            gui.Enabled = false
            blur.Enabled = false
        end
    end)
end)

local function runRemote(entry)]==],
    "close button"
)
]=]

coreSource = coreSource:sub(1, insertAt - 1) .. liveFixes .. coreSource:sub(insertAt)

local chunk, compileError = loadstring(coreSource)
if not chunk then
    error("[Salty Hub] Failed to compile patched HubCore.lua: " .. tostring(compileError), 0)
end

return chunk()
