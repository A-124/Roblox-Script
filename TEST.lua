-- ============================================
-- 🥚 LEE HUB - STEAL AN EGG (MAX IMPROVED & SAFE)
-- Coded by: Lee
-- ============================================

if not game:IsLoaded() then pcall(function() game.Loaded:Wait() end) end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local fastPromptEnabled = false
local menuVisible = false -- Naka-false muna sa simula para malinis
local defaultHoldDurations = {}

-- [[ MAX ANTI-DETECT & ANTI-KICK BYPASS ]]
-- Tinatakpan ang mga function checks para hindi madaliang ma-flag ng client-side anti-cheat
pcall(function()
	if getgenv then
		local mt = getrawmetatable(game)
		if mt then
			setreadonly(mt, false)
			local oldIndex = mt.__index
			mt.__index = newcclosure(function(self, k)
				if k == "WalkSpeed" or k == "JumpPower" then
					return 16
				end
				return oldIndex(self, k)
			end)
			setreadonly(mt, true)
		end
	end
end)

-- Tahimik na Anti-AFK na hindi nag ti-trigger ng suspicious movement reports
task.spawn(function()
	while task.wait(60) do
		pcall(function()
			local vu = game:GetService("VirtualUser")
			if vu then
				vu:CaptureController()
				vu:ClickButton2(Vector2.new())
			end
		end)
	end
end)

-- [[ UI SETUP ]]
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LeeHubMaxStealAnEgg"
screenGui.ResetOnSpawn = false
if syn and syn.protect_gui then
	syn.protect_gui(screenGui)
	screenGui.Parent = CoreGui
elseif gethui then
	screenGui.Parent = gethui()
else
	screenGui.Parent = CoreGui
end

-- Floating Round Icon ("L" button na nasa gitna/gilid)
local toggleMenuBtn = Instance.new("TextButton")
toggleMenuBtn.Name = "LeeToggleBtn"
toggleMenuBtn.Size = UDim2.new(0, 52, 0, 52)
toggleMenuBtn.Position = UDim2.new(0, 25, 0.45, 0)
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
toggleMenuBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
toggleMenuBtn.Text = "L"
toggleMenuBtn.TextSize = 24
toggleMenuBtn.Font = Enum.Font.GothamBold
toggleMenuBtn.Active = true
toggleMenuBtn.Draggable = true
toggleMenuBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleMenuBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(255, 215, 0)
toggleStroke.Thickness = 2
toggleStroke.Parent = toggleMenuBtn

-- Main Frame (Naka-center at may Tabs)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 360, 0, 260)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -130)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false -- Sisiguraduhing kontrolado ng toggle
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(50, 50, 70)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

-- Title Bar with Credit ("Coded by Lee")
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
titleLabel.Position = UDim2.new(0.04, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.Text = "LEE HUB | Steal an Egg"
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.new(0.35, 0, 1, 0)
creditLabel.Position = UDim2.new(0.6, 0, 0, 0)
creditLabel.BackgroundTransparency = 1
creditLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
creditLabel.Text = "Coded by Lee"
creditLabel.TextSize = 11
creditLabel.Font = Enum.Font.GothamItalic
creditLabel.TextXAlignment = Enum.TextXAlignment.Right
creditLabel.Parent = titleBar

-- [[ TABS SYSTEM ]]
local tabButtonContainer = Instance.new("Frame")
tabButtonContainer.Size = UDim2.new(1, -20, 0, 32)
tabButtonContainer.Position = UDim2.new(0, 10, 0, 48)
tabButtonContainer.BackgroundTransparency = 1
tabButtonContainer.Parent = mainFrame

local tabListLayout = Instance.new("UIListLayout")
tabListLayout.FillDirection = Enum.FillDirection.Horizontal
tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabListLayout.Padding = UDim.new(0, 8)
tabListLayout.Parent = tabButtonContainer

local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -20, 1, -95)
contentContainer.Position = UDim2.new(0, 10, 0, 85)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

local tabs = {}
local tabPages = {}

local function createTab(name, isDefault)
	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(0, 105, 1, 0)
	tabBtn.BackgroundColor3 = isDefault and Color3.fromRGB(45, 45, 65) or Color3.fromRGB(28, 28, 38)
	tabBtn.TextColor3 = isDefault and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 180)
	tabBtn.Text = name
	tabBtn.TextSize = 12
	tabBtn.Font = Enum.Font.GothamBold
	tabBtn.Parent = tabButtonContainer

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = tabBtn

	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.Visible = isDefault
	page.Parent = contentContainer

	local pageLayout = Instance.new("UIListLayout")
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Padding = UDim.new(0, 8)
	pageLayout.Parent = page

	tabs[name] = tabBtn
	tabPages[name] = page

	tabBtn.MouseButton1Click:Connect(function()
		for tName, tBtn in pairs(tabs) do
			tBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
			tBtn.TextColor3 = Color3.fromRGB(160, 160, 180)
			tabPages[tName].Visible = false
		end
		tabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
		tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		page.Visible = true
	end)

	return page
end

-- Create Tabs
local mainTabPage = createTab("Main", true)
local miscTabPage = createTab("Misc", false)
local nextUpdatePage = createTab("Next Update", false)

-- [[ TAB 1: MAIN FEATURES ]]
local fastPromptBtn = Instance.new("TextButton")
fastPromptBtn.Size = UDim2.new(1, 0, 0, 40)
fastPromptBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
fastPromptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fastPromptBtn.Text = "Fast Prompt: OFF"
fastPromptBtn.TextSize = 13
fastPromptBtn.Font = Enum.Font.GothamBold
fastPromptBtn.Parent = mainTabPage

local fpCorner = Instance.new("UICorner")
fpCorner.CornerRadius = UDim.new(0, 6)
fpCorner.Parent = fastPromptBtn

fastPromptBtn.MouseButton1Click:Connect(function()
	fastPromptEnabled = not fastPromptEnabled
	if fastPromptEnabled then
		fastPromptBtn.Text = "Fast Prompt: ON"
		fastPromptBtn.BackgroundColor3 = Color3.fromRGB(45, 180, 45)
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("ProximityPrompt") then
				if not defaultHoldDurations[obj] then
					defaultHoldDurations[obj] = obj.HoldDuration
				end
				obj.HoldDuration = 0
			end
		end
	else
		fastPromptBtn.Text = "Fast Prompt: OFF"
		fastPromptBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
		for obj, originalDuration in pairs(defaultHoldDurations) do
			if obj and obj.Parent then
				obj.HoldDuration = originalDuration
			end
		end
		defaultHoldDurations = {}
	end
end)

ProximityPromptService.PromptAdded:Connect(function(prompt)
	if fastPromptEnabled then
		if not defaultHoldDurations[prompt] then
			defaultHoldDurations[prompt] = prompt.HoldDuration
		end
		prompt.HoldDuration = 0
	end
end)

-- [[ TAB 2: MISC FEATURES ]]
local antiKickLabel = Instance.new("TextLabel")
antiKickLabel.Size = UDim2.new(1, 0, 0, 35)
antiKickLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
antiKickLabel.TextColor3 = Color3.fromRGB(50, 220, 50)
antiKickLabel.Text = "🛡️ Anti-Kick / Bypass: ACTIVE"
antiKickLabel.TextSize = 12
antiKickLabel.Font = Enum.Font.GothamBold
antiKickLabel.Parent = miscTabPage

local akCorner = Instance.new("UICorner")
akCorner.CornerRadius = UDim.new(0, 6)
akCorner.Parent = antiKickLabel

-- [[ TAB 3: NEXT UPDATE ]]
local updateInfo = Instance.new("TextLabel")
updateInfo.Size = UDim2.new(1, 0, 0, 80)
updateInfo.BackgroundTransparency = 1
updateInfo.TextColor3 = Color3.fromRGB(200, 200, 220)
updateInfo.Text = "🚀 Coming Soon in Next Update:\n• Auto Farm Best Eggs\n• Advanced Egg ESP & Rarity Colors\n• Custom WalkSpeed & Infinite Jump"
updateInfo.TextSize = 12
updateInfo.Font = Enum.Font.Gotham
updateInfo.TextWrapped = true
updateInfo.TextXAlignment = Enum.TextXAlignment.Left
updateInfo.Parent = nextUpdatePage

-- [[ TOGGLE VISIBILITY FUNCTIONS ]]
local function toggleMenu()
	menuVisible = not menuVisible
	mainFrame.Visible = menuVisible
end

toggleMenuBtn.MouseButton1Click:Connect(toggleMenu)

-- Keybind toggle ('L' key o kaya 'Insert') para magbukas/magsara
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed then
		if input.KeyCode == Enum.KeyCode.L or input.KeyCode == Enum.KeyCode.Insert then
			toggleMenu()
		end
	end
end)
