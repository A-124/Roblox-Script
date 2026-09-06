-- ERNUR HUB
-- GitHub: ernurhub.lua

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Ескі GUI-ді өшіру
local old = PlayerGui:FindFirstChild("ERNUR_HUB")
if old then
    old:Destroy()
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ERNUR_HUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Негізгі терезе
local Hub = Instance.new("Frame")
Hub.Size = UDim2.fromOffset(320, 350)
Hub.Position = UDim2.new(0.5, -160, 0.5, -175)
Hub.BackgroundColor3 = Color3.fromRGB(25, 25, 29)
Hub.BorderSizePixel = 0
Hub.Parent = ScreenGui

local HubCorner = Instance.new("UICorner")
HubCorner.CornerRadius = UDim.new(0, 16)
HubCorner.Parent = Hub

-- Тақырып
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 50)
Title.Position = UDim2.fromOffset(10, 5)
Title.BackgroundTransparency = 1
Title.Text = "ERNUR HUB"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 25
Title.Font = Enum.Font.GothamBold
Title.Parent = Hub

-- Батырма жасау
local function Button(text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -30, 0, 48)
    b.Position = UDim2.fromOffset(15, y)
    b.BackgroundColor3 = Color3.fromRGB(43, 43, 49)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 16
    b.Font = Enum.Font.Gotham
    b.Parent = Hub

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = b

    return b
end

local Egg = Button("🥚 Egg", 60)
local Teleport = Button("🚀 Teleport", 115)
local ESP = Button("👁 ESP : OFF", 170)
local Settings = Button("⚙️ Settings", 225)

-- Ашып/жабатын батырма
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.fromOffset(55, 55)
Toggle.Position = UDim2.new(0, 15, 0.5, -27)
Toggle.BackgroundColor3 = Color3.fromRGB(43, 43, 49)
Toggle.BorderSizePixel = 0
Toggle.Text = "☰"
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.TextSize = 24
Toggle.Font = Enum.Font.GothamBold
Toggle.Parent = ScreenGui

local TC = Instance.new("UICorner")
TC.CornerRadius = UDim.new(0, 12)
TC.Parent = Toggle

Toggle.MouseButton1Click:Connect(function()
    Hub.Visible = not Hub.Visible
end)

-- Egg
Egg.MouseButton1Click:Connect(function()
    print("ERNUR HUB: Egg clicked")
end)

-- Teleport: кездейсоқ ойыншыға телепорт
Teleport.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not root then return end

    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= LocalPlayer
        and target.Character
        and target.Character:FindFirstChild("HumanoidRootPart") then

            root.CFrame =
                target.Character.HumanoidRootPart.CFrame
                * CFrame.new(0, 3, 0)

            break
        end
    end
end)

-- ESP
local ESPEnabled = false
local ESPObjects = {}

local function AddESP(player)
    if player == LocalPlayer then return end

    local function CharacterAdded(character)
        if not ESPEnabled then return end

        local highlight = Instance.new("Highlight")
        highlight.Name = "ERNUR_ESP"
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = character

        ESPObjects[player] = highlight
    end

    if player.Character then
        CharacterAdded(player.Character)
    end

    player.CharacterAdded:Connect(CharacterAdded)
end

local function RemoveESP()
    for _, object in pairs(ESPObjects) do
        if object then
            object:Destroy()
        end
    end

    table.clear(ESPObjects)
end

ESP.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled

    if ESPEnabled then
        ESP.Text = "👁 ESP : ON"

        for _, player in ipairs(Players:GetPlayers()) do
            AddESP(player)
        end
    else
        ESP.Text = "👁 ESP : OFF"
        RemoveESP()
    end
end)

Players.PlayerAdded:Connect(function(player)
    if ESPEnabled then
        AddESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        ESPObjects[player]:Destroy()
        ESPObjects[player] = nil
    end
end)

-- Settings
Settings.MouseButton1Click:Connect(function()
    print("ERNUR HUB: Settings")
end)

-- Drag
local dragging = false
local dragStart
local startPosition

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = Hub.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then

        local delta = input.Position - dragStart

        Hub.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false
    end
end)

print("ERNUR HUB loaded successfully!")
