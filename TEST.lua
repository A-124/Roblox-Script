-- ============================================
-- 🥚 LEE HUB - STEAL AN EGG (IMPROVED VERSION)
-- Coded by Lee
-- ============================================

if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local menuVisible = true

-- Config states
local Config = {
    AutoFarm = false,
    EggESP = false,
    WalkSpeed = 16,
    SpeedEnabled = false,
    TeleportMethod = "Instant", -- "Instant" or "Tween"
    FarmRadius = 200, -- Maximum distance para i-farm
}

-- [[ SAFE ANTI-AFK ]]
task.spawn(function()
    while task.wait(60) do
        pcall(function()
            local vu = game:GetService("VirtualUser")
            if vu then
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end
        end)
    end
end)

-- [[ GUI CREATION ]]
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LeeHubScratch"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- Floating Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "LeeToggleBtn"
toggleBtn.Size = UDim2.new(0, 52, 0, 52)
toggleBtn.Position = UDim2.new(0, 25, 0.45, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
toggleBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
toggleBtn.Text = "L"
toggleBtn.TextSize = 24
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Active = true
toggleBtn.Draggable = true
toggleBtn.Parent = screenGui

local tCorner = Instance.new("UICorner", toggleBtn)
tCorner.CornerRadius = UDim.new(1, 0)
local tStroke = Instance.new("UIStroke", toggleBtn)
tStroke.Color = Color3.fromRGB(255, 215, 0)
tStroke.Thickness = 2

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 350)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mCorner = Instance.new("UICorner", mainFrame)
mCorner.CornerRadius = UDim.new(0, 12)
local mStroke = Instance.new("UIStroke", mainFrame)
mStroke.Color = Color3.fromRGB(50, 50, 70)
mStroke.Thickness = 1.5

-- Title Bar
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
titleBar.BorderSizePixel = 0
local tbCorner = Instance.new("UICorner", titleBar)
tbCorner.CornerRadius = UDim.new(0, 12)

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
titleLabel.Position = UDim2.new(0.04, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.Text = "LEE HUB v2 | Steal an Egg"
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local creditLabel = Instance.new("TextLabel", titleBar)
creditLabel.Size = UDim2.new(0.35, 0, 1, 0)
creditLabel.Position = UDim2.new(0.6, 0, 0, 0)
creditLabel.BackgroundTransparency = 1
creditLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
creditLabel.Text = "Coded by Lee"
creditLabel.TextSize = 11
creditLabel.Font = Enum.Font.GothamItalic
creditLabel.TextXAlignment = Enum.TextXAlignment.Right

-- Content Container
local contentContainer = Instance.new("ScrollingFrame", mainFrame)
contentContainer.Size = UDim2.new(1, -20, 1, -55)
contentContainer.Position = UDim2.new(0, 10, 0, 48)
contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0
contentContainer.ScrollBarThickness = 3
contentContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y

local listLayout = Instance.new("UIListLayout", contentContainer)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 10)

-- Helper para sa Toggles
local function createToggle(text, callback)
    local btn = Instance.new("TextButton", contentContainer)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text .. ": OFF"
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    local bCorner = Instance.new("UICorner", btn)
    bCorner.CornerRadius = UDim.new(0, 6)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(45, 180, 45) or Color3.fromRGB(180, 45, 45)
        callback(state)
    end)
    return btn
end

-- [[ HELPER FUNCTIONS ]]

-- Function para mahanap ang pinakamalapit na egg
local function findNearestEgg(maxDistance)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearestEgg = nil
    local shortestDistance = maxDistance or 200
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and string.find(string.lower(obj.Name), "egg") then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                local distance = (root.Position - part.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestEgg = obj
                end
            end
        end
    end
    
    return nearestEgg
end

-- Function para i-tween ang character
local function tweenTo(position)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    
    local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, tweenInfo, {CFrame = position})
    tween:Play()
    tween.Completed:Wait()
    return true
end

-- Function para kunin ang egg
local function collectEgg(eggModel)
    local success = false
    
    -- Try ProximityPrompts
    for _, prompt in pairs(eggModel:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function()
                prompt:InputHoldBegin()
                task.wait(0.1)
                prompt:InputHoldEnd()
                success = true
            end)
        end
    end
    
    -- Try RemoteEvents
    if not success then
        -- Hanapin ang remote events
        local remotes = ReplicatedStorage:GetDescendants()
        for _, remote in pairs(remotes) do
            if remote:IsA("RemoteEvent") then
                local remoteName = string.lower(remote.Name)
                if string.find(remoteName, "egg") or string.find(remoteName, "collect") or string.find(remoteName, "steal") then
                    pcall(function()
                        remote:FireServer(eggModel)
                        success = true
                    end)
                end
            end
        end
    end
    
    -- Try ClickDetectors
    if not success then
        for _, clickDetector in pairs(eggModel:GetDescendants()) do
            if clickDetector:IsA("ClickDetector") then
                pcall(function()
                    clickDetector:Click()
                    success = true
                end)
            end
        end
    end
    
    return success
end

-- [[ FEATURES IMPLEMENTATION ]]

-- 1. Auto Farm with Smart Targeting
createToggle("Auto Farm Best Eggs", function(state)
    Config.AutoFarm = state
    task.spawn(function()
        while Config.AutoFarm do
            task.wait(0.2)
            pcall(function()
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                local nearestEgg = findNearestEgg(Config.FarmRadius)
                if nearestEgg then
                    local part = nearestEgg.PrimaryPart or nearestEgg:FindFirstChildWhichIsA("BasePart")
                    if part then
                        -- Teleport sa egg
                        if Config.TeleportMethod == "Tween" then
                            tweenTo(part.CFrame + Vector3.new(0, 3, 0))
                        else
                            root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                        end
                        
                        task.wait(0.3)
                        
                        -- Subukan kunin ang egg
                        collectEgg(nearestEgg)
                        task.wait(0.2)
                    end
                end
            end)
        end
    end)
end)

-- 2. Egg ESP with Cleanup
local espCache = {}
createToggle("Egg ESP", function(state)
    Config.EggESP = state
    if not state then
        -- Cleanup
        for obj, highlight in pairs(espCache) do
            if highlight then 
                highlight:Destroy() 
            end
        end
        espCache = {}
    else
        task.spawn(function()
            while Config.EggESP do
                task.wait(0.5)
                pcall(function()
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("Model") and string.find(string.lower(obj.Name), "egg") then
                            if not espCache[obj] then
                                local highlight = Instance.new("Highlight")
                                highlight.FillColor = Color3.fromRGB(255, 215, 0)
                                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                highlight.FillTransparency = 0.3
                                highlight.OutlineTransparency = 0
                                highlight.Parent = obj
                                espCache[obj] = highlight
                            end
                        end
                    end
                    
                    -- Remove highlights for deleted eggs
                    for obj, highlight in pairs(espCache) do
                        if not obj or not obj.Parent then
                            if highlight then highlight:Destroy() end
                            espCache[obj] = nil
                        end
                    end
                end)
            end
        end)
    end
end)

-- 3. Speed Boost with GUI slider
createToggle("Speed Boost (28)", function(state)
    Config.SpeedEnabled = state
    Config.WalkSpeed = state and 28 or 16
    pcall(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = Config.WalkSpeed
        end
    end)
    
    -- Auto-update speed sa respawn
    if state then
        player.CharacterAdded:Connect(function(char)
            task.wait(1)
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and Config.SpeedEnabled then
                humanoid.WalkSpeed = Config.WalkSpeed
            end
        end)
    end
end)

-- 4. Teleport Method Toggle
createToggle("Teleport Method (Tween)", function(state)
    Config.TeleportMethod = state and "Tween" or "Instant"
end)

-- [[ TOGGLE MENU VISIBILITY ]]
local function toggleMenu()
    menuVisible = not menuVisible
    mainFrame.Visible = menuVisible
end

toggleBtn.MouseButton1Click:Connect(toggleMenu)

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and (input.KeyCode == Enum.KeyCode.L or input.KeyCode == Enum.KeyCode.Insert) then
        toggleMenu()
    end
end)

-- [[ ANTI-CHEAT SAFETY ]]
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            if Config.SpeedEnabled and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.WalkSpeed ~= Config.WalkSpeed then
                    humanoid.WalkSpeed = Config.WalkSpeed
                end
            end
        end)
    end
end)
