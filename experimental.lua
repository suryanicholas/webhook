local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local net = ReplicatedStorage
    .Packages._Index["sleitnick_net@0.2.0"]
    .net

local hooked = {}
local epURL = "https://creature-plans-dual-cited.trycloudflare.com/fish-caught"
local gate = {
    SECRET = true,
    FORGOTTEN = true
}

local tierByColor = {
    ["255,185,43"] = "Legendary",
    ["255,25,25"] = "Mythic",
    ["24,255,152"] = "SECRET",
    ["0,0,0"] = "FORGOTTEN",
}

local function getRGB(colorString)
    local r, g, b = colorString:match(
        "rgb%((%d+)%s*,%s*(%d+)%s*,%s*(%d+)%)"
    )

    return r and (r .. "," .. g .. "," .. b)
end

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
                Url = epURL,
                Method = "POST",

                Headers = {
                    ["Content-Type"] = "application/json"
                },

                Body = HttpService:JSONEncode(data)
            })
        end)
    end)
end

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local collapsed = false

local gui = Instance.new("ScreenGui")
gui.Name = "WebhookController"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(260, 185)
panel.Position = UDim2.fromOffset(16, 64)
panel.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
panel.BorderSizePixel = 0
panel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 7)
panelCorner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(14, 116, 144)
stroke.Thickness = 2
stroke.Parent = panel

local topButtons = Instance.new("Frame")
topButtons.Name = "TopButtons"
topButtons.Size = UDim2.new(1, -16, 0, 25)
topButtons.Position = UDim2.fromOffset(8, 4)
topButtons.BackgroundTransparency = 1
topButtons.Parent = panel

local topLayout = Instance.new("UIListLayout")
topLayout.FillDirection = Enum.FillDirection.Horizontal
topLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
topLayout.VerticalAlignment = Enum.VerticalAlignment.Center
topLayout.Padding = UDim.new(0, 6)
topLayout.Parent = topButtons

local collapseButton = Instance.new("TextButton")
collapseButton.Name = "Collapse"
collapseButton.Size = UDim2.fromOffset(22, 22)
collapseButton.Text = "−"
collapseButton.TextSize = 18
collapseButton.Font = Enum.Font.GothamBold
collapseButton.TextColor3 = Color3.fromRGB(203, 213, 225)
collapseButton.BackgroundColor3 = Color3.fromRGB(71, 85, 105)
collapseButton.BorderSizePixel = 0
collapseButton.Parent = topButtons

local collapseCorner = Instance.new("UICorner")
collapseCorner.CornerRadius = UDim.new(0, 4)
collapseCorner.Parent = collapseButton

local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.Size = UDim2.fromOffset(22, 22)
closeButton.Text = "×"
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold
closeButton.TextColor3 = Color3.fromRGB(239, 68, 68)
closeButton.BackgroundColor3 = Color3.fromRGB(71, 85, 105)
closeButton.BorderSizePixel = 0
closeButton.Parent = topButtons

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeButton

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, -32, 0, 35)
header.Position = UDim2.fromOffset(16, 34)
header.BackgroundTransparency = 1
header.Parent = panel

local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, 0, 0, 1)
headerLine.Position = UDim2.new(0, 0, 1, -1)
headerLine.BackgroundColor3 = Color3.fromRGB(148, 163, 184)
headerLine.BorderSizePixel = 0
headerLine.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -35, 1, 0)
title.Position = UDim2.fromOffset(0, 0)
title.BackgroundTransparency = 1
title.Text = "🚀 Webhook Controller"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local version = Instance.new("TextLabel")
version.Size = UDim2.fromOffset(30, 20)
version.Position = UDim2.new(1, -30, 0, 8)
version.BackgroundTransparency = 1
version.Text = "v0.1"
version.TextColor3 = Color3.fromRGB(100, 116, 139)
version.TextSize = 11
version.Font = Enum.Font.Gotham
version.TextXAlignment = Enum.TextXAlignment.Right
version.Parent = header

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -16, 1, -78)
content.Position = UDim2.fromOffset(8, 76)
content.BackgroundTransparency = 1
content.Parent = panel
local function createToggle(name, displayColor, y)
    local row = Instance.new("Frame")

    row.Size = UDim2.new(1, 0, 0, 25)
    row.Position = UDim2.fromOffset(0, y)

    row.BackgroundTransparency = 1
    row.Parent = content

    -- Tier name
    local label = Instance.new("TextLabel")

    label.Size = UDim2.new(1, -50, 1, 0)

    label.BackgroundTransparency = 1
    label.Text = name

    label.TextColor3 = displayColor
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold

    label.TextXAlignment = Enum.TextXAlignment.Left

    label.Parent = row

    -- Switch
    local switch = Instance.new("TextButton")

    switch.Size = UDim2.fromOffset(32, 16)
    switch.Position = UDim2.new(1, -32, 0.5, -8)

    switch.Text = ""
    switch.BorderSizePixel = 0

    switch.Parent = row

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switch

    -- Knob
    local knob = Instance.new("Frame")

    knob.Size = UDim2.fromOffset(12, 12)
    knob.Position = UDim2.fromOffset(2, 2)

    knob.BorderSizePixel = 0
    knob.Parent = switch

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    -- Update visual
    local function update()
        if gate[name] then
            switch.BackgroundColor3 =
                Color3.fromRGB(134, 239, 172)

            knob.BackgroundColor3 =
                Color3.fromRGB(22, 101, 52)

            knob.Position =
                UDim2.new(1, -14, 0, 2)
        else
            switch.BackgroundColor3 =
                Color3.fromRGB(248, 113, 113)

            knob.BackgroundColor3 =
                Color3.fromRGB(153, 27, 27)

            knob.Position =
                UDim2.fromOffset(2, 2)
        end
    end

    switch.MouseButton1Click:Connect(function()
        gate[name] = not gate[name]

        update()

    end)

    update()

    return row
end

createToggle(
    "SECRET",
    Color3.fromRGB(24, 255, 152),
    0
)

createToggle(
    "FORGOTTEN",
    Color3.fromRGB(15, 15, 15),
    32
)

local displayNameInput = Instance.new("TextBox")

displayNameInput.Name = "DisplayNameInput"
displayNameInput.Size = UDim2.new(1, 0, 0, 30)
displayNameInput.Position = UDim2.fromOffset(0, 72)

displayNameInput.BackgroundColor3 =
    Color3.fromRGB(71, 85, 105)

displayNameInput.BorderSizePixel = 0

displayNameInput.Text = ""
displayNameInput.PlaceholderText = "Display Name..."
displayNameInput.PlaceholderColor3 =
    Color3.fromRGB(148, 163, 184)

displayNameInput.TextColor3 =
    Color3.fromRGB(226, 232, 240)

displayNameInput.TextSize = 13
displayNameInput.Font = Enum.Font.Gotham

displayNameInput.ClearTextOnFocus = false

displayNameInput.TextXAlignment =
    Enum.TextXAlignment.Left

displayNameInput.Parent = content

local inputPadding = Instance.new("UIPadding")
inputPadding.PaddingLeft = UDim.new(0, 10)
inputPadding.PaddingRight = UDim.new(0, 10)
inputPadding.Parent = displayNameInput

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 5)
inputCorner.Parent = displayNameInput

local testButton = Instance.new("TextButton")
testButton.Size = UDim2.new(1, 0, 0, 30)
testButton.Position = UDim2.fromOffset(0, 108)
testButton.Text = "Test Webhook"
testButton.TextColor3 = Color3.fromRGB(148, 163, 184)
testButton.TextSize = 13
testButton.Font = Enum.Font.GothamBold
testButton.BackgroundColor3 = Color3.fromRGB(71, 85, 105)
testButton.BorderSizePixel = 0
testButton.Parent = content

local testCorner = Instance.new("UICorner")
testCorner.CornerRadius = UDim.new(0, 5)
testCorner.Parent = testButton

local iconButton = Instance.new("TextButton")
iconButton.Name = "CollapsedIcon"
iconButton.Size = UDim2.fromOffset(46, 46)
iconButton.Position = UDim2.fromOffset(12, 64)
iconButton.Text = "🚀"
iconButton.TextSize = 24
iconButton.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
iconButton.BorderSizePixel = 0
iconButton.Visible = false
iconButton.Parent = gui

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 8)
iconCorner.Parent = iconButton

local iconStroke = Instance.new("UIStroke")
iconStroke.Color = Color3.fromRGB(14, 116, 144)
iconStroke.Thickness = 2
iconStroke.Parent = iconButton

collapseButton.MouseButton1Click:Connect(function()
    collapsed = true

    panel.Visible = false
    iconButton.Visible = true
end)

iconButton.MouseButton1Click:Connect(function()
    collapsed = false

    iconButton.Visible = false
    panel.Visible = true
end)

closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

testButton.MouseButton1Click:Connect(function()
    local displayName = displayNameInput.Text
    if displayName == "" then
        displayName = "TestUser"
    end
    local testData = {
        displayName = displayName,
        fishTier = "FORGOTTEN",
        variant = "BLOODMOON",
        fishCaught = "Thunderzilla",
        weight = "1.1M",
        rarity = "25M"
    }
    pcall(function()
        request({
            Url = epURL,
            Method = "POST",

            Headers = {
                ["Content-Type"] = "application/json"
            },

            Body = HttpService:JSONEncode(testData)
        })
    end)
end)

for _, object in ipairs(net:GetDescendants()) do
    hookRemote(object)
end

net.DescendantAdded:Connect(function(object)
    hookRemote(object)
end)