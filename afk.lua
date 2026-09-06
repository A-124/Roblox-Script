-- ==========================================
-- STEAL AN EGG: ULTIMATE CLOVER/SPEED HUB V4
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
            title = "🛡️ [Steal an Egg Hub] " .. title,
            description = description,
            color = color,
            footer = { text = "Cloud AFK Sync • " .. os.date("%I:%M %p") }
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

-- Ultimate Performance Mode
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

if CoreGui:FindFirstChild("UltimateStealEggHubV4") then
    CoreGui.UltimateStealEggHubV4:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "UltimateStealEggHubV4"
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
Title.Text = " 🥚 Steal an Egg [V4 Fix]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Button
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
    sendDiscordEmbed("Test V4", "Gumagana ang V4 patch at nakakonekta sa GitHub raw link mo!", 3447003)
end)

-- Error Handler / Auto Rejoin
game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" then
        sendDiscordEmbed("Na-disconnect", "Nag-aauto-reconnect ang alt account para tuloy ang farm.", 15158332)
        task.wait(4)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

applyPerformanceMode(true)

-- Improved Steal & Hatch Loop batay sa __OBJECTS / Areas structure
task.spawn(function()
    sendDiscordEmbed("V4 Hub Started", "Naka-deploy na ang fixed loop para sa Steal an Egg.", 3066993)
    
    while true do
        local elapsed = math.floor(tick() - startTime)
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        
        StatsLabel.Text = string.format(" Uptime: %02d:%02d | FPS: %d\n Status: V4 Scanning Areas...", hours, minutes, fps)
        
        -- Pag-target sa __OBJECTS folder structure na nakita sa console
        if autoStealActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local objectsFolder = Workspace:FindFirstChild("__OBJECTS")
                if objectsFolder then
                    local areas = objectsFolder:FindFirstChild("Areas")
                    if areas then
                        for _, area in pairs(areas:GetChildren()) do
                            -- Hanapin ang mga ProximityPrompt o Egg triggers sa bawat Area (Desert, Prehistoric, atbp.)
                            for _, descendant in pairs(area:GetDescendants()) do
                                if descendant:IsA("ProximityPrompt") then
                                    fireproximityprompt(descendant)
                                elseif descendant:IsA("BasePart") and (descendant.Name:lower():find("egg") or descendant.Name:lower():find("steal")) then
                                    -- Direct touch interest kung sakaling walang prompt
                                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, descendant, 0)
                                    task.wait(0.05)
                                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, descendant, 1)
                                end
                            end
                        end
                    end
                end
            end)
        end
        
        task.wait(1.5)
    end
end)
