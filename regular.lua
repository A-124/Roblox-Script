-- ═══════════════════════════════════════════════════════
--  CELZZ STEAL | AFK MODE FINAL
--  Powered by EGX AI | ENDXZ
--  Dedicated to ENDXZ | JAILBREAK HAS DONE
-- ═══════════════════════════════════════════════════════

local CONFIG = {
    AutoSteal = false,
    AFKMode = true,
    NightPause = true,
    RejoinOnKick = true,
    WalkToEgg = true,
    MinDelay = 0.50,
    MaxDelay = 1.20,
    EggCooldown = 2.5,
    MaxDistance = 500,
    AutoRejoinDelay = 10,
}

local RUNNING = true

local RARITY_PRIORITY = { "secret", "eternal", "lunar", "divine" }

local HIGH_PRIORITY_EGGS = {
    ["unicorn"] = "divine", ["kitsune"] = "divine",
    ["eternal lunar dragon"] = "eternal", ["gorilla king"] = "eternal",
    ["oni tiger"] = "eternal", ["mosasaurus"] = "eternal",
    ["el maja"] = "eternal", ["ice dragon"] = "eternal", ["lava dragon"] = "eternal",
    ["mutant shark"] = "secret", ["stag"] = "secret", ["t-rex"] = "secret",
    ["tralaledon"] = "secret", ["cosmic skeleton boss"] = "secret",
    ["cosmic dragon"] = "secret", ["king snake"] = "secret",
    ["cerberus"] = "secret", ["kraken"] = "secret", ["phoenix"] = "secret",
}

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser       = game:GetService("VirtualUser")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")
local TeleportService   = game:GetService("TeleportService")
local LocalPlayer       = Players.LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("CELZZ_STEAL_UI")
if old then old:Destroy() end

local THEME = {
    Bg=Color3.fromRGB(8,8,10), Panel=Color3.fromRGB(14,14,18), HeaderBg=Color3.fromRGB(18,18,22),
    RowBg=Color3.fromRGB(22,22,28), Border=Color3.fromRGB(45,45,55), Accent=Color3.fromRGB(200,200,210),
    AccentDim=Color3.fromRGB(120,120,130), Text=Color3.fromRGB(235,235,240),
    TextDim=Color3.fromRGB(140,140,150), Green=Color3.fromRGB(0,200,90),
}

local gui = Instance.new("ScreenGui")
gui.Name = "CELZZ_STEAL_UI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = PlayerGui

-- CIRCLE
local circle = Instance.new("TextButton")
circle.Size = UDim2.new(0, 56, 0, 56)
circle.Position = UDim2.new(0, 20, 0.5, -28)
circle.BackgroundColor3 = THEME.Bg
circle.BorderSizePixel = 0
circle.Text = "CELZZ"
circle.TextColor3 = THEME.Text
circle.TextSize = 13
circle.Font = Enum.Font.GothamBold
circle.AutoButtonColor = false
circle.Parent = gui
local circleCorner = Instance.new("UICorner") circleCorner.CornerRadius = UDim.new(1,0) circleCorner.Parent = circle
local stroke = Instance.new("UIStroke") stroke.Color = THEME.Accent stroke.Thickness = 1.2 stroke.Transparency = 0.35 stroke.Parent = circle

-- MINI DOT
local miniDot = Instance.new("TextButton")
miniDot.Size = UDim2.new(0, 26, 0, 26)
miniDot.Position = UDim2.new(0, 20, 0.5, -13)
miniDot.BackgroundColor3 = THEME.Bg
miniDot.BorderSizePixel = 0
miniDot.Text = ""
miniDot.AutoButtonColor = false
miniDot.Visible = false
miniDot.Parent = gui
local miniCorner = Instance.new("UICorner") miniCorner.CornerRadius = UDim.new(1,0) miniCorner.Parent = miniDot
local miniStroke = Instance.new("UIStroke") miniStroke.Color = THEME.Accent miniStroke.Thickness = 1 miniStroke.Transparency = 0.3 miniStroke.Parent = miniDot
local miniGlow = Instance.new("Frame")
miniGlow.Size = UDim2.new(0, 9, 0, 9)
miniGlow.Position = UDim2.new(0.5, -4.5, 0.5, -4.5)
miniGlow.BackgroundColor3 = THEME.Accent
miniGlow.BorderSizePixel = 0
miniGlow.Parent = miniDot
local miniGlowCorner = Instance.new("UICorner") miniGlowCorner.CornerRadius = UDim.new(1,0) miniGlowCorner.Parent = miniGlow

-- PANEL
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 320, 0, 460)
panel.Position = UDim2.new(0, 90, 0.5, -230)
panel.BackgroundColor3 = THEME.Panel
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui
local panelCorner = Instance.new("UICorner") panelCorner.CornerRadius = UDim.new(0,12) panelCorner.Parent = panel
local panelStroke = Instance.new("UIStroke") panelStroke.Color = THEME.Border panelStroke.Thickness = 1 panelStroke.Transparency = 0.1 panelStroke.Parent = panel

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 46)
header.BackgroundColor3 = THEME.HeaderBg
header.BorderSizePixel = 0
header.Parent = panel
local headerCorner = Instance.new("UICorner") headerCorner.CornerRadius = UDim.new(0,12) headerCorner.Parent = header
local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 12)
headerFix.Position = UDim2.new(0, 0, 1, -12)
headerFix.BackgroundColor3 = THEME.HeaderBg
headerFix.BorderSizePixel = 0
headerFix.Parent = header
local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, 0, 0, 1)
headerLine.Position = UDim2.new(0, 0, 1, -1)
headerLine.BackgroundColor3 = THEME.Border
headerLine.BorderSizePixel = 0
headerLine.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 0, 22)
title.Position = UDim2.new(0, 18, 0, 6)
title.BackgroundTransparency = 1
title.Text = "CELZZ STEAL"
title.TextColor3 = THEME.Text
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -100, 0, 14)
subtitle.Position = UDim2.new(0, 18, 0, 26)
subtitle.BackgroundTransparency = 1
subtitle.Text = "AFK Mode  •  EGX AI  •  ENDXZ"
subtitle.TextColor3 = THEME.TextDim
subtitle.TextSize = 9
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -66, 0, 10)
minBtn.BackgroundColor3 = THEME.RowBg
minBtn.BorderSizePixel = 0
minBtn.Text = "−"
minBtn.TextColor3 = THEME.Text
minBtn.TextSize = 18
minBtn.Font = Enum.Font.GothamBold
minBtn.AutoButtonColor = false
minBtn.Parent = header
local minCorner = Instance.new("UICorner") minCorner.CornerRadius = UDim.new(1,0) minCorner.Parent = minBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -36, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(30, 12, 16)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(220, 90, 100)
closeBtn.TextSize = 13
closeBtn.Font = Enum.Font.GothamBold
closeBtn.AutoButtonColor = false
closeBtn.Parent = header
local closeCorner = Instance.new("UICorner") closeCorner.CornerRadius = UDim.new(1,0) closeCorner.Parent = closeBtn

minBtn.MouseButton1Click:Connect(function()
    panel.Visible = false
    circle.Visible = false
    miniDot.Visible = true
end)

closeBtn.MouseButton1Click:Connect(function()
    RUNNING = false
    CONFIG.AutoSteal = false
    gui:Destroy()
end)

miniDot.MouseButton1Click:Connect(function()
    miniDot.Visible = false
    circle.Visible = true
    panel.Visible = true
end)

minBtn.MouseEnter:Connect(function()
    TweenService:Create(minBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(40, 40, 48) }):Play()
end)
minBtn.MouseLeave:Connect(function()
    TweenService:Create(minBtn, TweenInfo.new(0.15), { BackgroundColor3 = THEME.RowBg }):Play()
end)
closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(60, 20, 28) }):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(30, 12, 16) }):Play()
end)

-- DRAG
local dragging, dragStart, startPos, dragTarget
local function makeDraggable(target)
    target.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragTarget = target
            dragStart = input.Position startPos = target.Position
        end
    end)
    target.InputChanged:Connect(function(input)
        if dragging and dragTarget == target and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    target.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false dragTarget = nil
        end
    end)
end
makeDraggable(circle)
makeDraggable(miniDot)

-- CONTENT
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -20, 1, -60)
content.Position = UDim2.new(0, 10, 0, 52)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 2
content.ScrollBarImageColor3 = THEME.AccentDim
content.CanvasSize = UDim2.new(0, 0, 0, 500)
content.Parent = panel

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 7)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = content

-- AUTO STEAL BUTTON
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(1, -6, 0, 54)
autoBtn.BackgroundColor3 = THEME.RowBg
autoBtn.BorderSizePixel = 0
autoBtn.Text = "AUTO STEAL  •  OFF"
autoBtn.TextColor3 = THEME.TextDim
autoBtn.TextSize = 14
autoBtn.Font = Enum.Font.GothamBold
autoBtn.AutoButtonColor = false
autoBtn.Parent = content
local autoCorner = Instance.new("UICorner") autoCorner.CornerRadius = UDim.new(0,10) autoCorner.Parent = autoBtn
local autoStroke = Instance.new("UIStroke") autoStroke.Color = THEME.Border autoStroke.Thickness = 1 autoStroke.Parent = autoBtn

-- STATUS
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, -6, 0, 32)
statusFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
statusFrame.BorderSizePixel = 0
statusFrame.Parent = content
local statusCorner = Instance.new("UICorner") statusCorner.CornerRadius = UDim.new(0,6) statusCorner.Parent = statusFrame
local statusStroke = Instance.new("UIStroke") statusStroke.Color = THEME.Border statusStroke.Thickness = 1 statusStroke.Parent = statusFrame

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, -16, 1, 0)
statusLbl.Position = UDim2.new(0, 10, 0, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "● BOT: Idle"
statusLbl.TextColor3 = THEME.TextDim
statusLbl.TextSize = 11
statusLbl.Font = Enum.Font.GothamMedium
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.Parent = statusFrame

local function updateStatus(txt, color)
    statusLbl.Text = "● BOT: " .. txt
    statusLbl.TextColor3 = color or THEME.TextDim
end

-- TOGGLE BUILDER
local function makeToggle(name, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 38)
    row.BackgroundColor3 = THEME.RowBg
    row.BorderSizePixel = 0
    row.Parent = content
    local rCorner = Instance.new("UICorner") rCorner.CornerRadius = UDim.new(0,8) rCorner.Parent = row
    local rStroke = Instance.new("UIStroke") rStroke.Color = THEME.Border rStroke.Thickness = 1 rStroke.Parent = row
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0) label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1 label.Text = name label.TextColor3 = THEME.Text
    label.TextSize = 12 label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left label.Parent = row
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 38, 0, 20) toggleBg.Position = UDim2.new(1, -52, 0.5, -10)
    toggleBg.BackgroundColor3 = default and THEME.Accent or Color3.fromRGB(40, 40, 48)
    toggleBg.BorderSizePixel = 0 toggleBg.Parent = row
    local tCorner = Instance.new("UICorner") tCorner.CornerRadius = UDim.new(1,0) tCorner.Parent = toggleBg
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = THEME.Bg knob.BorderSizePixel = 0 knob.Parent = toggleBg
    local kCorner = Instance.new("UICorner") kCorner.CornerRadius = UDim.new(1,0) kCorner.Parent = knob
    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0) click.BackgroundTransparency = 1 click.Text = "" click.Parent = row
    local state = default
    click.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(toggleBg, TweenInfo.new(0.2), { BackgroundColor3 = state and THEME.Accent or Color3.fromRGB(40, 40, 48) }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), { Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) }):Play()
        if callback then callback(state) end
    end)
end

-- SLIDER BUILDER
local function makeSlider(name, min, max, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 58)
    row.BackgroundColor3 = THEME.RowBg
    row.BorderSizePixel = 0
    row.Parent = content
    local rCorner = Instance.new("UICorner") rCorner.CornerRadius = UDim.new(0,8) rCorner.Parent = row
    local rStroke = Instance.new("UIStroke") rStroke.Color = THEME.Border rStroke.Thickness = 1 rStroke.Parent = row
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -100, 0, 24) label.Position = UDim2.new(0, 14, 0, 6)
    label.BackgroundTransparency = 1 label.Text = name label.TextColor3 = THEME.Text
    label.TextSize = 12 label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left label.Parent = row
    local valueLbl = Instance.new("TextLabel")
    valueLbl.Size = UDim2.new(0, 70, 0, 24) valueLbl.Position = UDim2.new(1, -84, 0, 6)
    valueLbl.BackgroundTransparency = 1 valueLbl.Text = tostring(default)
    valueLbl.TextColor3 = THEME.Accent valueLbl.TextSize = 12
    valueLbl.Font = Enum.Font.GothamBold valueLbl.TextXAlignment = Enum.TextXAlignment.Right
    valueLbl.Parent = row
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -28, 0, 5) sliderBg.Position = UDim2.new(0, 14, 0, 42)
    sliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    sliderBg.BorderSizePixel = 0 sliderBg.Parent = row
    local sCorner = Instance.new("UICorner") sCorner.CornerRadius = UDim.new(1,0) sCorner.Parent = sliderBg
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = THEME.Accent fill.BorderSizePixel = 0 fill.Parent = sliderBg
    local fCorner = Instance.new("UICorner") fCorner.CornerRadius = UDim.new(1,0) fCorner.Parent = fill
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    knob.BackgroundColor3 = THEME.Text knob.BorderSizePixel = 0 knob.Parent = sliderBg
    local kCorner = Instance.new("UICorner") kCorner.CornerRadius = UDim.new(1,0) kCorner.Parent = knob
    local draggingSlider = false
    local function update(input)
        local relX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * relX)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        knob.Position = UDim2.new(relX, -6, 0.5, -6)
        valueLbl.Text = tostring(val)
        if callback then callback(val) end
    end
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)
end

-- AUTO STEAL TOGGLE
autoBtn.MouseButton1Click:Connect(function()
    CONFIG.AutoSteal = not CONFIG.AutoSteal
    if CONFIG.AutoSteal then
        TweenService:Create(autoBtn, TweenInfo.new(0.25), { BackgroundColor3 = THEME.Green }):Play()
        TweenService:Create(autoStroke, TweenInfo.new(0.25), { Color = Color3.fromRGB(0, 255, 120) }):Play()
        autoBtn.Text = "AUTO STEAL  •  ON"
        autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        updateStatus("Scanning eggs...", THEME.Green)
    else
        TweenService:Create(autoBtn, TweenInfo.new(0.25), { BackgroundColor3 = THEME.RowBg }):Play()
        TweenService:Create(autoStroke, TweenInfo.new(0.25), { Color = THEME.Border }):Play()
        autoBtn.Text = "AUTO STEAL  •  OFF"
        autoBtn.TextColor3 = THEME.TextDim
        updateStatus("Idle", THEME.TextDim)
    end
end)

autoBtn.MouseEnter:Connect(function()
    TweenService:Create(autoBtn, TweenInfo.new(0.15), { BackgroundColor3 = CONFIG.AutoSteal and Color3.fromRGB(0, 230, 105) or Color3.fromRGB(32, 32, 40) }):Play()
end)
autoBtn.MouseLeave:Connect(function()
    TweenService:Create(autoBtn, TweenInfo.new(0.15), { BackgroundColor3 = CONFIG.AutoSteal and THEME.Green or THEME.RowBg }):Play()
end)

makeToggle("AFK Mode", CONFIG.AFKMode, function(v) CONFIG.AFKMode = v end)
makeToggle("Night Pause", CONFIG.NightPause, function(v) CONFIG.NightPause = v end)
makeToggle("Rejoin on Kick", CONFIG.RejoinOnKick, function(v) CONFIG.RejoinOnKick = v end)
makeToggle("Walk to Egg", CONFIG.WalkToEgg, function(v) CONFIG.WalkToEgg = v end)
makeSlider("Min Delay (ms)", 100, 1000, 500, function(v) CONFIG.MinDelay = v/1000 end)
makeSlider("Max Delay (ms)", 100, 2000, 1200, function(v) CONFIG.MaxDelay = v/1000 end)
makeSlider("Egg Cooldown (ms)", 500, 5000, 2500, function(v) CONFIG.EggCooldown = v/1000 end)

-- OPEN PANEL
local panelOpen = false
circle.MouseButton1Click:Connect(function()
    if not dragging then
        panelOpen = not panelOpen
        panel.Visible = panelOpen
        if panelOpen then
            panel.Position = UDim2.new(0, 90, 0.5, -230)
        end
    end
end)

circle.MouseEnter:Connect(function()
    TweenService:Create(circle, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(20, 20, 26) }):Play()
    TweenService:Create(stroke, TweenInfo.new(0.2), { Transparency = 0 }):Play()
end)
circle.MouseLeave:Connect(function()
    TweenService:Create(circle, TweenInfo.new(0.2), { BackgroundColor3 = THEME.Bg }):Play()
    TweenService:Create(stroke, TweenInfo.new(0.2), { Transparency = 0.35 }):Play()
end)

-- ANTI-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- CORE LOGIC
local function getEggRarity(egg)
    local name = egg.Name:lower()
    local attrRarity = ""
    pcall(function()
        attrRarity = (egg:GetAttribute("Rarity") or egg:GetAttribute("Type") or egg:GetAttribute("Tier") or ""):lower()
    end)
    for key, rarity in pairs(HIGH_PRIORITY_EGGS) do
        if name:find(key, 1, true) then return rarity end
    end
    for _, rarity in ipairs(RARITY_PRIORITY) do
        if attrRarity:find(rarity) then return rarity end
    end
    return nil
end

local function getEggPrice(egg)
    local price = 0
    pcall(function()
        price = tonumber(egg:GetAttribute("Price")) or tonumber(egg:GetAttribute("Value"))
            or tonumber(egg:GetAttribute("Worth")) or tonumber(egg:GetAttribute("Cost")) or 0
    end)
    return price
end

local function botScanBestEgg()
    local priorityEggs, normalEggs = {}, {}
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local myPos = hrp and hrp.Position or Vector3.new(0,0,0)

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local name = obj.Name:lower()
            if name:find("egg") then
                local rarity = getEggRarity(obj)
                local price = getEggPrice(obj)
                local ok, pos = pcall(function() return obj.Position or obj:GetPivot().Position end)
                if not ok or not pos then continue end
                local dist = (pos - myPos).Magnitude
                if dist > CONFIG.MaxDistance then continue end

                if rarity then
                    local pnum = 99
                    for i, r in ipairs(RARITY_PRIORITY) do if r == rarity then pnum = i break end end
                    table.insert(priorityEggs, { obj = obj, rarity = rarity, price = price, priority = pnum, dist = dist })
                else
                    table.insert(normalEggs, { obj = obj, rarity = "normal", price = price, priority = 99, dist = dist })
                end
            end
        end
    end

    if #priorityEggs > 0 then
        table.sort(priorityEggs, function(a, b)
            if a.priority ~= b.priority then return a.priority < b.priority end
            return a.price > b.price
        end)
        return priorityEggs[1], "RARITY"
    end
    if #normalEggs > 0 then
        table.sort(normalEggs, function(a, b) return a.price > b.price end)
        return normalEggs[1], "PRICE"
    end
    return nil, "NONE"
end

local function findRemotes()
    local remotes = {}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = obj.Name:lower()
            if n:find("steal") or n:find("egg") or n:find("collect") or n:find("grab") or n:find("pick") then
                table.insert(remotes, obj)
            end
        end
    end
    return remotes
end

local function walkTo(targetPos, timeout)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return false end
    timeout = timeout or 15
    local startTime = tick()
    hum:MoveTo(targetPos)
    while tick() - startTime < timeout do
        if not RUNNING or not CONFIG.AutoSteal then return false end
        local dist = (hrp.Position - targetPos).Magnitude
        if dist < 6 then
            hum:MoveTo(hrp.Position)
            return true
        end
        hum:MoveTo(targetPos)
        task.wait(0.1)
    end
    return false
end

local function stealEgg(eggData)
    if not eggData or not eggData.obj then return end
    local egg = eggData.obj
    local remotes = findRemotes()

    if CONFIG.WalkToEgg then
        local pos
        pcall(function() pos = egg.Position or egg:GetPivot().Position end)
        if pos then
            updateStatus("Walking to " .. eggData.rarity .. " egg...", Color3.fromRGB(100, 200, 255))
            local arrived = walkTo(pos, 15)
            if not arrived then
                updateStatus("Cannot reach, skip...", Color3.fromRGB(200, 150, 100))
                return
            end
        end
    end

    updateStatus("Stealing " .. eggData.rarity .. " egg...", THEME.Green)
    for _, r in ipairs(remotes) do
        pcall(function()
            if r:IsA("RemoteEvent") then
                r:FireServer(egg)
            elseif r:IsA("RemoteFunction") then
                r:InvokeServer(egg)
            end
        end)
        local delay = CONFIG.MinDelay + math.random() * (CONFIG.MaxDelay - CONFIG.MinDelay)
        task.wait(delay)
    end
end

local function isNight()
    return Lighting.ClockTime < 6 or Lighting.ClockTime > 18
end

-- LOOP UTAMA
task.spawn(function()
    while RUNNING and task.wait(0.1) do
        if not CONFIG.AutoSteal then continue end
        pcall(function()
            if CONFIG.NightPause and isNight() then
                updateStatus("Night time, pausing...", Color3.fromRGB(200, 200, 100))
                task.wait(3)
                return
            end

            updateStatus("Scanning eggs...", THEME.Green)
            local best, mode = botScanBestEgg()
            if best then
                if mode == "RARITY" then
                    updateStatus("🎯 " .. best.rarity:upper() .. " detected!", Color3.fromRGB(0, 255, 120))
                else
                    updateStatus("💰 Best price: $" .. best.price, Color3.fromRGB(255, 200, 100))
                end
                stealEgg(best)
                local cd = CONFIG.EggCooldown + math.random() * 1.0
                task.wait(cd)
            else
                updateStatus("No egg found, waiting...", Color3.fromRGB(200, 150, 100))
                task.wait(2)
            end
        end)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if p == LocalPlayer and CONFIG.RejoinOnKick then
        task.wait(CONFIG.AutoRejoinDelay)
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
end)

print("[CELZZ STEAL] Loaded | AFK Mode | Tuan ENDXZ 😹")
