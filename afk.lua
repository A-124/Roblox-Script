-- ==========================================
-- DISCORD REMOTE LOGGER (STEAL AN EGG
-- ==========================================

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local WebhookURL = "https://discord.com/api/webhooks/1546132377942757508/hKr0zsMTzZ-jsVPV1Yqz42bZVL8AXgBZiX_PSXjnckCbC2COhet3FIyLQ45PN6fY18oB"

-- Function para mag-send agad sa Discord
local function sendRemoteLog(remoteName, details)
    local payload = {
        embeds = {{
            title = "📡 Remote Caught: " .. remoteName,
            description = "```lua\n" .. tostring(details) .. "\n```",
            color = 16776960,
            footer = { text = "Remote Logger • " .. os.date("%I:%M:%S %p") }
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

-- UI Indicator para alam mong active
if CoreGui:FindFirstChild("DiscordLoggerUI") then
    CoreGui.DiscordLoggerUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "DiscordLoggerUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 50)
Frame.Position = UDim2.new(0.5, -110, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.Active = true
Frame.Draggable = true

local Label = Instance.new("TextLabel", Frame)
Label.Size = UDim2.new(1, 0, 1, 0)
Label.BackgroundTransparency = 1
Label.Text = "📡 Discord Logger Active\n(Mag-steal ka na)"
Label.TextColor3 = Color3.fromRGB(0, 255, 128)
Label.Font = Enum.Font.SourceSansBold
Label.TextSize = 12

-- Prevent spamming identical remotes in a second
local lastLogged = {}

pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if method == "FireServer" or method == "InvokeServer" then
            local rName = self.Name
            if not lastLogged[rName] or (tick() - lastLogged[rName] > 2) then
                lastLogged[rName] = tick()
                
                local argText = "Method: " .. method
                for i, arg in ipairs(args) do
                    argText = argText .. string.format("\nArg[%d]: %s (%s)", i, tostring(arg), typeof(arg))
                end
                
                sendRemoteLog(rName, argText)
            end
        end
        
        return oldNamecall(self, ...)
    end)
end)

-- Send startup notice
pcall(function()
    request({
        Url = WebhookURL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode({
            content = "🟢 **Remote Logger Started!** Mag-manual steal ka na sa laro para makita natin sa Discord ang mga remotes."
        })
    })
end)
