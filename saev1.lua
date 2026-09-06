--!nonstrict
--[[h
    SyncHub Lite Pro - UI & Custom Features for Steal an Egg
--]]

local Players          = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local RunService       = game:GetService("RunService")
local Lighting           = game:GetService("Lighting")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")

local lp = Players.LocalPlayer
local State = {
    noclip = false,
    autoSteal = false,
    selectedRarities = {},
}

-- UI Framework Setup (Inlined minimalist UI for Delta / Mobile)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SyncHubLiteUI"
screenGui.ResetOnSpawn = false
if syn and syn.protect_gui then
    syn.protect_gui(screenGui)
    screenGui.Parent = game.CoreGui
elseif gethui then
    screenGui.Parent = gethui()
else
    screenGui.Parent = game.CoreGui
end

-- Main Window Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 380)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 19, 24)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(44, 47, 57)
stroke.Thickness = 1.5
stroke.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 30, 37)
titleBar.TextColor3 = Color3.fromRGB(236, 238, 243)
titleBar.Text = "  SyncHub Lite - Steal an Egg"
titleBar.TextSize = 14
titleBar.Font = Enum.Font.GothamBold
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

-- Scrolling Container for Options
local scrollContainer = Instance.new("ScrollingFrame")
scrollContainer.Size = UDim2.new(1, -20, 1, -55)
scrollContainer.Position = UDim2.new(0, 10, 0, 48)
scrollContainer.BackgroundTransparency = 1
scrollContainer.CanvasSize = UDim2.new(0, 0, 0, 500)
scrollContainer.ScrollBarThickness = 4
scrollContainer.Parent = mainFrame

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 8)
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Parent = scrollContainer

-- Helper function to create toggles in UI
local function createToggle(name, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(33, 35, 43)
    btn.TextColor3 = Color3.fromRGB(236, 238, 243)
    btn.Text = "  " .. name .. ": " .. (defaultState and "ON" or "OFF")
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = scrollContainer
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = "  " .. name .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(88, 214, 141) or Color3.fromRGB(33, 35, 43)
        btn.TextColor3 = state and Color3.fromRGB(18, 19, 24) or Color3.fromRGB(236, 238, 243)
        callback(state)
    end)
end

-- =========================================================================
-- IMPLEMENTING SELECTED FEATURES INTO UI
-- =========================================================================

-- 1. Performance Boosters: Extreme FPS
createToggle("Extreme FPS Mode", false, function(on)
    if on then
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 1e6
        end)
        for _, inst in workspace:GetDescendants() do
            if inst:IsA("BasePart") then
                pcall(function()
                    inst.Material = Enum.Material.SmoothPlastic
                    inst.CastShadow = false
                end)
            end
        end
    end
end)

-- 2. Movement Hacks: Noclip
createToggle("Noclip", false, function(on)
    State.noclip = on
    if on then
        State.noclipConn = RunService.Stepped:Connect(function()
            local c = lp.Character
            if c then
                for _, part in c:GetDescendants() do
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

-- 3. Auto Steal Toggle
createToggle("Auto Steal Eggs", false, function(on)
    State.autoSteal = on
end)

-- Basic Auto Steal Loop Handler
task.spawn(function()
    while true do
        task.wait(1)
        if State.autoSteal then
            pcall(function()
                local char = lp.Character
                local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
                if root then
                    for _, d in workspace:GetDescendants() do
                        if d:IsA("Model") and string.find(string.lower(d.Name), "egg", 1, true) then
                            if not string.find(d:GetFullName(), lp.Name, 1, true) then
                                local targetPart = d:FindFirstChildWhichIsA("BasePart")
                                if targetPart then
                                    root.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
                                    task.wait(0.5)
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

print("[SyncHub Lite] UI loaded successfully with selected features!")
