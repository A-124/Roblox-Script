local w = "https://discord.com/api/webhooks/1546132377942757508/hKr0zsMTzZ-jsVPV1Yqz42bZVL8AXgBZiX_PSXjnckCbC2COhet3FIyLQ45PN6fY18oB"
local g = game:GetService("CoreGui") 
if g:FindFirstChild("S") then g.S:Destroy() end
local s = Instance.new("ScreenGui", g) 
s.Name = "S"
local f = Instance.new("Frame", s) 
f.Size = UDim2.new(0, 180, 0, 100) 
f.Position = UDim2.new(0.5, -90, 0.5, -50) 
f.BackgroundColor3 = Color3.fromRGB(30, 30, 30) 
f.Active = true 
f.Draggable = true
local b = Instance.new("TextButton", f) 
b.Size = UDim2.new(0, 160, 0, 40) 
b.Position = UDim2.new(0, 10, 0, 30) 
b.BackgroundColor3 = Color3.fromRGB(0, 170, 255) 
b.Text = "Test Webhook" 
b.TextColor3 = Color3.new(1, 1, 1) 
b.Font = Enum.Font.SourceSansBold 
b.TextSize = 14
local function m(t) 
    pcall(function() 
        request({Url = w, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = game:GetService("HttpService"):JSONEncode({content = t})}) 
    end) 
end
b.MouseButton1Click:Connect(function() m("🔔 Test galing Delta UI!") end)
m("🟢 AFK Started!")
task.spawn(function() 
    while true do 
        task.wait(1800) 
        m("⏳ Buhay pa ang account.") 
    end 
end)
