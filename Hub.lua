-- Velora Hub bootstrap v21
-- Smooth rounded shell, fixed position, and background blur.

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

local chunk, compileError = loadstring(source)
if not chunk then
    error("[Velora Hub] Failed to compile v21: " .. tostring(compileError), 0)
end

return chunk()
