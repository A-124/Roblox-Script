--[[
  Steal Egg + Server Hop
  Coded by: azi_.x (Safe Anti-AFK & Default OFF state)
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

-- Lahat naka-OFF sa simula ayon sa gusto mo
local Config = {
	AutoSteal = false,
	EggESP = false,
	OwnerESP = false,
	RarityColors = false,
	NearestOnly = false,
	MaxDistance = 500,
	IgnoreFriends = true,
	PathWalk = false,
	InstantTP = false,
	ReturnBase = false,
	SpeedAssist = false,
	WalkSpeed = 24,
	HumanizeDelay = 0.35,
	StopOnFull = false,
	Panic = false,
	ShowStatus = true,
	ArrowNearest = false,
	ServerHopLowest = false,
	AntiAFK = true, -- Ligtas na Anti-AFK para iwas-kick
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

-- ========== SAFE ANTI-AFK (Iwas Anti-Cheat Detection) ==========
task.spawn(function()
	while task.wait(60) do -- Mas matagal na interval para hindi kahina-hinala sa server
		if Config.AntiAFK then
			pcall(function()
				-- Gumagamit ng simpleng camera nudge sa halip na agresibong pagbago ng Humanoid state
				local cam = workspace.CurrentCamera
				if cam then
					cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(0.01), 0)
					task.wait(0.05)
					cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(-0.01), 0)
				end
			end)
		end
	end
end)

local function httpGet(url)
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
	local servers = getServersSorted()
	if #servers > 0 then
		notify("Server Hop", "Lumilipat sa mas tahimik na server...")
		TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[1].id, player)
	else
		notify("Server Hop", "Walang nahanap na ibang server.")
	end
end

notify("Loaded", "Safe script executed. Lahat ng features ay naka-OFF.")
