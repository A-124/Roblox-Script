-- ============================================
-- 🥚 LEE HUB - CLEAN VERSION
-- Steal an Egg
-- Coded by Lee
-- ============================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- ============================================
-- SERVICES
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- ============================================
-- CLEANUP PREVIOUS VERSION
-- ============================================

pcall(function()
    local oldGui = CoreGui:FindFirstChild("LeeHubClean")
    if oldGui then
        oldGui:Destroy()
    end
end)

pcall(function()
    local oldGui = game:GetService("Players").LocalPlayer
        :WaitForChild("PlayerGui")
        :FindFirstChild("LeeHubClean")

    if oldGui then
        oldGui:Destroy()
    end
end)

-- ============================================
-- STATE
-- ============================================

local fastPromptEnabled = false
local originalHoldDurations = {}
local connections = {}

-- ============================================
-- GUI PARENT
-- ============================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LeeHubClean"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

pcall(function()
    if gethui then
        screenGui.Parent = gethui()
        return
    end
end)

if not screenGui.Parent then
    screenGui.Parent = CoreGui
end

-- ============================================
-- HELPERS
-- ============================================

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end

local function setButtonState(button, enabled, text)
    if enabled then
        button.Text = text .. ": ON"
        button.BackgroundColor3 = Color3.fromRGB(45, 170, 75)
    else
        button.Text = text .. ": OFF"
        button.BackgroundColor3 = Color3.fromRGB(170, 55, 55)
    end
end

local function restorePrompts()
    for prompt, originalDuration in pairs(originalHoldDurations) do
        if prompt and prompt.Parent then
            pcall(function()
                prompt.HoldDuration = originalDuration
            end)
        end
    end

    table.clear(originalHoldDurations)
end

local function setFastPrompt(enabled)
    fastPromptEnabled = enabled

    if enabled then
        for _, object in ipairs(workspace:GetDescendants()) do
            if object:IsA("ProximityPrompt") then
                if originalHoldDurations[object] == nil then
                    originalHoldDurations[object] = object.HoldDuration
                end

                pcall(function()
                    object.HoldDuration = 0
                end)
            end
        end
    else
        restorePrompts()
    end
end

-- ============================================
-- FLOATING BUTTON
-- ============================================

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.fromOffset(54, 54)
toggleButton.Position = UDim2.new(0, 20, 0.5, -27)
toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 27)
toggleButton.TextColor3 = Color3.fromRGB(255, 215, 0)
toggleButton.Text = "L"
toggleButton.TextSize = 24
toggleButton.Font = Enum.Font.GothamBold
toggleButton.AutoButtonColor = true
toggleButton.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleButton

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(255, 215, 0)
toggleStroke.Thickness = 2
toggleStroke.Parent = toggleButton

-- ============================================
-- MAIN FRAME
-- ============================================

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.fromOffset(370, 285)
mainFrame.Position = UDim2.new(0.5, -185, 0.5, -142)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(55, 55, 75)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

-- ============================================
-- TITLE BAR
-- ============================================

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 34)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.65, 0, 1, 0)
titleLabel.Position = UDim2.fromOffset(14, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "LEE HUB | Steal an Egg"
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.new(0.3, -10, 1, 0)
creditLabel.Position = UDim2.new(0.7, 0, 0, 0)
creditLabel.BackgroundTransparency = 1
creditLabel.Text = "Coded by Lee"
creditLabel.TextColor3 = Color3.fromRGB(145, 145, 165)
creditLabel.TextSize = 10
creditLabel.Font = Enum.Font.GothamItalic
creditLabel.TextXAlignment = Enum.TextXAlignment.Right
creditLabel.Parent = titleBar

-- ============================================
-- TAB BAR
-- ============================================

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -20, 0, 36)
tabBar.Position = UDim2.fromOffset(10, 52)
tabBar.BackgroundTransparency = 1
tabBar.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabBar

-- ============================================
-- CONTENT
-- ============================================

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -100)
content.Position = UDim2.fromOffset(10, 94)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local tabs = {}
local pages = {}

local function createTab(name, order)
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(108, 34)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    button.TextColor3 = Color3.fromRGB(160, 160, 180)
    button.Text = name
    button.TextSize = 11
    button.Font = Enum.Font.GothamBold
    button.LayoutOrder = order
    button.Parent = tabBar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    connect(layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        page.CanvasSize = UDim2.new(
            0,
            0,
            0,
            layout.AbsoluteContentSize.Y + 10
        )
    end)

    tabs[name] = button
    pages[name] = page

    connect(button.MouseButton1Click, function()
        for tabName, tabButton in pairs(tabs) do
            tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            tabButton.TextColor3 = Color3.fromRGB(160, 160, 180)
            pages[tabName].Visible = false
        end

        button.BackgroundColor3 = Color3.fromRGB(48, 48, 68)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        page.Visible = true
    end)

    return page
end

local mainPage = createTab("Main", 1)
local miscPage = createTab("Misc", 2)
local updatePage = createTab("Next Update", 3)

-- ============================================
-- MAIN PAGE
-- ============================================

local fastPromptButton = Instance.new("TextButton")
fastPromptButton.Size = UDim2.new(1, 0, 0, 44)
fastPromptButton.BackgroundColor3 = Color3.fromRGB(170, 55, 55)
fastPromptButton.TextColor3 = Color3.fromRGB(255, 255, 255)
fastPromptButton.Text = "Fast Prompt: OFF"
fastPromptButton.TextSize = 13
fastPromptButton.Font = Enum.Font.GothamBold
fastPromptButton.Parent = mainPage

local fpCorner = Instance.new("UICorner")
fpCorner.CornerRadius = UDim.new(0, 7)
fpCorner.Parent = fastPromptButton

connect(fastPromptButton.MouseButton1Click, function()
    setFastPrompt(not fastPromptEnabled)
    setButtonState(
        fastPromptButton,
        fastPromptEnabled,
        "Fast Prompt"
    )
end)

local description = Instance.new("TextLabel")
description.Size = UDim2.new(1, 0, 0, 55)
description.BackgroundTransparency = 1
description.Text = "Sets ProximityPrompt HoldDuration to 0 locally.\nServer-side validation may still apply."
description.TextColor3 = Color3.fromRGB(175, 175, 190)
description.TextSize = 11
description.Font = Enum.Font.Gotham
description.TextWrapped = true
description.TextXAlignment = Enum.TextXAlignment.Left
description.Parent = mainPage

-- ============================================
-- NEW PROMPT HANDLER
-- ============================================

connect(ProximityPromptService.PromptAdded, function(prompt)
    if not fastPromptEnabled then
        return
    end

    if originalHoldDurations[prompt] == nil then
        originalHoldDurations[prompt] = prompt.HoldDuration
    end

    pcall(function()
        prompt.HoldDuration = 0
    end)
end)

-- ============================================
-- MISC PAGE
-- ============================================

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 55)
statusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
statusLabel.TextColor3 = Color3.fromRGB(100, 220, 120)
statusLabel.Text = "● LEE HUB is running\nNo anti-kick / anti-detect bypass active."
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextWrapped = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = miscPage

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 7)
statusCorner.Parent = statusLabel

-- ============================================
-- NEXT UPDATE PAGE
-- ============================================

local updateLabel = Instance.new("TextLabel")
updateLabel.Size = UDim2.new(1, 0, 0, 100)
updateLabel.BackgroundTransparency = 1
updateLabel.TextColor3 = Color3.fromRGB(200, 200, 215)
updateLabel.Text =
    "🚀 Planned Features\n\n" ..
    "• Egg information panel\n" ..
    "• Rarity display\n" ..
    "• Better mobile layout\n" ..
    "• Additional quality-of-life tools"
updateLabel.TextSize = 12
updateLabel.Font = Enum.Font.Gotham
updateLabel.TextWrapped = true
updateLabel.TextXAlignment = Enum.TextXAlignment.Left
updateLabel.TextYAlignment = Enum.TextYAlignment.Top
updateLabel.Parent = updatePage

-- ============================================
-- SHOW MAIN TAB
-- ============================================

tabs["Main"].BackgroundColor3 = Color3.fromRGB(48, 48, 68)
tabs["Main"].TextColor3 = Color3.fromRGB(255, 255, 255)
pages["Main"].Visible = true

-- ============================================
-- MOBILE-FRIENDLY TOGGLE
-- ============================================

local menuVisible = true

connect(toggleButton.MouseButton1Click, function()
    menuVisible = not menuVisible
    mainFrame.Visible = menuVisible
end)

-- ============================================
-- KEYBOARD TOGGLE
-- ============================================

connect(UserInputService.InputBegan, function(input, processed)
    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.L
        or input.KeyCode == Enum.KeyCode.Insert then

        menuVisible = not menuVisible
        mainFrame.Visible = menuVisible
    end
end)

-- ============================================
-- MOBILE DRAG SYSTEM
-- ============================================

local function makeDraggable(guiObject)
    local dragging = false
    local dragStart
    local startPosition

    connect(guiObject.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = guiObject.Position

            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false

                    if connection then
                        connection:Disconnect()
                    end
                end
            end)
        end
    end)

    connect(guiObject.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            local moveConnection

            moveConnection = UserInputService.InputChanged:Connect(function(changedInput)
                if not dragging then
                    if moveConnection then
                        moveConnection:Disconnect()
                    end
                    return
                end

                if changedInput == input then
                    local delta = changedInput.Position - dragStart

                    guiObject.Position = UDim2.new(
                        startPosition.X.Scale,
                        startPosition.X.Offset + delta.X,
                        startPosition.Y.Scale,
                        startPosition.Y.Offset + delta.Y
                    )
                end
            end)

            table.insert(connections, moveConnection)
        end
    end)
end

makeDraggable(mainFrame)
makeDraggable(toggleButton)

-- ============================================
-- FINAL STATUS
-- ============================================

print("[LEE HUB] Loaded successfully.")
print("[LEE HUB] Fast Prompt: OFF")
print("[LEE HUB] GUI: READY")
print("[LEE HUB] Mobile controls: READY")
