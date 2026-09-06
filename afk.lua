--// STEAL AN EGG - SERVER BROWSER & AUTO HOP [PRO UI]
--// PlaceId: 107778070777162

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local PlaceId = 107778070777162

-- Alisin ang lumang GUI kung meron man para iwas duplicate
if CoreGui:FindFirstChild("StealAnEggServerBrowser") then
    CoreGui.StealAnEggServerBrowser:Destroy()
end

--// GUI Setup
local Gui = Instance.new("ScreenGui")
Gui.Name = "StealAnEggServerBrowser"
Gui.ResetOnSpawn = false
Gui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(420, 500)
Main.Position = UDim2.new(0.5, -210, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(45, 45, 55)
Stroke.Thickness = 1.5
Stroke.Parent = Main

--// Top Bar / Header
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundTransparency = 1
TopBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.fromOffset(15, 0)
Title.BackgroundTransparency = 1
Title.Text = "🥚 STEAL AN EGG: SERVER FINDER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Minimize / Toggle Button (-)
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.fromOffset(32, 32)
MinBtn.Position = UDim2.new(1, -80, 0.5, -16)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

-- Close Button (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(32, 32)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

--// Container para sa Controls at List
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, 0, 1, -45)
Container.Position = UDim2.fromOffset(0, 45)
Container.BackgroundTransparency = 1
Container.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -30, 0, 20)
Status.Position = UDim2.fromOffset(15, 5)
Status.BackgroundTransparency = 1
Status.Text = "Status: Ready"
Status.TextColor3 = Color3.fromRGB(150, 150, 160)
Status.TextSize = 12
Status.Font = Enum.Font.Gotham
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Container

--// Buttons
local Refresh = Instance.new("TextButton")
Refresh.Size = UDim2.fromOffset(190, 36)
Refresh.Position = UDim2.fromOffset(15, 32)
Refresh.BackgroundColor3 = Color3.fromRGB(40, 110, 210)
Refresh.Text = "🔄 REFRESH"
Refresh.TextColor3 = Color3.fromRGB(255, 255, 255)
Refresh.TextSize = 13
Refresh.Font = Enum.Font.GothamBold
Refresh.Parent = Container
Instance.new("UICorner", Refresh).CornerRadius = UDim.new(0, 8)

local AutoHop = Instance.new("TextButton")
AutoHop.Size = UDim2.fromOffset(190, 36)
AutoHop.Position = UDim2.fromOffset(215, 32)
AutoHop.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
AutoHop.Text = "⚡ AUTO HOP: OFF"
AutoHop.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoHop.TextSize = 13
AutoHop.Font = Enum.Font.GothamBold
AutoHop.Parent = Container
Instance.new("UICorner", AutoHop).CornerRadius = UDim.new(0, 8)

--// Server list
local List = Instance.new("ScrollingFrame")
List.Size = UDim2.new(1, -30, 1, -85)
List.Position = UDim2.fromOffset(15, 75)
List.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
List.BorderSizePixel = 0
List.ScrollBarThickness = 4
List.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 75)
List.CanvasSize = UDim2.new()
List.Parent = Container

Instance.new("UICorner", List).CornerRadius = UDim.new(0, 8)

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 6)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Parent = List

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 8)
Padding.Parent = List

-- Floating Open Button (Lilitaw kapag naka-minimize o close para madaling mabuksan ulit sa mobile)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.fromOffset(50, 50)
OpenBtn.Position = UDim2.new(0, 15, 0.5, -25)
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
OpenBtn.Text = "🥚"
OpenBtn.TextSize = 22
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.Parent = Gui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(70, 70, 90)

-- Minimize & Close Logic
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Container.Visible = not minimized
    Main.Size = minimized and UDim2.fromOffset(420, 45) or UDim2.fromOffset(420, 500)
    MinBtn.Text = minimized and "+" or "-"
end)

CloseBtn.MouseButton1Click:Connect(function()
    Gui.Enabled = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    Gui.Enabled = true
    OpenBtn.Visible = false
end)

--// Make server row
local function AddServer(server)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -14, 0, 48)
    Row.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    Row.BorderSizePixel = 0
    Row.Parent = List

    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)

    local PlayersText = Instance.new("TextLabel")
    PlayersText.Size = UDim2.new(1, -100, 1, 0)
    PlayersText.Position = UDim2.fromOffset(12, 0)
    PlayersText.BackgroundTransparency = 1
    PlayersText.TextXAlignment = Enum.TextXAlignment.Left
    PlayersText.Text = "👤  Players: " .. server.playing .. "/" .. server.maxPlayers
    PlayersText.TextColor3 = Color3.fromRGB(230, 230, 230)
    PlayersText.TextSize = 14
    PlayersText.Font = Enum.Font.GothamMedium
    PlayersText.Parent = Row

    local Join = Instance.new("TextButton")
    Join.Size = UDim2.fromOffset(75, 30)
    Join.Position = UDim2.new(1, -83, 0.5, -15)
    Join.BackgroundColor3 = Color3.fromRGB(40, 110, 210)
    Join.Text = "JOIN"
    Join.TextColor3 = Color3.fromRGB(255, 255, 255)
    Join.TextSize = 12
    Join.Font = Enum.Font.GothamBold
    Join.Parent = Row

    Instance.new("UICorner", Join).CornerRadius = UDim.new(0, 6)

    Join.MouseButton1Click:Connect(function()
        Status.Text = "Status: Joining server..."
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
    Status.Text = "Status: Scanning servers (0-1 players)..."

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
            Status.Text = "Status: Failed to scan. Retrying..."
            task.wait(2)
            continue
        end

        for _, server in ipairs(result.data or {}) do
            if server.id ~= game.JobId and server.playing <= 1 and server.playing < server.maxPlayers then
                found += 1
                AddServer(server)
                Status.Text = "Status: Found " .. found .. " server(s)"
            end
        end

        cursor = result.nextPageCursor
        task.wait(0.1)
    until not cursor

    List.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 15)

    if found == 0 then
        Status.Text = "Status: No 0-1 player servers found"
    else
        Status.Text = "Status: Found " .. found .. " server(s)"
    end

    return found
end

--// Refresh
Refresh.MouseButton1Click:Connect(function()
    Refresh.Active = false
    ScanServers()
    Refresh.Active = true
end)

--// Auto Hop
local Auto = false

AutoHop.MouseButton1Click:Connect(function()
    Auto = not Auto

    if Auto then
        AutoHop.Text = "⚡ AUTO HOP: ON"
        AutoHop.BackgroundColor3 = Color3.fromRGB(180, 50, 50)

        task.spawn(function()
            while Auto do
                Status.Text = "Status: Looking for empty server..."
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
                                Status.Text = "Status: Joining " .. server.playing .. "/" .. server.maxPlayers
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
                    Status.Text = "Status: No server found. Rescanning..."
                    task.wait(3)
                end
            end
        end)

    else
        AutoHop.Text = "⚡ AUTO HOP: OFF"
        AutoHop.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
        Status.Text = "Status: Auto Hop stopped"
    end
end)

--// Initial scan
task.spawn(function()
    ScanServers()
end)
