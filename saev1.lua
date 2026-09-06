-- ============================================
-- 🐝 BEE HUB - STEAL AN EGG
-- OPTIMIZED FOR DELTA EXECUTOR
-- ============================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Services
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

-- ============================================
-- SETTINGS
-- ============================================

local settings = {
    AutoSteal = true,
    WalkToEggs = true,
    AntiAFK = true,
    AutoSell = false,
    StealDelay = 1.5,
    MaxDistance = 50,
    ESPEnabled = true,
}

-- ============================================
-- CREATE GUI (Mobile-Friendly)
-- ============================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BeeHub"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 420)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Corner
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 45)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🐝 BEE HUB"
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 25)
statusLabel.Position = UDim2.new(0, 0, 0, 45)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🟢 Auto-Steal: ON"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- Stats
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, 0, 0, 25)
statsLabel.Position = UDim2.new(0, 0, 0, 70)
statusLabel.BackgroundTransparency = 1
statsLabel.Text = "🍳 Eggs: 0"
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statsLabel.TextSize = 14
statsLabel.Font = Enum.Font.Gotham
statsLabel.Parent = mainFrame

-- ============================================
-- BUTTONS
-- ============================================

local function createButton(text, yPos, color, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.85, 0, 0, 35)
    button.Position = UDim2.new(0.075, 0, yPos, 0)
    button.BackgroundColor3 = color or Color3.fromRGB(255, 215, 0)
    button.BackgroundTransparency = 0.25
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.Parent = mainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    return button
end

-- Buttons
createButton("🔄 Toggle Auto-Steal", 0.27, Color3.fromRGB(255, 215, 0), function()
    settings.AutoSteal = not settings.AutoSteal
    statusLabel.Text = settings.AutoSteal and "🟢 Auto-Steal: ON" or "🔴 Auto-Steal: OFF"
    statusLabel.TextColor3 = settings.AutoSteal and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

createButton("🚶 Toggle Walk", 0.38, Color3.fromRGB(100, 200, 255), function()
    settings.WalkToEggs = not settings.WalkToEggs
end)

createButton("👁️ Toggle ESP", 0.49, Color3.fromRGB(255, 100, 255), function()
    settings.ESPEnabled = not settings.ESPEnabled
    if not settings.ESPEnabled then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BillboardGui") and obj.Name == "EggESP" then
                obj:Destroy()
            end
        end
    end
end)

createButton("🌀 Teleport to Egg", 0.60, Color3.fromRGB(100, 255, 100), function()
    teleportToEgg()
end)

createButton("💰 Auto-Sell", 0.71, Color3.fromRGB(255, 200, 100), function()
    settings.AutoSell = not settings.AutoSell
end)

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    print("🐝 BEE HUB - Closed")
end)

-- ============================================
-- FIND REMOTES
-- ============================================

local remotes = {}

local function findRemotes()
    local remoteNames = {
        "StealEgg", "RequestCarryAreaEgg", "CarryEgg", "RequestStealEgg",
        "EggSteal", "Steal", "AreaEggRequest", "StealEggRemote",
        "GrabEgg", "TakeEgg", "PickupEgg", "EggInteract",
        "RequestDropHeldAreaEgg", "RequestPlaceEgg"
    }
    
    local folders = {
        replicatedStorage,
        replicatedStorage:FindFirstChild("Events"),
        replicatedStorage:FindFirstChild("Remotes"),
        replicatedStorage:FindFirstChild("RemoteEvents"),
        game:GetService("ReplicatedFirst"),
    }
    
    for _, folder in pairs(folders) do
        if folder then
            for _, name in pairs(remoteNames) do
                local found = folder:FindFirstChild(name)
                if found then
                    remotes[name] = found
                    print("🐝 Found: " .. name)
                end
            end
        end
    end
end

findRemotes()

-- ============================================
-- FIND EGGS
-- ============================================

local function findNearestEgg()
    local nearest = nil
    local nearestDist = settings.MaxDistance
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            local name = obj.Name:lower()
            if name:find("egg") or name:find("steal") or name:find("carry") or name:find("area") then
                local pos = nil
                if obj:IsA("Model") then
                    pos = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("PrimaryPart")
                else
                    pos = obj
                end
                
                if pos and rootPart then
                    local dist = (rootPart.Position - pos.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = obj
                    end
                end
            end
        end
    end
    
    return nearest, nearestDist
end

-- ============================================
-- ESP
-- ============================================

local espObjects = {}

local function updateESP()
    -- Cleanup dead ESP
    for i = #espObjects, 1, -1 do
        if not espObjects[i].egg or not espObjects[i].egg.Parent then
            if espObjects[i].billboard then
                espObjects[i].billboard:Destroy()
            end
            table.remove(espObjects, i)
        end
    end
    
    if not settings.ESPEnabled then return end
    
    -- Find and create ESP for eggs
    local eggs = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("egg") then
            table.insert(eggs, obj)
        end
    end
    
    for _, egg in pairs(eggs) do
        local exists = false
        for _, esp in pairs(espObjects) do
            if esp.egg == egg then
                exists = true
                break
            end
        end
        
        if not exists then
            local part = egg:FindFirstChild("HumanoidRootPart") or egg:FindFirstChild("PrimaryPart")
            if part then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "EggESP"
                billboard.Size = UDim2.new(0, 80, 0, 25)
                billboard.Adornee = part
                billboard.AlwaysOnTop = true
                billboard.Parent = egg
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = "🥚"
                label.TextColor3 = Color3.fromRGB(255, 215, 0)
                label.TextScaled = true
                label.Font = Enum.Font.GothamBold
                label.Parent = billboard
                
                table.insert(espObjects, {
                    egg = egg,
                    billboard = billboard
                })
            end
        end
    end
end

-- ============================================
-- MOVEMENT
-- ============================================

local function moveTo(position)
    if not rootPart then return false end
    
    local distance = (rootPart.Position - position).Magnitude
    if distance < 5 then return true end
    
    local tween = tweenService:Create(rootPart, TweenInfo.new(
        distance / 25,
        Enum.EasingStyle.Linear
    ), {
        CFrame = CFrame.new(position)
    })
    
    tween:Play()
    tween.Completed:Wait()
    return true
end

local function walkToEgg()
    if not settings.WalkToEggs then return false end
    
    local egg, dist = findNearestEgg()
    if egg then
        local pos = nil
        if egg:IsA("Model") then
            local part = egg:FindFirstChild("HumanoidRootPart") or egg:FindFirstChild("PrimaryPart")
            if part then pos = part.Position end
        else
            pos = egg.Position
        end
        
        if pos then
            moveTo(pos)
            return true
        end
    end
    return false
end

local function teleportToEgg()
    local egg, dist = findNearestEgg()
    if egg then
        local pos = nil
        if egg:IsA("Model") then
            local part = egg:FindFirstChild("HumanoidRootPart") or egg:FindFirstChild("PrimaryPart")
            if part then pos = part.Position end
        else
            pos = egg.Position
        end
        
        if pos and rootPart then
            rootPart.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
            print("🐝 Teleported!")
            return true
        end
    end
    return false
end

-- ============================================
-- STEAL
-- ============================================

local stealCooldown = false
local stealCount = 0

local function stealEgg()
    if stealCooldown then return false end
    stealCooldown = true
    
    local success = false
    
    -- Try remotes
    for name, remote in pairs(remotes) do
        if remote and remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer()
                success = true
            end)
        elseif remote and remote:IsA("RemoteFunction") then
            pcall(function()
                remote:InvokeServer()
                success = true
            end)
        end
    end
    
    -- Alternative: Click on egg
    if not success then
        local egg = findNearestEgg()
        if egg then
            local clickDetector = egg:FindFirstChild("ClickDetector")
            if clickDetector then
                pcall(function()
                    clickDetector:FireClick(player)
                    success = true
                end)
            else
                local touchPart = egg:FindFirstChild("TouchPart") or (egg:IsA("Part") and egg)
                if touchPart and rootPart then
                    pcall(function()
                        firetouchinterest(rootPart, touchPart, 0)
                        wait(0.1)
                        firetouchinterest(rootPart, touchPart, 1)
                        success = true
                    end)
                end
            end
        end
    end
    
    if success then
        stealCount = stealCount + 1
        statsLabel.Text = "🍳 Eggs: " .. stealCount
    end
    
    wait(0.5)
    stealCooldown = false
    return success
end

-- ============================================
-- ANTI-AFK
-- ============================================

local function antiAfk()
    if not settings.AntiAFK then return end
    
    pcall(function()
        local vu = game:GetService("VirtualUser")
        if vu then
            vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            wait(0.1)
            vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end
    end)
    
    pcall(function()
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
end

-- ============================================
-- AUTO-SELL
-- ============================================

local function autoSell()
    if not settings.AutoSell then return end
    
    local sellRemote = replicatedStorage:FindFirstChild("SellEgg") or 
                        replicatedStorage:FindFirstChild("RequestSellEgg") or
                        replicatedStorage:FindFirstChild("Sell")
    
    if sellRemote then
        pcall(function()
            sellRemote:FireServer()
        end)
    end
end

-- ============================================
-- MAIN LOOP
-- ============================================

print("🐝 BEE HUB - Steal an Egg Loaded!")
print("🐝 Found " .. table.getn(remotes) .. " remotes")

spawn(function()
    while screenGui and screenGui.Parent do
        updateESP()
        
        if settings.AntiAFK then
            antiAfk()
        end
        
        if settings.AutoSteal then
            local success = stealEgg()
            if not success and settings.WalkToEggs then
                walkToEgg()
            end
        end
        
        if settings.AutoSell then
            autoSell()
        end
        
        wait(settings.StealDelay)
    end
end)

-- ============================================
-- KEYBINDS
-- ============================================

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        settings.AutoSteal = not settings.AutoSteal
        statusLabel.Text = settings.AutoSteal and "🟢 Auto-Steal: ON" or "🔴 Auto-Steal: OFF"
        statusLabel.TextColor3 = settings.AutoSteal and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end
    
    if input.KeyCode == Enum.KeyCode.R then
        stealEgg()
    end
    
    if input.KeyCode == Enum.KeyCode.T then
        teleportToEgg()
    end
    
    if input.KeyCode == Enum.KeyCode.H then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

-- ============================================
-- CLEANUP
-- ============================================

game:GetService("RunService"):SetStopped(function()
    screenGui:Destroy()
    for _, esp in pairs(espObjects) do
        if esp.billboard then
            esp.billboard:Destroy()
        end
    end
    print("🐝 BEE HUB - Unloaded")
end)

print("🐝 Controls: F=Toggle | R=Steal | T=Teleport | H=Hide GUI")
print("🐝 BEE HUB - Ready! Press F to start! 🐝")
