-- Shadow Network loader generated for Velora Hub.
-- Reconstructs the exact user-provided v1.3.7 source from compressed repository data.

local BASE = "https://raw.githubusercontent.com/MrRos3/Hub/main/scripts/shadow_network/"
local cache = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))

local encoded = game:HttpGet(BASE .. "part1.txt?v=" .. cache)
    .. game:HttpGet(BASE .. "part2.txt?v=" .. cache)

local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local decodeMap = {}
for i = 1, #alphabet do
    decodeMap[string.byte(alphabet, i)] = i - 1
end

local function base64Decode(input)
    local out = table.create(math.floor(#input * 0.75))
    local oi = 0
    local i = 1

    while i <= #input do
        local c1 = decodeMap[string.byte(input, i)]
        local c2 = decodeMap[string.byte(input, i + 1)]
        local c3b = string.byte(input, i + 2)
        local c4b = string.byte(input, i + 3)
        local c3 = c3b and decodeMap[c3b] or nil
        local c4 = c4b and decodeMap[c4b] or nil

        if c1 == nil or c2 == nil then
            break
        end

        local n = c1 * 262144 + c2 * 4096 + (c3 or 0) * 64 + (c4 or 0)

        oi += 1
        out[oi] = string.char(math.floor(n / 65536) % 256)

        if c3 ~= nil then
            oi += 1
            out[oi] = string.char(math.floor(n / 256) % 256)
        end

        if c4 ~= nil then
            oi += 1
            out[oi] = string.char(n % 256)
        end

        i += 4
    end

    return table.concat(out)
end

local function lzssDecode(input)
    local bytes = table.create(100000)
    local outLen = 0
    local pos = 1
    local total = #input

    while pos <= total do
        local flags = string.byte(input, pos)
        pos += 1

        for bit = 0, 7 do
            if pos > total then
                break
            end

            local isMatch = math.floor(flags / (2 ^ bit)) % 2 == 1

            if isMatch then
                local b1 = string.byte(input, pos)
                local b2 = string.byte(input, pos + 1)
                pos += 2

                local packed = b1 * 256 + b2
                local distance = math.floor(packed / 16) + 1
                local length = (packed % 16) + 3

                for _ = 1, length do
                    local sourceIndex = outLen - distance + 1
                    outLen += 1
                    bytes[outLen] = bytes[sourceIndex]
                end
            else
                outLen += 1
                bytes[outLen] = string.byte(input, pos)
                pos += 1
            end
        end
    end

    local chunks = table.create(math.ceil(outLen / 4096))
    local ci = 0
    for startIndex = 1, outLen, 4096 do
        local finish = math.min(startIndex + 4095, outLen)
        local chars = table.create(finish - startIndex + 1)
        local j = 0
        for k = startIndex, finish do
            j += 1
            chars[j] = string.char(bytes[k])
        end
        ci += 1
        chunks[ci] = table.concat(chars)
    end

    return table.concat(chunks)
end

local compressed = base64Decode(encoded)
local source = lzssDecode(compressed)
local chunk, err = loadstring(source)

if not chunk then
    error("[Shadow Network] Failed to compile reconstructed source: " .. tostring(err), 0)
end

return chunk()
