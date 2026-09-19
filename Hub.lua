-- Velora Hub bootstrap v17
-- Force-fresh card thumbnails and keep letter fallback behind images.

local BASE_URL = "https://raw.githubusercontent.com/MrRos3/Hub/c22bddd46b75afb036ab5874fd5a8cc476f65f19/Hub.lua"
local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))

local ok, source = pcall(function()
    return game:HttpGet(BASE_URL .. "?v=" .. cache)
end)

if not ok or type(source) ~= "string" or source == "" then
    error("[Velora Hub] Failed to download v16 base.", 0)
end

local function replacePlain(text, needle, replacement)
    local a, b = string.find(text, needle, 1, true)
    if not a then
        return text
    end
    return text:sub(1, a - 1) .. replacement .. text:sub(b + 1)
end

-- Force a brand-new local filename so an old/bad Velora Piano cache cannot be reused.
source = replacePlain(
    source,
    'local path = "VeloraHub/assets/card_" .. tostring(entry.Id or "script") .. ".jpg"',
    'local path = "VeloraHub/assets/card_" .. tostring(entry.Id or "script") .. "_v17.jpg"'
)

-- Keep the fallback letter underneath the ImageLabel. If an executor cannot render
-- one thumbnail, the tile will never become an empty black square again.
source = replacePlain(
    source,
    '    if initialText then\n        initialText.Visible = false\n    end\n\n    return true',
    '    -- Keep the letter visible underneath the image as a safe fallback.\n    -- A valid image sits above it at ZIndex 5, so the letter is naturally covered.\n    return true'
)

local chunk, compileError = loadstring(source)
if not chunk then
    error("[Velora Hub] Failed to compile v17 bootstrap: " .. tostring(compileError), 0)
end

return chunk()