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

local chunk, compileError = loadstring(source)
if not chunk then
    error("[SaltyHub] Failed to compile patched Hub bootstrap: " .. tostring(compileError), 0)
end

return chunk()
