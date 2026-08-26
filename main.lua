local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

--==================================================
-- CONFIG
--==================================================

local ENDPOINT = "https://common-mixture-pay-flashing.trycloudflare.com/fish-caught"

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- SEND GATE
--==================================================

local SEND_GATE = {
    Legendary = false,
    Mythic = false,
    SECRET = true,
    FORGOTTEN = true,
}

--==================================================
-- GUI
--==================================================

local oldGui = playerGui:FindFirstChild("FishGateGUI")

if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "FishGateGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(240, 250)
frame.Position = UDim2.new(0, 20, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

--==================================================
-- TITLE
--==================================================

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -50, 0, 45)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "Fish API Gate"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

--==================================================
-- MINIMIZE
--==================================================

local minimize = Instance.new("TextButton")
minimize.Name = "Minimize"
minimize.Size = UDim2.fromOffset(35, 35)
minimize.Position = UDim2.new(1, -40, 0, 5)
minimize.BackgroundTransparency = 1
minimize.Text = "—"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.TextSize = 20
minimize.Font = Enum.Font.GothamBold
minimize.Parent = frame

--==================================================
-- BUTTON CONTAINER
--==================================================

local container = Instance.new("Frame")
container.Name = "Buttons"
container.Size = UDim2.new(1, -20, 0, 195)
container.Position = UDim2.fromOffset(10, 48)
container.BackgroundTransparency = 1
container.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = container

--==================================================
-- TIER BUTTONS
--==================================================

local tiers = {
    "Legendary",
    "Mythic",
    "SECRET",
    "FORGOTTEN",
}

for _, tier in ipairs(tiers) do

    local button = Instance.new("TextButton")

    button.Name = tier
    button.Size = UDim2.new(1, 0, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
    button.BorderSizePixel = 0

    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 14
    button.Font = Enum.Font.GothamMedium

    button.Parent = container

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 7)
    buttonCorner.Parent = button

    local function updateButton()

        if SEND_GATE[tier] then

            button.Text = tier .. "  [ON]"
            button.BackgroundColor3 =
                Color3.fromRGB(40, 130, 75)

        else

            button.Text = tier .. "  [OFF]"
            button.BackgroundColor3 =
                Color3.fromRGB(55, 55, 60)

        end

    end

    button.MouseButton1Click:Connect(function()

        SEND_GATE[tier] = not SEND_GATE[tier]

        updateButton()

        print(
            "[FishGate]",
            tier,
            SEND_GATE[tier] and "ON" or "OFF"
        )

    end)

    updateButton()
end

--==================================================
-- MINIMIZE LOGIC
--==================================================

local minimized = false

minimize.MouseButton1Click:Connect(function()

    minimized = not minimized

    container.Visible = not minimized

    if minimized then

        frame.Size = UDim2.fromOffset(240, 45)
        minimize.Text = "+"

    else

        frame.Size = UDim2.fromOffset(240, 250)
        minimize.Text = "—"

    end

end)

--==================================================
-- GUI READY
--==================================================

print("[FishGate] GUI loaded")

--==================================================
-- NET
--==================================================

local packages = ReplicatedStorage:WaitForChild("Packages")
local index = packages:WaitForChild("_Index")
local netPackage = index:WaitForChild("sleitnick_net@0.2.0")
local net = netPackage:WaitForChild("net")

local hooked = {}

--==================================================
-- RGB → FISH TIER
--==================================================

local tierByColor = {
    ["255,185,43"] = "Legendary",
    ["255,25,25"] = "Mythic",
    ["24,255,152"] = "SECRET",
    ["0,0,0"] = "FORGOTTEN",
}

--==================================================
-- RGB PARSER
--==================================================

local function getRGB(colorString)

    if type(colorString) ~= "string" then
        return nil
    end

    local r, g, b = colorString:match(
        "rgb%((%d+)%s*,%s*(%d+)%s*,%s*(%d+)%)"
    )

    if not r then
        return nil
    end

    return r .. "," .. g .. "," .. b
end

--==================================================
-- RICHTEXT PARSER
--==================================================

local function parseMessage(text)

    if type(text) ~= "string" then
        return nil
    end

    local displayName = text:match(
        '<font color="[^"]+">([^<]+)</font>%s+obtained a'
    )

    if not displayName then
        return nil
    end

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
        return nil
    end

    local variant = nil
    local fishBlock

    if #blocks >= 2 then
        variant = blocks[1].value
        fishBlock = blocks[2]
    else
        fishBlock = blocks[1]
    end

    local rgb = getRGB(fishBlock.color)

    local fishTier =
        tierByColor[rgb] or "Unknown"

    local fishCaught, weight =
        fishBlock.value:match(
            "^(.-)%s*%(([^()]+)%)$"
        )

    if not fishCaught then
        return nil
    end

    local rarity = text:match(
        "with a 1 in ([^%s]+) chance!"
    )

    if not rarity then
        return nil
    end

    return {
        displayName = displayName,
        fishTier = fishTier,
        variant = variant,
        fishCaught = fishCaught,
        weight = weight,
        rarity = rarity,
    }
end

--==================================================
-- HOOK REMOTE
--==================================================

local function hookRemote(remote)

    if not remote:IsA("RemoteEvent") then
        return
    end

    if hooked[remote] then
        return
    end

    hooked[remote] = true

    print("[FishGate] Hooked:", remote:GetFullName())

    remote.OnClientEvent:Connect(function(message)

        if type(message) ~= "string" then
            return
        end

        if not (
            message:find("obtained a", 1, true)
            and
            message:find("with a 1 in", 1, true)
            and
            message:find("chance!", 1, true)
        ) then
            return
        end

        local data = parseMessage(message)

        if not data then
            return
        end

        print(
            "[Fish]",
            data.displayName,
            data.fishTier,
            data.variant or "None",
            data.fishCaught,
            data.weight,
            data.rarity
        )

        -- GATE
        if SEND_GATE[data.fishTier] ~= true then
            print(
                "[FishGate] Blocked:",
                data.fishTier
            )
            return
        end

        print(
            "[FishGate] Sending:",
            data.fishCaught
        )

        -- HTTP
        local success, result = pcall(function()

            return request({
                Url = ENDPOINT,
                Method = "POST",

                Headers = {
                    ["Content-Type"] = "application/json"
                },

                Body = HttpService:JSONEncode(data)
            })

        end)

        if not success then

            warn(
                "[FishGate] HTTP error:",
                result
            )

        else

            print(
                "[FishGate] HTTP request completed"
            )

        end

    end)
end

--==================================================
-- SCAN EXISTING REMOTES
--==================================================

for _, object in ipairs(net:GetDescendants()) do
    hookRemote(object)
end

--==================================================
-- NEW REMOTES
--==================================================

net.DescendantAdded:Connect(function(object)
    hookRemote(object)
end)

print("[FishGate] Listener ready")