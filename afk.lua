-- ==========================================
-- STEAL AN EGG: NATIVE AUTO-FARM (V6 - FINAL)
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local WebhookURL = "https://discord.com/api/webhooks/1546132377942757508/hKr0zsMTzZ-jsVPV1Yqz42bZVL8AXgBZiX_PSXjnckCbC2COhet3FIyLQ45PN6fY18oB"

local startTime = tick()
local autoFarmActive = true
local ultimatePerfActive = true

-- Hanapin ang eksaktong RemoteFunction mula sa ReplicatedStorage o Workspace
local eggRemote = nil
pcall(function()
    eggRemote = ReplicatedStorage:FindFirstChild("RF") and ReplicatedStorage.RF:FindFirstChild("EggWorld") and ReplicatedStorage.RF.EggWorld:FindFirstChild("AskFieldEggCarry")
end)

local function sendDiscordEmbed(title, description, color)
    local payload = {
        embeds = {{
            title = "🛡️ [Native Auto-Farm] " + title,
            description = description,
            color = color,
            footer = { text = "Cloud AFK • " .. os.date("%I:%M %p") }
        }}
    }
    pcall(function()
        request({
            Url = WebhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)
end

-- Performance Mode para sa Redfinger
local function applyPerformanceMode(state)
    if state then
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
    end
end

if CoreGui:FindFirstChild("NativeEggFarmHub") then
    CoreGui.NativeEggFarmHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "NativeEggFarmHub"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 200)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -35, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
Title.Text = " 🥚 Steal an Egg [V6 Working]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 12

local StatsLabel = Instance.new("TextLabel", MainFrame)
StatsLabel.Size = UDim2.new(1, -20, 0, 45)
StatsLabel.Position = UDim2.new(0, 10, 0, 45)
StatsLabel.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
StatsLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
StatsLabel.Font = Enum.Font.Code
StatsLabel.TextSize = 10
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left

local FarmBtn = Instance.new("TextButton", MainFrame)
FarmBtn.Size = UDim2.new(1, -20, 0, 30)
FarmBtn.Position = UDim2.new(0, 10, 0, 100)
FarmBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
FarmBtn.Text = "Auto-Carry Egg: ON"
FarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmBtn.Font = Enum.Font.SourceSansBold
FarmBtn.TextSize = 12

FarmBtn.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    FarmBtn.Text = autoFarmActive and "Auto-Carry Egg: ON" or "Auto-Carry Egg: OFF"
    FarmBtn.BackgroundColor3 = autoFarmActive and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
end)

-- Auto Rejoin
game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" then
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

applyPerformanceMode(true)

-- Ang mismong sariling Auto-Farm Loop gamit ang natuklasang RemoteFunction
task.spawn(function()
    while true do
        local elapsed = math.floor(tick() - startTime)
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        
        StatsLabel.Text = string.format(" Uptime: %02d:%02d\n Status: Native Farming Active", hours, minutes)
        
        if autoFarmActive and eggRemote then
            pcall(function()
                -- Direktang tinatawag ang server gamit ang natagpuang RemoteFunction
                eggRemote:InvokeServer()
            end)
        end
        
        task.wait(1) -- Pwedeng baguhin ang bilis ng pag-trigger
    end
end)
