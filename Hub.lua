-- Velora Hub bootstrap v22
-- Rounded fixed shell, background blur, unclipped cards, and clean script handoff.

local BASE_URL = "https://raw.githubusercontent.com/MrRos3/Hub/ee46da2e478a880769e84c7382cb8e393e4245ea/Hub.lua"
local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))

local ok, source = pcall(function()
    return game:HttpGet(BASE_URL .. "?v=" .. cache)
end)

if not ok or type(source) ~= "string" or source == "" then
    error("[Velora Hub] Failed to download base UI.", 0)
end

local function replacePlain(needle, replacement)
    local startPos, endPos = string.find(source, needle, 1, true)
    if not startPos then
        return false
    end
    source = source:sub(1, startPos - 1) .. replacement .. source:sub(endPos + 1)
    return true
end

replacePlain(
    'local Workspace = game:GetService("Workspace")',
    'local Workspace = game:GetService("Workspace")\nlocal Lighting = game:GetService("Lighting")'
)

replacePlain(
    'local gui = create("ScreenGui", {',
    'local oldBlur = Lighting:FindFirstChild("SaltyHubBlur")\nif oldBlur then\n    oldBlur:Destroy()\nend\n\nlocal blur = Instance.new("BlurEffect")\nblur.Name = "SaltyHubBlur"\nblur.Size = 14\nblur.Parent = Lighting\n\nlocal gui = create("ScreenGui", {'
)

replacePlain(
    '    BackgroundTransparency = 0.68,',
    '    BackgroundTransparency = 0.76,'
)

replacePlain(
    '    corner(12),\n    stroke(Color3.fromHex("#2D2932"), 0.1, 1),',
    '    corner(14),\n    stroke(Color3.fromHex("#2D2932"), 0.18, 1),'
)

replacePlain(
    '    Active = true,\n    Parent = main,\n})',
    '    Active = false,\n    Parent = main,\n}, {\n    corner(12),\n})'
)

-- Give UIStroke a couple of pixels of breathing room inside the ScrollingFrame.
-- Without this, Roblox clips the outside half of the top/left card borders.
replacePlain(
    'local gridLayout = create("UIGridLayout", {',
    'create("UIPadding", {\n    PaddingTop = UDim.new(0, 2),\n    PaddingLeft = UDim.new(0, 2),\n    PaddingRight = UDim.new(0, 2),\n    PaddingBottom = UDim.new(0, 2),\n    Parent = grid,\n})\n\nlocal gridLayout = create("UIGridLayout", {'
)

replacePlain(
    'local function setShown(value)\n    shown = value\n    gui.Enabled = value\nend',
    'local function setShown(value)\n    shown = value\n    if value then\n        gui.Enabled = true\n        if blur and blur.Parent then\n            tween(blur, 0.18, { Size = 14 })\n        end\n    else\n        if blur and blur.Parent then\n            tween(blur, 0.14, { Size = 0 })\n        end\n        gui.Enabled = false\n    end\nend'
)

replacePlain(
    '    if toggleConnection then\n        toggleConnection:Disconnect()\n    end\n    gui:Destroy()',
    '    if toggleConnection then\n        toggleConnection:Disconnect()\n    end\n    if blur and blur.Parent then\n        blur:Destroy()\n    end\n    gui:Destroy()'
)

replacePlain(
    '        dragging = true',
    '        dragging = false'
)

-- Loading a script bypasses setShown(), so clear blur explicitly before the Hub hides.
replacePlain(
    '        notify(entry.Name, "Loading latest build...", "info")\n        gui.Enabled = false\n        shown = false',
    '        notify(entry.Name, "Loading latest build...", "info")\n        if blur and blur.Parent then\n            blur.Size = 0\n        end\n        gui.Enabled = false\n        shown = false'
)

-- If a script fails and the Hub comes back, restore its blur too.
replacePlain(
    '            if not ok then\n                gui.Enabled = true\n                shown = true\n                notify(entry.Name .. " could not launch", compactError(err), "error")',
    '            if not ok then\n                gui.Enabled = true\n                shown = true\n                if blur and blur.Parent then\n                    blur.Size = 14\n                end\n                notify(entry.Name .. " could not launch", compactError(err), "error")'
)

local chunk, compileError = loadstring(source)
if not chunk then
    if blur and blur.Parent then
        blur:Destroy()
    end
    error("[Velora Hub] Failed to compile v22: " .. tostring(compileError), 0)
end

return chunk()
