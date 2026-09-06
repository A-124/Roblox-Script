--!nonstrict
--[[
    SyncHub LITE - Custom Auto Steal with Section/Area Dropdown
    Gaya ng logic sa orihinal na file pero naka-lite UI at may dropdown para sa Area/Section.
--]]

local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local RunService         = game:GetService("RunService")
local HttpService        = game:GetService("HttpService")
local Lighting           = game:GetService("Lighting")

local lp = Players.LocalPlayer
local State = {
    autoSteal = false,
    targetArea = "All",
    targetRarity = "All",
    noclip = false,
    steals = 0,
}

local AREAS = { "All", "Cherry Blossom", "Cosmic", "Volcano", "Prehistoric", "Abyss Ocean" }
local RARITIES = { "All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Cosmic", "Divine", "Eternal", "Secret" }
local MOVE_MODES = { "Walk", "Glide" }

-- Simpleng Floating GUI para sa Delta / Mobile
local sg = Instance.new("ScreenGui")
sg.Name = "SyncHubLiteSection"
sg.ResetOnSpawn = false
sg.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 300, 0, 400)
main.Position = UDim2.new(0.5, -150, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(18, 19, 24)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", main).Color = Color3.fromRGB(50, 50, 60)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(28, 30, 37)
title.Text = " SyncHub - Steal an Egg (Section Fix)"
title.TextColor3 = Color3.fromRGB(88, 214, 141)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- Close Button
local closeBtn = Instance.new("TextButton", title)
closeBtn.Size = UDim2.fromOffset(24, 24)
closeBtn.Position = UDim2.new(1, -28, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(226, 98, 98)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

-- Container ng mga widgets
local container = Instance.new("ScrollingFrame", main)
container.Size = UDim2.new(1, -16, 1, -45)
container.Position = UDim2.new(0, 8, 0, 40)
container.BackgroundTransparency = 1
container.CanvasSize = UDim2.new(0, 0, 0, 450)
container.ScrollBarThickness = 3

local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Helper: Toggle Button
local function createToggle(text, callback)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(33, 35, 43)
    btn.TextColor3 = Color3.fromRGB(236, 238, 243)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.Text = "  " .. text .. ": OFF"
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = "  " .. text .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(88, 214, 141) or Color3.fromRGB(33, 35, 43)
        btn.TextColor3 = state and Color3.fromRGB(18, 19, 24) or Color3.fromRGB(236, 238, 243)
        callback(state)
    end)
end

-- Helper: Dropdown
local function createDropdown(text, options, currentVal, callback)
    local frame = Instance.new("Frame", container)
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(33, 35, 43)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.Position = UDim2.new(0, 8, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. currentVal
    lbl.TextColor3 = Color3.fromRGB(146, 152, 166)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -16, 0, 22)
    btn.Position = UDim2.new(0, 8, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(44, 47, 57)
    btn.Text = "Piliin... v"
    btn.TextColor3 = Color3.fromRGB(236, 238, 243)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local listFrame = Instance.new("ScrollingFrame", frame)
    listFrame.Size = UDim2.new(1, 0, 0, 110)
    listFrame.Position = UDim2.new(0, 0, 1, 4)
    listFrame.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
    listFrame.Visible = false
    listFrame.ZIndex = 15
    listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 24)
    listFrame.ScrollBarThickness = 2
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 4)
    Instance.new("UIListLayout", listFrame)

    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton", listFrame)
        optBtn.Size = UDim2.new(1, 0, 0, 24)
        optBtn.BackgroundColor3 = Color3.fromRGB(33, 35, 43)
        optBtn.TextColor3 = Color3.fromRGB(236, 238, 243)
        optBtn.Text = opt
        optBtn.TextSize = 10
        optBtn.ZIndex = 16
        optBtn.MouseButton1Click:Connect(function()
            lbl.Text = text .. ": " .. opt
            listFrame.Visible = false
            callback(opt)
        end)
    end

    btn.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
    end)
end

-- 1. SECTION / AREA DROPDOWN
createDropdown("Steal Section (Area)", AREAS, State.targetArea, function(opt)
    State.targetArea = opt
end)

-- 2. RARITY DROPDOWN
createDropdown("Steal Rarity Filter", RARITIES, State.targetRarity, function(opt)
    State.targetRarity = opt
end)

-- 3. AUTO STEAL TOGGLE
createToggle("Auto Steal (Active)", function(on)
    State.autoSteal = on
end)

-- 4. NOCLIP TOGGLE
createToggle("Noclip Mode", function(on)
    State.noclip = on
    if on then
        State.noclipConn = RunService.Stepped:Connect(function()
            local c = lp.Character
            if c then
                for _, part in ipairs(c:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    elseif State.noclipConn then
        State.noclipConn:Disconnect()
        State.noclipConn = nil
    end
end)

-- Core Reader logic gaya ng hango sa file
local function readInfo(model)
    local info = { name = model.Name, instance = model }
    local ok, attrs = pcall(function() return model:GetAttributes() end)
    if ok and type(attrs) == "table" then
        for rawKey, value in attrs do
            local key = string.lower(rawKey)
            if string.find(key, "rarity") then info.rarity = tostring(value)
            elseif string.find(key, "area") or string.find(key, "biome") then info.area = tostring(value) end
        end
    end
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("ValueBase") then
            local key = string.lower(d.Name)
            local value = select(2, pcall(function() return d.Value end))
            if string.find(key, "rarity") then info.rarity = tostring(value)
            elseif string.find(key, "area") then info.area = tostring(value) end
        elseif d:IsA("TextLabel") and d.Text ~= "" then
            local text = d.Text
            for _, r in ipairs(RARITIES) do if string.find(text, r, 1, true) then info.rarity = r end end
            for _, a in ipairs(AREAS) do if string.find(text, a, 1, true) then info.area = a end end
        end
    end
    return info
end

-- Auto Steal Loop
task.spawn(function()
    while true do
        task.wait(0.4)
        if State.autoSteal then
            pcall(function()
                local char = lp.Character
                local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not root or not hum then return end

                local source = workspace
                for _, d in ipairs(source:GetDescendants()) do
                    if d:IsA("Model") and string.find(string.lower(d.Name), "egg", 1, true) then
                        if not string.find(d:GetFullName(), lp.Name, 1, true) then
                            local info = readInfo(d)
                            
                            -- I-filter base sa napiling Section/Area at Rarity
                            local passArea = (State.targetArea == "All") or (info.area and string.find(string.lower(info.area), string.lower(State.targetArea), 1, true))
                            local passRarity = (State.targetRarity == "All") or (info.rarity == State.targetRarity)

                            if passArea and passRarity then
                                local targetPart = d.PrimaryPart or d:FindFirstChildWhichIsA("BasePart")
                                if targetPart then
                                    hum.WalkSpeed = 35
                                    hum:MoveTo(targetPart.Position)
                                    task.wait(0.3)

                                    -- Hanapin ang RemoteEvent para ma-trigger ang steal
                                    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                                        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                                            local rName = string.lower(remote.Name)
                                            if string.find(rName, "steal") or string.find(rName, "egg") or string.find(rName, "claim") then
                                                pcall(function()
                                                    if remote:IsA("RemoteEvent") then
                                                        remote:FireServer(d)
                                                    else
                                                        remote:InvokeServer(d)
                                                    end
                                                end)
                                            end
                                        end
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)
