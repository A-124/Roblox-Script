--// STEAL AN EGG - SERVER BROWSER + AUTO FARM HUB
--// PlaceId: 107778070777162

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlaceId = 107778070777162

-- Hanapin ang Remote para sa Auto-Farm
local eggRemote = nil
pcall(function()
    eggRemote = ReplicatedStorage:FindFirstChild("RF") and ReplicatedStorage.RF:FindFirstChild("EggWorld") and ReplicatedStorage.RF.EggWorld:FindFirstChild("AskFieldEggCarry")
end)

--// GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "StealAnEggHub"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(420, 540)
Main.Position = UDim2.new(0.5, -210, 0.5, -270)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Main

--// Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.fromOffset(10, 5)
Title.BackgroundTransparency = 1
Title.Text = "STEAL AN EGG [HUB + FARM]"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 20)
Status.Position = UDim2.fromOffset(10, 42)
Status.BackgroundTransparency = 1
Status.Text = "Ready"
Status.TextColor3 = Color3.fromRGB(180, 180, 180)
Status.TextSize = 13
Status.Font = Enum.Font.Gotham
Status.Parent = Main

--// Buttons
local Refresh = Instance.new("TextButton")
Refresh.Size = UDim2.fromOffset(125, 32)
Refresh.Position = UDim2.fromOffset(10, 68)
Refresh.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
Refresh.Text = "REFRESH"
Refresh.TextColor3 = Color3.new(1, 1, 1)
Refresh.TextSize = 13
Refresh.Font = Enum.Font.GothamBold
Refresh.Parent = Main
Instance.new("UICorner", Refresh).CornerRadius = UDim.new(0, 7)

local AutoHop = Instance.new("TextButton")
AutoHop.Size = UDim2.fromOffset(125, 32)
AutoHop.Position = UDim2.fromOffset(145, 68)
AutoHop.BackgroundColor3 = Color3.fromRGB(50, 170, 90)
AutoHop.Text = "AUTO HOP: OFF"
AutoHop.TextColor3 = Color3.new(1, 1, 1)
AutoHop.TextSize = 13
AutoHop.Font = Enum.Font.GothamBold
AutoHop.Parent = Main
Instance.new("UICorner", AutoHop).CornerRadius = UDim.new(0, 7)

-- Bagong Button para sa Auto-Farm Toggle
local AutoFarmBtn = Instance.new("TextButton")
AutoFarmBtn.Size = UDim2.fromOffset(120, 32)
AutoFarmBtn.Position = UDim2.fromOffset(280, 68)
AutoFarmBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
AutoFarmBtn.Text = "AUTO-FARM: ON"
AutoFarmBtn.TextColor3 = Color3.new(1, 1, 1)
AutoFarmBtn.TextSize = 13
AutoFarmBtn.Font = Enum.Font.GothamBold
AutoFarmBtn.Parent = Main
Instance.new("UICorner", AutoFarmBtn).CornerRadius = UDim.new(0, 7)

--// Server list
local List = Instance.new("ScrollingFrame")
List.Size = UDim2.new(1, -20, 1, -165)
List.Position = UDim2.fromOffset(10, 110)
List.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
List.BorderSizePixel = 0
List.ScrollBarThickness = 5
List.CanvasSize = UDim2.new()
List.Parent = Main
Instance.new("UICorner", List).CornerRadius = UDim.new(0, 7)

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 6)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Parent = List

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 8)
Padding.Parent = List

--// Make server row
local function AddServer(server)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -16, 0, 50)
    Row.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    Row.BorderSizePixel = 0
    Row.Parent = List
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 7)

    local PlayersText = Instance.new("TextLabel")
    PlayersText.Size = UDim2.new(1, -100, 1, 0)
    PlayersText.Position = UDim2.fromOffset(10, 0)
    PlayersText.BackgroundTransparency = 1
    PlayersText.TextXAlignment = Enum.TextXAlignment.Left
    PlayersText.Text = "👤  " .. server.playing .. "/" .. server.maxPlayers
    PlayersText.TextColor3 = Color3.new(1, 1, 1)
    PlayersText.TextSize = 15
    PlayersText.Font = Enum.Font.GothamMedium
    PlayersText.Parent = Row

    local Join = Instance.new("TextButton")
    Join.Size = UDim2.fromOffset(75, 30)
    Join.Position = UDim2.new(1, -85, 0.5, -15)
    Join.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
    Join.Text = "JOIN"
    Join.TextColor3 = Color3.new(1, 1, 1)
    Join.TextSize = 12
    Join.Font = Enum.Font.GothamBold
    Join.Parent = Row
    Instance.new("UICorner", Join).CornerRadius = UDim.new(0, 6)

    Join.MouseButton1Click:Connect(function()
        Status.Text = "Joining server..."
        TeleportService:TeleportToPlaceInstance(PlaceId, server.id, Player)
    end)
end

--// Clear list
local function ClearList()
    for _, child in ipairs(List:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

--// Scan servers
local function ScanServers()
    ClearList()
    Status.Text = "Scanning servers..."

    local cursor = nil
    local found = 0

    repeat
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor then
            url = url .. "&cursor=" .. HttpService:UrlEncode(cursor)
        end

        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if not success then
            Status.Text = "Failed to scan. Retrying..."
            task.wait(2)
            continue
        end

        for _, server in ipairs(result.data or {}) do
            if server.id ~= game.JobId and server.playing <= 1 and server.playing < server.maxPlayers then
                found += 1
                AddServer(server)
                Status.Text = "Found " .. found .. " server(s)"
            end
        end

        cursor = result.nextPageCursor
        task.wait(0.1)
    until not cursor

    List.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 15)
    if found == 0 then
        Status.Text = "No 0-1 player servers found"
    else
        Status.Text = "Found " .. found .. " server(s)"
    end
end

Refresh.MouseButton1Click:Connect(function()
    ScanServers()
end)

--// Auto Hop Toggle
local Auto = false
AutoHop.MouseButton1Click:Connect(function()
    Auto = not Auto
    if Auto then
        AutoHop.Text = "AUTO HOP: ON"
        AutoHop.BackgroundColor3 = Color3.fromRGB(200, 70, 70)

        task.spawn(function()
            while Auto do
                Status.Text = "Looking for server..."
                local cursor = nil
                local joined = false

                repeat
                    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                    if cursor then
                        url = url .. "&cursor=" .. HttpService:UrlEncode(cursor)
                    end

                    local success, result = pcall(function()
                        return HttpService:JSONDecode(game:HttpGet(url))
                    end)

                    if success then
                        for _, server in ipairs(result.data or {}) do
                            if server.id ~= game.JobId and server.playing <= 1 and server.playing < server.maxPlayers then
                                Status.Text = "Joining " .. server.playing .. "/" .. server.maxPlayers
                                joined = true
                                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, Player)
                                break
                            end
                        end
                        cursor = result.nextPageCursor
                    else
                        task.wait(2)
                    end

                    if joined then break end
                    task.wait(0.2)
                until not cursor

                if not joined then
                    Status.Text = "Rescanning servers..."
                    task.wait(3)
                end
            end
        end)
    else
        AutoHop.Text = "AUTO HOP: OFF"
        AutoHop.BackgroundColor3 = Color3.fromRGB(50, 170, 90)
        Status.Text = "Auto Hop stopped"
    end
end)

--// Auto Farm Loop (Kasama na rito ang natuklasan nating Remote)
local AutoFarm = true
AutoFarmBtn.MouseButton1Click:Connect(function()
    AutoFarm = not AutoFarm
    AutoFarmBtn.Text = AutoFarm and "AUTO-FARM: ON" or "AUTO-FARM: OFF"
    AutoFarmBtn.BackgroundColor3 = AutoFarm and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
end)

task.spawn(function()
    while true do
        if AutoFarm and eggRemote then
            pcall(function()
                eggRemote:InvokeServer()
            end)
        end
        task.wait(1)
    end
end)

--// Initial scan
task.spawn(function()
    ScanServers()
end)
