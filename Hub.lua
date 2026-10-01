-- SaltyHub bootstrap wrapper
-- Loads the last full Hub bootstrap from an immutable commit, then injects the latest Villa Control image fix.

local BASE_HUB = "https://raw.githubusercontent.com/MrRos3/Hub/9d703784570d597222c57fbcd6dd166a185c6ef6/Hub.lua"
local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))

local ok, source = pcall(function()
    return game:HttpGet(BASE_HUB .. "?v=" .. cache)
end)

if not ok or type(source) ~= "string" or source == "" then
    error("[SaltyHub] Failed to download base Hub bootstrap.", 0)
end

local anchor = "-- Once terminated, global input/viewport hooks become inert instead of touching destroyed UI."
local insertAt = string.find(source, anchor, 1, true)
if not insertAt then
    error("[SaltyHub] Villa image patch anchor was not found.", 0)
end

local villaImageFix = [=[
-- Villa Control image transport.
-- Build the JPEG from six small text chunks, then pass the finished local JPEG to getcustomasset.
-- The JPEG itself was encoded with the exact quantization tables + 4:4:4 layout used by the working Stop the Timer card.
replacePlain(
[==[local function cacheRemoteAsset(url, path)
    if not canCache or not url or url == "" then
        return ""
    end
    if not isfile(path) then
        local ok, bytes = pcall(function()
            return game:HttpGet(url)
        end)
        if ok and type(bytes) == "string" then
            if string.find(url, ".b64.txt", 1, true) then
                bytes = decodeBase64(bytes)
            end
            if #bytes > 100 then
                pcall(writefile, path, bytes)
            end
        end
    end
    if isfile(path) then
        local ok, asset = pcall(customAsset, path)
        if ok and type(asset) == "string" then
            return asset
        end
    end
    return ""
end]==],
[==[local function cacheRemoteAsset(url, path)
    if not canCache or not url or url == "" then
        return ""
    end

    if not isfile(path) then
        local bytes

        if url == "__SALTY_VILLA_V5_PARTS__" then
            local parts = {}
            local allOk = true
            for i = 1, 6 do
                local okPart, part = pcall(function()
                    return game:HttpGet(
                        BASE_RAW .. "assets/cards/villa-control-v5-part" .. tostring(i) .. ".txt?v=villa-control-v5"
                    )
                end)
                if not okPart or type(part) ~= "string" or part == "" then
                    allOk = false
                    break
                end
                parts[i] = part
            end
            if allOk then
                bytes = decodeBase64(table.concat(parts))
            end
        else
            local okDownload, downloaded = pcall(function()
                return game:HttpGet(url)
            end)
            if okDownload and type(downloaded) == "string" then
                bytes = downloaded
                if string.find(url, ".b64.txt", 1, true) then
                    bytes = decodeBase64(bytes)
                end
            end
        end

        if type(bytes) == "string" and #bytes > 100 then
            pcall(writefile, path, bytes)
        end
    end

    if isfile(path) then
        local okAsset, asset = pcall(customAsset, path)
        if okAsset and type(asset) == "string" then
            return asset
        end
    end
    return ""
end]==],
    "Villa deterministic image transport"
)

replacePlain(
[==[        ImageUrl = BASE_RAW .. "assets/cards/villa-control-v1.jpg?v=villa-control-v1",
        ImageCache = "card_villa_control_v1.jpg",]==],
[==[        ImageUrl = "__SALTY_VILLA_V5_PARTS__",
        ImageCache = "card_villa_control_v5_exact.jpg",]==],
    "Villa Control image refresh"
)

]=]

source = source:sub(1, insertAt - 1) .. villaImageFix .. source:sub(insertAt)


local polishAnchor = "coreSource = coreSource:sub(1, insertAt - 1) .. liveFixes .. coreSource:sub(insertAt)"
local polishAt = string.find(source, polishAnchor, 1, true)
if not polishAt then error("[SaltyHub] UI polish anchor was not found.", 0) end
local premiumPolish = [====[
liveFixes = liveFixes .. [===[
-- Presentation refinements applied after the existing compatibility and image fixes.

replacePlain(
[==[Color3.fromHex("#686871")]==],
[==[Color3.fromHex("#858590")]==],
"secondary contrast 1"
)

replacePlain(
[==[Color3.fromHex("#6D6D77")]==],
[==[Color3.fromHex("#93939E")]==],
"game subtitle contrast 1"
)

replacePlain(
[==[Color3.fromHex("#6D6D77")]==],
[==[Color3.fromHex("#93939E")]==],
"game subtitle contrast 2"
)

replacePlain(
[==[Color3.fromRGB(190, 190, 198)]==],
[==[Color3.fromRGB(218, 218, 226)]==],
"image clarity 1"
)

replacePlain(
[==[Color3.fromRGB(190, 190, 198)]==],
[==[Color3.fromRGB(218, 218, 226)]==],
"image clarity 2"
)

replacePlain(
[==[Color3.fromRGB(190, 190, 198)]==],
[==[Color3.fromRGB(218, 218, 226)]==],
"image clarity 3"
)

replacePlain(
[==[Color3.fromRGB(190, 190, 198)]==],
[==[Color3.fromRGB(218, 218, 226)]==],
"image clarity 4"
)

replacePlain(
[==[Color3.fromRGB(190, 190, 198)]==],
[==[Color3.fromRGB(218, 218, 226)]==],
"image clarity 5"
)

replacePlain(
[==[Color3.fromRGB(220, 220, 226)]==],
[==[Color3.fromRGB(242, 242, 248)]==],
"image hover 1"
)

replacePlain(
[==[Color3.fromRGB(220, 220, 226)]==],
[==[Color3.fromRGB(242, 242, 248)]==],
"image hover 2"
)

replacePlain(
[==[SurfaceHover = Color3.fromHex("#111116")]==],
[==[SurfaceHover = Color3.fromHex("#17151D")]==],
"surface hierarchy"
)

replacePlain(
[==[local query = normalize(searchBox.Text)]==],
[==[local query = normalize(searchBox.Text):match("^%s*(.-)%s*$")]==],
"trim search"
)

replacePlain(
[==[scale.Scale = math.clamp(fit, 0.55, 1)]==],
[==[scale.Scale = math.clamp(fit, 0.1, 1)]==],
"fit small viewports"
)

replacePlain(
[==[local imageWrap = create("Frame", {
        Size = UDim2.new(1, 0, 0, 78)]==],
[==[local imageWrap = create("Frame", {
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.new(1, -16, 0, 70)]==],
"inset grid image"
)

replacePlain(
[==[local imageWrap = create("Frame", {
        Size = UDim2.fromOffset(122, 92)]==],
[==[local imageWrap = create("Frame", {
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.fromOffset(114, 76)]==],
"inset list image"
)

replacePlain(
[==[local imageWrap = create("Frame", {
        Size = UDim2.new(1, 0, 0, 138)]==],
[==[local imageWrap = create("Frame", {
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.new(1, -24, 0, 126)]==],
"inset details image"
)

replacePlain(
[==[TextSize = size.Y.Offset >= 34 and 10 or 9,]==],
[==[TextSize = size.Y.Offset >= 34 and 11 or 10,]==],
"load label hierarchy"
)

replacePlain(
[==[UDim2.fromOffset(81, 27), UDim2.new(1, -93, 1, -35)]==],
[==[UDim2.fromOffset(96, 30), UDim2.new(1, -108, 1, -38)]==],
"grid action spacing"
)

replacePlain(
[==[Size = UDim2.new(1, -103, 0, 14)]==],
[==[Size = UDim2.new(1, -124, 0, 14)]==],
"grid subtitle action clearance"
)

replacePlain(
[==[Text = entry.Name,
        TextColor3]==],
[==[Text = entry.Name,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextColor3]==],
"title overflow 1"
)

replacePlain(
[==[Text = entry.Name,
        TextColor3]==],
[==[Text = entry.Name,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextColor3]==],
"title overflow 2"
)

replacePlain(
[==[Text = entry.Name,
        TextColor3]==],
[==[Text = entry.Name,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextColor3]==],
"title overflow 3"
)

replacePlain(
[==[Color = THEME.Accent, Transparency = 0]==],
[==[Color = THEME.AccentBorder, Transparency = 0]==],
"card border hover 1"
)

replacePlain(
[==[Color = THEME.Accent, Transparency = 0]==],
[==[Color = THEME.AccentBorder, Transparency = 0]==],
"card border hover 2"
)

replacePlain(
[==[tween(card, 0.18]==],
[==[tween(card, 0.14]==],
"card response 1"
)

replacePlain(
[==[tween(card, 0.18]==],
[==[tween(card, 0.14]==],
"card response 2"
)

replacePlain(
[==[tween(card, 0.18]==],
[==[tween(card, 0.14]==],
"card response 3"
)

replacePlain(
[==[tween(card, 0.18]==],
[==[tween(card, 0.14]==],
"card response 4"
)

replacePlain(
[==[tween(image, 0.18]==],
[==[tween(image, 0.16]==],
"image response 1"
)

replacePlain(
[==[tween(image, 0.18]==],
[==[tween(image, 0.16]==],
"image response 2"
)

replacePlain(
[==[tween(image, 0.18]==],
[==[tween(image, 0.16]==],
"image response 3"
)

replacePlain(
[==[tween(image, 0.18]==],
[==[tween(image, 0.16]==],
"image response 4"
)

replacePlain(
[==[local function tween(object, duration, props, style, direction)
    local anim]==],
[==[local activeTweens = setmetatable({}, { __mode = "k" })
local function tween(object, duration, props, style, direction)
    local tracks = activeTweens[object]
    if not tracks then
        tracks = {}
        activeTweens[object] = tracks
    end
    for property in pairs(props) do
        if tracks[property] then tracks[property]:Cancel() end
    end
    local anim]==],
"interrupt overlapping motion"
)

replacePlain(
[==[    anim:Play()
    return anim]==],
[==[    for property in pairs(props) do tracks[property] = anim end
    anim.Completed:Once(function()
        for property in pairs(props) do
            if tracks[property] == anim then tracks[property] = nil end
        end
    end)
    anim:Play()
    return anim]==],
"release animation tracks"
)

replacePlain(
[==[            imageLabel.ImageTransparency = 0]==],
[==[            tween(imageLabel, 0.18, { ImageTransparency = 0 })]==],
"thumbnail reveal"
)

replacePlain(
[==[    button.MouseButton1Click:Connect(function()
        runRemote(entry)
    end)]==],
[==[    local hovered = false
    button.MouseEnter:Connect(function() hovered = true end)
    button.MouseLeave:Connect(function() hovered = false end)
    button.InputBegan:Connect(function(input)
        if not loading[entry.Id] and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            tween(button, 0.08, { BackgroundColor3 = THEME.AccentSoft })
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tween(button, 0.12, { BackgroundColor3 = hovered and THEME.AccentHover or THEME.Accent })
        end
    end)
    button.MouseButton1Click:Connect(function()
        runRemote(entry)
    end)]==],
"load press feedback"
)

replacePlain(
[==[searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    content.CanvasPosition = Vector2.zero
    renderContent()
end)]==],
[==[local searchRevision = 0
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    searchRevision += 1
    local revision = searchRevision
    task.delay(0.10, function()
        if hubTerminated or revision ~= searchRevision then return end
        content.CanvasPosition = Vector2.zero
        renderContent()
    end)
end)]==],
"debounce search"
)

replacePlain(
[==[    clearCards()
    styleFilterButtons()]==],
[==[    if hubTerminated or not content.Parent then return end
    clearCards()
    styleFilterButtons()]==],
"render lifecycle guard"
)

replacePlain(
[==[    closeDetails()
    selectedEntry = entry]==],
[==[    if hubTerminated or not main.Parent then return end
    sortPopup.Visible = false
    closeDetails()
    selectedEntry = entry]==],
"detail lifecycle"
)

replacePlain(
[==[    detailBackdrop.MouseButton1Click:Connect(closeDetails)]==],
[==[    tween(detailBackdrop, 0.18, { BackgroundTransparency = 0.42 })
    detailBackdrop.MouseButton1Click:Connect(closeDetails)]==],
"detail backdrop"
)

replacePlain(
[==[        Size = UDim2.fromOffset(286, 540),]==],
[==[        Size = UDim2.fromOffset(304, 540),]==],
"detail breathing room"
)

replacePlain(
[==[tween(detailPanel, 0.22, { Position = UDim2.new(1, -286, 0, 0) })]==],
[==[tween(detailPanel, 0.20, { Position = UDim2.new(1, -304, 0, 0) })]==],
"detail entrance"
)

replacePlain(
[==[    tween(detailPanel, 0.20]==],
[==[    local panelCorner = corner(12)
    panelCorner.Parent = detailPanel
    tween(detailPanel, 0.20]==],
"detail frame"
)

replacePlain(
[==[Size = UDim2.new(1, -36, 0, 48)]==],
[==[Size = UDim2.new(1, -36, 0, 56)]==],
"description spacing"
)

replacePlain(
[==[Position = UDim2.fromOffset(18, 452)]==],
[==[Position = UDim2.new(0, 18, 1, -54)]==],
"detail favorite footer"
)

replacePlain(
[==[UDim2.fromOffset(66, 452), 60]==],
[==[UDim2.new(0, 66, 1, -54), 60]==],
"detail action footer"
)

replacePlain(
[==[-- Interaction wiring --------------------------------------------------------]==],
[==[-- Compact controls ---------------------------------------------------------
local clearSearch = create("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -10, 0.5, 0),
    Size = UDim2.fromOffset(28, 28),
    BackgroundColor3 = THEME.Surface2,
    BorderSizePixel = 0,
    Text = "×",
    TextColor3 = THEME.TextSoft,
    TextSize = 17,
    AutoButtonColor = false,
    Visible = false,
    Parent = searchFrame,
}, { corner(6) })
clearSearch.Activated:Connect(function()
    searchBox.Text = ""
    searchBox:CaptureFocus()
end)
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    clearSearch.Visible = searchBox.Text ~= ""
    shortcut.Visible = searchBox.Text == ""
end)
sortPopup:GetPropertyChangedSignal("Visible"):Connect(function()
    chevron.Rotation = sortPopup.Visible and 180 or 0
    local s = sortButton:FindFirstChildOfClass("UIStroke")
    tween(s, 0.12, { Color = sortPopup.Visible and THEME.AccentBorder or THEME.Border })
    for _, option in ipairs(sortPopup:GetChildren()) do
        if option:IsA("TextButton") then
            option.TextColor3 = option.Text == currentSort and THEME.AccentBright or THEME.TextSoft
        end
    end
end)
-- Interaction wiring --------------------------------------------------------]==],
"compact search and sort feedback"
)

]===]
]====]
source = source:sub(1, polishAt - 1) .. premiumPolish .. source:sub(polishAt)

local chunk, compileError = loadstring(source)
if not chunk then
    error("[SaltyHub] Failed to compile patched Hub bootstrap: " .. tostring(compileError), 0)
end

return chunk()

