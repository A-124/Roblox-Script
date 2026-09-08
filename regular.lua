--[[
========================================================
        LUCRIT SCRIPTS — STEAL A EGG HUB
        PREMIUM SINGLE-FILE SCRIPT HUB
========================================================

Safe script-library version.

Features:
• Home
• Scripts
• Favorites
• Settings
• Info
• Search
• Notifications
• Responsive scaling
• Dragging
• Minimize / restore
• Close / reopen
• Favorites
• Animated background
• Script source viewer
• Defensive error handling

========================================================
]]

--------------------------------------------------------
-- SERVICES
--------------------------------------------------------

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

if not Player then
	return
end

local PlayerGui = Player:WaitForChild("PlayerGui")

--------------------------------------------------------
-- CONFIG
--------------------------------------------------------

local Config = {
	Brand = "LUCRIT SCRIPTS",
	Subtitle = "STEAL A EGG HUB",
	Version = "1.1.0",

	Theme = {
		Background = Color3.fromRGB(6, 7, 11),
		Panel = Color3.fromRGB(12, 14, 21),
		Panel2 = Color3.fromRGB(17, 20, 29),
		Panel3 = Color3.fromRGB(24, 28, 39),

		Primary = Color3.fromRGB(90, 140, 255),
		Cyan = Color3.fromRGB(60, 215, 255),
		Purple = Color3.fromRGB(150, 90, 255),

		Text = Color3.fromRGB(245, 247, 255),
		Muted = Color3.fromRGB(140, 147, 167),

		Success = Color3.fromRGB(70, 220, 135),
		Warning = Color3.fromRGB(255, 190, 70),
		Danger = Color3.fromRGB(255, 90, 90),

		Border = Color3.fromRGB(42, 47, 63),
	},

	Animations = true,
	BackgroundEffects = true,
}

--------------------------------------------------------
-- SCRIPT DATABASE
--------------------------------------------------------

local Scripts = {

	{
		description = "Zyphora Hub for Steal a Egg.",
		name = "Zyphora Hub",
		game = "Steal a Egg",

		loadstring = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/jdififjhdudis-del/ZZy/refs/heads/main/ZZy.lua"))()
]],
	},

	{
		description = "AJJANS New Rift Events script for Steal a Egg.",
		name = "AJJANS NEW RIET EVENTS",
		game = "Steal a Egg",

		loadstring = [[
loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/36107afd3107e8d841f9d1a69e2465d4.lua"))()
]],
	},

	{
		description = "Glazehub for Steal a Egg.",
		name = "Glazehub",
		game = "Steal a Egg",

		loadstring = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/GlazeScripts/Fyy-Community/refs/heads/main/Glazehub.lua"))()
]],
	},

	{
		description = "Free Private Server for Steal a Egg.",
		name = "PrivateServer",
		game = "Steal a Egg",

		loadstring = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/raw-roblox/PrivateServerBypass/refs/heads/main/lua"))()
]],
	},

	{
		description = "zeroinhub for Steal a Egg.",
		name = "zeroinhub",
		game = "Steal a Egg",

		loadstring = [[
loadstring(game:HttpGet("https://zeroinhub.com/api/script"))()
]],
	},

{
		description = "Clover Hub for Steal a Egg.",
		name = "CloverHub",
		game = "Steal a Egg",

		loadstring = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/Ryuun0x/Clover/refs/heads/main/main.lua"))()
]],
	},

}

--------------------------------------------------------
-- STATE
--------------------------------------------------------

local State = {
	Page = "Home",
	Search = "",

	Favorites = {},

	Animations = true,
	Effects = true,
	Sound = false,

	Scale = 1,

	Minimized = false,
	Closed = false,
}

--------------------------------------------------------
-- REMOVE OLD GUI
--------------------------------------------------------

local Existing = PlayerGui:FindFirstChild("LucritScripts")

if Existing then
	Existing:Destroy()
end

--------------------------------------------------------
-- GUI
--------------------------------------------------------

local Gui = Instance.new("ScreenGui")
Gui.Name = "LucritScripts"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder = 999
Gui.Parent = PlayerGui

--------------------------------------------------------
-- HELPERS
--------------------------------------------------------

local function Corner(Object, Radius)
	local CornerObject = Instance.new("UICorner")
	CornerObject.CornerRadius = UDim.new(0, Radius or 10)
	CornerObject.Parent = Object

	return CornerObject
end

local function AddStroke(Object, Transparency)
	local Stroke = Instance.new("UIStroke")

	Stroke.Color = Config.Theme.Border
	Stroke.Transparency = Transparency or 0.3
	Stroke.Thickness = 1

	Stroke.Parent = Object

	return Stroke
end

local function Tween(Object, Properties, Duration)
	if not Object or not Object.Parent then
		return
	end

	if not State.Animations then
		for Property, Value in pairs(Properties) do
			pcall(function()
				Object[Property] = Value
			end)
		end

		return
	end

	local Info = TweenInfo.new(
		Duration or 0.25,
		Enum.EasingStyle.Quart,
		Enum.EasingDirection.Out
	)

	local Success, Animation = pcall(function()
		return TweenService:Create(
			Object,
			Info,
			Properties
		)
	end)

	if Success and Animation then
		Animation:Play()
		return Animation
	end
end

local function MakeLabel(
	Parent,
	Text,
	TextSize,
	TextColor,
	Font
)
	local Label = Instance.new("TextLabel")

	Label.BackgroundTransparency = 1
	Label.Text = tostring(Text or "")
	Label.TextColor3 = TextColor or Config.Theme.Text
	Label.TextSize = TextSize or 13
	Label.Font = Font or Enum.Font.Gotham

	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextYAlignment = Enum.TextYAlignment.Center

	Label.Parent = Parent

	return Label
end

--------------------------------------------------------
-- BACKGROUND
--------------------------------------------------------

local Background = Instance.new("Frame")

Background.Name = "Background"
Background.Size = UDim2.fromScale(1, 1)
Background.BackgroundColor3 = Config.Theme.Background
Background.BackgroundTransparency = 0.5
Background.BorderSizePixel = 0

Background.Parent = Gui

local BackgroundGradient = Instance.new("UIGradient")

BackgroundGradient.Rotation = 135

BackgroundGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(
		0,
		Color3.fromRGB(7, 8, 14)
	),

	ColorSequenceKeypoint.new(
		0.5,
		Color3.fromRGB(10, 12, 20)
	),

	ColorSequenceKeypoint.new(
		1,
		Color3.fromRGB(7, 7, 13)
	),
})

BackgroundGradient.Parent = Background

--------------------------------------------------------
-- GLOW
--------------------------------------------------------

local Glow = Instance.new("Frame")

Glow.Name = "Glow"

Glow.Size = UDim2.fromOffset(500, 500)

Glow.Position = UDim2.new(
	0.5,
	-250,
	0.5,
	-250
)

Glow.BackgroundColor3 = Config.Theme.Purple
Glow.BackgroundTransparency = 0.94
Glow.BorderSizePixel = 0

Glow.Parent = Background

Corner(Glow, 500)

--------------------------------------------------------
-- MAIN WINDOW
--------------------------------------------------------

local Window = Instance.new("Frame")

Window.Name = "Window"

Window.AnchorPoint = Vector2.new(0.5, 0.5)

Window.Position = UDim2.fromScale(
	0.5,
	0.5
)

Window.Size = UDim2.new(
	0.82,
	0,
	0.78,
	0
)

Window.BackgroundColor3 = Config.Theme.Panel
Window.BackgroundTransparency = 0.03
Window.BorderSizePixel = 0

Window.ClipsDescendants = true

Window.Parent = Gui

Corner(Window, 17)
AddStroke(Window, 0.2)

--------------------------------------------------------
-- WINDOW GRADIENT
--------------------------------------------------------

local WindowGradient = Instance.new("UIGradient")

WindowGradient.Rotation = 135

WindowGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(
		0,
		Color3.fromRGB(17, 20, 30)
	),

	ColorSequenceKeypoint.new(
		1,
		Color3.fromRGB(9, 11, 17)
	),
})

WindowGradient.Parent = Window

--------------------------------------------------------
-- HEADER
--------------------------------------------------------

local Header = Instance.new("Frame")

Header.Name = "Header"

Header.Size = UDim2.new(
	1,
	0,
	0,
	76
)

Header.BackgroundTransparency = 1
Header.Parent = Window

--------------------------------------------------------
-- BRAND
--------------------------------------------------------

local Brand = MakeLabel(
	Header,
	Config.Brand,
	20,
	Config.Theme.Text,
	Enum.Font.GothamBold
)

Brand.Position = UDim2.fromOffset(
	25,
	12
)

Brand.Size = UDim2.new(
	0.5,
	0,
	0,
	30
)

--------------------------------------------------------
-- SUBTITLE
--------------------------------------------------------

local Subtitle = MakeLabel(
	Header,
	Config.Subtitle,
	10,
	Config.Theme.Primary,
	Enum.Font.GothamBold
)

Subtitle.Position = UDim2.fromOffset(
	26,
	40
)

Subtitle.Size = UDim2.new(
	0.5,
	0,
	0,
	20
)

--------------------------------------------------------
-- STATUS
--------------------------------------------------------

local Status = Instance.new("Frame")

Status.AnchorPoint = Vector2.new(1, 0.5)

Status.Position = UDim2.new(
	1,
	-22,
	0.5,
	0
)

Status.Size = UDim2.fromOffset(
	170,
	38
)

Status.BackgroundColor3 = Config.Theme.Panel2
Status.BorderSizePixel = 0

Status.Parent = Header

Corner(Status, 10)
AddStroke(Status, 0.3)

local StatusDot = Instance.new("Frame")

StatusDot.Position = UDim2.fromOffset(
	13,
	15
)

StatusDot.Size = UDim2.fromOffset(
	8,
	8
)

StatusDot.BackgroundColor3 = Config.Theme.Success
StatusDot.BorderSizePixel = 0

StatusDot.Parent = Status

Corner(StatusDot, 20)

local StatusLabel = MakeLabel(
	Status,
	"Hub Status  •  Online",
	11,
	Config.Theme.Text,
	Enum.Font.GothamMedium
)

StatusLabel.Position = UDim2.fromOffset(
	29,
	0
)

StatusLabel.Size = UDim2.new(
	1,
	-35,
	1,
	0
)

--------------------------------------------------------
-- WINDOW CONTROLS
--------------------------------------------------------

local WindowControls = Instance.new("Frame")

WindowControls.AnchorPoint = Vector2.new(
	1,
	0.5
)

WindowControls.Position = UDim2.new(
	1,
	-205,
	0.5,
	0
)

WindowControls.Size = UDim2.fromOffset(
	72,
	34
)

WindowControls.BackgroundTransparency = 1

WindowControls.Parent = Header

local ControlsLayout = Instance.new("UIListLayout")

ControlsLayout.FillDirection =
	Enum.FillDirection.Horizontal

ControlsLayout.Padding =
	UDim.new(0, 8)

ControlsLayout.VerticalAlignment =
	Enum.VerticalAlignment.Center

ControlsLayout.Parent = WindowControls

local function ControlButton(
	Text,
	TextColor
)
	local Button = Instance.new("TextButton")

	Button.Size = UDim2.fromOffset(
		32,
		32
	)

	Button.BackgroundColor3 =
		Config.Theme.Panel2

	Button.BorderSizePixel = 0

	Button.Text = Text

	Button.TextColor3 =
		TextColor or Config.Theme.Text

	Button.TextSize = 15

	Button.Font =
		Enum.Font.GothamBold

	Button.AutoButtonColor = false

	Button.Parent = WindowControls

	Corner(Button, 9)
	AddStroke(Button, 0.35)

	Button.MouseEnter:Connect(function()
		Tween(
			Button,
			{
				BackgroundColor3 =
					Config.Theme.Panel3
			},
			0.15
		)
	end)

	Button.MouseLeave:Connect(function()
		Tween(
			Button,
			{
				BackgroundColor3 =
					Config.Theme.Panel2
			},
			0.15
		)
	end)

	return Button
end

local MinimizeButton =
	ControlButton("–")

local CloseButton =
	ControlButton(
		"×",
		Config.Theme.Warning
	)

--------------------------------------------------------
-- CONTENT
--------------------------------------------------------

local Content = Instance.new("Frame")

Content.Name = "Content"

Content.Position = UDim2.fromOffset(
	14,
	76
)

Content.Size = UDim2.new(
	1,
	-28,
	1,
	-90
)

Content.BackgroundTransparency = 1

Content.Parent = Window

--------------------------------------------------------
-- TOGGLE BUTTON
--------------------------------------------------------

local ToggleButton = Instance.new("TextButton")

ToggleButton.Name = "ToggleButton"

ToggleButton.Position = UDim2.fromOffset(
	20,
	20
)

ToggleButton.Size = UDim2.fromOffset(
	52,
	52
)

ToggleButton.BackgroundColor3 =
	Config.Theme.Panel

ToggleButton.Text = "L"

ToggleButton.TextColor3 =
	Config.Theme.Primary

ToggleButton.TextSize = 20

ToggleButton.Font =
	Enum.Font.GothamBold

ToggleButton.AutoButtonColor = false

ToggleButton.BorderSizePixel = 0

ToggleButton.Visible = false

ToggleButton.Parent = Gui

Corner(ToggleButton, 26)
AddStroke(ToggleButton, 0.2)

--------------------------------------------------------
-- WINDOW STATE
--------------------------------------------------------

local FullWindowSize = Window.Size

local MinimizedWindowSize = UDim2.new(
	FullWindowSize.X.Scale,
	FullWindowSize.X.Offset,
	0,
	76
)

local function ApplyWindowState()

	if State.Closed then

		Window.Visible = false
		Background.Visible = false
		ToggleButton.Visible = true

		return
	end

	Window.Visible = true
	ToggleButton.Visible = false

	if State.Minimized then

		Content.Visible = false
		Background.Visible = false

		Tween(
			Window,
			{
				Size = MinimizedWindowSize
			},
			0.25
		)

		MinimizeButton.Text = "+"

	else

		Content.Visible = true
		Background.Visible = true

		Tween(
			Window,
			{
				Size = FullWindowSize
			},
			0.25
		)

		MinimizeButton.Text = "–"

	end
end

MinimizeButton.MouseButton1Click:Connect(function()

	State.Minimized =
		not State.Minimized

	ApplyWindowState()
end)

CloseButton.MouseButton1Click:Connect(function()

	State.Closed = true

	ApplyWindowState()
end)

ToggleButton.MouseButton1Click:Connect(function()

	State.Closed = false

	ApplyWindowState()
end)

--------------------------------------------------------
-- SIDEBAR
--------------------------------------------------------

local Sidebar = Instance.new("Frame")

Sidebar.Name = "Sidebar"

Sidebar.Size = UDim2.fromOffset(
	150,
	0
)

Sidebar.BackgroundColor3 =
	Config.Theme.Panel2

Sidebar.BorderSizePixel = 0

Sidebar.Parent = Content

Corner(Sidebar, 12)
AddStroke(Sidebar, 0.35)

local SidebarPadding =
	Instance.new("UIPadding")

SidebarPadding.PaddingTop =
	UDim.new(0, 10)

SidebarPadding.PaddingLeft =
	UDim.new(0, 9)

SidebarPadding.PaddingRight =
	UDim.new(0, 9)

SidebarPadding.Parent =
	Sidebar

local SidebarLayout =
	Instance.new("UIListLayout")

SidebarLayout.Padding =
	UDim.new(0, 6)

SidebarLayout.SortOrder =
	Enum.SortOrder.LayoutOrder

SidebarLayout.Parent =
	Sidebar

--------------------------------------------------------
-- PAGES
--------------------------------------------------------

local Pages = Instance.new("Frame")

Pages.Name = "Pages"

Pages.Position =
	UDim2.fromOffset(162, 0)

Pages.Size =
	UDim2.new(
		1,
		-162,
		1,
		0
	)

Pages.BackgroundTransparency = 1

Pages.Parent = Content

local PageObjects = {}

local function CreatePage(Name)

	local Page = Instance.new("Frame")

	Page.Name = Name

	Page.Size =
		UDim2.fromScale(1, 1)

	Page.BackgroundTransparency = 1

	Page.Visible = false

	Page.Parent = Pages

	PageObjects[Name] = Page

	return Page
end

local HomePage =
	CreatePage("Home")

local ScriptsPage =
	CreatePage("Scripts")

local FavoritesPage =
	CreatePage("Favorites")

local SettingsPage =
	CreatePage("Settings")

local InfoPage =
	CreatePage("Info")

--------------------------------------------------------
-- PAGE TITLE
--------------------------------------------------------

local function PageTitle(
	Page,
	Title,
	Description
)

	local TitleObject = MakeLabel(
		Page,
		Title,
		24,
		Config.Theme.Text,
		Enum.Font.GothamBold
	)

	TitleObject.Position =
		UDim2.fromOffset(10, 3)

	TitleObject.Size =
		UDim2.new(
			1,
			-20,
			0,
			32
		)

	local DescriptionObject =
		MakeLabel(
			Page,
			Description,
			11,
			Config.Theme.Muted,
			Enum.Font.Gotham
		)

	DescriptionObject.Position =
		UDim2.fromOffset(11, 36)

	DescriptionObject.Size =
		UDim2.new(
			1,
			-20,
			0,
			24
		)
end

PageTitle(
	HomePage,
	"Welcome to Lucrit",
	"Your premium Steal a Egg resource collection."
)

PageTitle(
	ScriptsPage,
	"Scripts",
	"Browse available resources."
)

PageTitle(
	FavoritesPage,
	"Favorites",
	"Your saved resources."
)

PageTitle(
	SettingsPage,
	"Settings",
	"Customize your Lucrit experience."
)

PageTitle(
	InfoPage,
	"Information",
	"About Lucrit Scripts."
)

--------------------------------------------------------
-- HOME CARD
--------------------------------------------------------

local HomeCard = Instance.new("Frame")

HomeCard.Position =
	UDim2.fromOffset(10, 78)

HomeCard.Size =
	UDim2.new(
		1,
		-20,
		0,
		205
	)

HomeCard.BackgroundColor3 =
	Config.Theme.Panel

HomeCard.BorderSizePixel = 0

HomeCard.Parent = HomePage

Corner(HomeCard, 14)
AddStroke(HomeCard, 0.3)

local HomeTitle = MakeLabel(
	HomeCard,
	"LUCRIT SCRIPTS",
	28,
	Config.Theme.Text,
	Enum.Font.GothamBold
)

HomeTitle.Position =
	UDim2.fromOffset(22, 20)

HomeTitle.Size =
	UDim2.new(
		1,
		-44,
		0,
		35
	)

local HomeSub = MakeLabel(
	HomeCard,
	"STEAL A EGG HUB",
	12,
	Config.Theme.Primary,
	Enum.Font.GothamBold
)

HomeSub.Position =
	UDim2.fromOffset(24, 57)

HomeSub.Size =
	UDim2.new(
		1,
		-44,
		0,
		20
	)

local HomeText = MakeLabel(
	HomeCard,
	"Premium resources. Clean interface. Built for Lucrit.",
	12,
	Config.Theme.Muted,
	Enum.Font.Gotham
)

HomeText.Position =
	UDim2.fromOffset(24, 87)

HomeText.Size =
	UDim2.new(
		1,
		-48,
		0,
		25
	)

local Stats = MakeLabel(
	HomeCard,
	"● ONLINE     •     SCRIPTS "
		.. tostring(#Scripts)
		.. "     •     VERSION "
		.. Config.Version,
	11,
	Config.Theme.Success,
	Enum.Font.GothamMedium
)

Stats.Position =
	UDim2.fromOffset(24, 128)

Stats.Size =
	UDim2.new(
		1,
		-48,
		0,
		25
	)

--------------------------------------------------------
-- SEARCH
--------------------------------------------------------

local Search = Instance.new("TextBox")

Search.Position =
	UDim2.fromOffset(10, 70)

Search.Size =
	UDim2.new(
		1,
		-20,
		0,
		42
	)

Search.BackgroundColor3 =
	Config.Theme.Panel2

Search.BorderSizePixel = 0

Search.Text = ""

Search.PlaceholderText =
	"Search scripts or games..."

Search.PlaceholderColor3 =
	Config.Theme.Muted

Search.TextColor3 =
	Config.Theme.Text

Search.TextSize = 11

Search.Font =
	Enum.Font.Gotham

Search.ClearTextOnFocus = false

Search.Parent =
	ScriptsPage

Corner(Search, 10)
AddStroke(Search, 0.3)

local SearchPadding =
	Instance.new("UIPadding")

SearchPadding.PaddingLeft =
	UDim.new(0, 13)

SearchPadding.PaddingRight =
	UDim.new(0, 13)

SearchPadding.Parent =
	Search

--------------------------------------------------------
-- SCRIPT SCROLL
--------------------------------------------------------

local ScriptScroll =
	Instance.new("ScrollingFrame")

ScriptScroll.Position =
	UDim2.fromOffset(10, 122)

ScriptScroll.Size =
	UDim2.new(
		1,
		-20,
		1,
		-132
	)

ScriptScroll.BackgroundTransparency = 1
ScriptScroll.BorderSizePixel = 0

ScriptScroll.ScrollBarThickness = 3

ScriptScroll.ScrollBarImageColor3 =
	Config.Theme.Primary

ScriptScroll.AutomaticCanvasSize =
	Enum.AutomaticSize.Y

ScriptScroll.CanvasSize =
	UDim2.new(0, 0, 0, 0)

ScriptScroll.Parent =
	ScriptsPage

local ScriptLayout =
	Instance.new("UIListLayout")

ScriptLayout.Padding =
	UDim.new(0, 9)

ScriptLayout.SortOrder =
	Enum.SortOrder.LayoutOrder

ScriptLayout.Parent =
	ScriptScroll

--------------------------------------------------------
-- FAVORITE SCROLL
--------------------------------------------------------

local FavoriteScroll =
	Instance.new("ScrollingFrame")

FavoriteScroll.Position =
	UDim2.fromOffset(10, 70)

FavoriteScroll.Size =
	UDim2.new(
		1,
		-20,
		1,
		-80
	)

FavoriteScroll.BackgroundTransparency = 1
FavoriteScroll.BorderSizePixel = 0

FavoriteScroll.ScrollBarThickness = 3

FavoriteScroll.ScrollBarImageColor3 =
	Config.Theme.Primary

FavoriteScroll.AutomaticCanvasSize =
	Enum.AutomaticSize.Y

FavoriteScroll.Parent =
	FavoritesPage

local FavoriteLayout =
	Instance.new("UIListLayout")

FavoriteLayout.Padding =
	UDim.new(0, 9)

FavoriteLayout.SortOrder =
	Enum.SortOrder.LayoutOrder

FavoriteLayout.Parent =
	FavoriteScroll

--------------------------------------------------------
-- NOTIFICATIONS
--------------------------------------------------------

local NotificationHolder =
	Instance.new("Frame")

NotificationHolder.AnchorPoint =
	Vector2.new(1, 1)

NotificationHolder.Position =
	UDim2.new(
		1,
		-20,
		1,
		-20
	)

NotificationHolder.Size =
	UDim2.fromOffset(
		310,
		300
	)

NotificationHolder.BackgroundTransparency = 1

NotificationHolder.Parent = Gui

local NotificationLayout =
	Instance.new("UIListLayout")

NotificationLayout.VerticalAlignment =
	Enum.VerticalAlignment.Bottom

NotificationLayout.HorizontalAlignment =
	Enum.HorizontalAlignment.Right

NotificationLayout.Padding =
	UDim.new(0, 8)

NotificationLayout.Parent =
	NotificationHolder

local function Notify(
	Title,
	Message
)

	local Notification =
		Instance.new("Frame")

	Notification.Size =
		UDim2.fromOffset(
			300,
			70
		)

	Notification.BackgroundColor3 =
		Config.Theme.Panel

	Notification.BorderSizePixel = 0

	Notification.Parent =
		NotificationHolder

	Corner(Notification, 11)
	AddStroke(Notification, 0.2)

	local Accent =
		Instance.new("Frame")

	Accent.Size =
		UDim2.new(
			0,
			3,
			1,
			0
		)

	Accent.BackgroundColor3 =
		Config.Theme.Primary

	Accent.BorderSizePixel = 0

	Accent.Parent =
		Notification

	Corner(Accent, 3)

	local TitleLabel =
		MakeLabel(
			Notification,
			Title,
			12,
			Config.Theme.Text,
			Enum.Font.GothamBold
		)

	TitleLabel.Position =
		UDim2.fromOffset(15, 8)

	TitleLabel.Size =
		UDim2.new(
			1,
			-25,
			0,
			22
		)

	local MessageLabel =
		MakeLabel(
			Notification,
			Message,
			10,
			Config.Theme.Muted,
			Enum.Font.Gotham
		)

	MessageLabel.Position =
		UDim2.fromOffset(15, 30)

	MessageLabel.Size =
		UDim2.new(
			1,
			-25,
			0,
			30
		)

	MessageLabel.TextWrapped = true

	Notification.Position =
		UDim2.new(
			1,
			320,
			0,
			0
		)

	Tween(
		Notification,
		{
			Position =
				UDim2.new(
					0,
					0,
					0,
					0
				)
		},
		0.35
	)

	task.delay(3, function()

		if not Notification.Parent then
			return
		end

		local Animation =
			Tween(
				Notification,
				{
					Position =
						UDim2.new(
							1,
							320,
							0,
							0
						)
				},
				0.3
			)

		if Animation then
			Animation.Completed:Wait()
		end

		if Notification then
			Notification:Destroy()
		end
	end)
end

--------------------------------------------------------
-- FAVORITES
--------------------------------------------------------

local function IsFavorite(Id)
	return State.Favorites[Id] == true
end

local RefreshFavorites

local function ToggleFavorite(Data)

	if not Data or not Data.name then
		return
	end

	State.Favorites[Data.name] =
		not State.Favorites[Data.name]

	if State.Favorites[Data.name] then

		Notify(
			"Added to favorites",
			Data.name .. " was added."
		)

	else

		Notify(
			"Removed from favorites",
			Data.name .. " was removed."
		)

	end
end

--------------------------------------------------------
-- SEARCH
--------------------------------------------------------

local function Matches(
	Data,
	Query
)

	if type(Data) ~= "table" then
		return false
	end

	Query =
		string.lower(
			tostring(Query or "")
		)

	if Query == "" then
		return true
	end

	local Name =
		string.lower(
			tostring(Data.name or "")
		)

	local Game =
		string.lower(
			tostring(Data.game or "")
		)

	local Description =
		string.lower(
			tostring(Data.description or "")
		)

	local Text =
		Name
		.. " "
		.. Game
		.. " "
		.. Description

	return string.find(
		Text,
		Query,
		1,
		true
	) ~= nil
end

--------------------------------------------------------
-- CLEAR LIST
--------------------------------------------------------

local function ClearList(Parent)

	for _, Object in ipairs(
		Parent:GetChildren()
	) do

		if not Object:IsA(
			"UIListLayout"
		) then

			Object:Destroy()
		end
	end
end

--------------------------------------------------------
-- SOURCE VIEWER
--------------------------------------------------------

local function ShowSource(Data)

	local Overlay =
		Instance.new("Frame")

	Overlay.Name =
		"SourceViewer"

	Overlay.Size =
		UDim2.fromScale(
			1,
			1
		)

	Overlay.BackgroundColor3 =
		Color3.fromRGB(
			0,
			0,
			0
		)

	Overlay.BackgroundTransparency =
		0.35

	Overlay.BorderSizePixel = 0

	Overlay.ZIndex = 100

	Overlay.Parent = Gui

	local Panel =
		Instance.new("Frame")

	Panel.AnchorPoint =
		Vector2.new(
			0.5,
			0.5
		)

	Panel.Position =
		UDim2.fromScale(
			0.5,
			0.5
		)

	Panel.Size =
		UDim2.new(
			0.7,
			0,
			0.7,
			0
		)

	Panel.BackgroundColor3 =
		Config.Theme.Panel

	Panel.BorderSizePixel = 0

	Panel.ZIndex = 101

	Panel.Parent = Overlay

	Corner(Panel, 14)
	AddStroke(Panel, 0.2)

	local Title =
		MakeLabel(
			Panel,
			Data.name or "Script Source",
			18,
			Config.Theme.Text,
			Enum.Font.GothamBold
		)

	Title.Position =
		UDim2.fromOffset(
			18,
			12
		)

	Title.Size =
		UDim2.new(
			1,
			-80,
			0,
			30
		)

	Title.ZIndex = 102

	local Close =
		Instance.new("TextButton")

	Close.AnchorPoint =
		Vector2.new(
			1,
			0
		)

	Close.Position =
		UDim2.new(
			1,
			-12,
			0,
			12
		)

	Close.Size =
		UDim2.fromOffset(
			34,
			34
		)

	Close.BackgroundColor3 =
		Config.Theme.Panel2

	Close.Text = "×"

	Close.TextColor3 =
		Config.Theme.Warning

	Close.TextSize = 18

	Close.Font =
		Enum.Font.GothamBold

	Close.AutoButtonColor = false

	Close.BorderSizePixel = 0

	Close.ZIndex = 102

	Close.Parent = Panel

	Corner(Close, 8)

	Close.MouseButton1Click:Connect(function()
		Overlay:Destroy()
	end)

	local SourceBox =
		Instance.new("TextBox")

	SourceBox.Position =
		UDim2.fromOffset(
			18,
			58
		)

	SourceBox.Size =
		UDim2.new(
			1,
			-36,
			1,
			-110
		)

	SourceBox.BackgroundColor3 =
		Config.Theme.Panel2

	SourceBox.BorderSizePixel = 0

	SourceBox.Text =
		tostring(
			Data.loadstring or
			"No source provided."
		)

	SourceBox.TextColor3 =
		Config.Theme.Text

	SourceBox.PlaceholderColor3 =
		Config.Theme.Muted

	SourceBox.TextSize = 11

	SourceBox.Font =
		Enum.Font.Code

	SourceBox.TextXAlignment =
		Enum.TextXAlignment.Left

	SourceBox.TextYAlignment =
		Enum.TextYAlignment.Top

	SourceBox.MultiLine = true

	SourceBox.ClearTextOnFocus = false

	SourceBox.TextEditable = false

	SourceBox.ZIndex = 102

	SourceBox.Parent = Panel

	Corner(SourceBox, 10)
	AddStroke(SourceBox, 0.3)

	local Notice =
		MakeLabel(
			Panel,
			"Source viewer • Review code before using it.",
			10,
			Config.Theme.Muted,
			Enum.Font.Gotham
		)

	Notice.Position =
		UDim2.new(
			0,
			18,
			1,
			-42
		)

	Notice.Size =
		UDim2.new(
			1,
			-36,
			0,
			25
		)

	Notice.ZIndex = 102
end

--------------------------------------------------------
-- SCRIPT CARD
--------------------------------------------------------

local function CreateScriptCard(
	Data,
	Parent
)

	if type(Data) ~= "table" then
		return
	end

	if type(Data.name) ~= "string" then
		return
	end

	local Card =
		Instance.new("Frame")

	Card.Name =
		"ScriptCard"

	Card.Size =
		UDim2.new(
			1,
			-2,
			0,
			142
		)

	Card.BackgroundColor3 =
		Config.Theme.Panel

	Card.BorderSizePixel = 0

	Card.Parent = Parent

	Corner(Card, 12)
	AddStroke(Card, 0.3)

	----------------------------------------------------
	-- ICON
	----------------------------------------------------

	local Icon =
		Instance.new("Frame")

	Icon.Position =
		UDim2.fromOffset(
			12,
			12
		)

	Icon.Size =
		UDim2.fromOffset(
			84,
			84
		)

	Icon.BackgroundColor3 =
		Config.Theme.Panel3

	Icon.BorderSizePixel = 0

	Icon.Parent = Card

	Corner(Icon, 10)

	local IconGradient =
		Instance.new("UIGradient")

	IconGradient.Rotation = 135

	IconGradient.Color =
		ColorSequence.new({
			ColorSequenceKeypoint.new(
				0,
				Config.Theme.Primary
			),

			ColorSequenceKeypoint.new(
				1,
				Config.Theme.Purple
			),
		})

	IconGradient.Transparency =
		NumberSequence.new({
			NumberSequenceKeypoint.new(
				0,
				0.82
			),

			NumberSequenceKeypoint.new(
				1,
				0.92
			),
		})

	IconGradient.Parent = Icon

	local Initials =
		string.sub(
			Data.name,
			1,
			2
		):upper()

	local IconText =
		MakeLabel(
			Icon,
			Initials,
			23,
			Config.Theme.Text,
			Enum.Font.GothamBold
		)

	IconText.Size =
		UDim2.fromScale(
			1,
			1
		)

	IconText.TextXAlignment =
		Enum.TextXAlignment.Center

	----------------------------------------------------
	-- NAME
	----------------------------------------------------

	local Name =
		MakeLabel(
			Card,
			Data.name,
			16,
			Config.Theme.Text,
			Enum.Font.GothamBold
		)

	Name.Position =
		UDim2.fromOffset(
			108,
			12
		)

	Name.Size =
		UDim2.new(
			1,
			-270,
			0,
			24
		)

	----------------------------------------------------
	-- GAME
	----------------------------------------------------

	local Game =
		MakeLabel(
			Card,
			Data.game or "Unknown Game",
			11,
			Config.Theme.Primary,
			Enum.Font.GothamMedium
		)

	Game.Position =
		UDim2.fromOffset(
			108,
			36
		)

	Game.Size =
		UDim2.new(
			1,
			-270,
			0,
			20
		)

	----------------------------------------------------
	-- DESCRIPTION
	----------------------------------------------------

	local Description =
		MakeLabel(
			Card,
			Data.description or "No description provided.",
			10,
			Config.Theme.Muted,
			Enum.Font.Gotham
		)

	Description.Position =
		UDim2.fromOffset(
			108,
			60
		)

	Description.Size =
		UDim2.new(
			1,
			-270,
			0,
			40
		)

	Description.TextWrapped = true
	Description.TextYAlignment =
		Enum.TextYAlignment.Top

	----------------------------------------------------
	-- STATUS
	----------------------------------------------------

	local StatusLabel =
		MakeLabel(
			Card,
			"● READY",
			10,
			Config.Theme.Success,
			Enum.Font.GothamMedium
		)

	StatusLabel.AnchorPoint =
		Vector2.new(
			1,
			0
		)

	StatusLabel.Position =
		UDim2.new(
			1,
			-14,
			0,
			12
		)

	StatusLabel.Size =
		UDim2.fromOffset(
			80,
			18
		)

	StatusLabel.TextXAlignment =
		Enum.TextXAlignment.Right

	----------------------------------------------------
	-- FAVORITE
	----------------------------------------------------

	local Favorite =
		Instance.new("TextButton")

	Favorite.AnchorPoint =
		Vector2.new(
			1,
			1
		)

	Favorite.Position =
		UDim2.new(
			1,
			-130,
			1,
			-13
		)

	Favorite.Size =
		UDim2.fromOffset(
			35,
			34
		)

	Favorite.BackgroundColor3 =
		Config.Theme.Panel3

	Favorite.Text =
		IsFavorite(Data.name)
		and "★"
		or "☆"

	Favorite.TextColor3 =
		IsFavorite(Data.name)
		and Config.Theme.Warning
		or Config.Theme.Text

	Favorite.TextSize = 18

	Favorite.Font =
		Enum.Font.GothamBold

	Favorite.AutoButtonColor = false

	Favorite.BorderSizePixel = 0

	Favorite.Parent = Card

	Corner(Favorite, 8)
	AddStroke(Favorite, 0.35)

	Favorite.MouseEnter:Connect(
		function()

			Tween(
				Favorite,
				{
					BackgroundColor3 =
						Color3.fromRGB(
							32,
							37,
							51
						)
				},
				0.15
			)

		end
	)

	Favorite.MouseLeave:Connect(
		function()

			Tween(
				Favorite,
				{
					BackgroundColor3 =
						Config.Theme.Panel3
				},
				0.15
			)

		end
	)

	Favorite.MouseButton1Click:Connect(
		function()

			ToggleFavorite(Data)

			Favorite.Text =
				IsFavorite(Data.name)
				and "★"
				or "☆"

			Favorite.TextColor3 =
				IsFavorite(Data.name)
				and Config.Theme.Warning
				or Config.Theme.Text

			if State.Page == "Favorites" then

				task.wait()

				if RefreshFavorites then
					RefreshFavorites()
				end

			end

		end
	)

	----------------------------------------------------
	-- SELECT / VIEW
	----------------------------------------------------

	local Select =
		Instance.new("TextButton")

	Select.AnchorPoint =
		Vector2.new(
			1,
			1
		)

	Select.Position =
		UDim2.new(
			1,
			-14,
			1,
			-13
		)

	Select.Size =
		UDim2.fromOffset(
			105,
			34
		)

	Select.BackgroundColor3 =
		Config.Theme.Primary

	Select.Text =
		"VIEW"

	Select.TextColor3 =
		Color3.new(
			1,
			1,
			1
		)

	Select.TextSize = 10

	Select.Font =
		Enum.Font.GothamBold

	Select.AutoButtonColor = false

	Select.BorderSizePixel = 0

	Select.Parent = Card

	Corner(Select, 8)

	Select.MouseEnter:Connect(
		function()

			Tween(
				Select,
				{
					BackgroundColor3 =
						Config.Theme.Cyan
				},
				0.15
			)

		end
	)

	Select.MouseLeave:Connect(
		function()

			Tween(
				Select,
				{
					BackgroundColor3 =
						Config.Theme.Primary
				},
				0.15
			)

		end
	)

	Select.MouseButton1Click:Connect(
		function()

			ShowSource(Data)

		end
	)

	----------------------------------------------------
	-- HOVER
	----------------------------------------------------

	Card.MouseEnter:Connect(
		function()

			Tween(
				Card,
				{
					BackgroundColor3 =
						Color3.fromRGB(
							19,
							23,
							33
						)
				},
				0.18
			)

		end
	)

	Card.MouseLeave:Connect(
		function()

			Tween(
				Card,
				{
					BackgroundColor3 =
						Config.Theme.Panel
				},
				0.18
			)

		end
	)

	return Card
end

--------------------------------------------------------
-- RENDER SCRIPTS
--------------------------------------------------------

local function RenderScripts()

	ClearList(
		ScriptScroll
	)

	local Found = 0

	for _, Data in ipairs(Scripts) do

		if Matches(
			Data,
			State.Search
		) then

			CreateScriptCard(
				Data,
				ScriptScroll
			)

			Found += 1
		end
	end

	if Found == 0 then

		local Empty =
			MakeLabel(
				ScriptScroll,
				"No scripts found.",
				12,
				Config.Theme.Muted,
				Enum.Font.GothamMedium
			)

		Empty.Size =
			UDim2.new(
				1,
				0,
				0,
				50
			)

		Empty.TextXAlignment =
			Enum.TextXAlignment.Center
	end
end

--------------------------------------------------------
-- RENDER FAVORITES
--------------------------------------------------------

RefreshFavorites = function()

	ClearList(
		FavoriteScroll
	)

	local Found = 0

	for _, Data in ipairs(Scripts) do

		if IsFavorite(Data.name) then

			CreateScriptCard(
				Data,
				FavoriteScroll
			)

			Found += 1
		end
	end

	if Found == 0 then

		local Empty =
			MakeLabel(
				FavoriteScroll,
				"No favorite scripts yet.",
				12,
				Config.Theme.Muted,
				Enum.Font.GothamMedium
			)

		Empty.Size =
			UDim2.new(
				1,
				0,
				0,
				50
			)

		Empty.TextXAlignment =
			Enum.TextXAlignment.Center
	end
end

--------------------------------------------------------
-- SEARCH EVENT
--------------------------------------------------------

Search:GetPropertyChangedSignal(
	"Text"
):Connect(
	function()

		State.Search =
			Search.Text

		RenderScripts()

	end
)

--------------------------------------------------------
-- NAVIGATION
--------------------------------------------------------

local NavigationButtons = {}

local NavigationData = {

	{
		Name = "Home",
		Text = "⌂   Home",
	},

	{
		Name = "Scripts",
		Text = "⚔   Scripts",
	},

	{
		Name = "Favorites",
		Text = "★   Favorites",
	},

	{
		Name = "Settings",
		Text = "⚙   Settings",
	},

	{
		Name = "Info",
		Text = "ⓘ   Info",
	},

}

local function Navigate(Name)

	if not PageObjects[Name] then
		return
	end

	State.Page = Name

	for PageName, Page in pairs(
		PageObjects
	) do

		Page.Visible =
			PageName == Name
	end

	for ButtonName, Button in pairs(
		NavigationButtons
	) do

		if ButtonName == Name then

			Tween(
				Button,
				{
					BackgroundColor3 =
						Color3.fromRGB(
							34,
							42,
							61
						),

					TextColor3 =
						Config.Theme.Text,
				},
				0.18
			)

		else

			Tween(
				Button,
				{
					BackgroundColor3 =
						Config.Theme.Panel2,

					TextColor3 =
						Config.Theme.Muted,
				},
				0.18
			)

		end
	end

	if Name == "Favorites" then

		RefreshFavorites()

	end
end

--------------------------------------------------------
-- NAVIGATION BUTTONS
--------------------------------------------------------

for Index, Item in ipairs(
	NavigationData
) do

	local Button =
		Instance.new("TextButton")

	Button.Size =
		UDim2.new(
			1,
			0,
			0,
			40
		)

	Button.BackgroundColor3 =
		Config.Theme.Panel2

	Button.BorderSizePixel = 0

	Button.Text =
		Item.Text

	Button.TextColor3 =
		Config.Theme.Muted

	Button.TextSize = 11

	Button.Font =
		Enum.Font.GothamMedium

	Button.TextXAlignment =
		Enum.TextXAlignment.Left

	Button.AutoButtonColor = false

	Button.LayoutOrder =
		Index

	Button.Parent =
		Sidebar

	Corner(Button, 9)

	local Padding =
		Instance.new("UIPadding")

	Padding.PaddingLeft =
		UDim.new(
			0,
			12
		)

	Padding.Parent =
		Button

	Button.MouseEnter:Connect(
		function()

			if State.Page ~= Item.Name then

				Tween(
					Button,
					{
						BackgroundColor3 =
							Color3.fromRGB(
								27,
								31,
								43
							)
					},
					0.15
				)

			end
		end
	)

	Button.MouseLeave:Connect(
		function()

			if State.Page ~= Item.Name then

				Tween(
					Button,
					{
						BackgroundColor3 =
							Config.Theme.Panel2
					},
					0.15
				)

			end
		end
	)

	Button.MouseButton1Click:Connect(
		function()

			Navigate(
				Item.Name
			)

		end
	)

	NavigationButtons[
		Item.Name
	] = Button
end

--------------------------------------------------------
-- SETTINGS
--------------------------------------------------------

local SettingsContainer =
	Instance.new("Frame")

SettingsContainer.Position =
	UDim2.fromOffset(
		10,
		70
	)

SettingsContainer.Size =
	UDim2.new(
		1,
		-20,
		1,
		-70
	)

SettingsContainer.BackgroundTransparency = 1

SettingsContainer.Parent =
	SettingsPage

local SettingsLayout =
	Instance.new("UIListLayout")

SettingsLayout.Padding =
	UDim.new(
		0,
		8
	)

SettingsLayout.Parent =
	SettingsContainer

local function SettingButton(Text)

	local Button =
		Instance.new("TextButton")

	Button.Size =
		UDim2.new(
			1,
			0,
			0,
			42
		)

	Button.BackgroundColor3 =
		Config.Theme.Panel2

	Button.BorderSizePixel = 0

	Button.Text =
		Text

	Button.TextColor3 =
		Config.Theme.Text

	Button.TextSize = 11

	Button.Font =
		Enum.Font.GothamMedium

	Button.TextXAlignment =
		Enum.TextXAlignment.Left

	Button.AutoButtonColor = false

	Button.Parent =
		SettingsContainer

	Corner(Button, 9)
	AddStroke(Button, 0.35)

	local Padding =
		Instance.new("UIPadding")

	Padding.PaddingLeft =
		UDim.new(
			0,
			14
		)

	Padding.Parent =
		Button

	return Button
end

--------------------------------------------------------
-- ANIMATIONS SETTING
--------------------------------------------------------

local AnimationButton =
	SettingButton(
		"Animations: ON"
	)

AnimationButton.MouseButton1Click:Connect(
	function()

		State.Animations =
			not State.Animations

		AnimationButton.Text =
			"Animations: "
			.. (
				State.Animations
				and "ON"
				or "OFF"
			)

	end
)

--------------------------------------------------------
-- EFFECTS SETTING
--------------------------------------------------------

local EffectsButton =
	SettingButton(
		"Background Effects: ON"
	)

EffectsButton.MouseButton1Click:Connect(
	function()

		State.Effects =
			not State.Effects

		Glow.Visible =
			State.Effects

		EffectsButton.Text =
			"Background Effects: "
			.. (
				State.Effects
				and "ON"
				or "OFF"
			)

	end
)

--------------------------------------------------------
-- SOUND SETTING
--------------------------------------------------------

local SoundButton =
	SettingButton(
		"Sound Effects: OFF"
	)

SoundButton.MouseButton1Click:Connect(
	function()

		State.Sound =
			not State.Sound

		SoundButton.Text =
			"Sound Effects: "
			.. (
				State.Sound
				and "ON"
				or "OFF"
			)

	end
)

--------------------------------------------------------
-- SCALE SETTING
--------------------------------------------------------

local ScaleButton =
	SettingButton(
		"UI Scale: 100%"
	)

ScaleButton.MouseButton1Click:Connect(
	function()

		State.Scale += 0.1

		if State.Scale > 1.3 then
			State.Scale = 0.8
		end

		ScaleButton.Text =
			"UI Scale: "
			.. math.floor(
				State.Scale * 100
			)
			.. "%"

		local Scale =
			Window:FindFirstChild(
				"UserScale"
			)

		if not Scale then

			Scale =
				Instance.new(
					"UIScale"
				)

			Scale.Name =
				"UserScale"

			Scale.Parent =
				Window

		end

		Tween(
			Scale,
			{
				Scale =
					State.Scale
			},
			0.25
		)

	end
)

--------------------------------------------------------
-- RESET
--------------------------------------------------------

local ResetButton =
	SettingButton(
		"Reset UI Settings"
	)

ResetButton.MouseButton1Click:Connect(
	function()

		State.Animations = true
		State.Effects = true
		State.Sound = false
		State.Scale = 1

		AnimationButton.Text =
			"Animations: ON"

		EffectsButton.Text =
			"Background Effects: ON"

		SoundButton.Text =
			"Sound Effects: OFF"

		ScaleButton.Text =
			"UI Scale: 100%"

		Glow.Visible = true

		local Scale =
			Window:FindFirstChild(
				"UserScale"
			)

		if Scale then
			Scale.Scale = 1
		end

		Notify(
			"Settings reset",
			"Lucrit settings restored."
		)

	end
)

--------------------------------------------------------
-- INFO PAGE
--------------------------------------------------------

local InfoCard =
	Instance.new("Frame")

InfoCard.Position =
	UDim2.fromOffset(
		10,
		70
	)

InfoCard.Size =
	UDim2.new(
		1,
		-20,
		0,
		245
	)

InfoCard.BackgroundColor3 =
	Config.Theme.Panel

InfoCard.BorderSizePixel = 0

InfoCard.Parent =
	InfoPage

Corner(InfoCard, 13)
AddStroke(InfoCard, 0.3)

local InfoTitle =
	MakeLabel(
		InfoCard,
		"LUCRIT SCRIPTS",
		21,
		Config.Theme.Text,
		Enum.Font.GothamBold
	)

InfoTitle.Position =
	UDim2.fromOffset(
		20,
		20
	)

InfoTitle.Size =
	UDim2.new(
		1,
		-40,
		0,
		30
	)

local InfoText =
	MakeLabel(
		InfoCard,

		"STEAL A EGG HUB\n\n"
			.. "Version: "
			.. Config.Version
			.. "\n"
			.. "Scripts: "
			.. #Scripts
			.. "\n"
			.. "Status: Online\n\n"
			.. "This hub is a script library. "
			.. "Use the View button to inspect "
			.. "the source associated with each "
			.. "entry before using it.",

	11,

	Config.Theme.Muted,

	Enum.Font.Gotham
)

InfoText.Position =
	UDim2.fromOffset(
		20,
		58
	)

InfoText.Size =
	UDim2.new(
		1,
		-40,
		0,
		170
	)

InfoText.TextWrapped = true
InfoText.TextYAlignment =
	Enum.TextYAlignment.Top

--------------------------------------------------------
-- RESPONSIVE SCALE
--------------------------------------------------------

local ResponsiveScale =
	Instance.new("UIScale")

ResponsiveScale.Name =
	"ResponsiveScale"

ResponsiveScale.Parent =
	Window

local function UpdateScale()

	local Camera =
		workspace.CurrentCamera

	if not Camera then
		return
	end

	local Viewport =
		Camera.ViewportSize

	if Viewport.X < 600 then

		ResponsiveScale.Scale =
			0.70

	elseif Viewport.X < 850 then

		ResponsiveScale.Scale =
			0.84

	else

		ResponsiveScale.Scale =
			1

	end
end

local Camera =
	workspace.CurrentCamera

if Camera then

	Camera:GetPropertyChangedSignal(
		"ViewportSize"
	):Connect(
		UpdateScale
	)

end

UpdateScale()

--------------------------------------------------------
-- DRAGGING
--------------------------------------------------------

local Dragging = false
local DragStart = nil
local StartPosition = nil

local function IsInteractive(Object)

	if not Object then
		return false
	end

	return Object:IsA("TextButton")
		or Object:IsA("ImageButton")
		or Object:IsA("TextBox")
end

Window.InputBegan:Connect(
	function(Input)

		if
			Input.UserInputType
			~= Enum.UserInputType.MouseButton1
			and
			Input.UserInputType
			~= Enum.UserInputType.Touch
		then
			return
		end

		local Objects =
			PlayerGui:GetGuiObjectsAtPosition(
				Input.Position.X,
				Input.Position.Y
			)

		for _, Object in ipairs(
			Objects
		) do

			if IsInteractive(Object) then
				return
			end
		end

		Dragging = true

		DragStart =
			Input.Position

		StartPosition =
			Window.Position

	end
)

Window.InputEnded:Connect(
	function(Input)

		if
			Input.UserInputType
			== Enum.UserInputType.MouseButton1
			or
			Input.UserInputType
			== Enum.UserInputType.Touch
		then

			Dragging = false

		end

	end
)

UserInputService.InputChanged:Connect(
	function(Input)

		if not Dragging then
			return
		end

		if
			Input.UserInputType
			~= Enum.UserInputType.MouseMovement
			and
			Input.UserInputType
			~= Enum.UserInputType.Touch
		then
			return
		end

		if not DragStart or not StartPosition then
			return
		end

		local Delta =
			Input.Position
			- DragStart

		Window.Position =
			UDim2.new(
				StartPosition.X.Scale,
				StartPosition.X.Offset
					+ Delta.X,

				StartPosition.Y.Scale,
				StartPosition.Y.Offset
					+ Delta.Y
			)

	end
)

--------------------------------------------------------
-- BACKGROUND ANIMATION
--------------------------------------------------------

task.spawn(
	function()

		while Gui.Parent do

			if State.Effects
				and Glow.Parent
			then

				local Time =
					os.clock()

				Glow.Position =
					UDim2.new(
						0.5
							+ math.sin(
								Time * 0.35
							) * 0.08,

						-250,

						0.5
							+ math.cos(
								Time * 0.3
							) * 0.08,

						-250
					)

				Glow.BackgroundTransparency =
					0.935
					+ math.sin(
						Time * 0.7
					) * 0.015

			end

			task.wait(0.04)

		end

	end
)

--------------------------------------------------------
-- OPEN ANIMATION
--------------------------------------------------------

local OriginalSize =
	Window.Size

Window.Size =
	UDim2.new(
		OriginalSize.X.Scale * 0.88,
		0,
		OriginalSize.Y.Scale * 0.88,
		0
	)

Window.BackgroundTransparency = 1

Tween(
	Window,
	{
		Size = OriginalSize,
		BackgroundTransparency = 0.03,
	},
	0.55
)

--------------------------------------------------------
-- INITIALIZE
--------------------------------------------------------

RenderScripts()

Navigate("Home")

task.delay(
	0.7,
	function()

		if Gui.Parent then

			Notify(
				"Welcome to Lucrit",
				"Lucrit Scripts is online."
			)

		end

	end
)
