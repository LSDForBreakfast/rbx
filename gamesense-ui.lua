-- Gamesense UI Library
-- Inspired by skeet.cc/gamesense.pub

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local GamesenseUI = {}
GamesenseUI.__index = GamesenseUI

-- Colors
local colors = {
    background = Color3.fromRGB(20, 20, 25),
    background_dark = Color3.fromRGB(15, 15, 20),
    background_light = Color3.fromRGB(30, 30, 35),
    accent = Color3.fromRGB(0, 150, 255),
    accent_hover = Color3.fromRGB(0, 170, 255),
    text = Color3.fromRGB(240, 240, 240),
    text_dark = Color3.fromRGB(180, 180, 180),
    success = Color3.fromRGB(0, 200, 100),
    warning = Color3.fromRGB(255, 165, 0),
    error = Color3.fromRGB(220, 60, 60),
    border = Color3.fromRGB(50, 50, 55)
}

-- Utility Functions
local function create(class, props)
    local obj = Instance.new(class)
    for prop, value in pairs(props) do
        if prop == "Parent" then
            obj.Parent = value
        else
            obj[prop] = value
        end
    end
    return obj
end

local function tween(obj, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.2,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(obj, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Window Class
local Window = {}
Window.__index = Window

function Window.new(title)
    local self = setmetatable({}, Window)
    
    self.title = title or "Gamesense UI"
    self.tabs = {}
    self.currentTab = nil
    self.open = false
    self.dragging = false
    self.dragOffset = Vector2.new()
    
    self:createUI()
    self:setupConnections()
    
    return self
end

function Window:createUI()
    -- Main container
    self.container = create("ScreenGui", {
        Name = "GamesenseUI",
        Parent = game.CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global
    })
    
    -- Background overlay (optional)
    self.overlay = create("Frame", {
        Name = "Overlay",
        Parent = self.container,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false
    })
    
    -- Main window
    self.mainFrame = create("Frame", {
        Name = "MainWindow",
        Parent = self.container,
        BackgroundColor3 = colors.background,
        BorderColor3 = colors.border,
        BorderSizePixel = 1,
        Position = UDim2.new(0.5, -200, 0.5, -150),
        Size = UDim2.new(0, 400, 0, 400),
        ClipsDescendants = true,
        Visible = false
    })
    
    -- Window title bar
    self.titleBar = create("Frame", {
        Name = "TitleBar",
        Parent = self.mainFrame,
        BackgroundColor3 = colors.background_dark,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35)
    })
    
    -- Title text
    self.titleText = create("TextLabel", {
        Name = "Title",
        Parent = self.titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.5, -10, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = self.title,
        TextColor3 = colors.text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Close button
    self.closeButton = create("TextButton", {
        Name = "CloseButton",
        Parent = self.titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -35, 0, 0),
        Size = UDim2.new(0, 35, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = colors.text_dark,
        TextSize = 24
    })
    
    -- Tab container
    self.tabContainer = create("Frame", {
        Name = "TabContainer",
        Parent = self.mainFrame,
        BackgroundColor3 = colors.background_dark,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(1, 0, 0, 40)
    })
    
    -- Tab list layout
    create("UIListLayout", {
        Parent = self.tabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0)
    })
    
    -- Content container
    self.contentContainer = create("Frame", {
        Name = "ContentContainer",
        Parent = self.mainFrame,
        BackgroundColor3 = colors.background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 75),
        Size = UDim2.new(1, 0, 1, -75),
        ClipsDescendants = true
    })
    
    create("ScrollingFrame", {
        Parent = self.contentContainer,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = colors.accent
    })
    
    -- Watermark
    self.watermark = create("TextLabel", {
        Name = "Watermark",
        Parent = self.container,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 200, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "gamesense.pub",
        TextColor3 = colors.accent,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = true
    })
end

function Window:setupConnections()
    -- Close button
    self.closeButton.MouseEnter:Connect(function()
        tween(self.closeButton, {TextColor3 = colors.error})
    end)
    
    self.closeButton.MouseLeave:Connect(function()
        tween(self.closeButton, {TextColor3 = colors.text_dark})
    end)
    
    self.closeButton.MouseButton1Click:Connect(function()
        self:toggle()
    end)
    
    -- Drag handling
    self.titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.dragging = true
            self.dragStart = input.Position
            self.startPos = self.mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if self.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - self.dragStart
            self.mainFrame.Position = UDim2.new(
                self.startPos.X.Scale,
                self.startPos.X.Offset + delta.X,
                self.startPos.Y.Scale,
                self.startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Keybind to toggle UI (Insert key)
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then
            self:toggle()
        end
    end)
end

function Window:toggle()
    self.open = not self.open
    self.mainFrame.Visible = self.open
    
    if self.open then
        tween(self.mainFrame, {Position = UDim2.new(0.5, -200, 0.5, -150)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
end

function Window:Tab(name)
    local tab = {}
    tab.name = name
    tab.elements = {}
    
    -- Create tab button
    tab.button = create("TextButton", {
        Name = name,
        Parent = self.tabContainer,
        BackgroundColor3 = colors.background_dark,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 100, 1, 0),
        Font = Enum.Font.Gotham,
        Text = name,
        TextColor3 = colors.text_dark,
        TextSize = 14
    })
    
    -- Create tab content frame
    tab.contentFrame = create("ScrollingFrame", {
        Name = name .. "Content",
        Parent = self.contentContainer,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = colors.accent,
        Visible = false
    })
    
    -- Layout for tab content
    local layout = create("UIListLayout", {
        Parent = tab.contentFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })
    
    create("UIPadding", {
        Parent = tab.contentFrame,
        PaddingLeft = UDim.new(0, 15),
        PaddingTop = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15)
    })
    
    -- Update canvas size
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.contentFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Tab button interactions
    tab.button.MouseEnter:Connect(function()
        if tab.button ~= self.currentTab then
            tween(tab.button, {TextColor3 = colors.text})
        end
    end)
    
    tab.button.MouseLeave:Connect(function()
        if tab.button ~= self.currentTab then
            tween(tab.button, {TextColor3 = colors.text_dark})
        end
    end)
    
    tab.button.MouseButton1Click:Connect(function()
        self:switchTab(tab)
    end)
    
    -- Add tab to window
    table.insert(self.tabs, tab)
    
    -- If first tab, make it active
    if #self.tabs == 1 then
        self:switchTab(tab)
    end
    
    -- Methods for adding elements
    function tab:Label(text)
        local label = create("TextLabel", {
            Name = "Label",
            Parent = tab.contentFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 25),
            Font = Enum.Font.GothamBold,
            Text = text,
            TextColor3 = colors.text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = #tab.elements + 1
        })
        
        table.insert(tab.elements, label)
        return label
    end
    
    function tab:Button(text, callback)
        local button = {}
        
        local frame = create("TextButton", {
            Name = "Button",
            Parent = tab.contentFrame,
            BackgroundColor3 = colors.background_light,
            BorderColor3 = colors.border,
            BorderSizePixel = 1,
            Size = UDim2.new(1, 0, 0, 35),
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = colors.text,
            TextSize = 14,
            LayoutOrder = #tab.elements + 1
        })
        
        local stroke = create("UIStroke", {
            Parent = frame,
            Color = colors.accent,
            Thickness = 1,
            Transparency = 0.8
        })
        
        -- Hover effects
        frame.MouseEnter:Connect(function()
            tween(frame, {BackgroundColor3 = colors.accent, TextColor3 = Color3.new(1, 1, 1)})
            tween(stroke, {Transparency = 0})
        end)
        
        frame.MouseLeave:Connect(function()
            tween(frame, {BackgroundColor3 = colors.background_light, TextColor3 = colors.text})
            tween(stroke, {Transparency = 0.8})
        end)
        
        frame.MouseButton1Click:Connect(function()
            if callback then
                callback()
            end
        end)
        
        table.insert(tab.elements, frame)
        
        function button:SetText(newText)
            frame.Text = newText
        end
        
        return button
    end
    
    function tab:Toggle(text, default, callback)
        local toggle = {}
        toggle.value = default or false
        
        local frame = create("Frame", {
            Name = "Toggle",
            Parent = tab.contentFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            LayoutOrder = #tab.elements + 1
        })
        
        local label = create("TextLabel", {
            Name = "Label",
            Parent = frame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0.7, 0, 1, 0),
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = colors.text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local toggleFrame = create("Frame", {
            Name = "ToggleFrame",
            Parent = frame,
            BackgroundColor3 = colors.background_light,
            BorderColor3 = colors.border,
            BorderSizePixel = 1,
            Position = UDim2.new(0.8, 0, 0.2, 0),
            Size = UDim2.new(0.2, 0, 0.6, 0)
        })
        
        local toggleDot = create("Frame", {
            Name = "ToggleDot",
            Parent = toggleFrame,
            BackgroundColor3 = colors.accent,
            Position = toggle.value and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0.5, 0, 1, 0)
        })
        
        -- Click to toggle
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                toggle.value = not toggle.value
                
                if toggle.value then
                    tween(toggleDot, {Position = UDim2.new(0.5, 0, 0, 0)})
                    tween(toggleFrame, {BackgroundColor3 = colors.accent:lerp(Color3.new(1,1,1), 0.2)})
                else
                    tween(toggleDot, {Position = UDim2.new(0, 0, 0, 0)})
                    tween(toggleFrame, {BackgroundColor3 = colors.background_light})
                end
                
                if callback then
                    callback(toggle.value)
                end
            end
        end)
        
        table.insert(tab.elements, frame)
        
        function toggle:SetValue(value)
            toggle.value = value
            
            if toggle.value then
                tween(toggleDot, {Position = UDim2.new(0.5, 0, 0, 0)})
                tween(toggleFrame, {BackgroundColor3 = colors.accent:lerp(Color3.new(1,1,1), 0.2)})
            else
                tween(toggleDot, {Position = UDim2.new(0, 0, 0, 0)})
                tween(toggleFrame, {BackgroundColor3 = colors.background_light})
            end
            
            if callback then
                callback(toggle.value)
            end
        end
        
        function toggle:GetValue()
            return toggle.value
        end
        
        return toggle
    end
    
    function tab:Slider(text, min, max, default, callback)
        local slider = {}
        slider.value = default or min
        slider.min = min
        slider.max = max
        
        local frame = create("Frame", {
            Name = "Slider",
            Parent = tab.contentFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 50),
            LayoutOrder = #tab.elements + 1
        })
        
        local label = create("TextLabel", {
            Name = "Label",
            Parent = frame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 20),
            Font = Enum.Font.Gotham,
            Text = text .. ": " .. tostring(slider.value),
            TextColor3 = colors.text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local sliderFrame = create("Frame", {
            Name = "SliderFrame",
            Parent = frame,
            BackgroundColor3 = colors.background_light,
            BorderColor3 = colors.border,
            BorderSizePixel = 1,
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 0, 15)
        })
        
        local fill = create("Frame", {
            Name = "Fill",
            Parent = sliderFrame,
            BackgroundColor3 = colors.accent,
            Size = UDim2.new((slider.value - min) / (max - min), 0, 1, 0)
        })
        
        local dot = create("Frame", {
            Name = "Dot",
            Parent = sliderFrame,
            BackgroundColor3 = Color3.new(1, 1, 1),
            Position = UDim2.new((slider.value - min) / (max - min), -5, 0, -2.5),
            Size = UDim2.new(0, 10, 0, 20),
            ZIndex = 2
        })
        
        local dragging = false
        
        local function update(value)
            local clamped = math.clamp(value, min, max)
            slider.value = math.floor(clamped * 100) / 100
            
            local percent = (slider.value - min) / (max - min)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            dot.Position = UDim2.new(percent, -5, 0, -2.5)
            label.Text = text .. ": " .. tostring(slider.value)
            
            if callback then
                callback(slider.value)
            end
        end
        
        sliderFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                local percent = (input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X
                update(min + (max - min) * percent)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local percent = (input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X
                update(min + (max - min) * math.clamp(percent, 0, 1))
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        table.insert(tab.elements, frame)
        
        function slider:SetValue(value)
            update(value)
        end
        
        function slider:GetValue()
            return slider.value
        end
        
        return slider
    end
    
    function tab:Dropdown(text, options, default, callback)
        local dropdown = {}
        dropdown.open = false
        dropdown.value = default or options[1]
        dropdown.options = options
        
        local frame = create("Frame", {
            Name = "Dropdown",
            Parent = tab.contentFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            LayoutOrder = #tab.elements + 1,
            ClipsDescendants = true
        })
        
        local label = create("TextLabel", {
            Name = "Label",
            Parent = frame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0.6, 0, 1, 0),
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = colors.text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local dropdownButton = create("TextButton", {
            Name = "DropdownButton",
            Parent = frame,
            BackgroundColor3 = colors.background_light,
            BorderColor3 = colors.border,
            BorderSizePixel = 1,
            Position = UDim2.new(0.6, 5, 0, 0),
            Size = UDim2.new(0.4, -5, 1, 0),
            Font = Enum.Font.Gotham,
            Text = dropdown.value,
            TextColor3 = colors.text,
            TextSize = 14
        })
        
        local dropdownFrame = create("Frame", {
            Name = "DropdownOptions",
            Parent = frame,
            BackgroundColor3 = colors.background_dark,
            BorderColor3 = colors.border,
            BorderSizePixel = 1,
            Position = UDim2.new(0.6, 5, 1, 5),
            Size = UDim2.new(0.4, -5, 0, 0),
            Visible = false,
            ClipsDescendants = true
        })
        
        local optionsLayout = create("UIListLayout", {
            Parent = dropdownFrame,
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        dropdownButton.MouseButton1Click:Connect(function()
            dropdown.open = not dropdown.open
            
            if dropdown.open then
                dropdownFrame.Visible = true
                tween(dropdownFrame, {Size = UDim2.new(0.4, -5, 0, math.min(#options * 30, 150))}, 0.2)
            else
                tween(dropdownFrame, {Size = UDim2.new(0.4, -5, 0, 0)}, 0.2, nil, function()
                    dropdownFrame.Visible = false
                end)
            end
        end)
        
        -- Populate options
        for i, option in ipairs(options) do
            local optionButton = create("TextButton", {
                Name = option,
                Parent = dropdownFrame,
                BackgroundColor3 = colors.background_dark,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.Gotham,
                Text = option,
                TextColor3 = colors.text,
                TextSize = 14,
                LayoutOrder = i
            })
            
            optionButton.MouseEnter:Connect(function()
                tween(optionButton, {BackgroundColor3 = colors.background_light})
            end)
            
            optionButton.MouseLeave:Connect(function()
                tween(optionButton, {BackgroundColor3 = colors.background_dark})
            end)
            
            optionButton.MouseButton1Click:Connect(function()
                dropdown.value = option
                dropdownButton.Text = option
                dropdown.open = false
                
                tween(dropdownFrame, {Size = UDim2.new(0.4, -5, 0, 0)}, 0.2, nil, function()
                    dropdownFrame.Visible = false
                end)
                
                if callback then
                    callback(option)
                end
            end)
        end
        
        table.insert(tab.elements, frame)
        
        function dropdown:SetValue(value)
            if table.find(options, value) then
                dropdown.value = value
                dropdownButton.Text = value
                if callback then
                    callback(value)
                end
            end
        end
        
        function dropdown:GetValue()
            return dropdown.value
        end
        
        function dropdown:AddOption(option)
            table.insert(options, option)
            -- Recreate options (simplified implementation)
        end
        
        return dropdown
    end
    
    function tab:Keybind(text, defaultKey, callback)
        local keybind = {}
        keybind.value = defaultKey or Enum.KeyCode.LeftControl
        keybind.listening = false
        
        local frame = create("Frame", {
            Name = "Keybind",
            Parent = tab.contentFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            LayoutOrder = #tab.elements + 1
        })
        
        local label = create("TextLabel", {
            Name = "Label",
            Parent = frame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0.6, 0, 1, 0),
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = colors.text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local keybindButton = create("TextButton", {
            Name = "KeybindButton",
            Parent = frame,
            BackgroundColor3 = colors.background_light,
            BorderColor3 = colors.border,
            BorderSizePixel = 1,
            Position = UDim2.new(0.6, 5, 0, 0),
            Size = UDim2.new(0.4, -5, 1, 0),
            Font = Enum.Font.Gotham,
            Text = tostring(keybind.value):gsub("Enum.KeyCode.", ""),
            TextColor3 = colors.text,
            TextSize = 14
        })
        
        local connection
        keybindButton.MouseButton1Click:Connect(function()
            keybind.listening = not keybind.listening
            
            if keybind.listening then
                keybindButton.Text = "..."
                keybindButton.BackgroundColor3 = colors.accent
                
                if connection then
                    connection:Disconnect()
                end
                
                connection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        keybind.value = input.KeyCode
                        keybindButton.Text = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                        keybindButton.BackgroundColor3 = colors.background_light
                        keybind.listening = false
                        
                        if connection then
                            connection:Disconnect()
                        end
                        
                        if callback then
                            callback(input.KeyCode)
                        end
                    end
                end)
            else
                keybindButton.BackgroundColor3 = colors.background_light
                keybindButton.Text = tostring(keybind.value):gsub("Enum.KeyCode.", "")
                
                if connection then
                    connection:Disconnect()
                end
            end
        end)
        
        table.insert(tab.elements, frame)
        
        function keybind:SetKey(key)
            keybind.value = key
            keybindButton.Text = tostring(key):gsub("Enum.KeyCode.", "")
        end
        
        function keybind:GetKey()
            return keybind.value
        end
        
        return keybind
    end
    
    return tab
end

function Window:switchTab(tab)
    -- Hide all tabs
    for _, t in ipairs(self.tabs) do
        t.contentFrame.Visible = false
        tween(t.button, {TextColor3 = colors.text_dark})
        tween(t.button, {BackgroundColor3 = colors.background_dark})
    end
    
    -- Show selected tab
    tab.contentFrame.Visible = true
    tween(tab.button, {TextColor3 = colors.accent})
    tween(tab.button, {BackgroundColor3 = colors.background})
    
    self.currentTab = tab
end

function Window:Destroy()
    self.container:Destroy()
    setmetatable(self, nil)
end

-- Public API
function GamesenseUI.new(title)
    return Window.new(title)
end

-- Example usage:
--[[
local ui = GamesenseUI.new("Gamesense UI")

local main = ui:Tab("Main")
local visuals = ui:Tab("Visuals")
local misc = ui:Tab("Misc")

main:Label("Welcome to Gamesense UI")
main:Label("Inspired by gamesense.pub")

main:Button("Test Button", function()
    print("Button clicked!")
end)

local toggle = main:Toggle("Enable Feature", false, function(value)
    print("Toggle:", value)
end)

local slider = main:Slider("Slider Example", 0, 100, 50, function(value)
    print("Slider:", value)
end)

local dropdown = main:Dropdown("Dropdown", {"Option 1", "Option 2", "Option 3"}, "Option 1", function(value)
    print("Selected:", value)
end)

local keybind = main:Keybind("Keybind", Enum.KeyCode.LeftControl, function(key)
    print("Keybind set to:", key)
end)

-- Toggle UI with Insert key
]]

return GamesenseUI
