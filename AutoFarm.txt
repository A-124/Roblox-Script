loadstring(game:HttpGet("https://scripts.wabisabi.mom/wabi-sabi-ui-lib.lua"))()
local lib = WabiSabi

local plrs = game:GetService("Players")
local ws   = game:GetService("Workspace")
local rs   = game:GetService("RunService")
local uis  = game:GetService("UserInputService")

while not plrs.LocalPlayer do task.wait(0.1) end
local lp = plrs.LocalPlayer

local localPlot        = nil
local health_offset    = 0x190
local fr               = false  
local pe               = true   
local re               = true   
local tmf              = false  
local ft               = nil    
local gsz              = false  
local ia               = false  

local fb   = CFrame.new(541.99, 70.43, -368.12)   
local mfp  = CFrame.new(544.35, 70.43, -413.09)   
local SAFE = Vector3.new(528.04, 70.79, -364.74)   

local ragdollState  = false
local storedJoints  = {}
local camera        = workspace.CurrentCamera

local State = {
    AutoFarm = false,
    MaxSpeed = 800,
    MinSpeed = 50,
    DecelDistance = 40.0,
    SafeFloorY = 70.0,
    CruiseAltitude = 150.0,
    SeparationLineX = 0.0,
    WallClearanceY = 160.0
}

local AntiStuck = {
    BlockedTime = 0,
    LastPos = Vector3.zero
}

local function eSF(root)
    if not root then return end
    local pos = root.Position
    if pos.Y < State.SafeFloorY then
        root.CFrame = CFrame.new(pos.X, State.SafeFloorY, pos.Z)
        local vel = root.AssemblyLinearVelocity
        if vel.Y < 0 then
            root.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
        end
    end
end

local function gTW(targetPos, options)
    options = options or {}
    local maxSpeed = options.MaxSpeed or State.MaxSpeed
    local minSpeed = options.MinSpeed or State.MinSpeed
    local decelDist = options.DecelDist or State.DecelDistance
    local arrivalRadius = options.ArrivalRadius or 4.5
    local timeout = options.Timeout or 10.0
    local isLanding = options.IsLanding or false

    local startTime = os.clock()
    local lastTick = startTime

    while fr and State.AutoFarm do
        local myChar = lp.Character
        local myHum = myChar and myChar:FindFirstChild("Humanoid")
        local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))

        if not myRoot or not myHum or myHum.Health <= 30 then
            dSR()
            break
        end

        local curPos = myRoot.Position
        local delta = targetPos - curPos
        local dist = delta.Magnitude

        if dist <= arrivalRadius or (os.clock() - startTime) > timeout then
            myRoot.AssemblyLinearVelocity = Vector3.zero
            break
        end

        local now = os.clock()
        local dt = math.clamp(now - lastTick, 0.008, 0.05)
        lastTick = now

        if (curPos - AntiStuck.LastPos).Magnitude < 1.0 then
            AntiStuck.BlockedTime = AntiStuck.BlockedTime + dt
            if AntiStuck.BlockedTime >= 1.2 then
                myRoot.CFrame = CFrame.new(curPos.X, curPos.Y + 20.0, curPos.Z)
                myRoot.AssemblyLinearVelocity = Vector3.new(0, 90, 0)
                AntiStuck.BlockedTime = 0
            end
        else
            AntiStuck.BlockedTime = 0
        end
        AntiStuck.LastPos = curPos

        local currentSpeed = maxSpeed
        if isLanding or dist <= decelDist then
            local alpha = math.clamp(dist / decelDist, 0.0, 1.0)
            currentSpeed = minSpeed + (maxSpeed - minSpeed) * (alpha ^ 0.85)
        end

        local dir = delta.Unit
        local vy = dir.Y * currentSpeed

        if curPos.Y <= (State.SafeFloorY + 1.5) and vy < 0 then
            vy = 0
        end

        myRoot.AssemblyLinearVelocity = Vector3.new(
            dir.X * currentSpeed,
            vy,
            dir.Z * currentSpeed
        )

        task.wait(0.015)
    end
end

local function fSR(targetPos, isLanding)
    local myChar = lp.Character
    local myHum = myChar and myChar:FindFirstChild("Humanoid")
    local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
    if not myRoot or not myHum or myHum.Health <= 30 then
        dSR()
        return
    end

    local cur = myRoot.Position

    local adaptiveY = State.CruiseAltitude
    local xMin = math.min(cur.X, targetPos.X)
    local xMax = math.max(cur.X, targetPos.X)
    if xMin <= (State.SeparationLineX + 8) and xMax >= (State.SeparationLineX - 8) then
        adaptiveY = math.max(adaptiveY, State.WallClearanceY)
    end

    local skyStart = Vector3.new(cur.X, adaptiveY, -364.0)
    gTW(skyStart, { MaxSpeed = 400.0, DecelDist = 20.0, ArrivalRadius = 8.0, Timeout = 2.0 })
    if not State.AutoFarm or not fr then return end

    local skyTarget = Vector3.new(targetPos.X, adaptiveY, targetPos.Z)
    gTW(skyTarget, { MaxSpeed = State.MaxSpeed, DecelDist = State.DecelDistance, ArrivalRadius = 14.0, Timeout = 6.0 })
    if not State.AutoFarm or not fr then return end

    local targetY = math.max(State.SafeFloorY + 0.5, targetPos.Y + 2.0)
    gTW(Vector3.new(targetPos.X, targetY, targetPos.Z), { MaxSpeed = 300.0, MinSpeed = 30.0, DecelDist = 25.0, ArrivalRadius = 5.0, IsLanding = true, Timeout = 2.5 })
end

local zonesData = {
    {minX = 553.42, maxX = 646.49, minZ = -433.38, maxZ = -295.05},
    {minX = 653.01, maxX = 793.51, minZ = -433.38, maxZ = -295.05},
    {minX = 796.48, maxX = 1005.04, minZ = -433.40, maxZ = -295.05},
    {minX = 1008.56, maxX = 1240.12, minZ = -433.38, maxZ = -295.05},
    {minX = 1244.13, maxX = 1564.18, minZ = -433.39, maxZ = -295.05},
    {minX = 1568.33, maxX = 1949.58, minZ = -433.39, maxZ = -295.05},
    {minX = 1953.30, maxX = 2378.73, minZ = -433.38, maxZ = -295.05},
    {minX = 2382.87, maxX = 2884.09, minZ = -433.40, maxZ = -295.05},
    {minX = 2888.03, maxX = 3523.51, minZ = -433.38, maxZ = -295.05},
    {minX = 3527.67, maxX = 4263.53, minZ = -433.38, maxZ = -295.05},
    {minX = 4268.09, maxX = 5123.06, minZ = -433.38, maxZ = -295.05},
}

local zoneNames = {"Forest", "Lake", "Desert", "Jungle", "Snow", "Volcano", "Abyss Ocean", "Prehistoric", "Cosmic", "Cherry Blossom", "Titan Temple"}

local selectedZones = {}
for i = 1, 11 do
    selectedZones[i] = false
end

local function iZ(pos, zoneIdx)
    local z = zonesData[zoneIdx]
    if not z then return false end
    return pos.X >= z.minX and pos.X <= z.maxX and pos.Z >= z.minZ and pos.Z <= z.maxZ
end

local function eR()
    local myChar = lp.Character
    if not myChar or not camera then return end
    storedJoints = {}
    for _, d in ipairs(myChar:GetDescendants()) do
        if d:IsA("Motor6D") and d.Name ~= "RootJoint" and d.Name ~= "Root" then
            table.insert(storedJoints, { joint = d, oldParent = d.Parent })
            d.Parent = camera
        end
    end
    ragdollState = true
end

local function dSR()
    for _, item in ipairs(storedJoints) do
        if item.joint and item.oldParent then
            pcall(function() item.joint.Parent = item.oldParent end)
        end
    end
    storedJoints = {}
    ragdollState = false
end

local function sCV()
    for i = 1, 25 do
        mousescroll(1)
        task.wait(0.02)
    end
    task.wait(0.1)
    mousemoverel(0, 10000)
    task.wait(0.15)
    for i = 1, 8 do
        mousescroll(-1)
        task.wait(0.04)
    end
end

task.spawn(function()
    local plots = ws:WaitForChild("Plots", 30)
    if not plots then return end

    while not lp.Character or not lp.Character:FindFirstChildOfClass("Humanoid") do
        task.wait(0.1)
    end

    local oldChar = lp.Character
    local hum = oldChar:FindFirstChildOfClass("Humanoid")
    if hum and hum.Address then
        memory_write("float", hum.Address + health_offset, -10)
    end

    while lp.Character == oldChar or not lp.Character do task.wait(0.05) end

    local newChar = lp.Character
    local hrp = newChar:WaitForChild("HumanoidRootPart", 10)
    if not hrp then return end

    task.wait(0.6)

    local shortestDist = math.huge
    for _, plot in ipairs(plots:GetChildren()) do
        local spawnPart = plot:FindFirstChild("SpawnLocation") or plot:FindFirstChildWhichIsA("BasePart", true)
        if spawnPart then
            local dist = (hrp.Position - spawnPart.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                localPlot = plot
            end
        end
    end
end)

local w = lib:CreateWindow({
    Title    = "Steal An Egg",
    SubTitle = "AutoFarm",
    Size     = Vector2.new(460, 460),
    Resize   = true,
})

local tb = w:AddTab({ Title = "Farm", Icon = "egg" })

tb:AddDropdown({
    Id = "zones_multidropdown",
    Title = "Zones to Farm",
    Values = zoneNames,
    Multi = true,
    Default = {},
    Callback = function(v)
        for i = 1, 11 do
            selectedZones[i] = false
        end
        if type(v) == "table" then
            for k, val in pairs(v) do
                local zoneName = ""
                local isChecked = true
                
                if type(k) == "string" then
                    zoneName = k
                    isChecked = (val == true)
                elseif type(val) == "string" then
                    zoneName = val
                    isChecked = true
                end
                
                if isChecked and zoneName ~= "" then
                    for idx, name in ipairs(zoneNames) do
                        if name == zoneName then
                            selectedZones[idx] = true
                            break
                        end
                    end
                end
            end
        end
    end
})

local ss = tb:AddSlider({
    Id = "global_tween_speed", Title = "Movement Speed",
    Min = 400, Max = 1250, Default = 800, Rounding = 0, 
    Callback = function(v) State.MaxSpeed = tonumber(v) or 800 end
})

local aft = tb:AddToggle({
    Id = "auto_feed_monster_toggle",
    Title = "Auto Feed Monster",
    Default = false, Callback = function() end
})

local rt = tb:AddToggle({
    Id = "rare_toggle",
    Title = "Farm Rare Eggs",
    Default = false,
    Callback = function(v) re = v end
})

local pt = tb:AddToggle({
    Id = "parasite_toggle",
    Title = "Farm Parasite Eggs",
    Default = false,
    Callback = function(v) pe = v end
})

local tmToggle = tb:AddToggle({
    Id = "treadmill_farm_toggle",
    Title = "Treadmill Farm (When No Eggs)",
    Default = false,
    Callback = function(v) tmf = v end
})

local fastPickupEnabled = false

local function pP(prompt)
    if not prompt then return end
    local addr = prompt.Address
    if not addr then return end
    local curHold = memory_read("float", addr + 0x120)
    if curHold and curHold > 0 then
        memory_write("float", addr + 0x120, 0.0)
    end
    local curDist = memory_read("float", addr + 0x128)
    if curDist and curDist < 18.0 then
        memory_write("float", addr + 0x128, 18.0)
    end
end

local function pAP()
    for _, c in ipairs(workspace:GetChildren()) do
        if c.Name == "SmartPromptPart" then
            for _, p in ipairs(c:GetChildren()) do
                if p.ClassName == "ProximityPrompt" then
                    pcall(pP, p)
                end
            end
        end
    end
end

local fastPickupThread = nil

tb:AddToggle({
    Id = "fast_pickup_toggle",
    Title = "Fast Pick Up",
    Default = false,
    Callback = function(v)
        fastPickupEnabled = v
        if v then
            pAP()
            fastPickupThread = task.spawn(function()
                while fastPickupEnabled do
                    task.wait(2.0)
                    pAP()
                end
            end)
        else
            fastPickupEnabled = false
        end
    end
})

local function gH()
    if fastPickupEnabled then return 0 end
    return 1.3
end

local function gA()
    if not aft then return false end
    if type(aft.Get) == "function" then return aft.Get() end
    return aft.Value == true
end

local function gP()
    local cp = nil
    local md = math.huge
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

    local sl = ws:FindFirstChild("AreaEggSlotsClient")
    if sl then
        for _, s in ipairs(sl:GetChildren()) do
            local pv = s:FindFirstChild("MonsterParasiteVisual")
            if pv then
                local pl = pv:FindFirstChild("Plane")
                if pl and pl:IsA("BasePart") then
                    if hrp then
                        local dst = (hrp.Position - pl.Position).Magnitude
                        if dst < md then
                            md = dst
                            cp = pl
                        end
                    else
                        cp = pl
                        break
                    end
                end
            end
        end
    end

    if not cp then
        for _, obj in ipairs(ws:GetChildren()) do
            local pv = obj:FindFirstChild("MonsterParasiteVisual", true)
            if pv then
                local pl = pv:FindFirstChild("Plane") or obj:FindFirstChildWhichIsA("BasePart", true)
                if pl and pl:IsA("BasePart") then
                    return pl
                end
            end
        end
    end
    return cp
end

local function gS()
    local sp = Vector3.new(544.71, 70.43, -364.68)
    local fp = nil
    local mxd = -1

    local sl = ws:FindFirstChild("AreaEggSlotsClient")
    if sl then
        for _, s in ipairs(sl:GetChildren()) do
            if s:FindFirstChild("RareAreaEggHighlight") then
                local pl = s:FindFirstChild("Plane") or s:FindFirstChildWhichIsA("BasePart")
                if pl and pl:IsA("BasePart") then
                    local dst = (pl.Position - sp).Magnitude
                    if dst > mxd then
                        mxd = dst
                        fp = pl
                    end
                end
            end
        end
    end

    if not fp then
        for _, obj in ipairs(ws:GetChildren()) do
            if obj:FindFirstChild("RareAreaEggHighlight", true) then
                local pl = obj:FindFirstChild("Plane") or obj:FindFirstChildWhichIsA("BasePart", true)
                if pl and pl:IsA("BasePart") then
                    return pl
                end
            end
        end
    end

    return fp
end

local function eES(pl, zoneIdx)
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    local dist = hrp and (hrp.Position - pl.Position).Magnitude or 0
    local posX = pl.Position.X

    local size = pl.Size
    local eggHeight = size.Y
    local eggVolume = size.X * size.Y * size.Z

    local slotName = ""
    local curr = pl
    while curr and curr ~= workspace do
        slotName = slotName .. " " .. curr.Name
        curr = curr.Parent
    end
    slotName = slotName:lower()

    local isGiant = (eggHeight >= 5.0) or (eggVolume >= 120.0) or slotName:find("titan") or slotName:find("giant")

    local sizeBonus = 0
    if isGiant then
        sizeBonus = 25000 + math.min(15000, eggVolume * 50)
    end

    local zoneBonus = zoneIdx * 100000
    local score = zoneBonus + sizeBonus + (posX * 3.0) - (dist * 0.12)
    return score
end

local function gBE()
    if re then
        local rareEgg = gS()
        if rareEgg then
            return rareEgg, "rare"
        end
    end

    if pe then
        local pEgg = gP()
        if pEgg then
            return pEgg, "parasite"
        end
    end

    local sl = ws:FindFirstChild("AreaEggSlotsClient")
    local bestEgg = nil
    local highestScore = -math.huge

    if sl then
        for i = 1, 11 do
            if selectedZones[i] then
                for _, s in ipairs(sl:GetChildren()) do
                    local pl = s:FindFirstChild("Plane") or s:FindFirstChildWhichIsA("BasePart", true)
                    if pl and pl:IsA("BasePart") and iZ(pl.Position, i) then
                        if pl.Parent then
                            local score = eES(pl, i)
                            if score > highestScore then
                                highestScore = score
                                bestEgg = pl
                            end
                        end
                    end
                end
            end
        end
    end

    for _, obj in ipairs(ws:GetChildren()) do
        if obj:FindFirstChild("Hitbox", true) then
            local pl = obj:FindFirstChild("Plane") or obj:FindFirstChildWhichIsA("BasePart", true)
            if pl and pl:IsA("BasePart") then
                for i = 1, 11 do
                    if selectedZones[i] and iZ(pl.Position, i) then
                        if pl.Parent then
                            local score = eES(pl, i) + 50000
                            if score > highestScore then
                                highestScore = score
                                bestEgg = pl
                            end
                        end
                    end
                end
            end
        end
    end

    if bestEgg then
        return bestEgg, "zone"
    end

    return nil, nil
end

local function gT()
    if not localPlot then return nil end
    local tmRender = ws:FindFirstChild("__ClientTreadmillRenders")
    if not tmRender then return nil end
    local plotNum = tostring(localPlot.Name):match("%d+")
    if not plotNum then return nil end
    local render = tmRender:FindFirstChild("TreadmillRender_" .. plotNum)
    if render then return render:FindFirstChild("BoundingBoxPart") end
    return nil
end

local function eT()
    pcall(function()
        keypress(0x20); task.wait(0.15); keyrelease(0x20)
    end)
end

local function ex(ep)
    return ep and ep.Parent ~= nil
end

local function gSZ()
    gsz = true
    ia  = true
    fSR(fb.Position, true)
    gsz = false
    ia  = false
end

local function dSE(ep)
    if not fr then return end
    ia = true

    fSR(ep.Position, true)
    if not fr then ia = false; return end

    task.wait(0.2)
    if not fr then ia = false; return end

    local maxAttempts = 3
    for i = 1, maxAttempts do
        if not fr or not ex(ep) then break end

        pcall(function()
            keypress(0x45)
            local hTime = gH()
            task.wait(hTime)
            keyrelease(0x45)
        end)

        task.wait(0.3)
    end

    if not fr then ia = false; return end

    if not ex(ep) then
        gSZ()
    else
        ia = false
    end
end

local function dPE(ep)
    if not fr or not pe then return end
    ia = true

    fSR(ep.Position, true)
    if not fr or not pe then ia = false; return end

    task.wait(0.2)
    if not fr or not pe then ia = false; return end

    local maxAttempts = 3
    for i = 1, maxAttempts do
        if not fr or not pe or not ex(ep) then break end

        pcall(function()
            keypress(0x45)
            local hTime = gH()
            task.wait(hTime)
            keyrelease(0x45)
        end)

        task.wait(0.3)
    end

    if not fr then ia = false; return end

    if not ex(ep) then
        local sl   = ep.Parent and ep.Parent.Parent
        local isSp = sl and sl:FindFirstChild("RareAreaEggHighlight") ~= nil

        if isSp or not gA() then
            gSZ()
        else
            fSR(mfp.Position, true)
            if fr then
                task.wait(1.5) 
                pcall(function()
                    keypress(0x45)
                    task.wait(0.25)
                    keyrelease(0x45)
                end)
                task.wait(1.0)
            end
            ia = false
        end
    else
        ia = false
    end
end

local function sF()
    if ft then return end
    ft = task.spawn(function()
        local lastEggState = false

        while fr and State.AutoFarm do
            if gsz or ia then task.wait(0.1); continue end

            local egg, eggType = gBE()
            if egg then
                if not ragdollState then
                    eR()
                end

                if not lastEggState then
                    lastEggState = true
                    task.wait(3.0)
                    egg, eggType = gBE()
                end
                
                if egg and fr then
                    if eggType == "parasite" then
                        dPE(egg)
                    else
                        dSE(egg)
                    end
                end
            else
                lastEggState = false
                if tmf and localPlot then
                    local tmPart = gT()
                    if tmPart then
                        local ch  = lp.Character
                        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                        if hrp and (hrp.Position - tmPart.Position).Magnitude > 3 then
                            ia = true
                            if ragdollState then
                                dSR()
                            end
                            fSR(tmPart.Position, true)
                            ia = false
                        end

                        while fr and State.AutoFarm and tmf do
                            local e = gBE()
                            if e ~= nil then
                                eT()
                                task.wait(0.2)
                                break
                            end
                            task.wait(0.2)
                        end
                    else
                        task.wait(0.2)
                    end
                else
                    task.wait(0.2)
                end
            end
        end

        ft = nil
    end)
end

local mt

local function cF(st, ui)
    if fr == st then return end
    fr = st
    State.AutoFarm = st

    if ui and mt then
        pcall(function()
            if type(mt.Set) == "function" then mt:Set(st)
            elseif mt.Value ~= nil then mt.Value = st end
        end)
    end

    if st then
        lib:Notify({ Title = "Auto Farm", Content = "Auto Farm started!", Duration = 2 })
        eR()  
        task.spawn(sCV)
        sF()
    else
        lib:Notify({ Title = "Auto Farm", Content = "Auto Farm stopped!", Duration = 2 })
        dSR() 
    end
end

mt = tb:AddToggle({
    Id = "main_farm_toggle", Title = "Start Stop Auto Farm", Default = false,
    Callback = function(st) cF(st, false) end
})

tb:AddKeybind({
    Id = "farm_keybind", Title = "Farm Keybind", Default = "F", Mode = "Toggle",
    Callback = function(s) cF(s, true) end
})

task.spawn(function()
    local lastChar = lp.Character
    while true do
        task.wait(0.5)
        local char = lp.Character
        if char ~= lastChar then
            lastChar = char
            if fr then
                task.wait(1.5) 
                dSR()
                eR()  
                task.spawn(sCV)
            end
        end
    end
end)

local cf = w:AddTab({ Title = "Config", Icon = "save" })
w:BuildConfigSection(cf)
lib:LoadAutoloadConfig()

local cr = w:AddTab({ Title = "Credits", Icon = "info" })
cr:AddParagraph({ Title = "Credits", Content = "Script by @xban11\nUI by @d.unne" })

local st_tab = w:AddTab({ Title = "Settings", Icon = "settings" })
w:BuildInterfaceSection(st_tab)
