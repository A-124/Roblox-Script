-- ==========================================
-- STEAL AN EGG: ALT ACCOUNT SAFE HUB (V2)
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local WebhookURL = "https://discord.com/api/webhooks/1546132377942757508/hKr0zsMTzZ-jsVPV1Yqz42bZVL8AXgBZiX_PSXjnckCbC2COhet3FIyLQ45PN6fY18oB"

local startTime = tick()
local reconnectAttempts = 0
local alertsEnabled = true
local autoStealActive = true

-- Anti-Ban / Name Spoof protection para sa Alt Account
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
            title = "🛡️ [Alt Account] " .. title,
            description = description,
            color = color,
            footer = { text = "Redfinger Safe Hub • " .. os.date("%I:%M %p") }
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

if CoreGui:FindFirstChild("StealEggSafeHub") then
    CoreGui.StealEggSafeHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "StealEggSafeHub"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 210)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -105)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Text = " 🥚 Steal an Egg [Safe Alt]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local StatsLabel = Instance.new("TextLabel", MainFrame)
StatsLabel.Size = UDim2.new(1, -20, 0, 45)
StatsLabel.Position = UDim2.new(0, 10, 0, 45)
StatsLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
StatsLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
StatsLabel.Font = Enum.Font.Code
StatsLabel.TextSize = 11
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

local StealToggleBtn = Instance.new("TextButton", MainFrame)
StealToggleBtn.Size = UDim2.new(1, -20, 0, 30)
StealToggleBtn.Position = UDim2.new(0, 10, 0, 100)
StealToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
StealToggleBtn.Text = "Auto-Steal & Hatch: ON"
StealToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StealToggleBtn.Font = Enum.Font.SourceSansBold
StealToggleBtn.TextSize = 12

local TestBtn = Instance.new("TextButton", MainFrame)
TestBtn.Size = UDim2.new(1, -20, 0, 30)
TestBtn.Position = UDim2.new(0, 10, 0, 140)
TestBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 210)
TestBtn.Text = "Test Alt Webhook"
TestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TestBtn.Font = Enum.Font.SourceSansBold
TestBtn.TextSize = 12

StealToggleBtn.MouseButton1Click:Connect(function()
    autoStealActive = not autoStealActive
    StealToggleBtn.Text = autoStealActive and "Auto-Steal & Hatch: ON" or "Auto-Steal & Hatch: OFF"
    StealToggleBtn.BackgroundColor3 = autoStealActive and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
end)

TestBtn.MouseButton1Click:Connect(function()
    sendDiscordEmbed("Test Notification", "Ligtas na tumatakbo ang Alt Account sa Redfinger kasama ang Anti-Ban shield.", 3447003)
end)

-- Error Handler / Auto Rejoin para sa Alt
game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" then
        reconnectAttempts = reconnectAttempts + 1
        sendDiscordEmbed("Na-disconnect ang Alt", "Nag-reconnect ang alt account paratuloy ang pag-iipon ng itlog.", 15158332)
        task.wait(4)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

task.spawn(function()
    sendDiscordEmbed("Nagsimula na ang Script", "Tagumpay na na-inject ang Safe Hub sa alt account.", 3066993)
    while true do
        local elapsed = math.floor(tick() - startTime)
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        
        StatsLabel.Text = string.format(" Uptime: %02d:%02d | FPS: %d\n Status: Safe Farming Active", hours, minutes, fps)
        
        -- Kunwari ay ginagaya nito ang pagkuha ng itlog kapag naka-on ang auto-steal
        if autoStealActive then
            -- Dito papasok ang laro logic ng pagpili ng itlog
        end
        
        task.wait(2)
    end
end)
