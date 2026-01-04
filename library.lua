-- Gamesense-inspired Roblox UI Library
-- Made for executors with proper injection handling

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

-- Utility functions
local function Create(class, props)
    local obj = Instance.new(class)
    for prop, val in pairs(props) do
        if prop == "Parent" then
            obj.Parent = val
        else
            obj[prop] = val
        end
    end
    return obj
end

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Main Window
function GamesenseUI:CreateWindow(title)
    local self = setmetatable({}, GamesenseUI)
    
    self.Tabs = {}
    self.Visible = false
    self.ActiveTab = nil
    
    -- ScreenGui
    self.ScreenGui = Create("ScreenGui", {
        Name = "GamesenseUI",
        DisplayOrder = 100,
        ResetOnSpawn = false
    })
    
    -- Main Frame
    self.MainFrame = Create("Frame", {
        Parent = self.ScreenGui,
        Size = UDim2.new(0, 500, 0, 450),
        Position = UDim2.new(0.5, -250, 0.5, -225),
        BackgroundColor3 = Config.BackgroundColor,
        BorderSizePixel = 0,
        Visible = false
    })
    
    -- Top Bar
    self.TopBar = Create("Frame", {
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Config.SecondaryColor,
        BorderSizePixel = 0
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
    
    local padding = Create("UIPadding", {
        Parent = self.Title,
        PaddingLeft = UDim.new(0, 10)
    })
    
    -- Close Button
    self.CloseButton = Create("TextButton", {
        Parent = self.TopBar,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0, 2),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Config.TextColor,
        Font = Enum.Font.GothamBold,
        TextSize = 24
    })
    
    -- Tab Container
    self.TabContainer = Create("Frame", {
        Parent = self.MainFrame,
        Size = UDim2.new(0, 150, 1, -35),
        Position = UDim2.new(0, 0, 0, 35),
        BackgroundColor3 = Config.SecondaryColor,
        BorderSizePixel = 0
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
        VerticalScrollBarInset = Enum.ScrollBarInset.Always
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
        PaddingRight = UDim.new(0, 10)
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
    
    self.TopBar.InputBegan:Connect(function(input)
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
    
    self.TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            Update(input)
        end
    end)
    
    -- Close button functionality
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Toggle keybind
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Config.ToggleKey then
            self:Toggle()
        end
    end)
    
    -- Make sure the UI is parented
    if syn and syn.protect_gui then
        syn.protect_gui(self.ScreenGui)
    elseif gethui then
        self.ScreenGui.Parent = gethui()
    elseif get_hidden_ui then
        self.ScreenGui.Parent = get_hidden_ui()
    else
        self.ScreenGui.Parent = game.CoreGui
    end
    
    return self
end

-- Tab system
function GamesenseUI:CreateTab(name, icon)
    local Tab = {}
    
    -- Tab Button
    Tab.Button = Create("TextButton", {
        Parent = self.TabContainer,
        Size = UDim2.new(1, -10, 0, 35),
        BackgroundColor3 = Config.SecondaryColor,
        BorderSizePixel = 0,
        Text = "  " .. name,
        TextColor3 = Config.TextColor,
        Font = Config.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    Tab.Button.LayoutOrder = #self.Tabs + 1
    
    -- Icon (placeholder for now)
    if icon then
        -- Icon implementation would go here
    end
    
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
    
    Tab.Button.MouseButton1Click:Connect(function()
        self:SwitchTab(Tab)
    end)
    
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
    local contentSize = 0
    for _, child in ipairs(tab.Content:GetChildren()) do
        if child:IsA("GuiObject") and child.Visible then
            contentSize = contentSize + child.AbsoluteSize.Y + 10
        end
    end
    
    self.ContentScrolling.CanvasSize = UDim2.new(0, 0, 0, contentSize + 20)
end

-- Toggle UI visibility
function GamesenseUI:Toggle()
    self.Visible = not self.Visible
    self.MainFrame.Visible = self.Visible
    
    if self.Visible then
        self.MainFrame:TweenSize(
            UDim2.new(0, 500, 0, 450),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.2,
            true
        )
    end
end

-- Section Creator
function GamesenseUI:CreateSection(tab, name)
    local Section = {}
    
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
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    Section.Content = Create("Frame", {
        Parent = Section.Frame,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 25),
        BackgroundColor3 = Config.SecondaryColor,
        BorderSizePixel = 0
    })
    
    local uiListLayout = Create("UIListLayout", {
        Parent = Section.Content,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    local uiPadding = Create("UIPadding", {
        Parent = Section.Content,
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 8)
    })
    
    function Section:UpdateSize()
        local totalHeight = 0
        for _, child in ipairs(self.Content:GetChildren()) do
            if child:IsA("GuiObject") and child.Visible then
                totalHeight = totalHeight + child.AbsoluteSize.Y + 5
            end
        end
        
        self.Content.Size = UDim2.new(1, 0, 0, totalHeight + 16)
        self.Frame.Size = UDim2.new(1, 0, 0, totalHeight + 41)
    end
    
    Section.Content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        Section:UpdateSize()
    end)
    
    Section:UpdateSize()
    
    return Section
end

-- Button Element
function GamesenseUI:CreateButton(section, text, callback)
    local Button = {}
    
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
        TextSize = 14
    })
    
    -- Hover effects
    local originalColor = Button.Button.BackgroundColor3
    local hoverColor = Color3.fromRGB(
        math.min(originalColor.R * 255 + 20, 255),
        math.min(originalColor.G * 255 + 20, 255),
        math.min(originalColor.B * 255 + 20, 255)
    )
    
    Button.Button.MouseEnter:Connect(function()
        Button.Button.BackgroundColor3 = hoverColor
    end)
    
    Button.Button.MouseLeave:Connect(function()
        Button.Button.BackgroundColor3 = originalColor
    end)
    
    Button.Button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    
    section:UpdateSize()
    
    return Button
end

-- Toggle Element
function GamesenseUI:CreateToggle(section, text, default, callback)
    local Toggle = {}
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
    
    Toggle.Indicator = Create("Frame", {
        Parent = Toggle.Button,
        Size = UDim2.new(0, 12, 0, 12),
        Position = Toggle.Value and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
        BackgroundColor3 = Config.TextColor,
        BorderSizePixel = 0
    })
    
    local corner = Create("UICorner", {
        Parent = Toggle.Button,
        CornerRadius = UDim.new(1, 0)
    })
    
    local indicatorCorner = Create("UICorner", {
        Parent = Toggle.Indicator,
        CornerRadius = UDim.new(1, 0)
    })
    
    function Toggle:Set(value)
        Toggle.Value = value
        Toggle.Button.BackgroundColor3 = value and Config.PrimaryColor or Color3.fromRGB(60, 60, 70)
        
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(Toggle.Indicator, tweenInfo, {
            Position = value and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        })
        tween:Play()
        
        if callback then
            callback(value)
        end
    end
    
    Toggle.Button.MouseButton1Click:Connect(function()
        Toggle:Set(not Toggle.Value)
    end)
    
    -- Initialize
    Toggle:Set(Toggle.Value)
    
    section:UpdateSize()
    
    return Toggle
end

-- Slider Element
function GamesenseUI:CreateSlider(section, text, min, max, default, callback)
    local Slider = {}
    Slider.Value = default or min
    Slider.Min = min
    Slider.Max = max
    
    Slider.Frame = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        LayoutOrder = #section.Content:GetChildren()
    })
    
    Slider.Label = Create("TextLabel", {
        Parent = Slider.Frame,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Config.TextColor,
        Font = Config.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    Slider.ValueLabel = Create("TextLabel", {
        Parent = Slider.Frame,
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -60, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(default or min),
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
    
    local trackCorner = Create("UICorner", {
        Parent = Slider.Track,
        CornerRadius = UDim.new(1, 0)
    })
    
    Slider.Fill = Create("Frame", {
        Parent = Slider.Track,
        Size = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0),
        BackgroundColor3 = Config.PrimaryColor,
        BorderSizePixel = 0
    })
    
    local fillCorner = Create("UICorner", {
        Parent = Slider.Fill,
        CornerRadius = UDim.new(1, 0)
    })
    
    Slider.Thumb = Create("Frame", {
        Parent = Slider.Track,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), -6, 0.5, -6),
        BackgroundColor3 = Config.TextColor,
        BorderSizePixel = 0
    })
    
    local thumbCorner = Create("UICorner", {
        Parent = Slider.Thumb,
        CornerRadius = UDim.new(1, 0)
    })
    
    local dragging = false
    
    local function UpdateSlider(input)
        local relativeX = (input.Position.X - Slider.Track.AbsolutePosition.X) / Slider.Track.AbsoluteSize.X
        local value = math.floor(Slider.Min + relativeX * (Slider.Max - Slider.Min))
        value = math.clamp(value, Slider.Min, Slider.Max)
        
        Slider.Value = value
        Slider.ValueLabel.Text = tostring(value)
        Slider.Fill.Size = UDim2.new((value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0)
        Slider.Thumb.Position = UDim2.new((value - Slider.Min) / (Slider.Max - Slider.Min), -6, 0.5, -6)
        
        if callback then
            callback(value)
        end
    end
    
    Slider.Thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    Slider.Thumb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    Slider.Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            UpdateSlider(input)
            dragging = true
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    function Slider:Set(value)
        value = math.clamp(value, Slider.Min, Slider.Max)
        Slider.Value = value
        Slider.ValueLabel.Text = tostring(value)
        Slider.Fill.Size = UDim2.new((value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0)
        Slider.Thumb.Position = UDim2.new((value - Slider.Min) / (Slider.Max - Slider.Min), -6, 0.5, -6)
        
        if callback then
            callback(value)
        end
    end
    
    section:UpdateSize()
    
    return Slider
end

-- Dropdown Element
function GamesenseUI:CreateDropdown(section, text, options, default, callback)
    local Dropdown = {}
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
    
    Dropdown.OptionsFrame = Create("ScrollingFrame", {
        Parent = Dropdown.Frame,
        Size = UDim2.new(0.5, 0, 0, 100),
        Position = UDim2.new(0.5, 0, 1, 5),
        BackgroundColor3 = Config.SecondaryColor,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Config.PrimaryColor,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        ClipsDescendants = true
    })
    
    local optionsList = Create("UIListLayout", {
        Parent = Dropdown.OptionsFrame,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    function Dropdown:Toggle()
        Dropdown.Open = not Dropdown.Open
        Dropdown.OptionsFrame.Visible = Dropdown.Open
        
        if Dropdown.Open then
            -- Populate options
            Dropdown.OptionsFrame:ClearAllChildren()
            
            for i, option in ipairs(Dropdown.Options) do
                local optionButton = Create("TextButton", {
                    Parent = Dropdown.OptionsFrame,
                    Size = UDim2.new(1, 0, 0, 25),
                    BackgroundColor3 = Color3.fromRGB(60, 60, 70),
                    BorderSizePixel = 0,
                    Text = option,
                    TextColor3 = Config.TextColor,
                    Font = Config.Font,
                    TextSize = 14,
                    AutoButtonColor = false,
                    LayoutOrder = i
                })
                
                optionButton.MouseEnter:Connect(function()
                    optionButton.BackgroundColor3 = Config.PrimaryColor
                end)
                
                optionButton.MouseLeave:Connect(function()
                    optionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                end)
                
                optionButton.MouseButton1Click:Connect(function()
                    Dropdown.Value = option
                    Dropdown.Button.Text = option
                    Dropdown:Toggle()
                    
                    if callback then
                        callback(option)
                    end
                end)
            end
            
            Dropdown.OptionsFrame.CanvasSize = UDim2.new(0, 0, 0, #Dropdown.Options * 25)
        end
    end
    
    Dropdown.Button.MouseButton1Click:Connect(function()
        Dropdown:Toggle()
    end)
    
    -- Close dropdown when clicking elsewhere
    local function closeDropdown(input, processed)
        if Dropdown.Open and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local framePos = Dropdown.OptionsFrame.AbsolutePosition
            local frameSize = Dropdown.OptionsFrame.AbsoluteSize
            
            if not (mousePos.X >= framePos.X and mousePos.X <= framePos.X + frameSize.X and
                   mousePos.Y >= framePos.Y and mousePos.Y <= framePos.Y + frameSize.Y) then
                Dropdown:Toggle()
            end
        end
    end
    
    UserInputService.InputBegan:Connect(closeDropdown)
    
    section:UpdateSize()
    
    return Dropdown
end

-- Label Element
function GamesenseUI:CreateLabel(section, text)
    local Label = {}
    
    Label.Frame = Create("Frame", {
        Parent = section.Content,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        LayoutOrder = #section.Content:GetChildren()
    })
    
    Label.Text = Create("TextLabel", {
        Parent = Label.Frame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Config.TextColor,
        Font = Config.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    section:UpdateSize()
    
    return Label
end

-- Keybind Element
function GamesenseUI:CreateKeybind(section, text, default, callback)
    local Keybind = {}
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
        TextSize = 14,
        AutoButtonColor = false
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
    
    Keybind.Button.MouseButton1Click:Connect(function()
        Keybind:SetListening(true)
    end)
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if Keybind.Listening and not processed then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Keybind.Value = input.KeyCode
                Keybind:SetListening(false)
                
                if callback then
                    callback(input.KeyCode)
                end
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                Keybind.Value = Enum.KeyCode.LeftControl -- Example, would need mouse button conversion
                Keybind:SetListening(false)
                
                if callback then
                    callback(Enum.KeyCode.LeftControl)
                end
            end
        elseif input.KeyCode == Keybind.Value and not Keybind.Listening then
            if callback then
                callback(Keybind.Value, true) -- Pass true to indicate it's being pressed
            end
        end
    end)
    
    section:UpdateSize()
    
    return Keybind
end

-- Color Picker (Basic version)
function GamesenseUI:CreateColorPicker(section, text, default, callback)
    local ColorPicker = {}
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
    
    ColorPicker.Preview = Create("Frame", {
        Parent = ColorPicker.Frame,
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -40, 0.5, -10),
        BackgroundColor3 = ColorPicker.Value,
        BorderSizePixel = 0
    })
    
    ColorPicker.Preview.MouseButton1Click:Connect(function()
        -- Note: Full color picker implementation would require a custom color wheel
        -- This is a simplified version
        local r, g, b = math.random(), math.random(), math.random()
        ColorPicker.Value = Color3.new(r, g, b)
        ColorPicker.Preview.BackgroundColor3 = ColorPicker.Value
        
        if callback then
            callback(ColorPicker.Value)
        end
    end)
    
    section:UpdateSize()
    
    return ColorPicker
end

return GamesenseUI
