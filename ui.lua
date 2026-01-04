--// KostelUI.lua
--// Minimal Roblox UI lib styled after the screenshot:
--// Tabs on top, left panel content with group header, checkbox+keybind, labels, separators, sliders.

-- Make compatible with executors
local isStudio = game:GetService("RunService"):IsStudio()
local Players = game:FindService("Players") or game:GetService("Players")

local UIS = game:FindService("UserInputService") or game:GetService("UserInputService")
local TweenService = game:FindService("TweenService") or game:GetService("TweenService")
local CoreGui = game:FindService("CoreGui") or game:GetService("CoreGui")

local Lib = {}
Lib.__index = Lib

--////////////////////////////
-- Styling
--////////////////////////////
local Theme = {
	WindowBg = Color3.fromRGB(22, 24, 28),
	TopBarBg = Color3.fromRGB(18, 19, 23),
	PanelBg = Color3.fromRGB(20, 22, 26),
	CardBg = Color3.fromRGB(26, 29, 34),
	Stroke = Color3.fromRGB(40, 44, 52),

	Text = Color3.fromRGB(235, 235, 235),
	SubText = Color3.fromRGB(165, 170, 180),

	Accent = Color3.fromRGB(90, 130, 255),
	Accent2 = Color3.fromRGB(60, 200, 120),

	Hover = Color3.fromRGB(34, 38, 45),
}

local function mk(className, props)
	local inst = Instance.new(className)
	for k, v in pairs(props or {}) do
		if k == "Parent" then
			-- Set parent last to avoid issues
			inst[k] = v
		else
			inst[k] = v
		end
	end
	return inst
end

local function addCorner(parent, r)
	local c = mk("UICorner", {CornerRadius = UDim.new(0, r or 8)})
	c.Parent = parent
	return c
end

local function addStroke(parent, thickness)
	local s = mk("UIStroke", {
		Color = Theme.Stroke,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
	s.Parent = parent
	return s
end

local function addPadding(parent, p)
	local pad = mk("UIPadding", {
		PaddingLeft = UDim.new(0, p or 10),
		PaddingRight = UDim.new(0, p or 10),
		PaddingTop = UDim.new(0, p or 10),
		PaddingBottom = UDim.new(0, p or 10),
	})
	pad.Parent = parent
	return pad
end

local function tween(obj, info, goal)
	local t = TweenService:Create(obj, info, goal)
	t:Play()
	return t
end

--////////////////////////////
-- Window
--////////////////////////////
function Lib:CreateWindow(opts)
	opts = opts or {}
	local title = opts.Title or "kostel.ltd"
	local parent = opts.Parent or nil

	-- Safe parent selection for executors
	if not parent then
		if isStudio then
			parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		else
			-- Try multiple possible parents for executor compatibility
			local success, result = pcall(function()
				return Players.LocalPlayer and Players.LocalPlayer:WaitForChild("PlayerGui")
			end)
			if success then
				parent = result
			else
				-- Fallback to CoreGui
				parent = CoreGui
			end
		end
	end

	local sg = mk("ScreenGui", {
		Name = "KostelUILib",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = parent,
	})

	local root = mk("Frame", {
		Name = "Root",
		Size = UDim2.fromOffset(680, 420),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.WindowBg,
		Parent = sg,
	})
	addCorner(root, 10)
	addStroke(root, 1)

	local top = mk("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = Theme.TopBarBg,
		BorderSizePixel = 0,
		Parent = root,
	})
	addCorner(top, 10)

	-- Clip top corners only
	local clip = mk("Frame", {
		Name = "TopClip",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = top,
	})

	local topInner = mk("Frame", {
		Name = "Inner",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Theme.TopBarBg,
		BorderSizePixel = 0,
		Parent = clip,
	})
	addCorner(topInner, 10)

	local tabsRow = mk("Frame", {
		Name = "TabsRow",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.fromOffset(8, 0),
		Parent = topInner,
	})

	local list = mk("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = tabsRow,
	})

	local titleBtn = mk("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.Text,
		Font = Enum.Font.Code,
		TextSize = 14,
		AutomaticSize = Enum.AutomaticSize.XY,
		Parent = tabsRow,
	})

	local divider = mk("Frame", {
		Name = "Divider",
		Size = UDim2.fromOffset(1, 18),
		BackgroundColor3 = Theme.Stroke,
		BorderSizePixel = 0,
		Parent = tabsRow,
	})

	-- Content container
	local content = mk("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -16, 1, -52),
		Position = UDim2.fromOffset(8, 48),
		Parent = root,
	})

	local window = setmetatable({
		ScreenGui = sg,
		Root = root,
		TopBar = topInner,
		Content = content,
		TabsRow = tabsRow,
		ActiveTab = nil,
		Tabs = {},
	}, Lib)

	-- Dragging
	do
		local dragging = false
		local dragStart, startPos
		topInner.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = root.Position
			end
		end)
		
		local inputChangedConn = UIS.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local delta = input.Position - dragStart
				root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
		
		local inputEndedConn = UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
		
		-- Store connections for cleanup
		window._dragConnections = {
			inputChangedConn,
			inputEndedConn
		}
	end

	-- Add destroy method
	function window:Destroy()
		if self._dragConnections then
			for _, conn in ipairs(self._dragConnections) do
				conn:Disconnect()
			end
		end
		if self.ScreenGui then
			self.ScreenGui:Destroy()
		end
	end

	return window
end

--////////////////////////////
-- Tab
--////////////////////////////
local Tab = {}
Tab.__index = Tab

function Lib:CreateTab(name)
	local window = self
	local btn = mk("TextButton", {
		Name = "TabButton_" .. name,
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = Theme.SubText,
		Font = Enum.Font.Code,
		TextSize = 13,
		AutomaticSize = Enum.AutomaticSize.XY,
		Parent = window.TabsRow,
	})

	local tabFrame = mk("Frame", {
		Name = "Tab_" .. name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		Parent = window.Content,
	})

	-- Left panel like screenshot
	local panel = mk("Frame", {
		Name = "LeftPanel",
		Size = UDim2.fromOffset(360, 320),
		BackgroundColor3 = Theme.PanelBg,
		BorderSizePixel = 0,
		Parent = tabFrame,
	})
	addCorner(panel, 10)
	addStroke(panel, 1)
	addPadding(panel, 10)

	local vlist = mk("UIListLayout", {
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = panel,
	})

	local t = setmetatable({
		Window = window,
		Name = name,
		Button = btn,
		Frame = tabFrame,
		Panel = panel,
		_connections = {},
	}, Tab)

	window.Tabs[name] = t

	local function setActive()
		for _, other in pairs(window.Tabs) do
			other.Frame.Visible = false
			other.Button.TextColor3 = Theme.SubText
		end
		t.Frame.Visible = true
		t.Button.TextColor3 = Theme.Text
		window.ActiveTab = t
	end

	local clickConn = btn.MouseButton1Click:Connect(setActive)
	table.insert(t._connections, clickConn)

	-- First tab auto active
	if not window.ActiveTab then
		setActive()
	end

	return t
end

--////////////////////////////
-- Components
--////////////////////////////
local function groupHeader(parent, text)
	local header = mk("TextButton", {
		Name = "GroupHeader",
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = Theme.CardBg,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Parent = parent,
	})
	addCorner(header, 8)
	addStroke(header, 1)

	local label = mk("TextLabel", {
		BackgroundTransparency = 1,
		Text = text .. "  ▼",
		TextColor3 = Theme.Text,
		Font = Enum.Font.Code,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -10, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		Parent = header,
	})

	return header
end

function Tab:AddDropdownHeader(text)
	return groupHeader(self.Panel, text)
end

function Tab:AddLabel(text, isDim)
	local lbl = mk("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = isDim and Theme.SubText or Theme.Text,
		Font = Enum.Font.Code,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 18),
		Parent = self.Panel,
	})
	return lbl
end

function Tab:AddSeparator()
	local sep = mk("Frame", {
		Name = "Separator",
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Theme.Stroke,
		BorderSizePixel = 0,
		Parent = self.Panel,
	})
	return sep
end

-- Checkbox with Keybind display (like "key: F1") and small indicator
function Tab:AddCheckbox(opts)
	opts = opts or {}
	local text = opts.Text or "Checkbox"
	local default = opts.Default or false
	local keybind = opts.Keybind or Enum.KeyCode.F1
	local callback = opts.Callback or function() end

	local row = mk("Frame", {
		Name = "CheckboxRow",
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Parent = self.Panel,
	})

	local box = mk("TextButton", {
		Name = "Box",
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.fromOffset(0, 5),
		BackgroundColor3 = Theme.CardBg,
		Text = "",
		AutoButtonColor = false,
		Parent = row,
	})
	addCorner(box, 4)
	addStroke(box, 1)

	local fill = mk("Frame", {
		Name = "Fill",
		Size = UDim2.new(1, -6, 1, -6),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Visible = default,
		Parent = box,
	})
	addCorner(fill, 3)

	local label = mk("TextLabel", {
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Theme.Text,
		Font = Enum.Font.Code,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -220, 1, 0),
		Position = UDim2.fromOffset(24, 0),
		Parent = row,
	})

	-- keybind pill
	local pill = mk("Frame", {
		Name = "KeyPill",
		Size = UDim2.fromOffset(76, 18),
		Position = UDim2.new(1, -116, 0, 4),
		BackgroundColor3 = Theme.CardBg,
		BorderSizePixel = 0,
		Parent = row,
	})
	addCorner(pill, 6)
	addStroke(pill, 1)

	local pillText = mk("TextLabel", {
		BackgroundTransparency = 1,
		Text = ("key: %s"):format(tostring(keybind):gsub("Enum.KeyCode.", "")),
		TextColor3 = Theme.SubText,
		Font = Enum.Font.Code,
		TextSize = 12,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = pill,
	})

	-- indicator dot + gear-ish placeholder
	local dot = mk("Frame", {
		Name = "Dot",
		Size = UDim2.fromOffset(10, 10),
		Position = UDim2.new(1, -30, 0, 8),
		BackgroundColor3 = Theme.Accent2,
		BorderSizePixel = 0,
		Parent = row,
	})
	addCorner(dot, 10)

	local state = default

	local function setState(v)
		state = v and true or false
		fill.Visible = state
		callback(state)
	end

	local boxConn = box.MouseButton1Click:Connect(function() 
		setState(not state) 
	end)
	
	local labelConn = label.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			setState(not state)
		end
	end)
	
	-- Store connections in the tab
	table.insert(self._connections, boxConn)
	table.insert(self._connections, labelConn)

	-- Keybind toggle
	local keybindConn = UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == keybind then
			setState(not state)
		end
	end)
	
	table.insert(self._connections, keybindConn)

	local checkboxObj = {
		Set = setState,
		Get = function() return state end,
		SetKeybind = function(newKey)
			keybind = newKey
			pillText.Text = ("key: %s"):format(tostring(keybind):gsub("Enum.KeyCode.", ""))
		end,
		_connections = {boxConn, labelConn, keybindConn}
	}

	-- Add destroy method to checkbox
	function checkboxObj:Destroy()
		for _, conn in ipairs(self._connections) do
			if conn then
				conn:Disconnect()
			end
		end
		if row then
			row:Destroy()
		end
	end

	setState(default)

	return checkboxObj
end

-- Slider (supports float and int display)
function Tab:AddSlider(opts)
	opts = opts or {}
	local text = opts.Text or "Slider"
	local min = opts.Min or 0
	local max = opts.Max or 1
	local default = opts.Default or min
	local isInt = opts.IsInt or false
	local suffix = opts.Suffix or (isInt and "%" or "f")
	local callback = opts.Callback or function() end

	local wrap = mk("Frame", {
		Name = "SliderWrap",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
		Parent = self.Panel,
	})

	local title = mk("TextLabel", {
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Theme.Text,
		Font = Enum.Font.Code,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -90, 0, 18),
		Parent = wrap,
	})

	local valueLbl = mk("TextLabel", {
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = Theme.SubText,
		Font = Enum.Font.Code,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(0, 90, 0, 18),
		Position = UDim2.new(1, -90, 0, 0),
		Parent = wrap,
	})

	local bar = mk("Frame", {
		Name = "Bar",
		Size = UDim2.new(1, 0, 0, 10),
		Position = UDim2.fromOffset(0, 26),
		BackgroundColor3 = Theme.CardBg,
		BorderSizePixel = 0,
		Parent = wrap,
	})
	addCorner(bar, 6)
	addStroke(bar, 1)

	local fill = mk("Frame", {
		Name = "Fill",
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Parent = bar,
	})
	addCorner(fill, 6)

	local dragging = false
	local val = default

	local function clamp(x) return math.clamp(x, min, max) end
	local function formatValue(x)
		if isInt then
			return ("%d%s"):format(x, suffix)
		else
			-- show like 0.535f
			return ("%.3f%s"):format(x, suffix)
		end
	end

	local function setValue(x, fromDrag)
		x = clamp(x)
		if isInt then x = math.floor(x + 0.5) end
		val = x

		local alpha = (val - min) / (max - min)
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		valueLbl.Text = formatValue(val)
		callback(val, fromDrag)
	end

	local function updateFromMouse()
		local success, mouseX = pcall(function()
			return UIS:GetMouseLocation().X
		end)
		if not success then return end
		
		local absPos = bar.AbsolutePosition.X
		local absSize = bar.AbsoluteSize.X
		local alpha = math.clamp((mouseX - absPos) / absSize, 0, 1)
		local newVal = min + (max - min) * alpha
		setValue(newVal, true)
	end

	local barConn = bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			updateFromMouse()
		end
	end)

	local inputChangedConn = UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateFromMouse()
		end
	end)

	local inputEndedConn = UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	-- Store connections
	table.insert(self._connections, barConn)
	table.insert(self._connections, inputChangedConn)
	table.insert(self._connections, inputEndedConn)

	local sliderObj = {
		Set = function(x) setValue(x, false) end,
		Get = function() return val end,
		_connections = {barConn, inputChangedConn, inputEndedConn}
	}
	
	-- Add destroy method
	function sliderObj:Destroy()
		for _, conn in ipairs(self._connections) do
			if conn then
				conn:Disconnect()
			end
		end
		if wrap then
			wrap:Destroy()
		end
	end

	setValue(default, false)

	return sliderObj
end

-- Add a method to properly destroy tabs
function Tab:Destroy()
	-- Disconnect all connections
	for _, conn in ipairs(self._connections) do
		if conn then
			conn:Disconnect()
		end
	end
	-- Remove from window tabs table
	self.Window.Tabs[self.Name] = nil
	-- Destroy UI elements
	if self.Frame then
		self.Frame:Destroy()
	end
	if self.Button then
		self.Button:Destroy()
	end
end

return Lib
