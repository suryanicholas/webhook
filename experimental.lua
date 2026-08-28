local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- STATE UI
--==================================================

local gate = {
    SECRET = true,
    FORGOTTEN = true
}

local collapsed = false

--==================================================
-- SCREEN GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "WebhookController"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

--==================================================
-- MAIN PANEL
--==================================================

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

--==================================================
-- TOP BUTTONS
--==================================================

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

-- Collapse
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

-- Close
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

--==================================================
-- HEADER
--==================================================

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

-- Title
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

-- Version
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

--==================================================
-- CONTENT
--==================================================

local content = Instance.new("Frame")
content.Name = "Content"

content.Size = UDim2.new(1, -16, 1, -78)
content.Position = UDim2.fromOffset(8, 76)

content.BackgroundTransparency = 1
content.Parent = panel

--==================================================
-- TOGGLE FUNCTION
--==================================================

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

        print(
            "[Gate]",
            name,
            gate[name]
        )

    end)

    update()

    return row
end

--==================================================
-- TOGGLES
--==================================================

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

--==================================================
-- TEST WEBHOOK BUTTON
--==================================================

local testButton = Instance.new("TextButton")

testButton.Size = UDim2.new(1, 0, 0, 30)
testButton.Position = UDim2.fromOffset(0, 72)

testButton.Text = "Test Webhook"

testButton.TextColor3 =
    Color3.fromRGB(148, 163, 184)

testButton.TextSize = 13
testButton.Font = Enum.Font.GothamBold

testButton.BackgroundColor3 =
    Color3.fromRGB(71, 85, 105)

testButton.BorderSizePixel = 0

testButton.Parent = content

local testCorner = Instance.new("UICorner")
testCorner.CornerRadius = UDim.new(0, 5)
testCorner.Parent = testButton

--==================================================
-- COLLAPSED ICON
--==================================================

local iconButton = Instance.new("TextButton")

iconButton.Name = "CollapsedIcon"
iconButton.Size = UDim2.fromOffset(46, 46)
iconButton.Position = UDim2.fromOffset(12, 64)

iconButton.Text = "🚀"
iconButton.TextSize = 24

iconButton.BackgroundColor3 =
    Color3.fromRGB(51, 65, 85)

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

--==================================================
-- COLLAPSE BEHAVIOR
--==================================================

collapseButton.MouseButton1Click:Connect(function()

    collapsed = true

    panel.Visible = false
    iconButton.Visible = true

end)

--==================================================
-- RESTORE BEHAVIOR
--==================================================

iconButton.MouseButton1Click:Connect(function()

    collapsed = false

    iconButton.Visible = false
    panel.Visible = true

end)

--==================================================
-- CLOSE BEHAVIOR
--==================================================

closeButton.MouseButton1Click:Connect(function()

    gui:Destroy()

end)

--==================================================
-- TEST BUTTON BEHAVIOR
--==================================================

testButton.MouseButton1Click:Connect(function()

    print("========== WEBHOOK TEST ==========")

    print("SECRET:", gate.SECRET)
    print("FORGOTTEN:", gate.FORGOTTEN)

    print("==================================")

end)