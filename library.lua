-- Gamesense-inspired Roblox UI Library
-- Made for executors with proper injection handling
-- Version 2.0 - Enhanced with security, themes, and features

local GamesenseUI = {}
GamesenseUI.__index = GamesenseUI

-- Configuration
local Config = {
    PrimaryColor = Color3.fromRGB(45, 125, 255),
    SecondaryColor = Color3.fromRGB(30, 30, 40),
    BackgroundColor = Color3.fromRGB(20, 20, 30),
    TextColor = Color3.fromRGB(240, 240, 240),
    AccentColor = Color3.fromRGB(255, 65, 65),
    Font = Enum.Font.Gotham,
    ToggleKey = Enum.KeyCode.RightShift
}

-- Themes System
GamesenseUI.Themes = {
    Dark = {
        PrimaryColor = Color3.fromRGB(45, 125, 255),
        SecondaryColor = Color3.fromRGB(30, 30, 40),
        BackgroundColor = Color3.fromRGB(20, 20, 30),
        TextColor = Color3.fromRGB(240, 240, 240),
        AccentColor = Color3.fromRGB(255, 65, 65)
    },
    Light = {
        PrimaryColor = Color3.fromRGB(0, 100, 255),
        SecondaryColor = Color3.fromRGB(240, 240, 245),
        BackgroundColor = Color3.fromRGB(250, 250, 255),
        TextColor = Color3.fromRGB(30, 30, 40),
        AccentColor = Color3.fromRGB(255, 50, 50)
    },
    Gamesense = {
        PrimaryColor = Color3.fromRGB(255, 65, 65),
        SecondaryColor = Color3.fromRGB(40, 40, 50),
        BackgroundColor = Color3.fromRGB(25, 25, 35),
        TextColor = Color3.fromRGB(220, 220, 220),
        AccentColor = Color3.fromRGB(65, 255, 65)
    },
    Midnight = {
        PrimaryColor = Color3.fromRGB(155, 89, 182),
        SecondaryColor = Color3.fromRGB(44, 62, 80),
        BackgroundColor = Color3.fromRGB(34, 49, 63),
        TextColor = Color3.fromRGB(236, 240, 241),
        AccentColor = Color3.fromRGB(241, 196, 15)
    }
}

-- Easing Styles for animations
local EasingStyles = {
    Linear = Enum.EasingStyle.Linear,
    Quad = Enum.EasingStyle.Quad,
    Cubic = Enum.EasingStyle.Cubic,
    Quart = Enum.EasingStyle.Quart,
    Quint = Enum.EasingStyle.Quint,
    Bounce = Enum.EasingStyle.Bounce,
    Elastic = Enum.EasingStyle.Elastic,
    Back = Enum.EasingStyle.Back,
    Sine = Enum.EasingStyle.Sine
}

-- Utility functions
local function Create(class, props)
    local obj = Instance.new(class)
    for prop, val in pairs(props) do
        if prop == "Parent" then
            obj.Parent = val
        else
            if pcall(function() return obj[prop] end) then
                obj[prop] = val
            end
        end
    end
    return obj
end

-- Enhanced GUI Protection
local function ProtectGUI(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        return syn.protect_gui
    elseif get_hidden_ui or gethui then
        local hiddenUI = get_hidden_ui or gethui
        gui.Parent = hiddenUI()
        return hiddenUI
    elseif game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
        -- Alternative parenting for better stealth
        local success, player = pcall(function() return game:GetService("Players").LocalPlayer end)
        if success and player then
            local playerGui = player:WaitForChild("PlayerGui")
            gui.Parent = playerGui
            return playerGui
        end
    end
    
    -- Fallback
    gui.Parent = game.CoreGui
    return game.CoreGui
end

-- Debounce utility
local function Debounce(func, wait)
    local last = 0
    return function(...)
        local now = tick()
        if now - last > wait then
            last = now
            return func(...)
        end
    end
end

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Main Window
function GamesenseUI:CreateWindow(title, options)
    options = options or {}
    
    local self = setmetatable({}, GamesenseUI)
    
    self.Tabs = {}
    self.Visible = false
    self.ActiveTab = nil
    self.Connections = {}
    self.Elements = {}
    self.ConfigFile = options.ConfigFile or "GamesenseUIConfig.json"
    
    -- ScreenGui
    self.ScreenGui = Create("ScreenGui", {
        Name = "GamesenseUI_" .. HttpService:GenerateGUID(false):sub(1, 8),
        DisplayOrder = options.DisplayOrder or 100,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })
    
    -- Store the protection method
    self.ProtectionMethod = ProtectGUI(self.ScreenGui)
    
    -- Main Frame
    self.MainFrame = Create("Frame", {
        Parent = self.ScreenGui,
        Size = UDim2.new(0, options.Width or 500, 0, options.Height or 450),
        Position = UDim2.new(0.5, -(options.Width or 500)/2, 0.5, -(options.Height or 450)/2),
        BackgroundColor3 = Config.BackgroundColor,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true
    })
    
    Create("UICorner", {
        Parent = self.MainFrame,
        CornerRadius = UDim.new(0, 6)
    })
    
    Create("UIStroke", {
        Parent = self.MainFrame,
        Color = Config.SecondaryColor,
        Thickness = 1
    })
    
    -- Top Bar
    self.TopBar = Create("Frame", {
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Config.SecondaryColor,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        Parent = self.TopBar,
        CornerRadius = UDim.new(0, 6, 0, 0)
    })
    
    -- Title
    self.Title = Create("TextLabel", {
        Parent = self.TopBar,
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Config.TextColor,
        Font = Config.Font,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    Create("UIPadding", {
        Parent = self.Title,
        PaddingLeft = UDim.new(0, 12)
    })
    
    -- Close Button
    self.CloseButton = Create("TextButton", {
        Parent = self.TopBar,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Config.TextColor,
        Font = Enum.Font.GothamBold,
        TextSize = 24,
        TextColor3 = Color3.fromRGB(200, 200, 200)
    })
    
    -- Minimize Button
    self.MinimizeButton = Create("TextButton", {
        Parent = self.TopBar,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -70, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "−",
        TextColor3 = Config.TextColor,
        Font = Enum.Font.GothamBold,
        TextSize = 24,
        TextColor3 = Color3.fromRGB(200, 200, 200)
    })
    
    self.Minimized = false
    
    -- Tab Container
    self.TabContainer = Create("Frame", {
        Parent = self.MainFrame,
        Size = UDim2.new(0, 150, 1, -35),
        Position = UDim2.new(0, 0, 0, 35),
        BackgroundColor3 = Config.SecondaryColor,
        BorderSizePixel = 0
    })
    
    local tabListLayout = Create("UIListLayout", {
        Parent = self.TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })
    
    Create("UIPadding", {
        Parent = self.TabContainer,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5)
    })
    
    -- Content Container
    self.ContentContainer = Create("Frame", {
        Parent = self.MainFrame,
        Size = UDim2.new(1, -150, 1, -35),
        Position = UDim2.new(0, 150, 0, 35),
        BackgroundColor3 = Config.BackgroundColor,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    
    -- Content Scrolling
    self.ContentScrolling = Create("ScrollingFrame", {
        Parent = self.ContentContainer,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Config.SecondaryColor,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        VerticalScrollBarInset = Enum.ScrollBarInset.Always,
        ScrollingDirection = Enum.ScrollingDirection.Y
    })
    
    local uiListLayout = Create("UIListLayout", {
        Parent = self.ContentScrolling,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    local uiPadding = Create("UIPadding", {
        Parent = self.ContentScrolling,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10)
    })
    
    -- Draggable functionality
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function Update(input)
        local delta = input.Position - dragStart
        self.MainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
    
    local dragConnection = self.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    table.insert(self.Connections, dragConnection)
    
    local inputChangedConnection = self.TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    table.insert(self.Connections, inputChangedConnection)
    
    local userInputChangedConnection = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            Update(input)
        end
    end)
    
    table.insert(self.Connections, userInputChangedConnection)
    
    -- Close button functionality
    local closeConnection = self.CloseButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    table.insert(self.Connections, closeConnection)
    
    -- Minimize button functionality
    local minimizeConnection = self.MinimizeButton.MouseButton1Click:Connect(function()
        self:Minimize()
    end)
    
    table.insert(self.Connections, minimizeConnection)
    
    -- Toggle keybind
    local toggleConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Config.ToggleKey then
            self:Toggle()
        end
    end)
    
    table.insert(self.Connections, toggleConnection)
    
    -- Auto-save on closing
    local autoSaveConnection = self.ScreenGui.Destroying:Connect(function()
        self:SaveConfig()
    end)
    
    table.insert(self.Connections, autoSaveConnection)
    
    -- Load saved config
    self:LoadConfig()
    
    return self
end

-- Theme management
function GamesenseUI:SetTheme(themeName)
    local theme = GamesenseUI.Themes[themeName]
    if theme then
        for key, value in pairs(theme) do
            Config[key] = value
        end
        self:UpdateTheme()
    end
end

function GamesenseUI:UpdateTheme()
    -- Update all UI elements with new theme colors
    if self.MainFrame then
        self.MainFrame.BackgroundColor3 = Config.BackgroundColor
        self.TopBar.BackgroundColor3 = Config.SecondaryColor
        self.TabContainer.BackgroundColor3 = Config.SecondaryColor
        self.Title.TextColor3 = Config.TextColor
        self.CloseButton.TextColor3 = Config.TextColor
        self.MinimizeButton.TextColor3 = Config.TextColor
        
        -- Update UIStroke
        local stroke = self.MainFrame:FindFirstChild("UIStroke")
        if stroke then
            stroke.Color = Config.SecondaryColor
        end
        
        -- Update scrollbar
        if self.ContentScrolling then
            self.ContentScrolling.ScrollBarImageColor3 = Config.SecondaryColor
        end
        
        -- Update all tabs
        for _, tab in ipairs(self.Tabs) do
            if tab.Button then
                if self.ActiveTab == tab then
                    tab.Button.BackgroundColor3 = Config.PrimaryColor
                else
                    tab.Button.BackgroundColor3 = Config.SecondaryColor
                end
                tab.Button.TextColor3 = Config.TextColor
            end
        end
        
        -- Update all elements
        for _, elementData in ipairs(self.Elements) do
            if elementData.Type == "Toggle" then
                elementData.Object.Button.BackgroundColor3 = elementData.Object.Value and Config.PrimaryColor or Color3.fromRGB(60, 60, 70)
            elseif elementData.Type == "Button" then
                elementData.Object.Button.BackgroundColor3 = Config.PrimaryColor
            elseif elementData.Type == "Slider" then
                elementData.Object.Fill.BackgroundColor3 = Config.PrimaryColor
            end
        end
    end
end

-- Tab system
function GamesenseUI:CreateTab(name, icon)
    local Tab = {}
    Tab.Name = name
    Tab.Elements = {}
    
    -- Tab Button
    Tab.Button = Create("TextButton", {
        Parent = self.TabContainer,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Config.SecondaryColor,
        BorderSizePixel = 0,
        Text = "  " .. name,
        TextColor3 = Config.TextColor,
        Font = Config.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false
    })
    
    Create("UICorner", {
        Parent = Tab.Button,
        CornerRadius = UDim.new(0, 4)
    })
    
    Tab.Button.LayoutOrder = #self.Tabs + 1
    
    -- Hover effect
    local originalColor = Tab.Button.BackgroundColor3
    Tab.Button.MouseEnter:Connect(function()
        if self.ActiveTab ~= Tab then
            Tab.Button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        end
    end)
    
    Tab.Button.MouseLeave:Connect(function()
        if self.ActiveTab ~= Tab then
            Tab.Button.BackgroundColor3 = originalColor
        end
    end)
    
    -- Content Frame
    Tab.Content = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false
    })
    
    Tab.Content.Parent = self.ContentScrolling
    
    local uiListLayout = Create("UIListLayout", {
        Parent = Tab.Content,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })
    
    local tabClickConnection = Tab.Button.MouseButton1Click:Connect(function()
        self:SwitchTab(Tab)
    end)
    
    table.insert(self.Connections, tabClickConnection)
    
    table.insert(self.Tabs, Tab)
    
    if #self.Tabs == 1 then
        self:SwitchTab(Tab)
    end
    
    return Tab
end

function GamesenseUI:SwitchTab(tab)
    if self.ActiveTab then
        self.ActiveTab.Content.Visible = false
        self.ActiveTab.Button.BackgroundColor3 = Config.SecondaryColor
    end
    
    self.ActiveTab = tab
    tab.Content.Visible = true
    tab.Button.BackgroundColor3 = Config.PrimaryColor
    
    -- Update scrolling frame size
    local function updateCanvasSize()
        local contentSize = 0
        for _, child in ipairs(tab.Content:GetChildren()) do
            if child:IsA("GuiObject") and child.Visible then
                contentSize = contentSize + child.AbsoluteSize.Y + 10
            end
        end
        
        self.ContentScrolling.CanvasSize = UDim2.new(0, 0, 0, math.max(contentSize + 20, self.ContentScrolling.AbsoluteSize.Y))
    end
    
    -- Debounce the canvas size update
    local debouncedUpdate = Debounce(updateCanvasSize, 0.1)
    debouncedUpdate()
    
    -- Also update when layout changes
    local layout = tab.Content:FindFirstChildOfClass("UIListLayout")
    if layout then
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(debouncedUpdate)
    end
end

-- Toggle UI visibility
function GamesenseUI:Toggle()
    self.Visible = not self.Visible
    self.MainFrame.Visible = self.Visible
    
    if self.Visible then
        self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
        self.MainFrame.Visible = true
        
        local tweenInfo = TweenInfo.new(0.3, EasingStyles.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(self.MainFrame, tweenInfo, {
            Size = UDim2.new(0, 500, 0, 450)
        })
        tween:Play()
    else
        local tweenInfo = TweenInfo.new(0.2, EasingStyles.Quad, Enum.EasingDirection.In)
        local tween = TweenService:Create(self.MainFrame, tweenInfo, {
            Size = UDim2.new(0, 0, 0, 0)
        })
        
        tween.Completed:Connect(function()
            if not self.Visible then
                self.MainFrame.Visible = false
            end
        end)
        
        tween:Play()
    end
end

-- Minimize window
function GamesenseUI:Minimize()
    self.Minimized = not self.Minimized
    
    if self.Minimized then
        self.ContentContainer.Visible = false
        self.TabContainer.Visible = false
        self.MainFrame.Size = UDim2.new(0, 500, 0, 35)
    else
        self.ContentContainer.Visible = true
        self.TabContainer.Visible = true
        self.MainFrame.Size = UDim2.new(0, 500, 0, 450)
    end
end

-- Section Creator
function GamesenseUI:CreateSection(tab, name)
    local Section = {}
    Section.Name = name
    
    Section.Frame = Create("Frame", {
        Parent = tab.Content,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = #tab.Content:GetChildren()
    })
    
    -- Section Title
    Section.Title = Create("TextLabel", {
        Parent = Section.Frame,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        Text = name:upper(),
        TextColor3 = Color3.fromRGB(150, 150, 170),
        Font = Config.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
    })
    
    Section.Content = Create("Frame", {
        Parent = Section.Frame,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 25),
        BackgroundColor3 = Config.SecondaryColor,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        Parent = Section.Content,
        CornerRadius = UDim.new(0, 4)
    })
    
    Create("UIStroke", {
        Parent = Section.Content,
        Color = Color3.fromRGB(50, 50, 60),
        Thickness = 1
    })
    
    local uiListLayout = Create("UIListLayout", {
        Parent = Section.Content,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })
    
    local uiPadding = Create("UIPadding", {
        Parent = Section.Content,
        PaddingTop = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12)
    })
    
    function Section:UpdateSize()
        local totalHeight = 0
        for _, child in ipairs(self.Content:GetChildren()) do
            if child:IsA("GuiObject") and child.Visible then
                totalHeight = totalHeight + child.AbsoluteSize.Y + 8
            end
        end
        
        self.Content.Size = UDim2.new(1, 0, 0, math.max(totalHeight + 24, 10))
        self.Frame.Size = UDim2.new(1, 0, 0, totalHeight + 41)
    end
    
    -- Use Heartbeat for size updates to prevent infinite loops
    local heartbeatConnection
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if Section.Frame.Parent then
            Section:UpdateSize()
        else
            heartbeatConnection:Disconnect()
        end
    end)
    
    table.insert(self.Connections, heartbeatConnection)
    
    return Section
end

-- Button Element
function GamesenseUI:CreateButton(section, text, callback, options)
    options = options or {}
    
    local Button = {}
    Button.Type = "Button"
    Button.Name = text
    
    Button.Frame = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        LayoutOrder = #section.Content:GetChildren()
    })
    
    Button.Button = Create("TextButton", {
        Parent = Button.Frame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Config.PrimaryColor,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = Config.TextColor,
        Font = Config.Font,
        TextSize = 14,
        AutoButtonColor = false
    })
    
    Create("UICorner", {
        Parent = Button.Button,
        CornerRadius = UDim.new(0, 4)
    })
    
    -- Hover effects
    local originalColor = Button.Button.BackgroundColor3
    local hoverColor = Color3.fromRGB(
        math.min(originalColor.R * 255 + 20, 255),
        math.min(originalColor.G * 255 + 20, 255),
        math.min(originalColor.B * 255 + 20, 255)
    )
    
    local pressedColor = Color3.fromRGB(
        math.max(originalColor.R * 255 - 20, 0),
        math.max(originalColor.G * 255 - 20, 0),
        math.max(originalColor.B * 255 - 20, 0)
    )
    
    Button.Button.MouseEnter:Connect(function()
        Button.Button.BackgroundColor3 = hoverColor
    end)
    
    Button.Button.MouseLeave:Connect(function()
        Button.Button.BackgroundColor3 = originalColor
    end)
    
    Button.Button.MouseButton1Down:Connect(function()
        Button.Button.BackgroundColor3 = pressedColor
    end)
    
    Button.Button.MouseButton1Up:Connect(function()
        Button.Button.BackgroundColor3 = hoverColor
    end)
    
    local clickConnection = Button.Button.MouseButton1Click:Connect(function()
        if callback then
            local success, err = pcall(callback)
            if not success then
                warn("Button callback error:", err)
            end
        end
    end)
    
    table.insert(self.Connections, clickConnection)
    
    -- Store for theme updates
    table.insert(self.Elements, {
        Type = "Button",
        Object = Button,
        Section = section
    })
    
    -- Store in tab for config saving
    if section.Parent.Parent then -- Find the tab
        for _, tab in ipairs(self.Tabs) do
            if tab.Content == section.Parent then
                table.insert(tab.Elements, {
                    Type = "Button",
                    Name = text,
                    Value = nil, -- Buttons don't have values
                    Callback = callback
                })
                break
            end
        end
    end
    
    return Button
end

-- Toggle Element
function GamesenseUI:CreateToggle(section, text, default, callback, options)
    options = options or {}
    
    local Toggle = {}
    Toggle.Type = "Toggle"
    Toggle.Name = text
    Toggle.Value = default or false
    
    Toggle.Frame = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        LayoutOrder = #section.Content:GetChildren()
    })
    
    Toggle.Label = Create("TextLabel", {
        Parent = Toggle.Frame,
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Config.TextColor,
        Font = Config.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    Toggle.Button = Create("TextButton", {
        Parent = Toggle.Frame,
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -40, 0.5, -10),
        BackgroundColor3 = Toggle.Value and Config.PrimaryColor or Color3.fromRGB(60, 60, 70),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false
    })
    
    Create("UICorner", {
        Parent = Toggle.Button,
        CornerRadius = UDim.new(1, 0)
    })
    
    Toggle.Indicator = Create("Frame", {
        Parent = Toggle.Button,
        Size = UDim2.new(0, 12, 0, 12),
        Position = Toggle.Value and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
        BackgroundColor3 = Config.TextColor,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        Parent = Toggle.Indicator,
        CornerRadius = UDim.new(1, 0)
    })
    
    function Toggle:Set(value, noCallback)
        Toggle.Value = value
        Toggle.Button.BackgroundColor3 = value and Config.PrimaryColor or Color3.fromRGB(60, 60, 70)
        
        local tweenInfo = TweenInfo.new(0.2, EasingStyles.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(Toggle.Indicator, tweenInfo, {
            Position = value and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        })
        tween:Play()
        
        if callback and not noCallback then
            local success, err = pcall(callback, value)
            if not success then
                warn("Toggle callback error:", err)
            end
        end
    end
    
    local clickConnection = Toggle.Button.MouseButton1Click:Connect(function()
        Toggle:Set(not Toggle.Value)
    end)
    
    table.insert(self.Connections, clickConnection)
    
    -- Store for theme updates
    table.insert(self.Elements, {
        Type = "Toggle",
        Object = Toggle,
        Section = section
    })
    
    -- Store in tab for config saving
    if section.Parent.Parent then
        for _, tab in ipairs(self.Tabs) do
            if tab.Content == section.Parent then
                table.insert(tab.Elements, {
                    Type = "Toggle",
                    Name = text,
                    Value = Toggle.Value,
                    Callback = callback
                })
                break
            end
        end
    end
    
    -- Initialize
    Toggle:Set(Toggle.Value, true)
    
    return Toggle
end

-- Slider Element
function GamesenseUI:CreateSlider(section, text, min, max, default, callback, options)
    options = options or {}
    local precision = options.Precision or 0
    
    local Slider = {}
    Slider.Type = "Slider"
    Slider.Name = text
    Slider.Value = default or min
    Slider.Min = min
    Slider.Max = max
    Slider.Precision = precision
    
    Slider.Frame = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        LayoutOrder = #section.Content:GetChildren()
    })
    
    local topFrame = Create("Frame", {
        Parent = Slider.Frame,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1
    })
    
    Slider.Label = Create("TextLabel", {
        Parent = topFrame,
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Config.TextColor,
        Font = Config.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    Slider.ValueLabel = Create("TextLabel", {
        Parent = topFrame,
        Size = UDim2.new(0.3, 0, 1, 0),
        Position = UDim2.new(0.7, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = string.format("%." .. precision .. "f", Slider.Value),
        TextColor3 = Config.TextColor,
        Font = Config.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    Slider.Track = Create("Frame", {
        Parent = Slider.Frame,
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(60, 60, 70),
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        Parent = Slider.Track,
        CornerRadius = UDim.new(1, 0)
    })
    
    Slider.Fill = Create("Frame", {
        Parent = Slider.Track,
        Size = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0),
        BackgroundColor3 = Config.PrimaryColor,
        BorderSizePixel = 0
    })
    
    Create("UICorner", {
        Parent = Slider.Fill,
        CornerRadius = UDim.new(1, 0)
    })
    
    Slider.Thumb = Create("Frame", {
        Parent = Slider.Track,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), -6, 0.5, -6),
        BackgroundColor3 = Config.TextColor,
        BorderSizePixel = 0,
        ZIndex = 2
    })
    
    Create("UICorner", {
        Parent = Slider.Thumb,
        CornerRadius = UDim.new(1, 0)
    })
    
    local dragging = false
    
    local function UpdateSlider(input)
        local relativeX = (input.Position.X - Slider.Track.AbsolutePosition.X) / Slider.Track.AbsoluteSize.X
        local rawValue = Slider.Min + relativeX * (Slider.Max - Slider.Min)
        
        -- Apply precision
        local value
        if Slider.Precision == 0 then
            value = math.floor(rawValue + 0.5)
        else
            local multiplier = 10 ^ Slider.Precision
            value = math.floor(rawValue * multiplier + 0.5) / multiplier
        end
        
        value = math.clamp(value, Slider.Min, Slider.Max)
        
        Slider.Value = value
        Slider.ValueLabel.Text = string.format("%." .. Slider.Precision .. "f", value)
        Slider.Fill.Size = UDim2.new((value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0)
        Slider.Thumb.Position = UDim2.new((value - Slider.Min) / (Slider.Max - Slider.Min), -6, 0.5, -6)
        
        if callback then
            local success, err = pcall(callback, value)
            if not success then
                warn("Slider callback error:", err)
            end
        end
    end
    
    local function StartDragging(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            
            local debouncedUpdate = Debounce(UpdateSlider, 0.01)
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if dragging then
                    debouncedUpdate(input)
                else
                    connection:Disconnect()
                end
            end)
            
            local endConnection
            endConnection = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    if connection then
                        connection:Disconnect()
                    end
                    endConnection:Disconnect()
                end
            end)
        end
    end
    
    Slider.Thumb.InputBegan:Connect(StartDragging)
    Slider.Track.InputBegan:Connect(StartDragging)
    
    function Slider:Set(value, noCallback)
        value = math.clamp(value, Slider.Min, Slider.Max)
        Slider.Value = value
        Slider.ValueLabel.Text = string.format("%." .. Slider.Precision .. "f", value)
        Slider.Fill.Size = UDim2.new((value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0)
        Slider.Thumb.Position = UDim2.new((value - Slider.Min) / (Slider.Max - Slider.Min), -6, 0.5, -6)
        
        if callback and not noCallback then
            local success, err = pcall(callback, value)
            if not success then
                warn("Slider callback error:", err)
            end
        end
    end
    
    -- Store for theme updates
    table.insert(self.Elements, {
        Type = "Slider",
        Object = Slider,
        Section = section
    })
    
    -- Store in tab for config saving
    if section.Parent.Parent then
        for _, tab in ipairs(self.Tabs) do
            if tab.Content == section.Parent then
                table.insert(tab.Elements, {
                    Type = "Slider",
                    Name = text,
                    Value = Slider.Value,
                    Min = Slider.Min,
                    Max = Slider.Max,
                    Precision = Slider.Precision,
                    Callback = callback
                })
                break
            end
        end
    end
    
    return Slider
end

-- Dropdown Element
function GamesenseUI:CreateDropdown(section, text, options, default, callback, optionsConfig)
    optionsConfig = optionsConfig or {}
    
    local Dropdown = {}
    Dropdown.Type = "Dropdown"
    Dropdown.Name = text
    Dropdown.Value = default or options[1]
    Dropdown.Options = options
    Dropdown.Open = false
    
    Dropdown.Frame = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        LayoutOrder = #section.Content:GetChildren()
    })
    
    Dropdown.Label = Create("TextLabel", {
        Parent = Dropdown.Frame,
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Config.TextColor,
        Font = Config.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    Dropdown.Button = Create("TextButton", {
        Parent = Dropdown.Frame,
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(60, 60, 70),
        BorderSizePixel = 0,
        Text = Dropdown.Value,
        TextColor3 = Config.TextColor,
        Font = Config.Font,
        TextSize = 14,
        AutoButtonColor = false
    })
    
    Create("UICorner", {
        Parent = Dropdown.Button,
        CornerRadius = UDim.new(0, 4)
    })
    
    -- Arrow indicator
    local arrow = Create("TextLabel", {
        Parent = Dropdown.Button,
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -20, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = Config.TextColor,
        Font = Config.Font,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center
    })
    
    Dropdown.OptionsFrame = Create("ScrollingFrame", {
        Parent = self.ScreenGui,
        Size = UDim2.new(0, Dropdown.Button.AbsoluteSize.X, 0, math.min(#options * 30 + 10, 150)),
        Position = UDim2.new(0, Dropdown.Button.AbsolutePosition.X, 0, Dropdown.Button.AbsolutePosition.Y + Dropdown.Button.AbsoluteSize.Y + 5),
        BackgroundColor3 = Config.SecondaryColor,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Config.PrimaryColor,
        CanvasSize = UDim2.new(0, 0, 0, #options * 30),
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 100
    })
    
    Create("UICorner", {
        Parent = Dropdown.OptionsFrame,
        CornerRadius = UDim.new(0, 4)
    })
    
    Create("UIStroke", {
        Parent = Dropdown.OptionsFrame,
        Color = Color3.fromRGB(50, 50, 60),
        Thickness = 1
    })
    
    local optionsList = Create("UIListLayout", {
        Parent = Dropdown.OptionsFrame,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Create("UIPadding", {
        Parent = Dropdown.OptionsFrame,
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5)
    })
    
    local dropdowns = {}
    
    function Dropdown:Toggle()
        -- Close all other dropdowns first
        for _, otherDropdown in ipairs(dropdowns) do
            if otherDropdown ~= Dropdown and otherDropdown.Open then
                otherDropdown:Toggle()
            end
        end
        
        Dropdown.Open = not Dropdown.Open
        Dropdown.OptionsFrame.Visible = Dropdown.Open
        
        if Dropdown.Open then
            table.insert(dropdowns, Dropdown)
            
            -- Position the dropdown
            Dropdown.OptionsFrame.Position = UDim2.new(
                0, Dropdown.Button.AbsolutePosition.X,
                0, Dropdown.Button.AbsolutePosition.Y + Dropdown.Button.AbsoluteSize.Y + 5
            )
            
            -- Populate options
            Dropdown.OptionsFrame:ClearAllChildren()
            
            for i, option in ipairs(Dropdown.Options) do
                local optionButton = Create("TextButton", {
                    Parent = Dropdown.OptionsFrame,
                    Size = UDim2.new(1, -10, 0, 25),
                    Position = UDim2.new(0, 5, 0, (i-1)*30),
                    BackgroundColor3 = Color3.fromRGB(60, 60, 70),
                    BorderSizePixel = 0,
                    Text = option,
                    TextColor3 = Config.TextColor,
                    Font = Config.Font,
                    TextSize = 14,
                    AutoButtonColor = false,
                    LayoutOrder = i
                })
                
                Create("UICorner", {
                    Parent = optionButton,
                    CornerRadius = UDim.new(0, 4)
                })
                
                optionButton.MouseEnter:Connect(function()
                    optionButton.BackgroundColor3 = Config.PrimaryColor
                end)
                
                optionButton.MouseLeave:Connect(function()
                    optionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                })
                
                optionButton.MouseButton1Click:Connect(function()
                    Dropdown.Value = option
                    Dropdown.Button.Text = option
                    Dropdown:Toggle()
                    
                    if callback then
                        local success, err = pcall(callback, option)
                        if not success then
                            warn("Dropdown callback error:", err)
                        end
                    end
                end)
            end
            
            Dropdown.OptionsFrame.CanvasSize = UDim2.new(0, 0, 0, #Dropdown.Options * 30)
        else
            -- Remove from active dropdowns
            for i, otherDropdown in ipairs(dropdowns) do
                if otherDropdown == Dropdown then
                    table.remove(dropdowns, i)
                    break
                end
            end
        end
    end
    
    local buttonConnection = Dropdown.Button.MouseButton1Click:Connect(function()
        Dropdown:Toggle()
    end)
    
    table.insert(self.Connections, buttonConnection)
    
    -- Close dropdown when clicking elsewhere
    local function closeDropdown(input, processed)
        if Dropdown.Open and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local buttonPos = Dropdown.Button.AbsolutePosition
            local buttonSize = Dropdown.Button.AbsoluteSize
            local framePos = Dropdown.OptionsFrame.AbsolutePosition
            local frameSize = Dropdown.OptionsFrame.AbsoluteSize
            
            local overButton = mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X and
                               mousePos.Y >= buttonPos.Y and mousePos.Y <= buttonPos.Y + buttonSize.Y
            local overFrame = mousePos.X >= framePos.X and mousePos.X <= framePos.X + frameSize.X and
                              mousePos.Y >= framePos.Y and mousePos.Y <= framePos.Y + frameSize.Y
            
            if not overButton and not overFrame then
                Dropdown:Toggle()
            end
        end
    end
    
    local closeConnection = UserInputService.InputBegan:Connect(closeDropdown)
    table.insert(self.Connections, closeConnection)
    
    -- Store for theme updates
    table.insert(self.Elements, {
        Type = "Dropdown",
        Object = Dropdown,
        Section = section
    })
    
    -- Store in tab for config saving
    if section.Parent.Parent then
        for _, tab in ipairs(self.Tabs) do
            if tab.Content == section.Parent then
                table.insert(tab.Elements, {
                    Type = "Dropdown",
                    Name = text,
                    Value = Dropdown.Value,
                    Options = Dropdown.Options,
                    Callback = callback
                })
                break
            end
        end
    end
    
    return Dropdown
end

-- Label Element
function GamesenseUI:CreateLabel(section, text, options)
    options = options or {}
    
    local Label = {}
    Label.Type = "Label"
    Label.Name = text
    
    Label.Frame = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, options.Height or 20),
        BackgroundTransparency = 1,
        LayoutOrder = #section.Content:GetChildren()
    })
    
    Label.Text = Create("TextLabel", {
        Parent = Label.Frame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = options.TextColor or Config.TextColor,
        Font = options.Font or Config.Font,
        TextSize = options.TextSize or 14,
        TextXAlignment = options.XAlignment or Enum.TextXAlignment.Left,
        TextYAlignment = options.YAlignment or Enum.TextYAlignment.Center
    })
    
    if options.Centered then
        Label.Text.TextXAlignment = Enum.TextXAlignment.Center
    end
    
    -- Store in tab for config saving
    if section.Parent.Parent then
        for _, tab in ipairs(self.Tabs) do
            if tab.Content == section.Parent then
                table.insert(tab.Elements, {
                    Type = "Label",
                    Name = text,
                    Value = text
                })
                break
            end
        end
    end
    
    return Label
end

-- Keybind Element
function GamesenseUI:CreateKeybind(section, text, default, callback, options)
    options = options or {}
    
    local Keybind = {}
    Keybind.Type = "Keybind"
    Keybind.Name = text
    Keybind.Value = default or Enum.KeyCode.Unknown
    Keybind.Listening = false
    
    Keybind.Frame = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        LayoutOrder = #section.Content:GetChildren()
    })
    
    Keybind.Label = Create("TextLabel", {
        Parent = Keybind.Frame,
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Config.TextColor,
        Font = Config.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    Keybind.Button = Create("TextButton", {
        Parent = Keybind.Frame,
        Size = UDim2.new(0, 80, 0, 25),
        Position = UDim2.new(1, -80, 0, 0),
        BackgroundColor3 = Color3.fromRGB(60, 60, 70),
        BorderSizePixel = 0,
        Text = tostring(Keybind.Value.Name):gsub("^%l", string.upper),
        TextColor3 = Config.TextColor,
        Font = Config.Font,
        TextSize = 12,
        AutoButtonColor = false
    })
    
    Create("UICorner", {
        Parent = Keybind.Button,
        CornerRadius = UDim.new(0, 4)
    })
    
    function Keybind:SetListening(listening)
        Keybind.Listening = listening
        if listening then
            Keybind.Button.BackgroundColor3 = Config.AccentColor
            Keybind.Button.Text = "..."
        else
            Keybind.Button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            Keybind.Button.Text = tostring(Keybind.Value.Name):gsub("^%l", string.upper)
        end
    end
    
    local buttonConnection = Keybind.Button.MouseButton1Click:Connect(function()
        Keybind:SetListening(true)
    end)
    
    table.insert(self.Connections, buttonConnection)
    
    local inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if Keybind.Listening and not processed then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Keybind.Value = input.KeyCode
                Keybind:SetListening(false)
                
                if callback then
                    local success, err = pcall(callback, input.KeyCode)
                    if not success then
                        warn("Keybind callback error:", err)
                    end
                end
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                Keybind.Value = Enum.UserInputType.MouseButton1
                Keybind:SetListening(false)
                
                if callback then
                    local success, err = pcall(callback, Enum.UserInputType.MouseButton1)
                    if not success then
                        warn("Keybind callback error:", err)
                    end
                end
            end
        elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Keybind.Value and not Keybind.Listening then
            if callback then
                local success, err = pcall(callback, Keybind.Value, true)
                if not success then
                    warn("Keybind callback error:", err)
                end
            end
        end
    end)
    
    table.insert(self.Connections, inputConnection)
    
    -- Store for theme updates
    table.insert(self.Elements, {
        Type = "Keybind",
        Object = Keybind,
        Section = section
    })
    
    -- Store in tab for config saving
    if section.Parent.Parent then
        for _, tab in ipairs(self.Tabs) do
            if tab.Content == section.Parent then
                table.insert(tab.Elements, {
                    Type = "Keybind",
                    Name = text,
                    Value = Keybind.Value,
                    Callback = callback
                })
                break
            end
        end
    end
    
    return Keybind
end

-- Color Picker (Enhanced version)
function GamesenseUI:CreateColorPicker(section, text, default, callback, options)
    options = options or {}
    
    local ColorPicker = {}
    ColorPicker.Type = "ColorPicker"
    ColorPicker.Name = text
    ColorPicker.Value = default or Config.PrimaryColor
    
    ColorPicker.Frame = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        LayoutOrder = #section.Content:GetChildren()
    })
    
    ColorPicker.Label = Create("TextLabel", {
        Parent = ColorPicker.Frame,
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Config.TextColor,
        Font = Config.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    ColorPicker.Preview = Create("TextButton", {
        Parent = ColorPicker.Frame,
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -40, 0.5, -10),
        BackgroundColor3 = ColorPicker.Value,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false
    })
    
    Create("UICorner", {
        Parent = ColorPicker.Preview,
        CornerRadius = UDim.new(0, 4)
    })
    
    Create("UIStroke", {
        Parent = ColorPicker.Preview,
        Color = Color3.fromRGB(80, 80, 90),
        Thickness = 1
    })
    
    -- Simple color picker dialog
    local colorDialog = Create("Frame", {
        Parent = self.ScreenGui,
        Size = UDim2.new(0, 200, 0, 180),
        BackgroundColor3 = Config.SecondaryColor,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 1000
    })
    
    Create("UICorner", {
        Parent = colorDialog,
        CornerRadius = UDim.new(0, 6)
    })
    
    Create("UIStroke", {
        Parent = colorDialog,
        Color = Config.PrimaryColor,
        Thickness = 1
    })
    
    local colorValues = {"FF0000", "00FF00", "0000FF", "FFFF00", "FF00FF", "00FFFF", "FFFFFF", "FF8800", "8800FF", "0088FF"}
    
    local colorGrid = Create("Frame", {
        Parent = colorDialog,
        Size = UDim2.new(1, -20, 1, -40),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundTransparency = 1
    })
    
    local uiGridLayout = Create("UIGridLayout", {
        Parent = colorGrid,
        CellSize = UDim2.new(0, 30, 0, 30),
        CellPadding = UDim2.new(0, 5, 0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    for i, hex in ipairs(colorValues) do
        local color = Color3.fromHex(hex)
        local colorButton = Create("TextButton", {
            Parent = colorGrid,
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false
        })
        
        Create("UICorner", {
            Parent = colorButton,
            CornerRadius = UDim.new(0, 4)
        })
        
        Create("UIStroke", {
            Parent = colorButton,
            Color = Color3.fromRGB(40, 40, 50),
            Thickness = 1
        })
        
        colorButton.MouseButton1Click:Connect(function()
            ColorPicker.Value = color
            ColorPicker.Preview.BackgroundColor3 = color
            colorDialog.Visible = false
            
            if callback then
                local success, err = pcall(callback, color)
                if not success then
                    warn("ColorPicker callback error:", err)
                end
            end
        end)
    end
    
    local dialogTitle = Create("TextLabel", {
        Parent = colorDialog,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        Text = "Select Color",
        TextColor3 = Config.TextColor,
        Font = Config.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center
    })
    
    local previewConnection = ColorPicker.Preview.MouseButton1Click:Connect(function()
        colorDialog.Position = UDim2.new(
            0, ColorPicker.Preview.AbsolutePosition.X - 90,
            0, ColorPicker.Preview.AbsolutePosition.Y + 25
        )
        colorDialog.Visible = not colorDialog.Visible
    end)
    
    table.insert(self.Connections, previewConnection)
    
    -- Close dialog when clicking elsewhere
    local function closeDialog(input)
        if colorDialog.Visible and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local dialogPos = colorDialog.AbsolutePosition
            local dialogSize = colorDialog.AbsoluteSize
            
            if not (mousePos.X >= dialogPos.X and mousePos.X <= dialogPos.X + dialogSize.X and
                   mousePos.Y >= dialogPos.Y and mousePos.Y <= dialogPos.Y + dialogSize.Y) then
                colorDialog.Visible = false
            end
        end
    end
    
    local dialogConnection = UserInputService.InputBegan:Connect(closeDialog)
    table.insert(self.Connections, dialogConnection)
    
    -- Store for theme updates
    table.insert(self.Elements, {
        Type = "ColorPicker",
        Object = ColorPicker,
        Section = section
    })
    
    -- Store in tab for config saving
    if section.Parent.Parent then
        for _, tab in ipairs(self.Tabs) do
            if tab.Content == section.Parent then
                table.insert(tab.Elements, {
                    Type = "ColorPicker",
                    Name = text,
                    Value = ColorPicker.Value,
                    Callback = callback
                })
                break
            end
        end
    end
    
    return ColorPicker
end

-- Tooltip System
function GamesenseUI:AddTooltip(element, text)
    if not element or not text then return end
    
    local tooltip = Create("Frame", {
        Parent = self.ScreenGui,
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Config.SecondaryColor,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 1000
    })
    
    Create("UICorner", {
        Parent = tooltip,
        CornerRadius = UDim.new(0, 4)
    })
    
    Create("UIStroke", {
        Parent = tooltip,
        Color = Config.PrimaryColor,
        Thickness = 1
    })
    
    local tooltipText = Create("TextLabel", {
        Parent = tooltip,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Config.TextColor,
        Font = Config.Font,
        TextSize = 12,
        TextWrapped = true
    })
    
    local hoverConnection
    hoverConnection = element.MouseEnter:Connect(function()
        -- Calculate size based on text
        local textSize = game:GetService("TextService"):GetTextSize(
            text, 
            12, 
            Config.Font, 
            Vector2.new(200, math.huge)
        )
        
        tooltip.Size = UDim2.new(0, textSize.X + 20, 0, textSize.Y + 10)
        
        -- Position tooltip near mouse
        local mousePos = UserInputService:GetMouseLocation()
        tooltip.Position = UDim2.new(0, mousePos.X + 15, 0, mousePos.Y + 15)
        tooltip.Visible = true
    end)
    
    local leaveConnection
    leaveConnection = element.MouseLeave:Connect(function()
        tooltip.Visible = false
    end)
    
    table.insert(self.Connections, hoverConnection)
    table.insert(self.Connections, leaveConnection)
end

-- Configuration Management
function GamesenseUI:SaveConfig(filename)
    filename = filename or self.ConfigFile
    
    local config = {
        WindowPosition = {
            X = self.MainFrame.Position.X.Scale,
            Y = self.MainFrame.Position.Y.Scale,
            OffsetX = self.MainFrame.Position.X.Offset,
            OffsetY = self.MainFrame.Position.Y.Offset
        },
        WindowSize = {
            Width = self.MainFrame.Size.X.Offset,
            Height = self.MainFrame.Size.Y.Offset
        },
        Theme = "Dark", -- Default theme
        Tabs = {}
    }
    
    for _, tab in ipairs(self.Tabs) do
        local tabConfig = {
            Name = tab.Name,
            Elements = {}
        }
        
        for _, element in ipairs(tab.Elements) do
            local valueToSave = element.Value
            
            -- Handle special types
            if element.Type == "ColorPicker" then
                valueToSave = {valueToSave.R, valueToSave.G, valueToSave.B}
            elseif element.Type == "Keybind" then
                valueToSave = tostring(valueToSave)
            end
            
            table.insert(tabConfig.Elements, {
                Type = element.Type,
                Name = element.Name,
                Value = valueToSave
            })
        end
        
        table.insert(config.Tabs, tabConfig)
    end
    
    if writefile then
        local success, err = pcall(function()
            writefile(filename, HttpService:JSONEncode(config))
        end)
        
        if not success then
            warn("Failed to save config:", err)
        end
    end
end

function GamesenseUI:LoadConfig(filename)
    filename = filename or self.ConfigFile
    
    if readfile and isfile then
        local success, fileContent = pcall(function()
            return readfile(filename)
        end)
        
        if success and fileContent then
            local success2, config = pcall(function()
                return HttpService:JSONDecode(fileContent)
            end)
            
            if success2 and config then
                -- Apply window position
                if config.WindowPosition then
                    self.MainFrame.Position = UDim2.new(
                        config.WindowPosition.X or 0.5,
                        config.WindowPosition.OffsetX or -250,
                        config.WindowPosition.Y or 0.5,
                        config.WindowPosition.OffsetY or -225
                    )
                end
                
                -- Apply theme
                if config.Theme and GamesenseUI.Themes[config.Theme] then
                    self:SetTheme(config.Theme)
                end
                
                -- Apply element values
                if config.Tabs then
                    for _, tabConfig in ipairs(config.Tabs) do
                        for _, elementConfig in ipairs(tabConfig.Elements) do
                            -- Find the element and apply value
                            for _, element in ipairs(self.Elements) do
                                if element.Object.Name == elementConfig.Name then
                                    if element.Type == "Toggle" and element.Object.Set then
                                        element.Object.Set(elementConfig.Value == true, true)
                                    elseif element.Type == "Slider" and element.Object.Set then
                                        element.Object.Set(elementConfig.Value or element.Object.Min, true)
                                    elseif element.Type == "ColorPicker" and elementConfig.Value then
                                        if type(elementConfig.Value) == "table" then
                                            element.Object.Value = Color3.new(
                                                elementConfig.Value[1] or 1,
                                                elementConfig.Value[2] or 1,
                                                elementConfig.Value[3] or 1
                                            )
                                            element.Object.Preview.BackgroundColor3 = element.Object.Value
                                        end
                                    elseif element.Type == "Dropdown" then
                                        element.Object.Value = elementConfig.Value or element.Object.Options[1]
                                        element.Object.Button.Text = element.Object.Value
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Cleanup and destruction
function GamesenseUI:Destroy()
    -- Disconnect all connections
    for _, connection in ipairs(self.Connections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end
    
    -- Clear tables
    self.Connections = {}
    self.Elements = {}
    self.Tabs = {}
    
    -- Destroy GUI
    if self.ScreenGui then
        self.ScreenGui:Destroy()
        self.ScreenGui = nil
    end
    
    -- Save config before destruction
    self:SaveConfig()
    
    -- Clear self reference
    setmetatable(self, nil)
    
    return nil
end

-- Create a notification system
function GamesenseUI:Notify(title, message, duration)
    duration = duration or 5
    
    local notification = Create("Frame", {
        Parent = self.ScreenGui,
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(1, -320, 1, -100),
        BackgroundColor3 = Config.SecondaryColor,
        BorderSizePixel = 0,
        ZIndex = 10000
    })
    
    Create("UICorner", {
        Parent = notification,
        CornerRadius = UDim.new(0, 6)
    })
    
    Create("UIStroke", {
        Parent = notification,
        Color = Config.PrimaryColor,
        Thickness = 1
    })
    
    local titleLabel = Create("TextLabel", {
        Parent = notification,
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Config.PrimaryColor,
        Font = Config.Font,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
    })
    
    local messageLabel = Create("TextLabel", {
        Parent = notification,
        Size = UDim2.new(1, -20, 1, -45),
        Position = UDim2.new(0, 10, 0, 35),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Config.TextColor,
        Font = Config.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })
    
    -- Animate in
    notification.Position = UDim2.new(1, 300, 1, -100)
    
    local tweenIn = TweenService:Create(notification, TweenInfo.new(0.3, EasingStyles.Quad), {
        Position = UDim2.new(1, -320, 1, -100)
    })
    tweenIn:Play()
    
    -- Auto remove after duration
    task.delay(duration, function()
        if notification and notification.Parent then
            local tweenOut = TweenService:Create(notification, TweenInfo.new(0.3, EasingStyles.Quad), {
                Position = UDim2.new(1, 300, 1, -100)
            })
            
            tweenOut.Completed:Connect(function()
                if notification and notification.Parent then
                    notification:Destroy()
                end
            end)
            
            tweenOut:Play()
        end
    end)
    
    -- Click to dismiss
    notification.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if notification and notification.Parent then
                notification:Destroy()
            end
        end
    end)
end

-- Export the library
return GamesenseUI
