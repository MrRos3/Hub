-- Velora Hub
-- Premium searchable script library.
-- UI first. Real script sources can be attached to SCRIPT_LIBRARY later.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LOCAL_PLAYER = Players.LocalPlayer

local CONFIG = {
    Title = "VELORA",
    Subtitle = "MY SCRIPTS",
    Tagline = "all your scripts in one place",
    ToggleKey = Enum.KeyCode.RightShift,
    UseBackgroundBlur = true,
    DemoMode = true,
}

local THEME = {
    Background = Color3.fromRGB(6, 6, 6),
    BackgroundSoft = Color3.fromRGB(12, 10, 14),
    Surface = Color3.fromRGB(18, 15, 20),
    SurfaceHover = Color3.fromRGB(26, 20, 29),
    SurfaceStrong = Color3.fromRGB(34, 25, 37),
    Accent = Color3.fromRGB(255, 94, 183),
    AccentSoft = Color3.fromRGB(205, 91, 170),
    Purple = Color3.fromRGB(54, 37, 92),
    PurpleBright = Color3.fromRGB(124, 90, 212),
    Text = Color3.fromRGB(248, 246, 250),
    Muted = Color3.fromRGB(174, 163, 178),
    Faint = Color3.fromRGB(105, 94, 110),
    Stroke = Color3.fromRGB(76, 58, 80),
    Success = Color3.fromRGB(139, 238, 190),
    Error = Color3.fromRGB(255, 126, 148),
}

-- SaltyIcons asset IDs from MrRos3/SaltyIcons.
local ICONS = {
    search = "rbxassetid://100557104978626",
    close = "rbxassetid://104564513546348",
    minus = "rbxassetid://123173530093622",
    star = "rbxassetid://130603316912957",
    heart = "rbxassetid://80686764701725",
    more = "rbxassetid://138158933921955",
    external = "rbxassetid://84143719799667",
    copy = "rbxassetid://103363146431717",
    fileCode = "rbxassetid://126008398730041",
    code = "rbxassetid://131595473006887",
    blocks = "rbxassetid://96464084024408",
    globe = "rbxassetid://123107843015250",
    mapPin = "rbxassetid://103242899547315",
    lockOpen = "rbxassetid://104913770360781",
    eye = "rbxassetid://75816651251769",
    scan = "rbxassetid://107823756128414",
    user = "rbxassetid://108864475481601",
    monitor = "rbxassetid://85421680333243",
    wrench = "rbxassetid://82686700366508",
    refresh = "rbxassetid://89604821239492",
    timer = "rbxassetid://118623780796527",
    folder = "rbxassetid://123581920995046",
    cloud = "rbxassetid://118483403617225",
    shield = "rbxassetid://113195655159420",
    radio = "rbxassetid://72684106434425",
    palette = "rbxassetid://79971389143262",
}

local SCRIPT_LIBRARY = {
    {Id="ghost-driver", Name="Ghost Driver", Subtitle="Roblox", Category="Roblox", Tags={"game specific","vehicle","automation"}, Icon=ICONS.mapPin, A=Color3.fromRGB(255,74,154), B=Color3.fromRGB(73,36,86), Demo=true},
    {Id="blox-fruits", Name="Blox Fruits", Subtitle="Roblox", Category="Roblox", Tags={"game specific","farm"}, Icon=ICONS.globe, A=Color3.fromRGB(85,116,255), B=Color3.fromRGB(43,42,105), Demo=true},
    {Id="pet-simulator", Name="Pet Simulator X", Subtitle="Roblox", Category="Roblox", Tags={"game specific","utility"}, Icon=ICONS.heart, A=Color3.fromRGB(255,93,194), B=Color3.fromRGB(95,42,103), Demo=true},
    {Id="blade-ball", Name="Blade Ball", Subtitle="Roblox", Category="Roblox", Tags={"game specific","combat"}, Icon=ICONS.star, A=Color3.fromRGB(255,72,118), B=Color3.fromRGB(102,34,58), Demo=true},
    {Id="arsenal", Name="Arsenal", Subtitle="Roblox", Category="Roblox", Tags={"game specific","combat"}, Icon=ICONS.scan, A=Color3.fromRGB(111,98,166), B=Color3.fromRGB(36,32,57), Demo=true},
    {Id="da-hood", Name="Da Hood", Subtitle="Roblox", Category="Roblox", Tags={"game specific"}, Icon=ICONS.mapPin, A=Color3.fromRGB(180,61,151), B=Color3.fromRGB(73,31,78), Demo=true},
    {Id="doors", Name="Doors", Subtitle="Roblox", Category="Roblox", Tags={"game specific","esp"}, Icon=ICONS.lockOpen, A=Color3.fromRGB(158,61,76), B=Color3.fromRGB(49,24,31), Demo=true},
    {Id="mm2", Name="MM2", Subtitle="Roblox", Category="Roblox", Tags={"game specific","combat"}, Icon=ICONS.eye, A=Color3.fromRGB(245,58,123), B=Color3.fromRGB(86,29,48), Demo=true},
    {Id="type-soul", Name="Type Soul", Subtitle="Roblox", Category="Roblox", Tags={"game specific"}, Icon=ICONS.user, A=Color3.fromRGB(168,84,255), B=Color3.fromRGB(61,34,89), Demo=true},
    {Id="jailbreak", Name="Jailbreak", Subtitle="Roblox", Category="Roblox", Tags={"game specific","vehicle"}, Icon=ICONS.lockOpen, A=Color3.fromRGB(194,92,255), B=Color3.fromRGB(67,39,96), Demo=true},
    {Id="salty-universal", Name="Salty Universal", Subtitle="Universal", Category="Universal", Tags={"universal","utility"}, Icon=ICONS.blocks, A=Color3.fromRGB(143,112,255), B=Color3.fromRGB(51,40,90), Demo=true},
    {Id="salty-ui", Name="Salty UI Library", Subtitle="UI / Library", Category="UI", Tags={"ui","library"}, Icon=ICONS.palette, A=Color3.fromRGB(129,111,255), B=Color3.fromRGB(48,41,83), Demo=true},
    {Id="remote-spy", Name="Remote Spy", Subtitle="Tools", Category="Tools", Tags={"tool","remote"}, Icon=ICONS.eye, A=Color3.fromRGB(185,104,255), B=Color3.fromRGB(60,40,84), Demo=true},
    {Id="fe-scripts", Name="FE Scripts", Subtitle="Universal", Category="Universal", Tags={"universal"}, Icon=ICONS.code, A=Color3.fromRGB(173,126,255), B=Color3.fromRGB(58,45,89), Demo=true},
    {Id="teleport-hub", Name="Teleport Hub", Subtitle="Tools", Category="Tools", Tags={"tool","teleport"}, Icon=ICONS.mapPin, A=Color3.fromRGB(191,113,255), B=Color3.fromRGB(63,39,88), Demo=true},
    {Id="game-utilities", Name="Game Utilities", Subtitle="Tools", Category="Tools", Tags={"tool","utility"}, Icon=ICONS.wrench, A=Color3.fromRGB(151,117,255), B=Color3.fromRGB(49,40,82), Demo=true},
    {Id="auto-farm", Name="Auto Farm", Subtitle="Universal", Category="Universal", Tags={"universal","automation"}, Icon=ICONS.refresh, A=Color3.fromRGB(116,101,255), B=Color3.fromRGB(43,39,79), Demo=true},
    {Id="speed-hub", Name="Speed Hub", Subtitle="Tools", Category="Tools", Tags={"tool","movement"}, Icon=ICONS.timer, A=Color3.fromRGB(145,116,255), B=Color3.fromRGB(49,41,83), Demo=true},
}

local function create(className, props, children)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do object[key] = value end
    for _, child in ipairs(children or {}) do child.Parent = object end
    return object
end

local function corner(radius)
    return create("UICorner", {CornerRadius = UDim.new(0, radius)})
end

local function stroke(color, transparency, thickness)
    return create("UIStroke", {Color=color, Transparency=transparency or 0, Thickness=thickness or 1, ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
end

local function tween(object, duration, props, style, direction)
    local t = TweenService:Create(object, TweenInfo.new(duration or 0.18, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function normalize(text) return string.lower(tostring(text or "")) end
local function contains(haystack, needle)
    if needle == "" then return true end
    return string.find(normalize(haystack), needle, 1, true) ~= nil
end

local function getGuiParent()
    local ok, result = pcall(function()
        if gethui then return gethui() end
        return CoreGui
    end)
    if ok and result then return result end
    return LOCAL_PLAYER:WaitForChild("PlayerGui")
end

local function iconLabel(parent, image, position, size, color, transparency, z)
    return create("ImageLabel", {BackgroundTransparency=1, Position=position, Size=size, Image=image, ImageColor3=color or THEME.Text, ImageTransparency=transparency or 0, ScaleType=Enum.ScaleType.Fit, ZIndex=z or 1, Parent=parent})
end

local function iconButton(parent, name, image, position, size)
    local button = create("ImageButton", {
        Name=name, BackgroundColor3=THEME.SurfaceStrong, BackgroundTransparency=1, Position=position, Size=size,
        Image=image, ImageColor3=THEME.Muted, ImageTransparency=0.02, ScaleType=Enum.ScaleType.Fit,
        AutoButtonColor=false, Parent=parent,
    }, {corner(10)})
    button.MouseEnter:Connect(function() tween(button,0.16,{BackgroundTransparency=0.2,ImageColor3=THEME.Text}) end)
    button.MouseLeave:Connect(function() tween(button,0.16,{BackgroundTransparency=1,ImageColor3=THEME.Muted}) end)
    button.MouseButton1Down:Connect(function() tween(button,0.08,{ImageTransparency=0.28}) end)
    button.MouseButton1Up:Connect(function() tween(button,0.1,{ImageTransparency=0.02}) end)
    return button
end

local guiParent = getGuiParent()
local oldGui = guiParent:FindFirstChild("VeloraHub")
if oldGui then oldGui:Destroy() end
local oldBlur = Lighting:FindFirstChild("VeloraHubBlur")
if oldBlur then oldBlur:Destroy() end

local blur
if CONFIG.UseBackgroundBlur then
    blur = create("BlurEffect", {Name="VeloraHubBlur", Size=0, Parent=Lighting})
    tween(blur,0.3,{Size=14})
end

local screen = create("ScreenGui", {Name="VeloraHub", ResetOnSpawn=false, IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=999999, Parent=guiParent})
pcall(function() if syn and syn.protect_gui then syn.protect_gui(screen) end end)

local backdrop = create("Frame", {Name="Backdrop",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(4,3,5),BackgroundTransparency=0.48,BorderSizePixel=0,Parent=screen})

local main = create("Frame", {
    Name="Main", AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromScale(0.90,0.86),
    BackgroundColor3=THEME.Background, BackgroundTransparency=0.03, BorderSizePixel=0, ClipsDescendants=true, Parent=backdrop,
}, {
    corner(22), stroke(Color3.fromRGB(107,69,106),0.38,1),
    create("UISizeConstraint",{MinSize=Vector2.new(900,560),MaxSize=Vector2.new(1540,900)}),
    create("UIGradient",{Rotation=18,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(15,9,15)),ColorSequenceKeypoint.new(0.45,THEME.Background),ColorSequenceKeypoint.new(1,Color3.fromRGB(10,8,14))})}),
})

local innerGlow = create("Frame", {Name="InnerGlow",Position=UDim2.fromOffset(-160,-210),Size=UDim2.fromOffset(520,520),BackgroundColor3=THEME.Purple,BackgroundTransparency=0.88,BorderSizePixel=0,Parent=main},{corner(260)})
local header = create("Frame", {Name="Header",BackgroundTransparency=1,Size=UDim2.new(1,0,0,132),Parent=main})
local brand = create("Frame", {Name="Brand",BackgroundTransparency=1,Position=UDim2.fromOffset(28,20),Size=UDim2.fromOffset(225,92),Parent=header})
local brandIconWrap = create("Frame", {BackgroundColor3=THEME.Purple,BackgroundTransparency=0.18,Position=UDim2.fromOffset(0,0),Size=UDim2.fromOffset(44,44),BorderSizePixel=0,Parent=brand},{corner(14),stroke(THEME.PurpleBright,0.52,1)})
iconLabel(brandIconWrap,ICONS.blocks,UDim2.fromOffset(10,10),UDim2.fromOffset(24,24),THEME.Accent)
create("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(56,-2),Size=UDim2.fromOffset(165,28),Text=CONFIG.Title,TextColor3=THEME.Text,TextSize=23,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,Parent=brand})
create("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(57,26),Size=UDim2.fromOffset(165,18),Text=CONFIG.Subtitle,TextColor3=THEME.Muted,TextSize=10,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left,Parent=brand})
local taglineLabel = create("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(2,57),Size=UDim2.fromOffset(220,18),Text=CONFIG.Tagline,TextColor3=Color3.fromRGB(195,144,183),TextTransparency=0.08,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,Parent=brand})

local searchWrap = create("Frame", {Name="SearchWrap",Position=UDim2.new(0,278,0,22),Size=UDim2.new(1,-482,0,50),BackgroundColor3=Color3.fromRGB(19,15,20),BackgroundTransparency=0.05,BorderSizePixel=0,Parent=header},{corner(15),stroke(Color3.fromRGB(102,71,103),0.38,1)})
iconLabel(searchWrap,ICONS.search,UDim2.fromOffset(16,14),UDim2.fromOffset(22,22),THEME.Muted)
local searchBox = create("TextBox",{Name="SearchBox",BackgroundTransparency=1,Position=UDim2.fromOffset(50,0),Size=UDim2.new(1,-92,1,0),PlaceholderText="Search a script, game, or keyword...",PlaceholderColor3=THEME.Faint,Text="",TextColor3=THEME.Text,TextSize=14,Font=Enum.Font.Gotham,ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,Parent=searchWrap})
local clearSearch = iconButton(searchWrap,"Clear",ICONS.close,UDim2.new(1,-39,0.5,-15),UDim2.fromOffset(30,30))
clearSearch.Visible=false

local countPill = create("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-116,0,27),Size=UDim2.fromOffset(82,38),BackgroundColor3=THEME.Surface,BackgroundTransparency=0.12,BorderSizePixel=0,Parent=header},{corner(12),stroke(THEME.Stroke,0.55,1)})
local countLabel = create("TextLabel",{BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Text=tostring(#SCRIPT_LIBRARY).." scripts",TextColor3=THEME.Muted,TextSize=11,Font=Enum.Font.GothamMedium,Parent=countPill})
local minimizeButton = iconButton(header,"Minimize",ICONS.minus,UDim2.new(1,-82,0,24),UDim2.fromOffset(36,36))
local closeButton = iconButton(header,"Close",ICONS.close,UDim2.new(1,-43,0,24),UDim2.fromOffset(36,36))

local filterClip = create("Frame",{BackgroundTransparency=1,Position=UDim2.new(0,278,0,82),Size=UDim2.new(1,-320,0,40),ClipsDescendants=true,Parent=header})
local filters = create("ScrollingFrame",{Name="Filters",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),AutomaticCanvasSize=Enum.AutomaticSize.X,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.X,ScrollBarThickness=0,BorderSizePixel=0,Parent=filterClip},{create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,8)})})

local content = create("Frame",{Name="Content",BackgroundTransparency=1,Position=UDim2.fromOffset(28,132),Size=UDim2.new(1,-56,1,-164),Parent=main})
local grid = create("ScrollingFrame",{Name="Grid",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=THEME.AccentSoft,ScrollBarImageTransparency=0.35,Parent=content})
local gridLayout = create("UIGridLayout",{CellPadding=UDim2.fromOffset(12,12),CellSize=UDim2.fromOffset(205,185),SortOrder=Enum.SortOrder.LayoutOrder,FillDirection=Enum.FillDirection.Horizontal,FillDirectionMaxCells=6,HorizontalAlignment=Enum.HorizontalAlignment.Left,VerticalAlignment=Enum.VerticalAlignment.Top,Parent=grid})
create("UIPadding",{PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,18),PaddingRight=UDim.new(0,5),Parent=grid})

local emptyState = create("Frame",{Name="EmptyState",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.45),Size=UDim2.fromOffset(360,150),BackgroundTransparency=1,Visible=false,Parent=content})
iconLabel(emptyState,ICONS.search,UDim2.new(0.5,-23,0,8),UDim2.fromOffset(46,46),THEME.Faint,0.12)
create("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(0,62),Size=UDim2.new(1,0,0,28),Text="Nothing found",TextColor3=THEME.Text,TextSize=20,Font=Enum.Font.GothamMedium,Parent=emptyState})
create("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(0,90),Size=UDim2.new(1,0,0,22),Text="Try a different search or category.",TextColor3=THEME.Muted,TextSize=12,Font=Enum.Font.Gotham,Parent=emptyState})
local footer = create("TextLabel",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,30,1,-8),Size=UDim2.new(1,-60,0,16),BackgroundTransparency=1,Text="VELORA  •  RIGHT SHIFT TO TOGGLE",TextColor3=THEME.Faint,TextSize=9,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left,Parent=main})

local toastHolder = create("Frame",{AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,-24),Size=UDim2.fromOffset(430,48),BackgroundTransparency=1,Parent=main})
local activeToast
local function notify(message,kind)
    if activeToast then activeToast:Destroy() end
    local accent=THEME.Accent
    if kind=="success" then accent=THEME.Success end
    if kind=="error" then accent=THEME.Error end
    local toast=create("Frame",{AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,12),Size=UDim2.fromOffset(390,44),BackgroundColor3=THEME.SurfaceStrong,BackgroundTransparency=0.04,BorderSizePixel=0,Parent=toastHolder},{corner(13),stroke(accent,0.46,1)})
    create("Frame",{Position=UDim2.fromOffset(10,11),Size=UDim2.fromOffset(3,22),BackgroundColor3=accent,BorderSizePixel=0,Parent=toast},{corner(2)})
    create("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(26,0),Size=UDim2.new(1,-38,1,0),Text=message,TextColor3=THEME.Text,TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=toast})
    activeToast=toast
    tween(toast,0.22,{Position=UDim2.new(0.5,0,1,0)})
    task.delay(2.3,function()
        if toast and toast.Parent then
            tween(toast,0.18,{Position=UDim2.new(0.5,0,1,12),BackgroundTransparency=1})
            task.wait(0.2)
            if toast then toast:Destroy() end
            if activeToast==toast then activeToast=nil end
        end
    end)
end

local favorites={}
local cards={}
local filterButtons={}
local currentFilter="All"

local function runEntry(entry)
    if entry.Demo then notify(entry.Name.." is a placeholder until we add your real script.","success") return end
    if type(entry.Run)=="function" then
        local ok,err=pcall(entry.Run)
        if ok then notify("Opened "..entry.Name..".","success") else notify(tostring(err),"error") end
        return
    end
    if type(entry.Source)=="string" and entry.Source~="" then
        if not loadstring then notify("loadstring is unavailable.","error") return end
        local chunk,compileError=loadstring(entry.Source)
        if not chunk then notify("Compile error: "..tostring(compileError),"error") return end
        local ok,runtimeError=pcall(chunk)
        if ok then notify("Opened "..entry.Name..".","success") else notify("Runtime error: "..tostring(runtimeError),"error") end
        return
    end
    if type(entry.Url)=="string" and entry.Url~="" then
        local ok,result=pcall(function()
            local source=game:HttpGet(entry.Url)
            if not loadstring then error("loadstring is unavailable") end
            local chunk,compileError=loadstring(source)
            if not chunk then error(compileError) end
            return chunk()
        end)
        if ok then notify("Opened "..entry.Name..".","success") else notify("Could not open "..entry.Name..": "..tostring(result),"error") end
        return
    end
    notify("No script attached to "..entry.Name.." yet.")
end

local function setFavorite(entry,value)
    favorites[entry.Id]=value
    local data=cards[entry.Id]
    if data then
        data.Favorite.ImageColor3=value and THEME.Accent or THEME.Muted
        data.Favorite.ImageTransparency=value and 0 or 0.16
    end
end

local function createCard(entry,order)
    local card=create("Frame",{Name=entry.Id,LayoutOrder=order,BackgroundColor3=THEME.Surface,BackgroundTransparency=0.06,BorderSizePixel=0,ClipsDescendants=true,Parent=grid},{corner(16),stroke(THEME.Stroke,0.5,1)})
    local scale=create("UIScale",{Scale=1,Parent=card})
    local art=create("Frame",{Name="Art",Size=UDim2.new(1,0,0,102),BackgroundColor3=entry.A or THEME.Accent,BorderSizePixel=0,ClipsDescendants=true,Parent=card},{corner(16),create("UIGradient",{Rotation=18,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,entry.A or THEME.Accent),ColorSequenceKeypoint.new(1,entry.B or THEME.Purple)})})})
    create("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,24,0.48,0),Size=UDim2.fromOffset(118,118),Rotation=18,BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0.92,BorderSizePixel=0,Parent=art},{corner(30)})
    local iconHalo=create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(62,62),BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0.89,BorderSizePixel=0,Parent=art},{corner(20),stroke(Color3.fromRGB(255,255,255),0.78,1)})
    local artIcon=iconLabel(iconHalo,entry.Icon or ICONS.fileCode,UDim2.fromOffset(14,14),UDim2.fromOffset(34,34),Color3.fromRGB(255,248,255),0.03)
    local shine=create("Frame",{Position=UDim2.new(-0.35,0,-0.25,0),Size=UDim2.fromOffset(48,160),Rotation=20,BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0.91,BorderSizePixel=0,Parent=art})
    create("Frame",{Position=UDim2.new(0,0,1,-14),Size=UDim2.new(1,0,0,15),BackgroundColor3=THEME.Surface,BorderSizePixel=0,Parent=art})
    create("TextLabel",{Name="Title",BackgroundTransparency=1,Position=UDim2.fromOffset(12,104),Size=UDim2.new(1,-24,0,22),Text=entry.Name,TextColor3=THEME.Text,TextSize=13,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=card})
    create("TextLabel",{Name="Subtitle",BackgroundTransparency=1,Position=UDim2.fromOffset(12,125),Size=UDim2.new(1,-24,0,16),Text=entry.Subtitle or entry.Category or "Script",TextColor3=THEME.Muted,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=card})
    local favorite=create("ImageButton",{Name="Favorite",Position=UDim2.fromOffset(10,149),Size=UDim2.fromOffset(26,26),BackgroundTransparency=1,Image=ICONS.star,ImageColor3=THEME.Muted,ImageTransparency=0.16,ScaleType=Enum.ScaleType.Fit,AutoButtonColor=false,Parent=card})
    local more=create("ImageButton",{Name="More",AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-8,1,-8),Size=UDim2.fromOffset(28,28),BackgroundColor3=THEME.SurfaceStrong,BackgroundTransparency=0.22,BorderSizePixel=0,Image=ICONS.more,ImageColor3=THEME.Muted,ScaleType=Enum.ScaleType.Fit,AutoButtonColor=false,Parent=card},{corner(9)})
    local open=create("TextButton",{Name="Open",AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-41,1,-8),Size=UDim2.fromOffset(76,28),BackgroundColor3=Color3.fromRGB(63,40,61),BackgroundTransparency=0.06,BorderSizePixel=0,Text="Open",TextColor3=THEME.Text,TextSize=11,Font=Enum.Font.GothamMedium,AutoButtonColor=false,Parent=card},{corner(9),stroke(THEME.Accent,0.64,1)})
    iconLabel(open,ICONS.external,UDim2.fromOffset(10,7),UDim2.fromOffset(14,14),THEME.Text,0.03)
    open.TextXAlignment=Enum.TextXAlignment.Right
    create("UIPadding",{PaddingRight=UDim.new(0,11),Parent=open})
    favorite.MouseButton1Click:Connect(function() setFavorite(entry,not favorites[entry.Id]) end)
    open.MouseButton1Click:Connect(function() runEntry(entry) end)
    more.MouseButton1Click:Connect(function() notify(entry.Name.."  •  "..(entry.Category or "Script")) end)
    local cardStroke=card:FindFirstChildOfClass("UIStroke")
    card.MouseEnter:Connect(function()
        tween(scale,0.18,{Scale=1.018})
        tween(card,0.18,{BackgroundColor3=THEME.SurfaceHover})
        tween(cardStroke,0.18,{Color=THEME.AccentSoft,Transparency=0.26})
        tween(iconHalo,0.18,{BackgroundTransparency=0.82})
        tween(artIcon,0.18,{ImageTransparency=0})
        shine.Position=UDim2.new(-0.35,0,-0.25,0)
        tween(shine,0.42,{Position=UDim2.new(1.18,0,-0.25,0)},Enum.EasingStyle.Quad)
        tween(open,0.16,{BackgroundColor3=Color3.fromRGB(92,49,80)})
    end)
    card.MouseLeave:Connect(function()
        tween(scale,0.18,{Scale=1})
        tween(card,0.18,{BackgroundColor3=THEME.Surface})
        tween(cardStroke,0.18,{Color=THEME.Stroke,Transparency=0.5})
        tween(iconHalo,0.18,{BackgroundTransparency=0.89})
        tween(open,0.16,{BackgroundColor3=Color3.fromRGB(63,40,61)})
    end)
    open.MouseButton1Down:Connect(function() tween(open,0.07,{BackgroundTransparency=0.25}) end)
    open.MouseButton1Up:Connect(function() tween(open,0.1,{BackgroundTransparency=0.06}) end)
    more.MouseEnter:Connect(function() tween(more,0.15,{BackgroundTransparency=0.04,ImageColor3=THEME.Text}) end)
    more.MouseLeave:Connect(function() tween(more,0.15,{BackgroundTransparency=0.22,ImageColor3=THEME.Muted}) end)
    favorite.MouseEnter:Connect(function() tween(favorite,0.15,{ImageColor3=THEME.Accent,ImageTransparency=0}) end)
    favorite.MouseLeave:Connect(function()
        local value=favorites[entry.Id]
        tween(favorite,0.15,{ImageColor3=value and THEME.Accent or THEME.Muted,ImageTransparency=value and 0 or 0.16})
    end)
    cards[entry.Id]={Frame=card,Favorite=favorite,Entry=entry}
    card.BackgroundTransparency=1
    scale.Scale=0.96
    task.delay(0.035*order,function()
        if card and card.Parent then
            tween(card,0.24,{BackgroundTransparency=0.06})
            tween(scale,0.28,{Scale=1})
        end
    end)
end

for index,entry in ipairs(SCRIPT_LIBRARY) do createCard(entry,index) end
local filterNames={"All","Roblox","Universal","Game Specific","UI","Tools","Favorites"}
local function makeFilter(name,order)
    local width=math.max(64,26+(#name*6.3))
    local button=create("TextButton",{Name=name,LayoutOrder=order,Size=UDim2.fromOffset(width,32),BackgroundColor3=THEME.Surface,BackgroundTransparency=0.12,BorderSizePixel=0,Text=name,TextColor3=THEME.Muted,TextSize=11,Font=Enum.Font.GothamMedium,AutoButtonColor=false,Parent=filters},{corner(16),stroke(THEME.Stroke,0.58,1)})
    filterButtons[name]=button
    return button
end
for index,name in ipairs(filterNames) do makeFilter(name,index) end

local function entryMatchesFilter(entry)
    if currentFilter=="All" then return true end
    if currentFilter=="Favorites" then return favorites[entry.Id]==true end
    if currentFilter=="Game Specific" then
        if normalize(entry.Category)=="game specific" then return true end
        for _,tag in ipairs(entry.Tags or {}) do if normalize(tag)=="game specific" then return true end end
        return false
    end
    return normalize(entry.Category)==normalize(currentFilter) or normalize(entry.Subtitle)==normalize(currentFilter)
end

local function entryMatchesSearch(entry,query)
    if query=="" then return true end
    if contains(entry.Name,query) or contains(entry.Subtitle,query) or contains(entry.Category,query) then return true end
    for _,tag in ipairs(entry.Tags or {}) do if contains(tag,query) then return true end end
    return false
end

local function refreshCards()
    local query=normalize(searchBox.Text)
    local visibleCount=0
    for _,entry in ipairs(SCRIPT_LIBRARY) do
        local data=cards[entry.Id]
        local visible=entryMatchesFilter(entry) and entryMatchesSearch(entry,query)
        data.Frame.Visible=visible
        if visible then visibleCount+=1 end
    end
    emptyState.Visible=visibleCount==0
    clearSearch.Visible=searchBox.Text~=""
    countLabel.Text=tostring(visibleCount)..(visibleCount==1 and " script" or " scripts")
end

local function refreshFilterStyles()
    for name,button in pairs(filterButtons) do
        local selected=name==currentFilter
        local outline=button:FindFirstChildOfClass("UIStroke")
        tween(button,0.16,{BackgroundColor3=selected and THEME.Accent or THEME.Surface,BackgroundTransparency=selected and 0 or 0.12,TextColor3=selected and Color3.fromRGB(35,17,30) or THEME.Muted})
        if outline then tween(outline,0.16,{Color=selected and THEME.Accent or THEME.Stroke,Transparency=selected and 0.2 or 0.58}) end
    end
end

for name,button in pairs(filterButtons) do
    button.MouseButton1Click:Connect(function() currentFilter=name refreshFilterStyles() refreshCards() end)
    button.MouseEnter:Connect(function() if currentFilter~=name then tween(button,0.14,{BackgroundColor3=THEME.SurfaceStrong,TextColor3=THEME.Text}) end end)
    button.MouseLeave:Connect(function() if currentFilter~=name then tween(button,0.14,{BackgroundColor3=THEME.Surface,TextColor3=THEME.Muted}) end end)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(refreshCards)
searchBox.Focused:Connect(function()
    local outline=searchWrap:FindFirstChildOfClass("UIStroke")
    tween(searchWrap,0.16,{BackgroundColor3=Color3.fromRGB(25,18,27)})
    if outline then tween(outline,0.16,{Color=THEME.Accent,Transparency=0.14}) end
end)
searchBox.FocusLost:Connect(function()
    local outline=searchWrap:FindFirstChildOfClass("UIStroke")
    tween(searchWrap,0.16,{BackgroundColor3=Color3.fromRGB(19,15,20)})
    if outline then tween(outline,0.16,{Color=Color3.fromRGB(102,71,103),Transparency=0.38}) end
end)
clearSearch.MouseButton1Click:Connect(function() searchBox.Text="" searchBox:CaptureFocus() end)

local minimized=false
local originalSize=main.Size
local function setMinimized(value)
    minimized=value
    content.Visible=not value
    filterClip.Visible=not value
    footer.Visible=not value
    countPill.Visible=not value
    taglineLabel.Visible=not value
    if value then
        tween(main,0.28,{Size=UDim2.new(originalSize.X.Scale,originalSize.X.Offset,0,96)})
        tween(header,0.2,{Size=UDim2.new(1,0,0,96)})
    else
        tween(main,0.28,{Size=originalSize})
        tween(header,0.2,{Size=UDim2.new(1,0,0,132)})
    end
end

minimizeButton.MouseButton1Click:Connect(function() setMinimized(not minimized) end)
local function setVisible(value)
    screen.Enabled=value
    if blur then tween(blur,0.2,{Size=value and 14 or 0}) end
end
closeButton.MouseButton1Click:Connect(function() setVisible(false) end)

UserInputService.InputBegan:Connect(function(input,gameProcessed)
    if input.KeyCode==CONFIG.ToggleKey and not gameProcessed then setVisible(not screen.Enabled) return end
    if input.KeyCode==Enum.KeyCode.K and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if not screen.Enabled then setVisible(true) end
        if minimized then setMinimized(false) end
        task.defer(function() searchBox:CaptureFocus() end)
    end
end)

local dragging=false
local dragStart
local startPosition
header.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true
        dragStart=input.Position
        startPosition=main.Position
    end
end)
header.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)
UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch then return end
    local delta=input.Position-dragStart
    main.Position=UDim2.new(startPosition.X.Scale,startPosition.X.Offset+delta.X,startPosition.Y.Scale,startPosition.Y.Offset+delta.Y)
end)

local function updateGridSize()
    local width=grid.AbsoluteSize.X
    if width<=0 then return end
    local columns
    if width>=1220 then columns=6 elseif width>=990 then columns=5 elseif width>=780 then columns=4 else columns=3 end
    local gap=12
    local usable=width-(gap*(columns-1))-8
    local cellWidth=math.floor(usable/columns)
    gridLayout.FillDirectionMaxCells=columns
    gridLayout.CellSize=UDim2.fromOffset(cellWidth,185)
end

grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGridSize)
task.defer(updateGridSize)
refreshFilterStyles()
refreshCards()

local targetSize=main.Size
main.Size=UDim2.fromScale(0.84,0.78)
main.BackgroundTransparency=0.16
innerGlow.BackgroundTransparency=1
tween(main,0.4,{Size=targetSize,BackgroundTransparency=0.03},Enum.EasingStyle.Quint)
tween(innerGlow,0.55,{BackgroundTransparency=0.88})

if CONFIG.DemoMode then
    task.delay(0.55,function()
        if screen and screen.Parent then notify("Velora Hub refreshed with SaltyIcons.","success") end
    end)
end
