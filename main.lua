local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "FishGateGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(240, 250)
frame.Position = UDim2.new(0, 20, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "Broadcast Controller"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = frame

local tiers = {
    "Legendary",
    "Mythic",
    "SECRET",
    "FORGOTTEN"
}

local ENDPOINT = "https://creature-plans-dual-cited.trycloudflare.com/fish-caught"

local net = ReplicatedStorage
    .Packages._Index["sleitnick_net@0.2.0"]
    .net

local hooked = {}

local gate = {
    Legendary = false,
    Mythic = false,
    SECRET = true,
    FORGOTTEN = true
}

for i, tier in ipairs(tiers) do

    local button = Instance.new("TextButton")

    button.Size = UDim2.new(1, -20, 0, 40)
    button.Position = UDim2.fromOffset(10, 45 + ((i - 1) * 48))

    button.TextSize = 14
    button.Font = Enum.Font.GothamMedium
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BorderSizePixel = 0

    button.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button

    local function update()
        button.Text = tier .. " [" ..
            (gate[tier] and "ON" or "OFF") ..
            "]"

        button.BackgroundColor3 =
            gate[tier]
            and Color3.fromRGB(40, 130, 75)
            or Color3.fromRGB(55, 55, 60)
    end

    button.MouseButton1Click:Connect(function()

        gate[tier] = not gate[tier]

        update()

    end)

    update()
end

--// RGB → Fish Tier
local tierByColor = {
    ["255,185,43"] = "Legendary",
    ["255,25,25"] = "Mythic",
    ["24,255,152"] = "SECRET",
    ["0,0,0"] = "FORGOTTEN",
}

--// RGB dari string rgb(...)
local function getRGB(colorString)
    local r, g, b = colorString:match(
        "rgb%((%d+)%s*,%s*(%d+)%s*,%s*(%d+)%)"
    )

    return r and (r .. "," .. g .. "," .. b)
end

--// Parser RichText
local function parseMessage(text)
    if type(text) ~= "string" then
        return
    end

    -- Display Name
    local displayName = text:match(
        '<font color="[^"]+">([^<]+)</font>%s+obtained a'
    )

    if not displayName then
        return
    end

    -- Cari blok <b><font>
    local blocks = {}

    for color, value in text:gmatch(
        '<b>%s*<font color="([^"]+)">([^<]+)</font>%s*</b>'
    ) do
        blocks[#blocks + 1] = {
            color = color,
            value = value
        }
    end

    if #blocks == 0 then
        return
    end

    -- Variant optional
    local variant
    local fishBlock

    if #blocks >= 2 then
        variant = blocks[1].value
        fishBlock = blocks[2]
    else
        fishBlock = blocks[1]
    end

    -- Tier dari warna fish
    local rgb = getRGB(fishBlock.color)
    local fishTier = tierByColor[rgb] or "Unknown"

    -- Fish + Weight
    local fishCaught, weight = fishBlock.value:match(
        "^(.-)%s*%(([^()]+)%)$"
    )

    if not fishCaught then
        return
    end

    -- Rarity
    local rarity = text:match(
        "with a 1 in ([^%s]+) chance!"
    )

    if not rarity then
        return
    end

    return {
        displayName = displayName,
        fishTier = fishTier,
        variant = variant,
        fishCaught = fishCaught,
        weight = weight,
        rarity = rarity
    }
end

--// Hook RemoteEvent
local function hookRemote(remote)
    if not remote:IsA("RemoteEvent") then
        return
    end

    if hooked[remote] then
        return
    end

    hooked[remote] = true

    remote.OnClientEvent:Connect(function(message)
        if type(message) ~= "string" then
            return
        end

        -- Pastikan ini notification fishing
        if not (
            message:find("obtained a", 1, true)
            and message:find("with a 1 in", 1, true)
            and message:find("chance!", 1, true)
        ) then
            return
        end

        local data = parseMessage(message)

        if not data then
            return
        end

        if gate[data.fishTier] ~= true then
            return
        end

        pcall(function()
            request({
                Url = ENDPOINT,
                Method = "POST",

                Headers = {
                    ["Content-Type"] = "application/json"
                },

                Body = HttpService:JSONEncode(data)
            })
        end)
    end)
end

--// Scan RemoteEvent yang sudah ada
for _, object in ipairs(net:GetDescendants()) do
    hookRemote(object)
end

--// Tangkap RemoteEvent yang muncul kemudian
net.DescendantAdded:Connect(function(object)
    hookRemote(object)
end)