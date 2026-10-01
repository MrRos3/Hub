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

-- Graphite / emerald presentation pass. No changes to scripts or asset transport.

replacePlain(
[==[    Stage = Color3.fromHex("#060606"),]==],
[==[    Stage = Color3.fromHex("#070909"),]==],
"theme Stage"
)

replacePlain(
[==[    Window = Color3.fromHex("#0A0A0C"),]==],
[==[    Window = Color3.fromHex("#101314"),]==],
"theme Window"
)

replacePlain(
[==[    Surface = Color3.fromHex("#0E0E11"),]==],
[==[    Surface = Color3.fromHex("#171B1D"),]==],
"theme Surface"
)

replacePlain(
[==[    Surface2 = Color3.fromHex("#121216"),]==],
[==[    Surface2 = Color3.fromHex("#202628"),]==],
"theme Surface2"
)

replacePlain(
[==[    SurfaceHover = Color3.fromHex("#17151D"),]==],
[==[    SurfaceHover = Color3.fromHex("#252D2D"),]==],
"theme SurfaceHover"
)

replacePlain(
[==[    Accent = Color3.fromHex("#36255C"),]==],
[==[    Accent = Color3.fromHex("#205D49"),]==],
"theme Accent"
)

replacePlain(
[==[    AccentHover = Color3.fromHex("#4A337D"),]==],
[==[    AccentHover = Color3.fromHex("#28765A"),]==],
"theme AccentHover"
)

replacePlain(
[==[    AccentSoft = Color3.fromHex("#2A1D49"),]==],
[==[    AccentSoft = Color3.fromHex("#183A2F"),]==],
"theme AccentSoft"
)

replacePlain(
[==[    AccentBorder = Color3.fromHex("#473270"),]==],
[==[    AccentBorder = Color3.fromHex("#367A60"),]==],
"theme AccentBorder"
)

replacePlain(
[==[    AccentBright = Color3.fromHex("#B08BE3"),]==],
[==[    AccentBright = Color3.fromHex("#83DCB1"),]==],
"theme AccentBright"
)

replacePlain(
[==[    Text = Color3.fromHex("#F5F5F7"),]==],
[==[    Text = Color3.fromHex("#F1F5F3"),]==],
"theme Text"
)

replacePlain(
[==[    TextSoft = Color3.fromHex("#D4D4D8"),]==],
[==[    TextSoft = Color3.fromHex("#D0DAD5"),]==],
"theme TextSoft"
)

replacePlain(
[==[    Muted = Color3.fromHex("#85858F"),]==],
[==[    Muted = Color3.fromHex("#A0AEA7"),]==],
"theme Muted"
)

replacePlain(
[==[    Muted2 = Color3.fromHex("#858590"),]==],
[==[    Muted2 = Color3.fromHex("#899A92"),]==],
"theme Muted2"
)

replacePlain(
[==[    Success = Color3.fromHex("#72AB8C"),]==],
[==[    Success = Color3.fromHex("#83DCB1"),]==],
"theme Success"
)

replacePlain(
[==[    Danger = Color3.fromHex("#D66978"),]==],
[==[    Danger = Color3.fromHex("#E48494"),]==],
"theme Danger"
)

replacePlain(
[==[Color3.fromHex("#171022")]==],
[==[Color3.fromHex("#17231E")]==],
"chrome #171022 1"
)

replacePlain(
[==[Color3.fromHex("#8870B5")]==],
[==[Color3.fromHex("#91C5AA")]==],
"chrome #8870B5 1"
)

replacePlain(
[==[Color3.fromHex("#8870B5")]==],
[==[Color3.fromHex("#91C5AA")]==],
"chrome #8870B5 2"
)

replacePlain(
[==[Color3.fromHex("#8870B5")]==],
[==[Color3.fromHex("#91C5AA")]==],
"chrome #8870B5 3"
)

replacePlain(
[==[Color3.fromHex("#7352B0")]==],
[==[Color3.fromHex("#68BE95")]==],
"chrome #7352B0 1"
)

replacePlain(
[==[Color3.fromHex("#D9CFF1")]==],
[==[Color3.fromHex("#D1EFDF")]==],
"chrome #D9CFF1 1"
)

replacePlain(
[==[Color3.fromHex("#C4B3E4")]==],
[==[Color3.fromHex("#B3E6CC")]==],
"chrome #C4B3E4 1"
)

replacePlain(
[==[Color3.fromHex("#C4B3E4")]==],
[==[Color3.fromHex("#B3E6CC")]==],
"chrome #C4B3E4 2"
)

replacePlain(
[==[Color3.fromHex("#E7DFF6")]==],
[==[Color3.fromHex("#E0F5E9")]==],
"chrome #E7DFF6 1"
)

replacePlain(
[==[Color3.fromHex("#E7DFF6")]==],
[==[Color3.fromHex("#E0F5E9")]==],
"chrome #E7DFF6 2"
)

replacePlain(
[==[Color3.fromHex("#3B2A5E")]==],
[==[Color3.fromHex("#426F59")]==],
"chrome #3B2A5E 1"
)

replacePlain(
[==[Color3.fromHex("#5B4A77")]==],
[==[Color3.fromHex("#577E68")]==],
"chrome #5B4A77 1"
)

replacePlain(
[==[Color3.fromHex("#6D657B")]==],
[==[Color3.fromHex("#91A69A")]==],
"chrome #6D657B 1"
)

replacePlain(
[==[Color3.fromHex("#777783")]==],
[==[Color3.fromHex("#98AB9E")]==],
"chrome #777783 1"
)

replacePlain(
[==[Color3.fromHex("#777783")]==],
[==[Color3.fromHex("#98AB9E")]==],
"chrome #777783 2"
)

replacePlain(
[==[Color3.fromHex("#9B9BA4")]==],
[==[Color3.fromHex("#AEBFB4")]==],
"chrome #9B9BA4 1"
)

replacePlain(
[==[Color3.fromHex("#A8A8B0")]==],
[==[Color3.fromHex("#BFCCC3")]==],
"chrome #A8A8B0 1"
)

replacePlain(
[==[Color3.fromHex("#65656E")]==],
[==[Color3.fromHex("#8F9F95")]==],
"chrome #65656E 1"
)

replacePlain(
[==[Color3.fromHex("#666671")]==],
[==[Color3.fromHex("#8F9F95")]==],
"chrome #666671 1"
)

replacePlain(
[==[Color3.fromHex("#666671")]==],
[==[Color3.fromHex("#8F9F95")]==],
"chrome #666671 2"
)

replacePlain(
[==[Color3.fromHex("#A7A7AF")]==],
[==[Color3.fromHex("#AFBFB5")]==],
"chrome #A7A7AF 1"
)

replacePlain(
[==[Color3.fromHex("#92929B")]==],
[==[Color3.fromHex("#A5B5AA")]==],
"chrome #92929B 1"
)

replacePlain(
[==[Color3.fromHex("#101014")]==],
[==[Color3.fromHex("#141A17")]==],
"chrome #101014 1"
)

replacePlain(
[==[Color3.fromHex("#111116")]==],
[==[Color3.fromHex("#1A211D")]==],
"chrome #111116 1"
)

replacePlain(
[==[    Border = Color3.fromRGB(31, 31, 36),]==],
[==[    Border = Color3.fromRGB(48, 60, 54),]==],
"theme border"
)

replacePlain(
[==[Color3.fromRGB(34, 34, 39)]==],
[==[THEME.Border]==],
"consistent border 34, 34, 39 1"
)

replacePlain(
[==[Color3.fromRGB(34, 34, 39)]==],
[==[THEME.Border]==],
"consistent border 34, 34, 39 2"
)

replacePlain(
[==[Color3.fromRGB(34, 34, 39)]==],
[==[THEME.Border]==],
"consistent border 34, 34, 39 3"
)

replacePlain(
[==[Color3.fromRGB(34, 34, 39)]==],
[==[THEME.Border]==],
"consistent border 34, 34, 39 4"
)

replacePlain(
[==[Color3.fromRGB(34, 34, 40)]==],
[==[THEME.Border]==],
"consistent border 34, 34, 40 1"
)

replacePlain(
[==[Color3.fromRGB(34, 34, 40)]==],
[==[THEME.Border]==],
"consistent border 34, 34, 40 2"
)

replacePlain(
[==[Color3.fromRGB(34, 34, 40)]==],
[==[THEME.Border]==],
"consistent border 34, 34, 40 3"
)

replacePlain(
[==[Color3.fromRGB(34, 34, 40)]==],
[==[THEME.Border]==],
"consistent border 34, 34, 40 4"
)

replacePlain(
[==[Color3.fromRGB(44, 44, 51)]==],
[==[THEME.Border]==],
"consistent border 44, 44, 51 1"
)

replacePlain(
[==[Color3.fromRGB(44, 44, 51)]==],
[==[THEME.Border]==],
"consistent border 44, 44, 51 2"
)

replacePlain(
[==[Color3.fromRGB(45, 45, 52)]==],
[==[THEME.Border]==],
"consistent border 45, 45, 52 1"
)

replacePlain(
[==[Color3.fromRGB(38, 38, 44)]==],
[==[THEME.Border]==],
"consistent border 38, 38, 44 1"
)

replacePlain(
[==[Color3.fromRGB(40, 40, 46)]==],
[==[THEME.Border]==],
"consistent border 40, 40, 46 1"
)

replacePlain(
[==[    Text = "Script library  •  Online library",]==],
[==[    Text = "Your script library",]==],
"header subtitle"
)

replacePlain(
[==[    Text = "SaltyHub",
    TextColor3 = THEME.Text,
    TextSize = 14,]==],
[==[    Text = "SaltyHub",
    TextColor3 = THEME.Text,
    TextSize = 16,]==],
"header hierarchy"
)

replacePlain(
[==[TextSize = 8,]==],
[==[TextSize = 9,]==],
"category readability 1"
)

replacePlain(
[==[TextSize = 8,]==],
[==[TextSize = 9,]==],
"category readability 2"
)

replacePlain(
[==[TextSize = 8,]==],
[==[TextSize = 9,]==],
"category readability 3"
)

replacePlain(
[==[TextSize = 8,]==],
[==[TextSize = 9,]==],
"category readability 4"
)

replacePlain(
[==[    PlaceholderText = "Search scripts, games, or categories...",]==],
[==[    PlaceholderText = "Search your library...",]==],
"search copy"
)

replacePlain(
[==[    local cardStroke = card:FindFirstChildOfClass("UIStroke")]==],
[==[    create("UIGradient", {
        Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(218, 230, 222)),
        Rotation = 90,
        Parent = card,
    })
    local cardStroke = card:FindFirstChildOfClass("UIStroke")]==],
"grid depth"
)

replacePlain(
[==[local function createListCard(entry, order)
    local root = create("Frame", {
        Name = entry.Id,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = order,
    })

    local card = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = THEME.Surface,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = root,
    }, { corner(11), stroke(THEME.Border, 0.08, 1) })
    local cardStroke = card:FindFirstChildOfClass("UIStroke")

    local imageWrap = create("Frame", {
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.fromOffset(114, 76),
        BackgroundColor3 = THEME.Surface2,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = card,
    }, { corner(10) })
    local image = create("ImageLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Image = "",
        ImageTransparency = 1,
        ImageColor3 = Color3.fromRGB(218, 218, 226),
        ScaleType = Enum.ScaleType.Crop,
        Parent = imageWrap,
    })
    if entry.Id == "velora-piano" then
        local fallback = addVeloraPianoFallback(imageWrap, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), image.ZIndex)
        bindThumbnailFallback(image, fallback)
    end
    setRemoteImage(image, entry.ImageUrl, entry.ImageCache)

    create("TextLabel", {
        Position = UDim2.fromOffset(136, 12),
        Size = UDim2.fromOffset(180, 11),
        BackgroundTransparency = 1,
        Text = entry.Category,
        TextColor3 = Color3.fromHex("#91C5AA"),
        TextSize = 9,
        FontFace = font(Enum.FontWeight.Bold),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    local title = create("TextLabel", {
        Position = UDim2.fromOffset(136, 28),
        Size = UDim2.new(1, -340, 0, 18),
        BackgroundTransparency = 1,
        Text = entry.Name,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextColor3 = Color3.fromHex("#EEEEF1"),
        TextSize = 13,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    create("TextLabel", {
        Position = UDim2.fromOffset(136, 47),
        Size = UDim2.new(1, -340, 0, 15),
        BackgroundTransparency = 1,
        Text = entry.Game,
        TextColor3 = Color3.fromHex("#93939E"),
        TextSize = 9,
        FontFace = font(Enum.FontWeight.Regular),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = card,
    })

    create("TextLabel", {
        Position = UDim2.fromOffset(136, 65),
        Size = UDim2.new(1, -345, 0, 16),
        BackgroundTransparency = 1,
        Text = entry.Description,
        TextColor3 = Color3.fromHex("#A5B5AA"),
        TextSize = 9,
        FontFace = font(Enum.FontWeight.Regular),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = card,
    })

    makeHeartButton(card, entry, UDim2.new(1, -105, 0, 12), 8)
    makeLoadButton(card, entry, UDim2.fromOffset(82, 29), UDim2.new(1, -95, 0.5, -14), 8)

    local clickLayer = create("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 3,
        Parent = card,
    })
    clickLayer.MouseButton1Click:Connect(function()
        openDetails(entry)
    end)
    clickLayer.MouseEnter:Connect(function()
        tween(card, 0.14, { BackgroundColor3 = THEME.SurfaceHover, Position = UDim2.fromOffset(0, -1) })
        tween(cardStroke, 0.18, { Color = THEME.AccentBorder, Transparency = 0 })
        tween(image, 0.16, { ImageColor3 = Color3.fromRGB(242, 242, 248) })
        tween(title, 0.18, { TextColor3 = THEME.Text })
    end)
    clickLayer.MouseLeave:Connect(function()
        tween(card, 0.14, { BackgroundColor3 = THEME.Surface, Position = UDim2.fromOffset(0, 0) })
        tween(cardStroke, 0.18, { Color = THEME.Border, Transparency = 0.08 })
        tween(image, 0.16, { ImageColor3 = Color3.fromRGB(218, 218, 226) })
        tween(title, 0.18, { TextColor3 = Color3.fromHex("#EEEEF1") })
    end)

    return root
end

]==],
[==[local function createListCard(entry, order)
    local root = create("Frame", {
        Name = entry.Id,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = order,
    })

    local card = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = THEME.Surface,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = root,
    }, { corner(11), stroke(THEME.Border, 0.08, 1) })
    create("UIGradient", {
        Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(218, 230, 222)),
        Rotation = 90,
        Parent = card,
    })
    local cardStroke = card:FindFirstChildOfClass("UIStroke")

    local imageWrap = create("Frame", {
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.fromOffset(114, 76),
        BackgroundColor3 = THEME.Surface2,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = card,
    }, { corner(10) })
    local image = create("ImageLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Image = "",
        ImageTransparency = 1,
        ImageColor3 = Color3.fromRGB(218, 218, 226),
        ScaleType = Enum.ScaleType.Crop,
        Parent = imageWrap,
    })
    if entry.Id == "velora-piano" then
        local fallback = addVeloraPianoFallback(imageWrap, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), image.ZIndex)
        bindThumbnailFallback(image, fallback)
    end
    setRemoteImage(image, entry.ImageUrl, entry.ImageCache)

    create("TextLabel", {
        Position = UDim2.fromOffset(136, 12),
        Size = UDim2.fromOffset(180, 11),
        BackgroundTransparency = 1,
        Text = entry.Category,
        TextColor3 = Color3.fromHex("#91C5AA"),
        TextSize = 9,
        FontFace = font(Enum.FontWeight.Bold),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    local title = create("TextLabel", {
        Position = UDim2.fromOffset(136, 28),
        Size = UDim2.new(1, -340, 0, 18),
        BackgroundTransparency = 1,
        Text = entry.Name,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextColor3 = Color3.fromHex("#EEEEF1"),
        TextSize = 13,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    create("TextLabel", {
        Position = UDim2.fromOffset(136, 47),
        Size = UDim2.new(1, -340, 0, 15),
        BackgroundTransparency = 1,
        Text = entry.Game,
        TextColor3 = Color3.fromHex("#93939E"),
        TextSize = 9,
        FontFace = font(Enum.FontWeight.Regular),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = card,
    })

    create("TextLabel", {
        Position = UDim2.fromOffset(136, 65),
        Size = UDim2.new(1, -345, 0, 16),
        BackgroundTransparency = 1,
        Text = entry.Description,
        TextColor3 = Color3.fromHex("#A5B5AA"),
        TextSize = 9,
        FontFace = font(Enum.FontWeight.Regular),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = card,
    })

    makeHeartButton(card, entry, UDim2.new(1, -105, 0, 12), 8)
    makeLoadButton(card, entry, UDim2.fromOffset(82, 29), UDim2.new(1, -95, 0.5, -14), 8)

    local clickLayer = create("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 3,
        Parent = card,
    })
    clickLayer.MouseButton1Click:Connect(function()
        openDetails(entry)
    end)
    clickLayer.MouseEnter:Connect(function()
        tween(card, 0.14, { BackgroundColor3 = THEME.SurfaceHover, Position = UDim2.fromOffset(0, -1) })
        tween(cardStroke, 0.18, { Color = THEME.AccentBorder, Transparency = 0 })
        tween(image, 0.16, { ImageColor3 = Color3.fromRGB(242, 242, 248) })
        tween(title, 0.18, { TextColor3 = THEME.Text })
    end)
    clickLayer.MouseLeave:Connect(function()
        tween(card, 0.14, { BackgroundColor3 = THEME.Surface, Position = UDim2.fromOffset(0, 0) })
        tween(cardStroke, 0.18, { Color = THEME.Border, Transparency = 0.08 })
        tween(image, 0.16, { ImageColor3 = Color3.fromRGB(218, 218, 226) })
        tween(title, 0.18, { TextColor3 = Color3.fromHex("#EEEEF1") })
    end)

    return root
end

]==],
"list depth"
)

replacePlain(
[==[    }, { corner(5) })

    local label = create("TextLabel", {]==],
[==[    }, { corner(7), stroke(THEME.AccentBorder, 0.25, 1) })

    local label = create("TextLabel", {]==],
"load action frame"
)

replacePlain(
[==[    create("TextLabel", {
        Position = UDim2.fromOffset(18, 156),
        Size = UDim2.fromOffset(220, 12),
        BackgroundTransparency = 1,
        Text = entry.Category,
        TextColor3 = Color3.fromHex("#91C5AA"),
        TextSize = 9,
        FontFace = font(Enum.FontWeight.Bold),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 57,
        Parent = detailPanel,
    })
    create("TextLabel", {
        Position = UDim2.fromOffset(18, 176),
        Size = UDim2.new(1, -36, 0, 28),
        BackgroundTransparency = 1,
        Text = entry.Name,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextColor3 = THEME.Text,
        TextSize = 20,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 57,
        Parent = detailPanel,
    })
    create("TextLabel", {
        Position = UDim2.fromOffset(18, 205),
        Size = UDim2.new(1, -36, 0, 16),
        BackgroundTransparency = 1,
        Text = entry.Game,
        TextColor3 = Color3.fromHex("#98AB9E"),
        TextSize = 10,
        FontFace = font(Enum.FontWeight.Regular),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 57,
        Parent = detailPanel,
    })
    create("TextLabel", {
        Position = UDim2.fromOffset(18, 233),
        Size = UDim2.new(1, -36, 0, 56),
        BackgroundTransparency = 1,
        Text = entry.Description,
        TextColor3 = Color3.fromHex("#AEBFB4"),
        TextSize = 10,
        FontFace = font(Enum.FontWeight.Regular),
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 57,
        Parent = detailPanel,
    })

    create("Frame", {
        Position = UDim2.fromOffset(18, 298),
        Size = UDim2.new(1, -36, 0, 1),
        BackgroundColor3 = THEME.Border,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ZIndex = 57,
        Parent = detailPanel,
    })

    create("TextLabel", {
        Position = UDim2.fromOffset(18, 314),
        Size = UDim2.fromOffset(220, 12),
        BackgroundTransparency = 1,
        Text = "SUPPORTED FEATURES",
        TextColor3 = Color3.fromHex("#91A69A"),
        TextSize = 9,
        FontFace = font(Enum.FontWeight.Bold),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 57,
        Parent = detailPanel,
    })

    for i, feature in ipairs(entry.Features or {}) do
        create("TextLabel", {
            Position = UDim2.fromOffset(20, 337 + (i - 1) * 24),
            Size = UDim2.new(1, -40, 0, 18),
            BackgroundTransparency = 1,
            Text = "✓   " .. feature,
            TextColor3 = Color3.fromHex("#BFCCC3"),
            TextSize = 10,
            FontFace = font(Enum.FontWeight.Regular),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 57,
            Parent = detailPanel,
        })
    end

    create("TextLabel", {
        Position = UDim2.fromOffset(18, 421),
        Size = UDim2.new(1, -36, 0, 16),
        BackgroundTransparency = 1,
        Text = "Last updated  " .. entry.Updated,
        TextColor3 = Color3.fromHex("#98AB9E"),
        TextSize = 9,
        FontFace = font(Enum.FontWeight.Regular),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 57,
        Parent = detailPanel,
    })

]==],
[==[    local detailBody = create("ScrollingFrame", {
        Name = "DetailBody",
        Position = UDim2.fromOffset(0, 144),
        Size = UDim2.new(1, 0, 1, -216),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = THEME.AccentBorder,
        ZIndex = 57,
        Parent = detailPanel,
    })
    create("TextLabel", {
        Position = UDim2.fromOffset(18, 12),
        Size = UDim2.fromOffset(220, 12),
        BackgroundTransparency = 1,
        Text = entry.Category,
        TextColor3 = Color3.fromHex("#91C5AA"),
        TextSize = 9,
        FontFace = font(Enum.FontWeight.Bold),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 57,
        Parent = detailBody,
    })
    create("TextLabel", {
        Position = UDim2.fromOffset(18, 32),
        Size = UDim2.new(1, -36, 0, 28),
        BackgroundTransparency = 1,
        Text = entry.Name,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextColor3 = THEME.Text,
        TextSize = 20,
        FontFace = font(Enum.FontWeight.SemiBold),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 57,
        Parent = detailBody,
    })
    create("TextLabel", {
        Position = UDim2.fromOffset(18, 61),
        Size = UDim2.new(1, -36, 0, 16),
        BackgroundTransparency = 1,
        Text = entry.Game,
        TextColor3 = Color3.fromHex("#98AB9E"),
        TextSize = 10,
        FontFace = font(Enum.FontWeight.Regular),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 57,
        Parent = detailBody,
    })
    create("TextLabel", {
        Position = UDim2.fromOffset(18, 89),
        Size = UDim2.new(1, -36, 0, 56),
        BackgroundTransparency = 1,
        Text = entry.Description,
        TextColor3 = Color3.fromHex("#AEBFB4"),
        TextSize = 10,
        FontFace = font(Enum.FontWeight.Regular),
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 57,
        Parent = detailBody,
    })

    create("Frame", {
        Position = UDim2.fromOffset(18, 154),
        Size = UDim2.new(1, -36, 0, 1),
        BackgroundColor3 = THEME.Border,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ZIndex = 57,
        Parent = detailBody,
    })

    create("TextLabel", {
        Position = UDim2.fromOffset(18, 170),
        Size = UDim2.fromOffset(220, 12),
        BackgroundTransparency = 1,
        Text = "SUPPORTED FEATURES",
        TextColor3 = Color3.fromHex("#91A69A"),
        TextSize = 9,
        FontFace = font(Enum.FontWeight.Bold),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 57,
        Parent = detailBody,
    })

    for i, feature in ipairs(entry.Features or {}) do
        create("TextLabel", {
            Position = UDim2.fromOffset(20, 193 + (i - 1) * 26),
            Size = UDim2.new(1, -40, 0, 18),
            BackgroundTransparency = 1,
            Text = "✓   " .. feature,
            TextColor3 = Color3.fromHex("#BFCCC3"),
            TextSize = 10,
            FontFace = font(Enum.FontWeight.Regular),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 57,
            Parent = detailBody,
        })
    end

    create("TextLabel", {
        Position = UDim2.fromOffset(18, 205 + #(entry.Features or {}) * 26),
        Size = UDim2.new(1, -36, 0, 16),
        BackgroundTransparency = 1,
        Text = "Last updated  " .. entry.Updated,
        TextColor3 = Color3.fromHex("#98AB9E"),
        TextSize = 9,
        FontFace = font(Enum.FontWeight.Regular),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 57,
        Parent = detailBody,
    })

]==],
"scrolling detail body"
)

replacePlain(
[==[-- Compact controls ---------------------------------------------------------]==],
[==[-- Consistent tactile feedback for secondary controls.
local function bindControlPress(button)
    button.Selectable = true
    local pressScale = create("UIScale", { Scale = 1, Parent = button })
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tween(pressScale, 0.07, { Scale = 0.96 })
        end
    end)
    local function release() tween(pressScale, 0.12, { Scale = 1 }) end
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then release() end
    end)
    button.MouseLeave:Connect(release)
end
for _, button in pairs(filterButtons) do bindControlPress(button) end
for _, button in ipairs({ sortButton, gridButton, listButton, closeButton }) do bindControlPress(button) end
-- Compact controls ---------------------------------------------------------]==],
"secondary press feedback"
)

replacePlain(
[==[clearSearch.Activated:Connect(function()]==],
[==[bindControlPress(clearSearch)
clearSearch.Activated:Connect(function()]==],
"search press feedback"
)

replacePlain(
[==[sortButton.MouseButton1Click:Connect(function()
    sortPopup.Visible = not sortPopup.Visible
end)]==],
[==[sortButton.Activated:Connect(function()
    sortPopup.Visible = not sortPopup.Visible
end)
local dismissSortConnection = UserInputService.InputBegan:Connect(function(input)
    if hubTerminated or not sortPopup.Visible then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local function inside(object)
        local p, s = object.AbsolutePosition, object.AbsoluteSize
        return input.Position.X >= p.X and input.Position.X <= p.X + s.X
            and input.Position.Y >= p.Y and input.Position.Y <= p.Y + s.Y
    end
    if not inside(sortButton) and not inside(sortPopup) then sortPopup.Visible = false end
end)
gui.Destroying:Once(function() dismissSortConnection:Disconnect() end)]==],
"dismiss sort outside"
)

]===]
]====]
source = source:sub(1, polishAt - 1) .. premiumPolish .. source:sub(polishAt)

local chunk, compileError = loadstring(source)
if not chunk then
    error("[SaltyHub] Failed to compile patched Hub bootstrap: " .. tostring(compileError), 0)
end

return chunk()


