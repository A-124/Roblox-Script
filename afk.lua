-- ==========================================
-- ROBLOX SUPER BIG AFK & DISCORD HUB
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local WebhookURL = "https://discord.com/api/webhooks/1546132377942757508/hKr0zsMTzZ-jsVPV1Yqz42bZVL8AXgBZiX_PSXjnckCbC2COhet3FIyLQ45PN6fY18oB"

-- Settings & Variables
local startTime = tick()
local reconnectAttempts = 0
local alertsEnabled = true
local lowCpuMode = false

-- Function para sa Rich Discord Embeds
local function sendDiscordEmbed(title, description, color)
    if not alertsEnabled then return end
    
    local payload = {
        embeds = {{
            title = title,
            description = description,
            color = color,
            footer = { text = "Redfinger Cloud Sync • " .. os.date("%I:%M %p") }
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

-- UI Setup (Floating Dashboard)
if CoreGui:FindFirstChild("SuperAFKHub") then
    CoreGui.SuperAFKHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "SuperAFKHub"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 220)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Active = true
MainFrame.Draggable = true

-- Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = " 🚀 Cloud AFK Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Uptime & Stats Label
local StatsLabel = Instance.new("TextLabel", MainFrame)
StatsLabel.Size = UDim2.new(1, -20, 0, 50)
StatsLabel.Position = UDim2.new(0, 10, 0, 45)
StatsLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
StatsLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
StatsLabel.Font = Enum.Font.Code
StatsLabel.TextSize = 12
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Buttons
local TestBtn = Instance.new("TextButton", MainFrame)
TestBtn.Size = UDim2.new(1, -20, 0, 30)
TestBtn.Position = UDim2.new(0, 10, 0, 105)
TestBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
TestBtn.Text = "Test Discord Embed"
TestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TestBtn.Font = Enum.Font.SourceSansBold
TestBtn.TextSize = 13

local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(1, -20, 0, 30)
ToggleBtn.Position = UDim2.new(0, 10, 0, 145)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
ToggleBtn.Text = "Discord Alerts: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 13

local CpuBtn = Instance.new("TextButton", MainFrame)
CpuBtn.Size = UDim2.new(1, -20, 0, 30)
CpuBtn.Position = UDim2.new(0, 10, 0, 185)
CpuBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
CpuBtn.Text = "Low-CPU Mode: OFF"
CpuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CpuBtn.Font = Enum.Font.SourceSansBold
CpuBtn.TextSize = 13

-- Button Actions
TestBtn.MouseButton1Click:Connect(function()
    sendDiscordEmbed("🔔 Test Alert", "Gumagana nang perpekto ang Super Big Update sa iyong Delta/Redfinger instance!", 3447003)
end)

ToggleBtn.MouseButton1Click:Connect(function()
    alertsEnabled = not alertsEnabled
    ToggleBtn.Text = alertsEnabled and "Discord Alerts: ON" or "Discord Alerts: OFF"
    ToggleBtn.BackgroundColor3 = alertsEnabled and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
end)

CpuBtn.MouseButton1Click:Connect(function()
    lowCpuMode = not lowCpuMode
    CpuBtn.Text = lowCpuMode and "Low-CPU Mode: ON" or "Low-CPU Mode: OFF"
    CpuBtn.BackgroundColor3 = lowCpuMode and Color3.fromRGB(180, 120, 0) or Color3.fromRGB(60, 60, 70)
end)

-- Auto-Rejoin / Anti-Disconnect System
game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" then
        sendDiscordEmbed("⚠️ Na-disconnect ang Account", "Na-detect ang Error/Kick. Sinusubukang mag-auto-rejoin...", 15158332)
        task.wait(3)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

-- Live UI Stats & Low-CPU Loop
task.spawn(function()
    sendDiscordEmbed("🟢 AFK Hub Started", "Tagumpay na na-load ang Super Big Update sa laro.", 3066993)
    
    while true do
        local elapsed = math.floor(tick() - startTime)
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = elapsed % 60
        
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        
        StatsLabel.Text = string.format(" Uptime: %02d:%02d:%02d\n FPS: %d | Ping: %dms\n Reconnects: %d", hours, minutes, seconds, fps, ping, reconnectAttempts)
        
        -- Low CPU Saver
        if lowCpuMode then
            task.wait(3)
        else
            task.wait(1)
        end
    end
end)

-- Periodic Status Report (Every 30 mins)
task.spawn(function()
    while true do
        task.wait(1800)
        sendDiscordEmbed("⏳ Status Update", "Patuloy at ligtas na tumatakbo ang account sa Redfinger.", 5763719)
    end
end)
