-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local fastPromptEnabled = false
local menuVisible = true

-- Store original HoldDuration values of ProximityPrompts to restore them later when turned off
local defaultHoldDurations = {}

-- GUI Setup (CoreGui container optimized for Delta and other executors)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealAnEggSimpleMenu"
screenGui.ResetOnSpawn = false
if syn and syn.protect_gui then
    syn.protect_gui(screenGui)
    screenGui.Parent = game.CoreGui
elseif gethui then
    screenGui.Parent = gethui()
else
    screenGui.Parent = game.CoreGui
end

-- Floating Toggle Button (Designed as a stylish circular egg icon)
local toggleMenuBtn = Instance.new("TextButton")
toggleMenuBtn.Name = "ToggleMenuButton"
toggleMenuBtn.Size = UDim2.new(0, 48, 0, 48)
toggleMenuBtn.Position = UDim2.new(0, 20, 0.5, -50)
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggleMenuBtn.TextColor3 = Color3.fromRGB(255, 220, 100)
toggleMenuBtn.Text = "🥚"
toggleMenuBtn.TextSize = 22
toggleMenuBtn.Font = Enum.Font.SourceSansBold
toggleMenuBtn.Active = true
toggleMenuBtn.Draggable = true
toggleMenuBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0) -- Perfect circle shape
toggleCorner.Parent = toggleMenuBtn

-- Subtle glowing border for the toggle button
local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(255, 200, 50)
toggleStroke.Thickness = 2
toggleStroke.Parent = toggleMenuBtn

-- Collapsible Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 110)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -55)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Title Bar
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "STEAL AN EGG"
titleLabel.TextSize = 12
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleLabel

-- Toggle menu visibility when clicking the floating egg icon
toggleMenuBtn.MouseButton1Click:Connect(function()
	menuVisible = not menuVisible
	mainFrame.Visible = menuVisible
end)

-- Feature Button: Fast Prompt / Instant Interaction
local fastPromptBtn = Instance.new("TextButton")
fastPromptBtn.Size = UDim2.new(1, -20, 0, 45)
fastPromptBtn.Position = UDim2.new(0, 10, 0, 48)
fastPromptBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
fastPromptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fastPromptBtn.Text = "Fast Prompt: OFF"
fastPromptBtn.TextSize = 13
fastPromptBtn.Font = Enum.Font.SourceSansBold
fastPromptBtn.Parent = mainFrame

local fpCorner = Instance.new("UICorner")
fpCorner.CornerRadius = UDim.new(0, 6)
fpCorner.Parent = fastPromptBtn

fastPromptBtn.MouseButton1Click:Connect(function()
	fastPromptEnabled = not fastPromptEnabled
	if fastPromptEnabled then
		fastPromptBtn.Text = "Fast Prompt: ON"
		fastPromptBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		
		-- Save and instantly set HoldDuration to 0 for all existing prompts in workspace
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
		fastPromptBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		
		-- Restore original HoldDuration values when disabled
		for obj, originalDuration in pairs(defaultHoldDurations) do
			if obj and obj.Parent then
				obj.HoldDuration = originalDuration
			end
		end
		defaultHoldDurations = {}
	end
end)

-- Listen for newly spawned ProximityPrompts in the game world
ProximityPromptService.PromptAdded:Connect(function(prompt)
	if fastPromptEnabled then
		if not defaultHoldDurations[prompt] then
			defaultHoldDurations[prompt] = prompt.HoldDuration
		end
		prompt.HoldDuration = 0
	end
end)
