--!nonstrict
--[[
    sae.lua - SyncHub for Steal an Egg (Single-file bundle)
    Load with your executor directly.
--]]

local ENV = (typeof(getgenv) == "function" and getgenv()) or _G

-- ==== synchub.lua (inlined) ==============================================
ENV.SyncHubInline = function()
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")

local ENV = (typeof(getgenv) == "function" and getgenv()) or _G
local hasFS = isfile and readfile and writefile and isfolder and makefolder

local THEME = {
    bg      = Color3.fromRGB(18, 19, 24),
    panel   = Color3.fromRGB(24, 26, 32),
    bar     = Color3.fromRGB(28, 30, 37),
    row     = Color3.fromRGB(33, 35, 43),
    rowHi   = Color3.fromRGB(41, 44, 54),
    accent  = Color3.fromRGB(88, 214, 141),
    warn    = Color3.fromRGB(232, 176, 84),
    bad     = Color3.fromRGB(226, 98, 98),
    off     = Color3.fromRGB(58, 61, 72),
    text    = Color3.fromRGB(236, 238, 243),
    dim     = Color3.fromRGB(146, 152, 166),
    stroke  = Color3.fromRGB(44, 47, 57),
}

local TWEEN = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function create(class, props, parent)
    local inst = Instance.new(class)
    for k, v in props do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

local function corner(inst, radius)
    create("UICorner", { CornerRadius = UDim.new(0, radius or 6) }, inst)
    return inst
end

local function stroke(inst, colour, thickness)
    create("UIStroke", {
        Color = colour or THEME.stroke,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, inst)
    return inst
end

local function list(parent, padding)
    return create("UIListLayout", {
        Padding = UDim.new(0, padding or 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, parent)
end

local function pad(parent, all)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, all or 8), PaddingRight = UDim.new(0, all or 8),
        PaddingTop = UDim.new(0, all or 8), PaddingBottom = UDim.new(0, all or 8),
    }, parent)
end

local function label(parent, text, size, colour, bold)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextSize = size or 12,
        TextColor3 = colour or THEME.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = text,
    }, parent)
end

local function join(values)
    local parts = {}
    for value, on in values do
        if on then table.insert(parts, tostring(value)) end
    end
    table.sort(parts)
    return parts
end

local Window = {}
Window.__index = Window

function Window.new(title, dir)
    local self = setmetatable({}, Window)
    self.title       = title or "SyncHub"
    self.dir         = dir or "SyncHub"
    self.cfgDir      = self.dir .. "/configs"
    self.connections = {}
    self.loops       = {}
    self.widgets     = {}
    self.tabs        = {}
    self.keybinds    = {}
    self.config      = {}
    self.activeTab   = nil
    self.order       = 0
    self.uiVisible   = true

    self:_ensureDirs()
    self.config = self:LoadConfig("default", true)
    self:_build()
    self:_bindHotkeys()
    return self
end

function Window:_ensureDirs()
    if not hasFS then return end
    pcall(function()
        if not isfolder(self.dir) then makefolder(self.dir) end
        if not isfolder(self.cfgDir) then makefolder(self.cfgDir) end
    end)
end

function Window:_cfgPath(name)
    return self.cfgDir .. "/" .. (name or "default") .. ".json"
end

function Window:ReadConfig(name)
    if not hasFS then return {} end
    local path = self:_cfgPath(name)
    if not isfile(path) then return {} end
    local ok, raw = pcall(readfile, path)
    if not ok then return {} end
    local decoded, result = pcall(function() return HttpService:JSONDecode(raw) end)
    return (decoded and type(result) == "table") and result or {}
end

function Window:LoadConfig(name, quiet)
    local data = self:ReadConfig(name)
    self.config = data
    self.configName = name or "default"
    if not quiet then
        for idx, widget in self.widgets do
            if data[idx] ~= nil and widget.Set then
                pcall(widget.Set, data[idx], true)
            end
        end
        self:Notify("Loaded config: " .. self.configName, "ok")
    end
    return data
end

function Window:SaveConfig(name)
    name = name or self.configName or "default"
    self.configName = name
    if not hasFS then return false end
    self:_ensureDirs()
    local ok = pcall(function()
        writefile(self:_cfgPath(name), HttpService:JSONEncode(self.config))
    end)
    if ok then self:Notify("Saved config: " .. name, "ok")
    else self:Notify("Save failed", "bad") end
    return ok
end

function Window:ListConfigs()
    local names = {}
    if not hasFS or not listfiles then return names end
    local ok, files = pcall(listfiles, self.cfgDir)
    if not ok then return names end
    for _, path in files do
        local name = string.match(path, "([^/\\]+)%.json$")
        if name then table.insert(names, name) end
    end
    table.sort(names)
    return names
end

function Window:Set(idx, value)
    self.config[idx] = value
    if not hasFS or self.autosave == false then return end
    self._saveToken = (self._saveToken or 0) + 1
    local token = self._saveToken
    task.delay(1, function()
        if self._saveToken ~= token then return end
        pcall(function()
            writefile(self:_cfgPath(self.configName or "default"),
                HttpService:JSONEncode(self.config))
        end)
    end)
end

function Window:Get(idx, fallback)
    local value = self.config[idx]
    return value == nil and fallback or value
end

function Window:Track(connection)
    table.insert(self.connections, connection)
    return connection
end

function Window:Loop(interval, fn, guard)
    local alive = true
    table.insert(self.loops, function() alive = false end)
    task.spawn(function()
        while alive do
            if not guard or guard() then
                local ok, err = pcall(fn)
                if not ok then warn("[SyncHub] loop: " .. tostring(err)) end
            end
            task.wait(interval)
        end
    end)
    return function() alive = false end
end

function Window:Destroy()
    for _, stop in self.loops do pcall(stop) end
    for _, c in self.connections do pcall(function() c:Disconnect() end) end
    self.loops, self.connections = {}, {}
    if self.onDestroy then pcall(self.onDestroy) end
    if self.gui then pcall(function() self.gui:Destroy() end) end
    if ENV.SyncHub == self then ENV.SyncHub = nil end
end

function Window:_parent()
    if gethui then
        local ok, hidden = pcall(gethui)
        if ok and hidden then return hidden end
    end
    local ok, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if ok and coreGui then return coreGui end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

function Window:_build()
    self.gui = create("ScreenGui", {
        Name           = "SyncHub_" .. tostring(math.random(1e5, 1e6)),
        IgnoreGuiInset = true,
        ResetOnSpawn   = false,
        DisplayOrder   = 999,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, self:_parent())

    local root = corner(create("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(520, 420),
        BackgroundColor3 = THEME.bg,
        BorderSizePixel = 0,
        Active = true,
        ClipsDescendants = true,
    }, self.gui), 10)
    stroke(root)
    self.root = root

    local bar = create("Frame", {
        Name = "TitleBar", Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = THEME.bar, BorderSizePixel = 0,
    }, root)

    create("Frame", {
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = THEME.stroke, BorderSizePixel = 0,
    }, bar)

    local titleLabel = label(bar, self.title, 14, THEME.text, true)
    titleLabel.Position = UDim2.fromOffset(13, 0)
    titleLabel.Size = UDim2.new(0, 160, 1, 0)

    self.status = label(bar, "", 11, THEME.dim)
    self.status.Position = UDim2.new(0, 180, 0, 0)
    self.status.Size = UDim2.new(1, -250, 1, 0)

    local function barButton(offset, text, colour)
        local button = corner(create("TextButton", {
            AutoButtonColor = false,
            Position = UDim2.new(1, offset, 0.5, -11),
            Size = UDim2.fromOffset(24, 22),
            BackgroundColor3 = THEME.row, BorderSizePixel = 0,
            Font = Enum.Font.GothamBold, TextSize = 14,
            TextColor3 = colour or THEME.dim, Text = text,
        }, bar), 5)
        return button
    end

    local closeButton    = barButton(-30, "x", THEME.bad)
    local minimiseButton = barButton(-60, "-")

    local rail = create("ScrollingFrame", {
        Name = "Tabs",
        Position = UDim2.fromOffset(0, 38), Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = THEME.panel, BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
    }, root)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    }, rail)
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
    }, rail)
    create("Frame", {
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = THEME.stroke, BorderSizePixel = 0, ZIndex = 2,
    }, rail)
    self.rail = rail

    self.pages = create("Frame", {
        Name = "Pages",
        Position = UDim2.fromOffset(0, 72), Size = UDim2.new(1, 0, 1, -72),
        BackgroundTransparency = 1,
    }, root)

    self.toasts = create("Frame", {
        Name = "Toasts",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -12, 1, -12),
        Size = UDim2.fromOffset(250, 300),
        BackgroundTransparency = 1,
    }, self.gui)
    create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
    }, self.toasts)

    local bubble = corner(create("TextButton", {
        Name = "Reopen", AutoButtonColor = false, Visible = false,
        Position = UDim2.fromScale(0.02, 0.4), Size = UDim2.fromOffset(44, 44),
        BackgroundColor3 = THEME.accent, BorderSizePixel = 0,
        Font = Enum.Font.GothamBold, TextSize = 17,
        TextColor3 = THEME.bg, Text = "S",
    }, self.gui), 22)
    self.bubble = bubble

    self:Track(minimiseButton.MouseButton1Click:Connect(function() self:SetVisible(false) end))
    self:Track(bubble.MouseButton1Click:Connect(function() self:SetVisible(true) end))
    self:Track(closeButton.MouseButton1Click:Connect(function() self:Destroy() end))

    self:_drag(bar, root)
    self:_drag(bubble, bubble)
end

function Window:SetVisible(visible)
    self.uiVisible = visible and true or false
    self.root.Visible = self.uiVisible
    self.bubble.Visible = not self.uiVisible
end

function Window:ToggleVisible()
    self:SetVisible(not self.uiVisible)
end

function Window:SetStatus(text, colour)
    if not self.status then return end
    self.status.Text = tostring(text or "")
    self.status.TextColor3 = colour or THEME.dim
end

function Window:_drag(handle, target)
    local dragging, origin, startPos = false, nil, nil
    self:Track(handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging, origin, startPos = true, input.Position, target.Position
            self:Track(input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end))
        end
    end))

    self:Track(UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - origin
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
end

function Window:_bindHotkeys()
    self:Track(UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        for _, bind in self.keybinds do
            if bind.key == input.KeyCode then pcall(bind.fn) end
        end
    end))
end

local Tab, Group = {}, {}
Tab.__index, Group.__index = Tab, Group

function Window:Tab(name)
    local win = self
    local self = setmetatable({}, Tab)
    self.win, self.name, self.order = win, name, #win.tabs + 1

    self.button = corner(create("TextButton", {
        Name = name, AutoButtonColor = false,
        Size = UDim2.fromOffset(math.max(58, #name * 8 + 20), 24),
        LayoutOrder = self.order,
        BackgroundColor3 = THEME.row, BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium, TextSize = 12,
        TextColor3 = THEME.dim, Text = name,
    }, win.rail), 5)

    self.page = create("ScrollingFrame", {
        Name = name .. "Page", Visible = false,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = THEME.off,
    }, win.pages)
    list(self.page, 7)
    pad(self.page, 10)

    win:Track(self.button.MouseButton1Click:Connect(function() win:Select(name) end))
    win.tabs[name] = self
    if not win.activeTab then win:Select(name) end
    return self
end

function Window:Select(name)
    for tabName, tab in self.tabs do
        local active = tabName == name
        tab.page.Visible = active
        TweenService:Create(tab.button, TWEEN, {
            BackgroundColor3 = active and THEME.accent or THEME.row,
        }):Play()
        tab.button.TextColor3 = active and THEME.bg or THEME.dim
    end
    self.activeTab = name
end

function Tab:Group(title, collapsed)
    local tab = self
    local win = tab.win
    local self = setmetatable({}, Group)
    self.win, self.title = win, title

    tab.groupCount = (tab.groupCount or 0) + 1
    local key = "__group_" .. tab.name "_" .. title
    local isCollapsed = win:Get(key, collapsed and true or false)

    local frame = corner(create("Frame", {
        Name = title,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = THEME.panel, BorderSizePixel = 0,
        LayoutOrder = tab.groupCount,
        ClipsDescendants = true,
    }, tab.page), 8)
    stroke(frame)
    self.frame = frame

    local header = create("TextButton", {
        Name = "Header", AutoButtonColor = false,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1, Text = "",
    }, frame)

    local titleLabel = label(header, title, 12, THEME.text, true)
    titleLabel.Position = UDim2.fromOffset(10, 0)
    titleLabel.Size = UDim2.new(1, -40, 1, 0)

    local chevron = label(header, isCollapsed and "+" or "-", 15, THEME.dim, true)
    chevron.Position = UDim2.new(1, -24, 0, 0)
    chevron.Size = UDim2.fromOffset(16, 30)
    chevron.TextXAlignment = Enum.TextXAlignment.Center

    local body = create("Frame", {
        Name = "Body", Visible = not isCollapsed,
        Position = UDim2.fromOffset(0, 30),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    }, frame)
    list(body, 5)
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
    }, body)
    self.body = body
    self.order = 0

    local function render()
        body.Visible = not isCollapsed
        chevron.Text = isCollapsed and "+" or "-"
        frame.AutomaticSize = isCollapsed and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
        if isCollapsed then frame.Size = UDim2.new(1, 0, 0, 30) end
    end

    win:Track(header.MouseButton1Click:Connect(function()
        isCollapsed = not isCollapsed
        win:Set(key, isCollapsed)
        render()
    end))

    render()
    return self
end

function Group:_next()
    self.order += 1
    return self.order
end

function Group:_row(height)
    return corner(create("Frame", {
        Size = UDim2.new(1, 0, 0, height or 32),
        LayoutOrder = self:_next(),
        BackgroundColor3 = THEME.row, BorderSizePixel = 0,
    }, self.body), 5)
end

function Group:_register(idx, handle)
    if idx then self.win.widgets[idx] = handle end
    return handle
end

function Group:_fail(idx, err)
    warn("[SyncHub] " .. tostring(idx) .. ": " .. tostring(err))
    self.win:SetStatus("error in " .. tostring(idx), THEME.bad)
end

function Group:Label(text)
    local widget = label(self.body, text, 12, THEME.dim)
    widget.Size = UDim2.new(1, 0, 0, 0)
    widget.AutomaticSize = Enum.AutomaticSize.Y
    widget.TextWrapped = true
    widget.LayoutOrder = self:_next()
    return { Instance = widget, Set = function(value) widget.Text = tostring(value) end }
end

function Group:Button(text, callback)
    local button = corner(create("TextButton", {
        Name = text, AutoButtonColor = false,
        Size = UDim2.new(1, 0, 0, 30), LayoutOrder = self:_next(),
        BackgroundColor3 = THEME.row, BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium, TextSize = 12,
        TextColor3 = THEME.text, Text = text,
    }, self.body), 5)

    self.win:Track(button.MouseEnter:Connect(function()
        TweenService:Create(button, TWEEN, { BackgroundColor3 = THEME.rowHi }):Play()
    end))
    self.win:Track(button.MouseLeave:Connect(function()
        TweenService:Create(button, TWEEN, { BackgroundColor3 = THEME.row }):Play()
    end))
    self.win:Track(button.MouseButton1Click:Connect(function()
        local ok, err = pcall(callback)
        if not ok then self:_fail(text, err) end
    end))
    return button
end

function Group:Toggle(idx, text, default, callback)
    local win = self.win
    local saved = win:Get(idx)
    local state = if type(saved) == "boolean" then saved else (default or false)

    local row = self:_row(32)
    local name = label(row, text, 12, THEME.text)
    name.Position = UDim2.fromOffset(10, 0)
    name.Size = UDim2.new(1, -62, 1, 0)

    local track = corner(create("Frame", {
        Position = UDim2.new(1, -48, 0.5, -10), Size = UDim2.fromOffset(38, 20),
        BackgroundColor3 = THEME.off, BorderSizePixel = 0,
    }, row), 10)
    local knob = corner(create("Frame", {
        Position = UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = THEME.text, BorderSizePixel = 0,
    }, track), 7)

    local hit = create("TextButton", {
        BackgroundTransparency = 1, Text = "",
        Size = UDim2.fromScale(1, 1), ZIndex = 3,
    }, row)

    local function render(animate)
        local info = animate and TWEEN or TweenInfo.new(0)
        TweenService:Create(track, info, { BackgroundColor3 = state and THEME.accent or THEME.off }):Play()
        TweenService:Create(knob, info, { Position = state and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3) }):Play()
    end

    local function apply(animate, silent)
        render(animate)
        win:Set(idx, state)
        if not silent and callback then
            local ok, err = pcall(callback, state)
            if not ok then self:_fail(idx, err) end
        end
    end

    win:Track(hit.MouseButton1Click:Connect(function()
        state = not state
        apply(true)
    end))

    render(false)
    task.defer(function()
        if callback then pcall(callback, state) end
    end)

    return self:_register(idx, {
        Instance = row,
        Get = function() return state end,
        Set = function(value, silent)
            state = value and true or false
            apply(true, silent)
        end,
    })
end

function Group:Slider(idx, text, min, max, default, step, callback)
    local win = self.win
    step = step or 1
    local saved = tonumber(win:Get(idx))
    local value = math.clamp(saved or default or min, min, max)

    local row = self:_row(44)
    local name = label(row, text, 12, THEME.text)
    name.Position = UDim2.fromOffset(10, 2)
    name.Size = UDim2.new(1, -80, 0, 18)

    local readout = label(row, tostring(value), 12, THEME.accent, true)
    readout.Position = UDim2.new(1, -74, 0, 2)
    readout.Size = UDim2.fromOffset(64, 18)
    readout.TextXAlignment = Enum.TextXAlignment.Right

    local bar = corner(create("Frame", {
        Position = UDim2.fromOffset(10, 26), Size = UDim2.new(1, -20, 0, 8),
        BackgroundColor3 = THEME.off, BorderSizePixel = 0,
    }, row), 4)
    local fill = corner(create("Frame", {
        Size = UDim2.fromScale((value - min) / math.max(max - min, 1), 1),
        BackgroundColor3 = THEME.accent, BorderSizePixel = 0,
    }, bar), 4)

    local function setFromScale(scale, silent)
        local raw = min + (max - min) * math.clamp(scale, 0, 1)
        local snapped = math.clamp(math.floor(raw / step + 0.5) * step, min, max)
        if snapped == value and not silent then return end
        value = snapped
        readout.Text = tostring(value)
        fill.Size = UDim2.fromScale((value - min) / math.max(max - min, 1), 1)
        win:Set(idx, value)
        if not silent and callback then pcall(callback, value) end
    end

    local dragging = false
    local function track(input)
        local scale = (input.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1)
        setFromScale(scale)
    end

    win:Track(bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            track(input)
        end
    end))
    win:Track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
    win:Track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            track(input)
        end
    end))

    task.defer(function() if callback then pcall(callback, value) end end)

    return self:_register(idx, {
        Instance = row,
        Get = function() return value end,
        Set = function(newValue, silent)
            setFromScale(((tonumber(newValue) or min) - min) / math.max(max - min, 1), silent)
        end,
    })
end

function Group:Input(idx, text, default, callback)
    local win = self.win
    local value = tostring(win:Get(idx, default or ""))

    local row = self:_row(48)
    local name = label(row, text, 12, THEME.text)
    name.Position = UDim2.fromOffset(10, 2)
    name.Size = UDim2.new(1, -20, 0, 16)

    local box = corner(create("TextBox", {
        Position = UDim2.fromOffset(10, 22), Size = UDim2.new(1, -20, 0, 20),
        BackgroundColor3 = THEME.bg, BorderSizePixel = 0,
        Font = Enum.Font.Gotham, TextSize = 12,
        TextColor3 = THEME.text, TextXAlignment = Enum.TextXAlignment.Left,
        PlaceholderText = "...", PlaceholderColor3 = THEME.dim,
        ClearTextOnFocus = false, Text = value,
    }, row), 4)
    create("UIPadding", { PaddingLeft = UDim.new(0, 6) }, box)

    win:Track(box.FocusLost:Connect(function()
        value = box.Text
        win:Set(idx, value)
        if callback then pcall(callback, value) end
    end))

    return self:_register(idx, {
        Instance = row,
        Get = function() return value end,
        Set = function(newValue, silent)
            value = tostring(newValue or "")
            box.Text = value
            win:Set(idx, value)
            if not silent and callback then pcall(callback, value) end
        end,
    })
end

function Group:Dropdown(idx, text, options, default, multi, callback)
    local win = self.win
    local saved = win:Get(idx)
    local value
    if multi then
        value = type(saved) == "table" and saved or {}
        if type(default) == "table" and saved == nil then
            for k, v in default do value[k] = v end
        end
    else
        value = type(saved) == "string" and saved or (default or options[1])
    end

    local row = self:_row(32)
    local name = label(row, text, 12, THEME.text)
    name.Position = UDim2.fromOffset(10, 0)
    name.Size = UDim2.new(0.45, -10, 1, 0)

    local summary = label(row, "", 11, THEME.accent)
    summary.Position = UDim2.new(0.45, 0, 0, 0)
    summary.Size = UDim2.new(0.55, -28, 1, 0)
    summary.TextXAlignment = Enum.TextXAlignment.Right

    local chevron = label(row, "v", 11, THEME.dim, true)
    chevron.Position = UDim2.new(1, -20, 0, 0)
    chevron.Size = UDim2.fromOffset(14, 32)

    local hit = create("TextButton", {
        BackgroundTransparency = 1, Text = "",
        Size = UDim2.fromScale(1, 1), ZIndex = 3,
    }, row)

    local menu = corner(create("Frame", {
        Visible = false,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = self:_next(),
        BackgroundColor3 = THEME.bg, BorderSizePixel = 0,
    }, self.body), 5)
    stroke(menu)
    local menuList = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, BorderSizePixel = 0,
        CanvasSize = UDim2.new(), ScrollBarThickness = 2,
        ScrollBarImageColor3 = THEME.off,
    }, menu)
    list(menuList, 2)
    pad(menuList, 4)

    local function describe()
        if multi then
            local picked = join(value)
            summary.Text = #picked == 0 and "none"
                or (#picked <= 2 and table.concat(picked, ", ")
                or (#picked .. " selected"))
        else
            summary.Text = tostring(value)
        end
    end

    local rows = {}
    local function renderRows()
        for option, entry in rows do
            local on = if multi then value[option] == true else value == option
            entry.tick.BackgroundColor3 = on and THEME.accent or THEME.off
            entry.text.TextColor3 = on and THEME.text or THEME.dim
        end
        describe()
    end

    for order, option in options do
        local entry = corner(create("TextButton", {
            Name = tostring(option), AutoButtonColor = false,
            Size = UDim2.new(1, 0, 0, 24), LayoutOrder = order,
            BackgroundColor3 = THEME.row, BorderSizePixel = 0, Text = "",
        }, menuList), 4)

        local tick = corner(create("Frame", {
            Position = UDim2.fromOffset(6, 7), Size = UDim2.fromOffset(10, 10),
            BackgroundColor3 = THEME.off, BorderSizePixel = 0,
        }, entry), 3)

        local entryText = label(entry, tostring(option), 11, THEME.dim)
        entryText.Position = UDim2.fromOffset(24, 0)
        entryText.Size = UDim2.new(1, -30, 1, 0)

        rows[option] = { tick = tick, text = entryText }

        win:Track(entry.MouseButton1Click:Connect(function()
            if multi then
                value[option] = not value[option] or nil
            else
                value = option
                menu.Visible = false
                chevron.Text = "v"
            end
            win:Set(idx, value)
            renderRows()
            if callback then pcall(callback, value) end
        end))
    end

    win:Track(hit.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
        chevron.Text = menu.Visible and "^" or "v"
    end))

    renderRows()
    task.defer(function() if callback then pcall(callback, value) end end)

    return self:_register(idx, {
        Instance = row,
        Get = function() return value end,
        Set = function(newValue, silent)
            value = newValue
            win:Set(idx, value)
            renderRows()
            if not silent and callback then pcall(callback, value) end
        end,
    })
end

function Group:Keybind(idx, text, default, callback)
    local win = self.win
    local savedName = win:Get(idx)
    local key = (savedName and Enum.KeyCode[savedName]) or default

    local row = self:_row(32)
    local name = label(row, text, 12, THEME.text)
    name.Position = UDim2.fromOffset(10, 0)
    name.Size = UDim2.new(1, -110, 1, 0)

    local button = corner(create("TextButton", {
        AutoButtonColor = false,
        Position = UDim2.new(1, -96, 0.5, -11), Size = UDim2.fromOffset(86, 22),
        BackgroundColor3 = THEME.bg, BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium, TextSize = 11,
        TextColor3 = THEME.accent, Text = key and key.Name or "none",
    }, row), 4)

    local bind = { key = key, fn = callback }
    table.insert(win.keybinds, bind)

    local listening = false
    win:Track(button.MouseButton1Click:Connect(function()
        listening = true
        button.Text = "press..."
    end))
    win:Track(UserInputService.InputBegan:Connect(function(input, processed)
        if not listening or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        listening = false
        if input.KeyCode == Enum.KeyCode.Escape then
            bind.key = nil
            button.Text = "none"
            win:Set(idx, nil)
            return
        end
        bind.key = input.KeyCode
        button.Text = input.KeyCode.Name
        win:Set(idx, input.KeyCode.Name)
    end))

    return self:_register(idx, {
        Instance = row,
        Get = function() return bind.key end,
        Set = function(newValue)
            local newKey = type(newValue) == "string" and Enum.KeyCode[newValue] or newValue
            bind.key = newKey
            button.Text = newKey and newKey.Name or "none"
        end,
    })
end

function Window:Notify(text, kind, duration)
    if not self.toasts then return end
    local colour = kind == "ok" and THEME.accent
        or kind == "bad" and THEME.bad
        or kind == "warn" and THEME.warn
        or THEME.dim

    local toast = corner(create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = THEME.bar, BorderSizePixel = 0,
        BackgroundTransparency = 1,
    }, self.toasts), 6)
    stroke(toast, colour)

    create("Frame", {
        Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = colour,
        BorderSizePixel = 0, ZIndex = 2,
    }, toast)

    local body = label(toast, tostring(text), 12, THEME.text)
    body.Position = UDim2.fromOffset(11, 0)
    body.Size = UDim2.new(1, -20, 0, 0)
    body.AutomaticSize = Enum.AutomaticSize.Y
    body.TextWrapped = true
    create("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }, toast)

    TweenService:Create(toast, TWEEN, { BackgroundTransparency = 0 }):Play()
    task.delay(duration or 3.5, function()
        TweenService:Create(toast, TWEEN, { BackgroundTransparency = 1 }):Play()
        body.TextTransparency = 1
        task.wait(0.2)
        pcall(function() toast:Destroy() end)
    end)
end

function Window:Overlay(enabled)
    if not enabled then
        if self.overlay then self.overlay.Visible = false end
        return
    end
    if self.overlay then
        self.overlay.Visible = true
        return
    end

    local frame = corner(create("Frame", {
        Name = "Overlay",
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.fromOffset(190, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = THEME.bg, BackgroundTransparency = 0.15,
        BorderSizePixel = 0, Active = true,
    }, self.gui), 8)
    stroke(frame)
    list(frame, 2)
    pad(frame, 8)
    self.overlay = frame
    self.overlayLines = {}
    self:_drag(frame, frame)

    local header = label(frame, self.title, 12, THEME.accent, true)
    header.Size = UDim2.new(1, 0, 0, 16)
    header.LayoutOrder = 0
    return frame
end

function Window:OverlaySet(key, text)
    if not self.overlay then return end
    local line = self.overlayLines[key]
    if not line then
        line = label(self.overlay, "", 11, THEME.dim)
        line.Size = UDim2.new(1, 0, 0, 14)
        line.LayoutOrder = #self.overlayLines + 1
        self.overlayLines[key] = line
    end
    line.Text = tostring(text)
end

if ENV.SyncHub then
    pcall(function() ENV.SyncHub:Destroy() end)
    ENV.SyncHub = nil
end

return {
    new = function(title, dir)
        local win = Window.new(title, dir)
        ENV.SyncHub = win
        return win
    end,
    THEME = THEME,
    create = create,
    corner = corner,
}
end
-- ==== end synchub.lua ====================================================

-- ==== steal_an_egg.lua ===================================================
local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local RunService         = game:GetService("RunService")
local TeleportService    = game:GetService("TeleportService")
local HttpService        = game:GetService("HttpService")
local Lighting           = game:GetService("Lighting")
local VirtualUser        = game:GetService("VirtualUser")

local ENV   = (typeof(getgenv) == "function" and getgenv()) or _G
local DIR  = "SyncHub"

local Hub = ENV.SyncHubInline()
local win = Hub.new("SyncHub - Steal an Egg", DIR .. "/StealAnEgg")

local RARITIES = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Cosmic", "Divine", "Eternal", "Secret" }
local AREAS = { "Cherry Blossom", "Cosmic", "Volcano", "Prehistoric", "Abyss Ocean" }
local PRIORITIES = { "Rarity", "KG", "Nearest", "Value" }
local MOVE_MODES = { "Walk", "Glide", "Teleport" }
local ACTIONS    = { "Steal", "Place", "Hatch", "CollectCash", "OpenChest", "SkipChest", "SellPet", "SellEgg", "EquipBest", "UpgradePen", "Treadmill", "UpgradeTreadmill", "BuyTrail", "ClaimIndex", "HungryMonster" }

local State = {
    lp        = Players.LocalPlayer,
    session   = os.time(),
    steals    = 0,
    hatches   = 0,
    logging   = false,
    log       = {},
    logSeen   = {},
    esp       = {},
    noclip    = false,
    hooked    = false,
}

local function lp() return State.lp end
local function char() return lp().Character end
local function root()
    local c = char()
    return c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
end
local function humanoid()
    local c = char()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local Adapter = { remotes = {}, containers = {} }
local REMOTE_CLASSES = { RemoteEvent = true, RemoteFunction = true, UnreliableRemoteEvent = true }

function Adapter:scan()
    self.remotes, self.containers = {}, {}
    for _, service in { ReplicatedStorage, workspace } do
        local ok, descendants = pcall(function() return service:GetDescendants() end)
        if ok then
            for _, d in descendants do
                if REMOTE_CLASSES[d.ClassName] then
                    local existing = self.remotes[d.Name]
                    if not existing or #d:GetFullName() < #existing:GetFullName() then
                        self.remotes[d.Name] = d
                    end
                end
            end
        end
    end

    local wanted = { plots = { "plot", "base", "pen", "island" }, eggs = { "egg" } }
    for _, child in workspace:GetChildren() do
        local lower = string.lower(child.Name)
        for slot, words in wanted do
            if not self.containers[slot] then
                for _, word in words do
                    if string.find(lower, word, 1, true) then
                        self.containers[slot] = child
                        break
                    end
                end
            end
        end
    end
end

function Adapter:invoke(action, ...)
    local binding = win:Get("bind_" .. action)
    if type(binding) ~= "table" or not binding.remote then return false, "unbound" end
    local remote = self.remotes[binding.remote]
    if not remote then self:scan(); remote = self.remotes[binding.remote] end
    if not remote then return false, "remote missing: " .. binding.remote end

    local args = {}
    local runtime = { ... }
    local used = 0
    for i, value in binding.args or {} do
        if value == "%s" then
            used += 1
            args[i] = runtime[used]
        else
            args[i] = value
        end
    end
    for i = used + 1, #runtime do table.insert(args, runtime[i]) end

    local method = binding.method == "InvokeServer" and "InvokeServer" or "FireServer"
    local ok, result = pcall(function() return remote[method](remote, table.unpack(args)) end)
    return ok, result
end

function Adapter:bound(action)
    local binding = win:Get("bind_" .. action)
    return type(binding) == "table" and binding.remote ~= nil
end

local Logger = {}
local function describeArg(value)
    local kind = typeof(value)
    if kind == "Instance" then return string.format("<%s:%s>", value.ClassName, value.Name)
    elseif kind == "table" then local ok, encoded = pcall(function() return HttpService:JSONDecode(value) end); return ok and encoded or "<table>"
    elseif kind == "string" then return string.format("%q", value) end
    return tostring(value)
end

local function signature(remoteName, method, args)
    local parts = { remoteName, method }
    for _, value in args do table.insert(parts, describeArg(value)) end
    return table.concat(parts, "|")
end

function Logger:record(remote, method, args)
    local sig = signature(remote.Name, method, args)
    local index = State.logSeen[sig]
    if index then
        State.log[index].hits += 1
        State.log[index].at = os.clock()
        return
    end

    local template = {}
    for i, value in args do template[i] = typeof(value) == "Instance" and value or value end

    table.insert(State.log, {
        remote   = remote.Name,
        path     = remote:GetFullName(),
        method   = method,
        args     = template,
        display  = sig,
        hits     = 1,
        at       = os.clock(),
    })
    State.logSeen[sig] = #State.log
    win:Notify("logged " .. remote.Name, "ok", 2)
end

function Logger:install()
    if State.hooked then return true end
    if not (hookmetamethod and getnamecallmethod and checkcaller) then return false end

    local original
    original = hookmetamethod(game, "__namecall", function(instance, ...)
        if State.logging and not checkcaller() then
            local ok, method = pcall(getnamecallmethod)
            if ok and (method == "FireServer" or method == "InvokeServer") and REMOTE_CLASSES[instance.ClassName] then
                local args = { ... }
                pcall(function() Logger:record(instance, method, args) end)
            end
        end
        return original(instance, ...)
    end)

    State.hooked = true
    return true
end

local function readInfo(model)
    local info = { name = model.Name, instance = model }
    local ok, attrs = pcall(function() return model:GetAttributes() end)
    if ok and type(attrs) == "table" then
        for rawKey, value in attrs do
            local key = string.lower(rawKey)
            if string.find(key, "rarity") then info.rarity = tostring(value)
            elseif string.find(key, "area") or string.find(key, "biome") then info.area = tostring(value) end
        end
    end
    return info
end

local function matchesFilter(info)
    local rarities = win:Get("TargetRarities")
    if type(rarities) == "table" and next(rarities) then
        if not (info.rarity and rarities[info.rarity]) then return false end
    end
    return true
end

local RARITY_RANK = {}
for index, rarity in RARITIES do RARITY_RANK[rarity] = index end

local function scoreOf(info, origin)
    local priority = win:Get("TargetPriority", "Rarity")
    if priority == "Nearest" then
        local part = info.instance:IsA("BasePart") and info.instance or info.instance:FindFirstChildWhichIsA("BasePart")
        if not part or not origin then return -math.huge end
        return -(part.Position - origin).Magnitude
    end
    return RARITY_RANK[info.rarity] or 0
end

local Features = {}
function Features.applyCharacter()
    local hum = humanoid()
    if not hum then return end
    pcall(function()
        hum.WalkSpeed = tonumber(win:Get("WalkSpeed", 16)) or 16
        hum.UseJumpPower = true
        hum.JumpPower = tonumber(win:Get("JumpPower", 50)) or 50
    end)
end

function Features.noclip(on)
    State.noclip = on
    if on and not State.noclipConn then
        State.noclipConn = win:Track(RunService.Stepped:Connect(function()
            local c = char()
            if not c then return end
            for _, part in c:GetDescendants() do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end))
    elseif not on and State.noclipConn then
        State.noclipConn:Disconnect()
        State.noclipConn = nil
    end
end

local ARRIVE = 7
local MAX_STEP = 18

function Features.moveTo(position, speed, mode)
    local part = root()
    if not part then return false end

    mode  = mode or win:Get("StealMode", "Walk")
    speed = math.max(tonumber(speed) or 120, 16)
    local deadline = os.clock() + 20

    if mode == "Teleport" then
        part.CFrame = CFrame.new(position + Vector3.new(0, 3, 0)) * (part.CFrame - part.Position)
        return true
    end

    if mode == "Walk" then
        local hum = humanoid()
        if not hum then return false end
        while os.clock() < deadline do
            part = root()
            if not part then return false end
            if (position - part.Position).Magnitude < ARRIVE then return true end
            hum:MoveTo(position)
            task.wait(0.25)
        end
        return false
    end

    while os.clock() < deadline do
        part = root()
        if not part then return false end
        local offset = position - part.Position
        if offset.Magnitude < ARRIVE then return true end
        local dt = RunService.Heartbeat:Wait()
        local step = math.min(offset.Magnitude, speed * dt, MAX_STEP)
        local rotation = part.CFrame - part.Position
        part.CFrame = CFrame.new(part.Position + offset.Unit * step) * rotation
    end
    return false
end

function Features.eggs()
    local found = {}
    local source = Adapter.containers.eggs or Adapter.containers.plots or workspace
    local myName = lp().Name

    local ok, descendants = pcall(function() return source:GetDescendants() end)
    if not ok then return found end

    for _, d in descendants do
        if d:IsA("Model") and string.find(string.lower(d.Name), "egg", 1, true) then
            if not string.find(d:GetFullName(), myName, 1, true) then
                table.insert(found, d)
            end
        end
    end
    return found
end

local function pivotOf(model)
    if not model then return nil end
    if model:IsA("BasePart") then return model.Position end
    local ok, pivot = pcall(function() return model:GetPivot().Position end)
    if ok then return pivot end
    local part = model:FindFirstChildWhichIsA("BasePart")
    return part and part.Position or nil
end

function Features.stealOnce()
    if not Adapter:bound("Steal") then
        win:Notify("Steal is unbound - pumunta sa REMOTES tab!", "warn", 5)
        return false
    end

    local origin = pivotOf(char())
    local best, bestScore = nil, -math.huge

    for _, model in Features.eggs() do
        local info = readInfo(model)
        if matchesFilter(info) then
            local position = pivotOf(model)
            if position then
                local score = scoreOf(info, origin)
                if score > bestScore then
                    best, bestScore = info, score
                end
            end
        end
    end

    if not best then return false end
    local target = pivotOf(best.instance)
    if not target then return false end

    Features.moveTo(target, win:Get("StealSpeed", 120))
    local ok = Adapter:invoke("Steal", best.instance)

    if ok then State.steals += 1 end
    return ok
end

-- UI Tabs Setup
local tabHome     = win:Tab("HOME")
local tabEggs     = win:Tab("EGGS")
local tabRemotes  = win:Tab("REMOTES")
local tabSettings = win:Tab("SETTINGS")

do
    local session = tabHome:Group("Session")
    local statLines = { session:Label("steals: 0"), session:Label("remotes found: 0") }
    win:Loop(1, function()
        statLines[1].Set(string.format("steals: %d", State.steals))
        local count = 0
        for _ in Adapter.remotes do count += 1 end
        statLines[2].Set("remotes found: " .. count)
    end)
    local server = tabHome:Group("Server")
    server:Button("Unload hub", function() win:Destroy() end)
end

do
    local filter = tabEggs:Group("Steal filter")
    filter:Dropdown("TargetRarities", "Rarities", RARITIES, {}, true)
    filter:Dropdown("TargetAreas", "Areas", AREAS, {}, true)
    filter:Dropdown("TargetPriority", "Priority", PRIORITIES, "Rarity")

    local steal = tabEggs:Group("Auto steal")
    steal:Toggle("AutoSteal", "Auto steal", false)
    steal:Dropdown("StealMode", "Travel mode", MOVE_MODES, "Walk")
    steal:Slider("StealSpeed", "Glide speed", 40, 400, 120, 10)
    steal:Slider("StealDelay", "Delay between steals", 0.5, 15, 2, 0.5)

    win:Loop(0.1, function()
        Features.stealOnce()
        task.wait(tonumber(win:Get("StealDelay", 2)) or 2)
    end, function()
        return win:Get("AutoSteal") == true
    end)
end

do
    local capture = tabRemotes:Group("Remote logger")
    capture:Label("1. Turn logging on. 2. Steal an egg by hand. 3. Bind below.")
    capture:Toggle("RemoteLogging", "Log outgoing remotes", false, function(on)
        State.logging = on
        if on and not Logger:install() then win:Notify("executor lacks hookmetamethod", "bad", 6) end
    end)

    local bind = tabRemotes:Group("Bind a call to an action")
    bind:Dropdown("BindAction", "Action", ACTIONS, "Steal")
    bind:Input("BindIndex", "Log entry number", "1")
    bind:Button("Bind", function()
        local action = win:Get("BindAction", "Steal")
        local index = tonumber(win:Get("BindIndex", "1"))
        local entry = index and State.log[index]
        if not entry then return win:Notify("no log entry " .. tostring(index), "bad") end

        local args = {}
        for i, value in entry.args do
            args[i] = typeof(value) == "Instance" and "%s" or value
        end

        win:Set("bind_" .. action, { remote = entry.remote, method = entry.method, args = args })
        win:Notify(action .. " -> " .. entry.remote, "ok", 5)
    end)
end

do
    local movement = tabSettings:Group("Movement")
    movement:Slider("WalkSpeed", "Walk speed", 16, 120, 16, 1, Features.applyCharacter)
    movement:Slider("JumpPower", "Jump power", 50, 150, 50, 5, Features.applyCharacter)
    movement:Toggle("Noclip", "Noclip", false, Features.noclip)
    
    local misc = tabSettings:Group("Misc")
    misc:Keybind("MenuKey", "Toggle menu", Enum.KeyCode.RightShift, function() win:ToggleVisible() end)
end

local found = Adapter:scan()
win:Track(lp().CharacterAdded:Connect(function()
    task.wait(0.6)
    Features.applyCharacter()
    if State.noclip then Features.noclip(true) end
end))

win:Select("HOME")
win:Notify(string.format("SyncHub ready. %d remotes discovered.", found), "ok", 5)
win.onDestroy = function() State.logging = false; Features.noclip(false) end

return win
