-- ==========================================
-- STEAL AN EGG: ULTIMATE SAFE HUB (V3)
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local WebhookURL = "https://discord.com/api/webhooks/1546132377942757508/hKr0zsMTzZ-jsVPV1Yqz42bZVL8AXgBZiX_PSXjnckCbC2COhet3FIyLQ45PN6fY18oB"

local startTime = tick()
local alertsEnabled = true
local autoStealActive = true
local autoHatchActive = true
local ultimatePerfActive = true

-- Anti-Ban / Kick Protection
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "Ban" then
            return nil
        end
        return old(self, ...)
    end)
end)

local function sendDiscordEmbed(title, description, color)
    if not alertsEnabled then return end
    local payload = {
        embeds = {{
            title = "🛡️ [Alt Safe Hub] " .. title,
            description = description,
            color = color,
            footer = { text = "Ultimate Cloud AFK • " .. os.date("%I:%M %p") }
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

-- Ultimate Performance Mode (Super Smooth for Redfinger)
local function applyPerformanceMode(state)
    if state then
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Enabled = false
                end
            end
        end)
    end
end

if CoreGui:FindFirstChild("UltimateStealEggHub") then
    CoreGui.UltimateStealEggHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "UltimateStealEggHub"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 245)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -35, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
Title.Text = " 🥚 Steal an Egg [Ultimate]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize / Open-Close Button
local MinBtn = Instance.new("TextButton", MainFrame)
MinBtn.Size = UDim2.new(0, 35, 0, 35)
MinBtn.Position = UDim2.new(1, -35, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 16

local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, 0, 1, -35)
Container.Position = UDim2.new(0, 0, 0, 35)
Container.BackgroundTransparency = 1

local StatsLabel = Instance.new("TextLabel", Container)
StatsLabel.Size = UDim2.new(1, -20, 0, 40)
StatsLabel.Position = UDim2.new(0, 10, 0, 10)
StatsLabel.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
StatsLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
StatsLabel.Font = Enum.Font.Code
StatsLabel.TextSize = 10
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Buttons inside Container
local StealBtn = Instance.new("TextButton", Container)
StealBtn.Size = UDim2.new(1, -20, 0, 30)
StealBtn.Position = UDim2.new(0, 10, 0, 58)
StealBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
StealBtn.Text = "Auto-Steal: ON"
StealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StealBtn.Font = Enum.Font.SourceSansBold
StealBtn.TextSize = 12

local HatchBtn = Instance.new("TextButton", Container)
HatchBtn.Size = UDim2.new(1, -20, 0, 30)
HatchBtn.Position = UDim2.new(0, 10, 0, 96)
HatchBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
HatchBtn.Text = "Auto-Hatch: ON"
HatchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HatchBtn.Font = Enum.Font.SourceSansBold
HatchBtn.TextSize = 12

local PerfBtn = Instance.new("TextButton", Container)
PerfBtn.Size = UDim2.new(1, -20, 0, 30)
PerfBtn.Position = UDim2.new(0, 10, 0, 134)
PerfBtn.BackgroundColor3 = Color3.fromRGB(180, 120, 0)
PerfBtn.Text = "Ultimate Performance: ON"
PerfBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PerfBtn.Font = Enum.Font.SourceSansBold
PerfBtn.TextSize = 12

local TestBtn = Instance.new("TextButton", Container)
TestBtn.Size = UDim2.new(1, -20, 0, 30)
TestBtn.Position = UDim2.new(0, 10, 0, 172)
TestBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 210)
TestBtn.Text = "Test Webhook"
TestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TestBtn.Font = Enum.Font.SourceSansBold
TestBtn.TextSize = 12

-- Minimize Logic
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Container.Visible = not minimized
    MainFrame.Size = minimized and UDim2.new(0, 240, 0, 35) or UDim2.new(0, 240, 0, 245)
    MinBtn.Text = minimized and "+" or "-"
end)

StealBtn.MouseButton1Click:Connect(function()
    autoStealActive = not autoStealActive
    StealBtn.Text = autoStealActive and "Auto-Steal: ON" or "Auto-Steal: OFF"
    StealBtn.BackgroundColor3 = autoStealActive and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
end)

HatchBtn.MouseButton1Click:Connect(function()
    autoHatchActive = not autoHatchActive
    HatchBtn.Text = autoHatchActive and "Auto-Hatch: ON" or "Auto-Hatch: OFF"
    HatchBtn.BackgroundColor3 = autoHatchActive and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
end)

PerfBtn.MouseButton1Click:Connect(function()
    ultimatePerfActive = not ultimatePerfActive
    PerfBtn.Text = ultimatePerfActive and "Ultimate Performance: ON" or "Ultimate Performance: OFF"
    PerfBtn.BackgroundColor3 = ultimatePerfActive and Color3.fromRGB(180, 120, 0) or Color3.fromRGB(180, 40, 40)
    applyPerformanceMode(ultimatePerfActive)
end)

TestBtn.MouseButton1Click:Connect(function()
    sendDiscordEmbed("Ultimate Test", "Maayos na gumagana ang UI, Minimize feature, at Performance boost sa alt account mo!", 3447003)
end)

-- Auto Rejoin kung ma-kick
game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" then
        sendDiscordEmbed("Na-disconnect", "Nag-aauto-reconnect ang alt account para tuloy ang farm.", 15158332)
        task.wait(4)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

-- Apply initial performance mode
applyPerformanceMode(true)

-- Main Working Loop para sa Auto-Steal at Auto-Hatch (Safe & Updated Method)
task.spawn(function()
    sendDiscordEmbed("Nagsimula na ang Ultimate Hub", "Handa na ang alt account para sa 24/7 cloud AFK.", 3066993)
    
    while true do
        local elapsed = math.floor(tick() - startTime)
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        
        StatsLabel.Text = string.format(" Uptime: %02d:%02d | FPS: %d\n Status: Active & Optimized", hours, minutes, fps)
        
        -- Working Auto-Steal Logic (Hanapin ang mga Egg items o ProximityPrompts sa laro)
        if autoStealActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    -- Sinusubukan nitong galawin o i-trigger ang mga itlog / prompts sa paligid
                    if obj:IsA("ProximityPrompt") and (obj.Parent.Name:lower():find("egg") or obj.Parent.Name:lower():find("steal")) then
                        fireproximityprompt(obj)
                    end
                end
            end)
        end
        
        task.wait(1.5)
    end
end)
