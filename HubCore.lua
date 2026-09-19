-- Salty Hub core loader
-- Applies the latest visual/behavior fixes to the approved v0-inspired UI.

local BASE = "https://raw.githubusercontent.com/MrRos3/Hub/main/hubcore/source/"
local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))
local names = {
    "01.lua.txt", "02.lua.txt", "03.lua.txt", "04.lua.txt", "05.lua.txt",
    "06.lua.txt", "07.lua.txt", "08.lua.txt", "09.lua.txt", "10.lua.txt",
}

local parts = table.create(#names)
for i, name in ipairs(names) do
    local ok, body = pcall(function()
        return game:HttpGet(BASE .. name .. "?v=" .. cache)
    end)
    if not ok or type(body) ~= "string" or body == "" then
        error(("[Salty Hub] Failed to download UI source chunk %s."):format(name), 0)
    end
    parts[i] = body
end

local source = table.concat(parts)

local function replacePlain(needle, replacement, label)
    local first, last = string.find(source, needle, 1, true)
    if not first then
        error("[Salty Hub] Patch target missing: " .. tostring(label or needle:sub(1, 48)), 0)
    end
    source = source:sub(1, first - 1) .. replacement .. source:sub(last + 1)
end

replacePlain(
    [[local SETTINGS_PATH = CACHE_ROOT .. "/settings.json"]],
    [[local SETTINGS_PATH = CACHE_ROOT .. "/settings.json"
local BRAND_LOGO_URL = "https://raw.githubusercontent.com/MrRos3/VantaUI/main/assets/salty-special.png?v=salty-hub-logo-v2"]],
    "brand logo url"
)

replacePlain(
[[local function setRemoteImage(imageLabel, url, cacheName)
    if not imageLabel or not imageLabel.Parent or not url or url == "" then
        return
    end
    task.spawn(function()
        local asset = cacheRemoteAsset(url, CACHE_ROOT .. "/assets/" .. cacheName)
        if asset ~= "" and imageLabel and imageLabel.Parent then
            imageLabel.Image = asset
            imageLabel.ImageTransparency = 0
        end
    end)
end]],
[[local function setRemoteImage(imageLabel, url, cacheName)
    if not imageLabel or not imageLabel.Parent or not url or url == "" then
        return
    end
    task.spawn(function()
        local asset = cacheRemoteAsset(url, CACHE_ROOT .. "/assets/" .. cacheName)
        if asset ~= "" and imageLabel and imageLabel.Parent then
            imageLabel.Image = asset
            imageLabel.ImageTransparency = 0
        end
    end)
end

local function addVeloraPianoFallback(parent, position, size, zIndex)
    local fallback = create("Frame", {
        Name = "VeloraPianoFallback",
        Position = position,
        Size = size,
        BackgroundColor3 = Color3.fromHex("#120F19"),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = zIndex or 1,
        Parent = parent,
    }, { corner(10) })

    create("UIGradient", {
        Rotation = 18,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#0E0D12")),
            ColorSequenceKeypoint.new(0.42, Color3.fromHex("#24173A")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#120E1D")),
        }),
        Parent = fallback,
    })

    create("TextLabel", {
        Position = UDim2.fromOffset(10, 8),
        Size = UDim2.new(1, -20, 0, 18),
        BackgroundTransparency = 1,
        Text = "VISUAL PIANO",
        TextColor3 = Color3.fromHex("#D9C9F6"),
        TextSize = 10,
        FontFace = font(Enum.FontWeight.Bold),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = (zIndex or 1) + 1,
        Parent = fallback,
    })

    local keyHolder = create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 8, 1, -6),
        Size = UDim2.new(1, -16, 0, 34),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = (zIndex or 1) + 1,
        Parent = fallback,
    }, { corner(6) })

    for i = 0, 11 do
        create("Frame", {
            Position = UDim2.new(i / 12, 1, 0, 0),
            Size = UDim2.new(1 / 12, -2, 1, 0),
            BackgroundColor3 = Color3.fromHex("#EEEAF6"),
            BorderSizePixel = 0,
            ZIndex = (zIndex or 1) + 2,
            Parent = keyHolder,
        }, { corner(2) })
    end

    for _, x in ipairs({ 0.072, 0.155, 0.322, 0.405, 0.488, 0.655, 0.738, 0.821 }) do
        create("Frame", {
            Position = UDim2.new(x, 0, 0, 0),
            Size = UDim2.new(0.052, 0, 0.62, 0),
            BackgroundColor3 = Color3.fromHex("#141018"),
            BorderSizePixel = 0,
            ZIndex = (zIndex or 1) + 3,
            Parent = keyHolder,
        }, { corner(2) })
    end

    return fallback
end

local function bindThumbnailFallback(imageLabel, fallback)
    if not imageLabel or not fallback then
        return
    end
    local function sync()
        if fallback.Parent then
            fallback.Visible = not (imageLabel.Image ~= "" and imageLabel.ImageTransparency < 1)
        end
    end
    sync()
    imageLabel:GetPropertyChangedSignal("Image"):Connect(sync)
    imageLabel:GetPropertyChangedSignal("ImageTransparency"):Connect(sync)
end]],
    "visual piano fallback"
)

replacePlain(
[[        ImageUrl = BASE_RAW .. "assets/cards/velora-piano.jpg?v=salty-v0",
        ImageCache = "card_velora-piano_v0.jpg",]],
[[        ImageUrl = BASE_RAW .. "assets/cards/velora-piano.jpg?v=visual-piano-v3",
        ImageCache = "card_velora-piano_visual_v3.jpg",]],
    "visual piano cache bump"
)

replacePlain(
[[local signatureLine = create("Frame", {
    Position = UDim2.fromOffset(22, 0),
    Size = UDim2.new(1, -44, 0, 1),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
    Parent = header,
})
create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("#6D4DB0")),
        ColorSequenceKeypoint.new(0.42, Color3.fromHex("#2D204B")),
        ColorSequenceKeypoint.new(1, THEME.Window),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.35),
        NumberSequenceKeypoint.new(0.42, 0.7),
        NumberSequenceKeypoint.new(1, 1),
    }),
    Parent = signatureLine,
})

local mark = create("Frame", {
    Name = "Mark",
    Position = UDim2.fromOffset(24, 18),
    Size = UDim2.fromOffset(29, 29),
    BackgroundColor3 = THEME.Accent,
    BorderSizePixel = 0,
    Rotation = 45,
    Parent = header,
}, {
    corner(8),
    stroke(Color3.fromHex("#8467C4"), 0.45, 1),
})
create("UIGradient", {
    Color = ColorSequence.new(Color3.fromHex("#44306E"), Color3.fromHex("#100D18")),
    Rotation = 45,
    Parent = mark,
})
create("Frame", {
    Position = UDim2.fromOffset(6, 6),
    Size = UDim2.fromOffset(8, 8),
    BackgroundColor3 = Color3.fromHex("#B8A2E6"),
    BorderSizePixel = 0,
    Parent = mark,
}, { corner(2) })
create("Frame", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -6, 1, -6),
    Size = UDim2.fromOffset(8, 8),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = mark,
}, { corner(2), stroke(Color3.fromHex("#6C529F"), 0, 1) })]],
[[local brandWrap = create("Frame", {
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
setRemoteImage(brandLogo, BRAND_LOGO_URL, "salty_brand_logo_v2.png")]],
    "header logo and purple line"
)

replacePlain(
[[    local image = create("ImageLabel", {
        Size = UDim2.new(1, 0, 0, 78),
        BackgroundColor3 = Color3.fromHex("#111116"),
        BorderSizePixel = 0,
        Image = "",
        ImageTransparency = 1,
        ImageColor3 = Color3.fromRGB(190, 190, 198),
        ScaleType = Enum.ScaleType.Crop,
        Parent = card,
    })
    setRemoteImage(image, entry.ImageUrl, entry.ImageCache)]],
[[    local imageWrap = create("Frame", {
        Size = UDim2.new(1, 0, 0, 78),
        BackgroundColor3 = Color3.fromHex("#111116"),
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
        ImageColor3 = Color3.fromRGB(190, 190, 198),
        ScaleType = Enum.ScaleType.Crop,
        Parent = imageWrap,
    })
    if entry.Id == "velora-piano" then
        local fallback = addVeloraPianoFallback(imageWrap, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), image.ZIndex)
        bindThumbnailFallback(image, fallback)
    end
    setRemoteImage(image, entry.ImageUrl, entry.ImageCache)]],
    "grid thumbnail clipping"
)

replacePlain(
[[    local image = create("ImageLabel", {
        Size = UDim2.fromOffset(122, 92),
        BackgroundColor3 = THEME.Surface2,
        BorderSizePixel = 0,
        Image = "",
        ImageTransparency = 1,
        ImageColor3 = Color3.fromRGB(190, 190, 198),
        ScaleType = Enum.ScaleType.Crop,
        Parent = card,
    })
    setRemoteImage(image, entry.ImageUrl, entry.ImageCache)]],
[[    local imageWrap = create("Frame", {
        Size = UDim2.fromOffset(122, 92),
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
        ImageColor3 = Color3.fromRGB(190, 190, 198),
        ScaleType = Enum.ScaleType.Crop,
        Parent = imageWrap,
    })
    if entry.Id == "velora-piano" then
        local fallback = addVeloraPianoFallback(imageWrap, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), image.ZIndex)
        bindThumbnailFallback(image, fallback)
    end
    setRemoteImage(image, entry.ImageUrl, entry.ImageCache)]],
    "list thumbnail clipping"
)

replacePlain(
[[    local image = create("ImageLabel", {
        Size = UDim2.new(1, 0, 0, 138),
        BackgroundColor3 = THEME.Surface2,
        BorderSizePixel = 0,
        Image = "",
        ImageTransparency = 1,
        ImageColor3 = Color3.fromRGB(190, 190, 198),
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 56,
        Parent = detailPanel,
    })
    setRemoteImage(image, entry.ImageUrl, entry.ImageCache)]],
[[    local imageWrap = create("Frame", {
        Size = UDim2.new(1, 0, 0, 138),
        BackgroundColor3 = THEME.Surface2,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 56,
        Parent = detailPanel,
    }, { corner(10) })
    local image = create("ImageLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Image = "",
        ImageTransparency = 1,
        ImageColor3 = Color3.fromRGB(190, 190, 198),
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 56,
        Parent = imageWrap,
    })
    if entry.Id == "velora-piano" then
        local fallback = addVeloraPianoFallback(imageWrap, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), 56)
        bindThumbnailFallback(image, fallback)
    end
    setRemoteImage(image, entry.ImageUrl, entry.ImageCache)]],
    "details thumbnail clipping"
)

replacePlain(
[[local renderContent
local openDetails

local function runRemote(entry)]],
[[local renderContent
local openDetails
local shown = true

local function runRemote(entry)]],
    "shared visibility state"
)

replacePlain(
[[    if loading[entry.Id] then
        return
    end
    loading[entry.Id] = true]],
[[    if loading[entry.Id] then
        return
    end
    shown = false
    gui.Enabled = false
    blur.Size = 0
    blur.Enabled = false
    loading[entry.Id] = true]],
    "hide hub on load"
)

replacePlain(
[[        else
            showToast(entry.Name .. " could not load", truncate(err, 60), "error")
        end]],
[[        else
            shown = true
            gui.Enabled = true
            blur.Enabled = true
            blur.Size = 8
            main.GroupTransparency = 0
            showToast(entry.Name .. " could not load", truncate(err, 60), "error")
        end]],
    "restore hub on load failure"
)

replacePlain(
[[local shown = true
local toggleConnection]],
[[local toggleConnection]],
    "remove duplicate visibility state"
)

local chunk, compileError = loadstring(source)
if not chunk then
    error("[Salty Hub] Failed to compile patched UI: " .. tostring(compileError), 0)
end

return chunk()
