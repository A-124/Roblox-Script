--[[
  Steal Egg + Server Hop
  Coded by: azi_.x
  Mobile-friendly | Delta-safe
]]

if not game:IsLoaded() then pcall(function() game.Loaded:Wait() end) end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
while not player do task.wait() player = Players.LocalPlayer end
local PlayerGui = player:WaitForChild("PlayerGui", 10)
local camera = workspace.CurrentCamera

local Config = {
	AutoSteal = false,
	EggESP = true,
	OwnerESP = true,
	RarityColors = true,
	NearestOnly = false,
	MaxDistance = 500,
	IgnoreFriends = true,
	PathWalk = false,
	InstantTP = true,
	ReturnBase = false,
	SpeedAssist = false,
	WalkSpeed = 24,
	HumanizeDelay = 0.35,
	StopOnFull = false,
	Panic = false,
	ShowStatus = true,
	ArrowNearest = true,
	ServerHopLowest = true, -- used by hop logic
}

local BaseCF = nil
local StatusText = "Idle"
local ESPFolder = nil
local Running = true

local function notify(title, text)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = tostring(title),
			Text = tostring(text),
			Duration = 3,
		})
	end)
end

local function httpGet(url)
	local fns = {}
	pcall(function() if game.HttpGet then return end end)
	local ok, res = pcall(function()
		return game:HttpGet(url)
	end)
	if ok and res then return res end
	local req = (syn and syn.request) or (http and http.request) or http_request or request
	if req then
		local ok2, r = pcall(function()
			return req({ Url = url, Method = "GET" })
		end)
		if ok2 and type(r) == "table" then
			return r.Body or r.body
		end
	end
	return nil
end

-- ========== SERVER HOP ==========
local function getServersSorted()
	local placeId = game.PlaceId
	local servers = {}
	local cursor = ""
	for _ = 1, 5 do
		local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s"):format(
			placeId,
			cursor ~= "" and ("&cursor=" .. cursor) or ""
		)
		local body = httpGet(url)
		if not body then break end
		local ok, data = pcall(function()
			return HttpService:JSONDecode(body)
		end)
		if not ok or type(data) ~= "table" or type(data.data) ~= "table" then break end
		for _, s in ipairs(data.data) do
			if s.id and s.playing and s.maxPlayers and s.id ~= game.JobId then
				table.insert(servers, {
					id = s.id,
					playing = s.playing or 0,
					max = s.maxPlayers or 0,
				})
			end
		end
		cursor = data.nextPageCursor
		if not cursor or cursor == "" then break end
	end
	table.sort(servers, function(a, b)
		return a.playing < b.playing
	end)
	return servers
end

local function hopLowest()
	StatusText = "Finding lowest server..."
	notify("Server Hop", "Searching lowest player servers...")
	local servers = getServersSorted()
	if #servers == 0 then
		StatusText = "No servers found"
		notify("Server Hop", "No servers found (HTTP blocked?)")
		return
	end
	local best = servers[1]
	StatusText = ("Hopping to %d players..."):format(best.playing)
	notify("Server Hop", ("Joining server with %d players"):format(best.playing))
	task.wait(0.4)
	pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, best.id, player)
	end)
end

local function hopOnePlayerOnly()
	StatusText = "Looking for 1-player servers..."
	notify("Server Hop", "Looking for 1-player servers only...")
	local servers = getServersSorted()
	local one = nil
	for _, s in ipairs(servers) do
		if s.playing == 1 then
			one = s
			break
		end
	end
	if not one then
		StatusText = "No 1-player server"
		notify("Server Hop", "No 1-player server found. Try Lowest instead.")
		return
	end
	StatusText = "Hopping to 1-player..."
	notify("Server Hop", "Joining 1-player server")
	task.wait(0.4)
	pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, one.id, player)
	end)
end

-- ========== EGG DETECTION (flexible) ==========
local EGG_NAME_PATTERNS = {
	"egg", "eggmodel", "stealeg", "stole", "petegg", "drop", "lootegg",
}

local function nameLooksLikeEgg(name)
	name = string.lower(tostring(name or ""))
	for _, p in ipairs(EGG_NAME_PATTERNS) do
		if string.find(name, p, 1, true) then return true end
	end
	return false
end

local function getPart(obj)
	if not obj then return nil end
	if obj:IsA("BasePart") then return obj end
	if obj:IsA("Model") then
		return obj.PrimaryPart
			or obj:FindFirstChild("Handle")
			or obj:FindFirstChildWhichIsA("BasePart", true)
	end
	return obj:FindFirstChildWhichIsA("BasePart")
end

local function getOwnerName(egg)
	local attrs = { "Owner", "OwnerName", "Player", "OwnerId", "UserId" }
	for _, a in ipairs(attrs) do
		local v = egg:GetAttribute(a)
		if v ~= nil then return tostring(v) end
	end
	local sv = egg:FindFirstChild("Owner") or egg:FindFirstChild("OwnerName")
	if sv and sv:IsA("StringValue") then return sv.Value end
	if sv and sv:IsA("ObjectValue") and sv.Value then
		return tostring(sv.Value.Name or sv.Value)
	end
	local parent = egg.Parent
	if parent and Players:FindFirstChild(parent.Name) then
		return parent.Name
	end
	return nil
end

local function isFriendOwned(egg)
	if not Config.IgnoreFriends then return false end
	local owner = getOwnerName(egg)
	if not owner then return false end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and (plr.Name == owner or plr.DisplayName == owner or tostring(plr.UserId) == owner) then
			local ok, friend = pcall(function()
				return player:IsFriendsWith(plr.UserId)
			end)
			if ok and friend then return true end
		end
	end
	return false
end

local function findEggs()
	local list = {}
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local function consider(obj)
		if not obj or not obj.Parent then return end
		if not (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Folder")) then return end
		if not nameLooksLikeEgg(obj.Name) and not nameLooksLikeEgg(obj.Parent and obj.Parent.Name) then
			-- also accept ProximityPrompt parents often used for steals
			local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
			if not prompt then return end
			local pt = string.lower(prompt.ActionText .. " " .. prompt.ObjectText)
			if not (string.find(pt, "steal") or string.find(pt, "egg") or string.find(pt, "take") or string.find(pt, "grab")) then
				return
			end
		end
		local part = getPart(obj)
		if not part then return end
		local dist = root and (part.Position - root.Position).Magnitude or 0
		if Config.MaxDistance > 0 and root and dist > Config.MaxDistance then return end
		if isFriendOwned(obj) then return end
		table.insert(list, { obj = obj, part = part, dist = dist, owner = getOwnerName(obj) })
	end

	pcall(function()
		for _, obj in ipairs(workspace:GetDescendants()) do
			if nameLooksLikeEgg(obj.Name) then
				consider(obj)
			elseif obj:IsA("ProximityPrompt") then
				consider(obj.Parent)
			end
		end
	end)

	table.sort(list, function(a, b) return a.dist < b.dist end)
	if Config.NearestOnly and #list > 1 then
		return { list[1] }
	end
	return list
end

local function fireSteal(eggEntry)
	local obj = eggEntry.obj
	local part = eggEntry.part
	-- ProximityPrompt
	local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
		or (part and part:FindFirstChildWhichIsA("ProximityPrompt", true))
	if prompt then
		pcall(function()
			if fireproximityprompt then
				fireproximityprompt(prompt)
			else
				prompt:InputHoldBegin()
				task.wait(prompt.HoldDuration or 0.1)
				prompt:InputHoldEnd()
			end
		end)
		return true
	end
	-- ClickDetector
	local cd = obj:FindFirstChildWhichIsA("ClickDetector", true)
	if cd then
		pcall(function()
			if fireclickdetector then
				fireclickdetector(cd)
			end
		end)
		return true
	end
	-- TouchInterest
	if part then
		pcall(function()
			if firetouchinterest and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				local root = player.Character.HumanoidRootPart
				firetouchinterest(root, part, 0)
				task.wait(0.05)
				firetouchinterest(root, part, 1)
			end
		end)
	end
	-- Common remote names (best-effort)
	pcall(function()
		for _, rem in ipairs(game:GetDescendants()) do
			if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
				local n = string.lower(rem.Name)
				if string.find(n, "steal") or string.find(n, "takeegg") or string.find(n, "grabegg") or string.find(n, "collectegg") then
					pcall(function()
						if rem:IsA("RemoteEvent") then
							rem:FireServer(obj)
							rem:FireServer(obj.Name)
							rem:FireServer()
						end
					end)
				end
			end
		end
	end)
	return true
end

local function tpTo(part)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root or not part then return end
	if Config.InstantTP then
		root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
	elseif Config.PathWalk then
		local hum = player.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:MoveTo(part.Position)
		end
	else
		root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
	end
end

local function saveBase()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root then
		BaseCF = root.CFrame
		notify("Base", "Saved return position")
	end
end

local function returnBase()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root and BaseCF then
		root.CFrame = BaseCF
	end
end

-- ========== ESP ==========
local function clearESP()
	if ESPFolder then
		ESPFolder:ClearAllChildren()
	end
end

local function ensureESPFolder()
	if ESPFolder and ESPFolder.Parent then return end
	ESPFolder = Instance.new("Folder")
	ESPFolder.Name = "AziEggESP"
	ESPFolder.Parent = PlayerGui
end

local function drawESP(eggs)
	ensureESPFolder()
	clearESP()
	if not Config.EggESP then return end
	for _, e in ipairs(eggs) do
		local part = e.part
		if not part then continue end
		local bill = Instance.new("BillboardGui")
		bill.Size = UDim2.new(0, 120, 0, 40)
		bill.AlwaysOnTop = true
		bill.Adornee = part
		bill.Parent = ESPFolder
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, 0, 1, 0)
		lbl.BackgroundTransparency = 0.35
		lbl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 11
		lbl.TextWrapped = true
		local text = ("Egg | %.0fm"):format(e.dist)
		if Config.OwnerESP and e.owner then
			text = text .. "\n" .. tostring(e.owner)
		end
		lbl.Text = text
		lbl.Parent = bill
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(255, 255, 255)
		stroke.Thickness = 1
		stroke.Parent = lbl
	end
end

-- ========== UI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "AziStealEgg"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 200
pcall(function()
	if gethui then gui.Parent = gethui() else gui.Parent = PlayerGui end
end)
if not gui.Parent then gui.Parent = PlayerGui end

local isMobile = UIS.TouchEnabled
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, isMobile and 260 or 280, 0, isMobile and 380 or 420)
Main.Position = UDim2.new(0.5, isMobile and -130 or -140, 0.5, isMobile and -190 or -210)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BorderSizePixel = 1
Main.BorderColor3 = Color3.fromRGB(255, 255, 255)
Main.Active = true
Main.Parent = gui

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 30)
Top.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Top.BorderSizePixel = 0
Top.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -36, 1, 0)
Title.Position = UDim2.new(0, 8, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Steal Egg | azi_.x"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 28, 0, 28)
Close.Position = UDim2.new(1, -30, 0, 1)
Close.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 12
Close.Parent = Top
Close.MouseButton1Click:Connect(function()
	Running = false
	clearESP()
	gui:Destroy()
end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -8, 1, -36)
Scroll.Position = UDim2.new(0, 4, 0, 32)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 900)
Scroll.Parent = Main

local StatusLbl = Instance.new("TextLabel")
StatusLbl.Size = UDim2.new(1, -8, 0, 22)
StatusLbl.Position = UDim2.new(0, 4, 0, 4)
StatusLbl.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
StatusLbl.Text = "Status: Idle"
StatusLbl.TextColor3 = Color3.fromRGB(180, 255, 180)
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.TextSize = 11
StatusLbl.Parent = Scroll

local y = 30
local function addToggle(text, default, cb)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -8, 0, 28)
	b.Position = UDim2.new(0, 4, 0, y)
	b.BackgroundColor3 = default and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(30, 30, 30)
	b.Text = text .. ": " .. (default and "ON" or "OFF")
	b.TextColor3 = default and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.Parent = Scroll
	local state = default
	b.MouseButton1Click:Connect(function()
		state = not state
		b.Text = text .. ": " .. (state and "ON" or "OFF")
		b.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(30, 30, 30)
		b.TextColor3 = state and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
		cb(state)
	end)
	y = y + 32
end

local function addBtn(text, cb)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -8, 0, 30)
	b.Position = UDim2.new(0, 4, 0, y)
	b.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	b.BorderSizePixel = 1
	b.BorderColor3 = Color3.fromRGB(255, 255, 255)
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.Parent = Scroll
	b.MouseButton1Click:Connect(cb)
	y = y + 34
end

local function addSlider(label, minV, maxV, default, cb)
	local lab = Instance.new("TextLabel")
	lab.Size = UDim2.new(1, -8, 0, 16)
	lab.Position = UDim2.new(0, 4, 0, y)
	lab.BackgroundTransparency = 1
	lab.Text = label .. ": " .. tostring(default)
	lab.TextColor3 = Color3.fromRGB(220, 220, 220)
	lab.Font = Enum.Font.Gotham
	lab.TextSize = 11
	lab.TextXAlignment = Enum.TextXAlignment.Left
	lab.Parent = Scroll
	y = y + 18
	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -8, 0, 12)
	track.Position = UDim2.new(0, 4, 0, y)
	track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	track.Parent = Scroll
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - minV) / math.max(maxV - minV, 1), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	fill.Parent = track
	local dragging = false
	local function setA(a)
		a = math.clamp(a, 0, 1)
		local v = math.floor(minV + (maxV - minV) * a + 0.5)
		fill.Size = UDim2.new((v - minV) / math.max(maxV - minV, 1), 0, 1, 0)
		lab.Text = label .. ": " .. tostring(v)
		cb(v)
	end
	track.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setA((i.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1))
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			setA((i.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1))
		end
	end)
	y = y + 20
end

addBtn("Hop → Lowest players", hopLowest)
addBtn("Hop → 1 player only", hopOnePlayerOnly)
addBtn("Save base (return pos)", saveBase)
addBtn("Return to base now", returnBase)
addBtn("Panic STOP all", function()
	Config.AutoSteal = false
	Config.Panic = true
	StatusText = "PANIC"
	notify("Panic", "Stopped")
	task.delay(1, function() Config.Panic = false end)
end)

addToggle("Auto Steal", false, function(s) Config.AutoSteal = s end)
addToggle("Egg ESP", true, function(s) Config.EggESP = s end)
addToggle("Owner ESP", true, function(s) Config.OwnerESP = s end)
addToggle("Nearest only", false, function(s) Config.NearestOnly = s end)
addToggle("Ignore friends' eggs", true, function(s) Config.IgnoreFriends = s end)
addToggle("Instant TP to egg", true, function(s) Config.InstantTP = s end)
addToggle("Return base after steal", false, function(s) Config.ReturnBase = s end)
addToggle("Speed assist", false, function(s) Config.SpeedAssist = s end)

addSlider("Max distance", 50, 2000, 500, function(v) Config.MaxDistance = v end)
addSlider("Humanize delay (x0.01s)", 10, 150, 35, function(v) Config.HumanizeDelay = v / 100 end)
addSlider("Speed when assist", 16, 80, 24, function(v) Config.WalkSpeed = v end)

Scroll.CanvasSize = UDim2.new(0, 0, 0, y + 20)

-- Drag
do
	local dragging, dragStart, startPos
	Top.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = i.Position
			startPos = Main.Position
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - dragStart
			Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

-- ========== MAIN LOOP ==========
task.spawn(function()
	while Running and gui.Parent do
		local ok, err = pcall(function()
			if Config.ShowStatus then
				StatusLbl.Text = "Status: " .. StatusText
			end
			if Config.SpeedAssist and player.Character then
				local h = player.Character:FindFirstChildOfClass("Humanoid")
				if h then h.WalkSpeed = Config.WalkSpeed end
			end
			local eggs = findEggs()
			drawESP(eggs)
			if #eggs > 0 then
				StatusText = ("Eggs: %d | Nearest: %.0fm"):format(#eggs, eggs[1].dist)
			else
				if not Config.AutoSteal then StatusText = "No eggs found" end
			end
			if Config.AutoSteal and not Config.Panic and #eggs > 0 then
				local target = eggs[1]
				StatusText = ("Stealing (%.0fm)..."):format(target.dist)
				tpTo(target.part)
				task.wait(0.15)
				fireSteal(target)
				task.wait(Config.HumanizeDelay or 0.35)
				if Config.ReturnBase then
					returnBase()
					task.wait(0.2)
				end
			end
		end)
		if not ok then
			StatusText = "Err"
			warn("[AziSteal]", err)
		end
		task.wait(0.25)
	end
end)

-- light anti-idle while auto
task.spawn(function()
	while Running and gui.Parent do
		task.wait(45)
		if Config.AutoSteal then
			pcall(function()
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new())
			end)
		end
	end
end)

notify("Steal Egg", "Loaded — azi_.x")
print("[azi_.x] Steal Egg loaded")
