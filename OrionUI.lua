local Orion = {}

-- Theme Configuration
Orion.Themes = {
    Default = {
        MainColor = Color3.fromRGB(139, 0, 23),
        SecondaryColor = Color3.fromRGB(181, 1, 31),
        BackgroundColor = Color3.fromRGB(25, 25, 25),
        TabColor = Color3.fromRGB(33, 33, 33),
        TextColor = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(198, 198, 198)
    },
    Dark = {
        MainColor = Color3.fromRGB(30, 30, 30),
        SecondaryColor = Color3.fromRGB(50, 50, 50),
        BackgroundColor = Color3.fromRGB(20, 20, 20),
        TabColor = Color3.fromRGB(40, 40, 40),
        TextColor = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180)
    },
    Blue = {
        MainColor = Color3.fromRGB(0, 100, 200),
        SecondaryColor = Color3.fromRGB(0, 150, 255),
        BackgroundColor = Color3.fromRGB(25, 25, 35),
        TabColor = Color3.fromRGB(35, 35, 45),
        TextColor = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 220)
    }
}

-- Utility Functions
local function MakeDraggable(frame, dragHandle)
    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local dragStart, frameStart
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                frameStart.X.Scale,
                frameStart.X.Offset + delta.X,
                frameStart.Y.Scale,
                frameStart.Y.Offset + delta.Y
            )
        end
    end)
end

local function CreateRoundedFrame(name, parent, size, position, color, cornerRadius)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Parent = parent
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    frame.Size = size
    frame.Position = position
    frame.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(cornerRadius or 0, 0)
    corner.Parent = frame
    
    return frame, corner
end

function Orion:CreateOrion(orionName, themeName)
    orionName = orionName or "Orion"
    local theme = Orion.Themes[themeName] or Orion.Themes.Default
    
    local isClosed = false
    local isMinimized = false
    
    -- Main GUI Container
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "OrionGUI"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Main Window
    local MainWindow = CreateRoundedFrame("MainWindow", ScreenGui, 
        UDim2.new(0, 528, 0, 310), 
        UDim2.new(0.3, 0, 0.3, 0), 
        theme.MainColor, 0.03
    )
    
    -- Inner Container
    local InnerContainer = CreateRoundedFrame("InnerContainer", MainWindow,
        UDim2.new(1, -6, 1, 0),
        UDim2.new(0.011, 0, 0, 0),
        theme.BackgroundColor, 0.03
    )
    
    -- Tab Container
    local TabContainer = CreateRoundedFrame("TabContainer", InnerContainer,
        UDim2.new(0, 100, 0, 309),
        UDim2.new(0, 0, 0, 0),
        theme.TabColor, 0.03
    )
    TabContainer.BorderColor3 = Color3.fromRGB(53, 53, 53)
    TabContainer.BorderSizePixel = 1
    
    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabContainer
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 2)
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.Parent = TabContainer
    TabPadding.PaddingRight = UDim.new(0, 2)
    TabPadding.PaddingTop = UDim.new(0, 5)
    
    -- Header
    local Header = CreateRoundedFrame("Header", InnerContainer,
        UDim2.new(0, 408, 0, 43),
        UDim2.new(0.208, 0, 0.026, 0),
        theme.SecondaryColor, 0.03
    )
    
    local LibTitle = Instance.new("TextLabel")
    LibTitle.Name = "LibTitle"
    LibTitle.Parent = Header
    LibTitle.BackgroundTransparency = 1
    LibTitle.Size = UDim2.new(0, 343, 1, 0)
    LibTitle.Position = UDim2.new(0.029, 0, 0, 0)
    LibTitle.Font = Enum.Font.GothamSemibold
    LibTitle.Text = orionName
    LibTitle.TextColor3 = theme.TextColor
    LibTitle.TextSize = 18
    LibTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Control Buttons
    local ControlButtons = Instance.new("Frame")
    ControlButtons.Name = "ControlButtons"
    ControlButtons.Parent = Header
    ControlButtons.BackgroundTransparency = 1
    ControlButtons.Size = UDim2.new(0, 60, 1, 0)
    ControlButtons.Position = UDim2.new(0.88, 0, 0, 0)
    
    local MinimizeBtn = Instance.new("ImageButton")
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Parent = ControlButtons
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
    MinimizeBtn.Position = UDim2.new(0, 0, 0.5, -10)
    MinimizeBtn.Image = "rbxassetid://6031094677"
    MinimizeBtn.ImageColor3 = theme.TextColor
    
    local CloseBtn = Instance.new("ImageButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = ControlButtons
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(0.5, 0, 0.5, -10)
    CloseBtn.Image = "rbxassetid://6031094678"
    CloseBtn.ImageColor3 = theme.TextColor
    
    -- Element Container
    local ElementContainer = CreateRoundedFrame("ElementContainer", InnerContainer,
        UDim2.new(0, 408, 0, 243),
        UDim2.new(0.208, 0, 0.187, 0),
        theme.TabColor, 0.03
    )
    
    -- Pages Folder
    local PagesFolder = Instance.new("Folder")
    PagesFolder.Name = "PagesFolder"
    PagesFolder.Parent = ElementContainer
    
    -- Make draggable
    MakeDraggable(MainWindow, Header)
    
    -- Button Functionality
    CloseBtn.MouseButton1Click:Connect(function()
        isClosed = not isClosed
        if isClosed then
            MainWindow:TweenSize(UDim2.new(0, 424, 0, 58), "In", "Quad", 0.15)
            CloseBtn.Image = "rbxassetid://6031094679"
        else
            MainWindow:TweenSize(UDim2.new(0, 528, 0, 310), "Out", "Quad", 0.15)
            CloseBtn.Image = "rbxassetid://6031094678"
        end
    end)
    
    MinimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            InnerContainer.Visible = false
            MinimizeBtn.Image = "rbxassetid://6031094680"
        else
            InnerContainer.Visible = true
            MinimizeBtn.Image = "rbxassetid://6031094677"
        end
    end)
    
    -- Tab Management
    local CurrentTab = nil
    local Tabs = {}
    
    local function SwitchToTab(tabName)
        for name, tabData in pairs(Tabs) do
            tabData.Page.Visible = (name == tabName)
            if name == tabName then
                game.TweenService:Create(tabData.Button, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = theme.SecondaryColor
                }):Play()
            else
                game.TweenService:Create(tabData.Button, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = theme.BackgroundColor
                }):Play()
            end
        end
        CurrentTab = tabName
    end
    
    -- Notification System
    local function Notify(title, message, duration)
        duration = duration or 5
        
        local Notification = Instance.new("Frame")
        Notification.Name = "Notification"
        Notification.Parent = ScreenGui
        Notification.BackgroundColor3 = theme.BackgroundColor
        Notification.BorderSizePixel = 0
        Notification.Size = UDim2.new(0, 300, 0, 80)
        Notification.Position = UDim2.new(1, -320, 1, -100)
        Notification.ZIndex = 100
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Notification
        
        local Stroke = Instance.new("UIStroke")
        Stroke.Parent = Notification
        Stroke.Color = theme.SecondaryColor
        Stroke.Thickness = 2
        
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Parent = Notification
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Size = UDim2.new(1, -20, 0, 30)
        TitleLabel.Position = UDim2.new(0, 10, 0, 5)
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.Text = title
        TitleLabel.TextColor3 = theme.TextColor
        TitleLabel.TextSize = 16
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local MessageLabel = Instance.new("TextLabel")
        MessageLabel.Parent = Notification
        MessageLabel.BackgroundTransparency = 1
        MessageLabel.Size = UDim2.new(1, -20, 0, 40)
        MessageLabel.Position = UDim2.new(0, 10, 0, 35)
        MessageLabel.Font = Enum.Font.Gotham
        MessageLabel.Text = message
        MessageLabel.TextColor3 = theme.TextSecondary
        MessageLabel.TextSize = 14
        MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
        MessageLabel.TextYAlignment = Enum.TextYAlignment.Top
        MessageLabel.TextWrapped = true
        
        Notification:TweenPosition(UDim2.new(1, -320, 1, -100), "Out", "Quad", 0.3)
        
        task.delay(duration, function()
            Notification:TweenPosition(UDim2.new(1, 20, 1, -100), "In", "Quad", 0.3)
            task.wait(0.3)
            Notification:Destroy()
        end)
    end
    
    -- Public Methods
    local OrionLib = {}
    
    function OrionLib:Notify(title, message, duration)
        Notify(title, message, duration)
    end
    
    function OrionLib:Destroy()
        ScreenGui:Destroy()
    end
    
    function OrionLib:Hide()
        ScreenGui.Enabled = false
    end
    
    function OrionLib:Show()
        ScreenGui.Enabled = true
    end
    
    function OrionLib:Toggle()
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
    
    function OrionLib:SetTheme(newThemeName)
        local newTheme = Orion.Themes[newThemeName]
        if newTheme then
            theme = newTheme
            -- Update colors
            MainWindow.BackgroundColor3 = theme.MainColor
            Header.BackgroundColor3 = theme.SecondaryColor
            InnerContainer.BackgroundColor3 = theme.BackgroundColor
            TabContainer.BackgroundColor3 = theme.TabColor
            LibTitle.TextColor3 = theme.TextColor
            
            -- Update all tabs
            for _, tabData in pairs(Tabs) do
                if CurrentTab == tabData.Name then
                    tabData.Button.BackgroundColor3 = theme.SecondaryColor
                else
                    tabData.Button.BackgroundColor3 = theme.BackgroundColor
                end
            end
        end
    end
    
    function OrionLib:CreateTab(tabName)
        tabName = tabName or "Tab"
        
        -- Tab Button
        local TabButton = CreateRoundedFrame("Tab_" .. tabName, TabContainer,
            UDim2.new(0, 95, 0, 32),
            UDim2.new(0.06, 0, 0, 0),
            theme.BackgroundColor, 0.03
        )
        TabButton.BorderSizePixel = 1
        TabButton.BorderColor3 = Color3.fromRGB(53, 53, 53)
        
        local ButtonText = Instance.new("TextButton")
        ButtonText.Name = "TextButton"
        ButtonText.Parent = TabButton
        ButtonText.BackgroundTransparency = 1
        ButtonText.Size = UDim2.new(1, 0, 1, 0)
        ButtonText.Font = Enum.Font.GothamSemibold
        ButtonText.Text = tabName
        ButtonText.TextColor3 = theme.TextColor
        ButtonText.TextSize = 14
        ButtonText.AutoButtonColor = false
        
        -- Page
        local Page = Instance.new("ScrollingFrame")
        Page.Name = "Page_" .. tabName
        Page.Parent = PagesFolder
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.ScrollBarThickness = 5
        Page.ScrollBarImageColor3 = theme.SecondaryColor
        Page.Visible = false
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        
        local PageList = Instance.new("UIListLayout")
        PageList.Parent = Page
        PageList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Padding = UDim.new(0, 5)
        
        local PagePadding = Instance.new("UIPadding")
        PagePadding.Parent = Page
        PagePadding.PaddingTop = UDim.new(0, 10)
        PagePadding.PaddingBottom = UDim.new(0, 10)
        
        -- Add to tabs
        Tabs[tabName] = {
            Name = tabName,
            Button = TabButton,
            Page = Page,
            Elements = {}
        }
        
        -- Set as first tab if none selected
        if not CurrentTab then
            CurrentTab = tabName
            SwitchToTab(tabName)
        end
        
        -- Click handler
        ButtonText.MouseButton1Click:Connect(function()
            SwitchToTab(tabName)
        end)
        
        -- Element Creation Functions
        local TabFunctions = {}
        
        function TabFunctions:AddLabel(text, textColor)
            local LabelFrame = CreateRoundedFrame("LabelFrame", Page,
                UDim2.new(0.95, 0, 0, 40),
                UDim2.new(0, 0, 0, 0),
                theme.BackgroundColor, 0.03
            )
            
            local Label = Instance.new("TextLabel")
            Label.Parent = LabelFrame
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.new(1, -10, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Font = Enum.Font.GothamSemibold
            Label.Text = text
            Label.TextColor3 = textColor or theme.TextColor
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            table.insert(Tabs[tabName].Elements, LabelFrame)
            return Label
        end
        
        function TabFunctions:AddButton(text, callback)
            local ButtonFrame = CreateRoundedFrame("ButtonFrame", Page,
                UDim2.new(0.95, 0, 0, 40),
                UDim2.new(0, 0, 0, 0),
                theme.BackgroundColor, 0.03
            )
            
            local Button = Instance.new("TextButton")
            Button.Parent = ButtonFrame
            Button.BackgroundColor3 = theme.SecondaryColor
            Button.Size = UDim2.new(0.35, 0, 0.7, 0)
            Button.Position = UDim2.new(0.025, 0, 0.15, 0)
            Button.Font = Enum.Font.GothamSemibold
            Button.Text = text
            Button.TextColor3 = theme.TextColor
            Button.TextSize = 14
            Button.AutoButtonColor = false
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 3)
            Corner.Parent = Button
            
            local InfoLabel = Instance.new("TextLabel")
            InfoLabel.Parent = ButtonFrame
            InfoLabel.BackgroundTransparency = 1
            InfoLabel.Size = UDim2.new(0.6, 0, 1, 0)
            InfoLabel.Position = UDim2.new(0.4, 0, 0, 0)
            InfoLabel.Font = Enum.Font.GothamSemibold
            InfoLabel.Text = text
            InfoLabel.TextColor3 = theme.TextSecondary
            InfoLabel.TextSize = 14
            InfoLabel.TextXAlignment = Enum.TextXAlignment.Right
            
            -- Hover effects
            local originalColor = theme.SecondaryColor
            local hoverColor = Color3.fromRGB(
                math.min(255, originalColor.R * 255 + 30),
                math.min(255, originalColor.G * 255 + 30),
                math.min(255, originalColor.B * 255 + 30)
            )
            
            Button.MouseEnter:Connect(function()
                game.TweenService:Create(Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = hoverColor
                }):Play()
            end)
            
            Button.MouseLeave:Connect(function()
                game.TweenService:Create(Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = originalColor
                }):Play()
            end)
            
            Button.MouseButton1Click:Connect(function()
                if callback then
                    task.spawn(callback)
                end
            end)
            
            table.insert(Tabs[tabName].Elements, ButtonFrame)
            return Button
        end
        
        function TabFunctions:AddToggle(text, defaultValue, callback)
            defaultValue = defaultValue or false
            
            local ToggleFrame = CreateRoundedFrame("ToggleFrame", Page,
                UDim2.new(0.95, 0, 0, 40),
                UDim2.new(0, 0, 0, 0),
                theme.BackgroundColor, 0.03
            )
            
            local InfoLabel = Instance.new("TextLabel")
            InfoLabel.Parent = ToggleFrame
            InfoLabel.BackgroundTransparency = 1
            InfoLabel.Size = UDim2.new(0.6, 0, 1, 0)
            InfoLabel.Position = UDim2.new(0.4, 0, 0, 0)
            InfoLabel.Font = Enum.Font.GothamSemibold
            InfoLabel.Text = text
            InfoLabel.TextColor3 = theme.TextSecondary
            InfoLabel.TextSize = 14
            InfoLabel.TextXAlignment = Enum.TextXAlignment.Right
            
            local ToggleOuter = CreateRoundedFrame("ToggleOuter", ToggleFrame,
                UDim2.new(0, 50, 0, 24),
                UDim2.new(0.05, 0, 0.2, 0),
                theme.SecondaryColor, 0.5
            )
            
            local ToggleInner = CreateRoundedFrame("ToggleInner", ToggleOuter,
                UDim2.new(0, 20, 0, 20),
                UDim2.new(0.02, 0, 0.02, 0),
                theme.TextColor, 0.5
            )
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Parent = ToggleOuter
            ToggleButton.BackgroundTransparency = 1
            ToggleButton.Size = UDim2.new(1, 0, 1, 0)
            ToggleButton.Text = ""
            
            local isToggled = defaultValue
            
            local function UpdateToggle()
                if isToggled then
                    ToggleInner:TweenPosition(UDim2.new(0.5, 0, 0.02, 0), "Out", "Quad", 0.2)
                    ToggleOuter.BackgroundColor3 = theme.SecondaryColor
                else
                    ToggleInner:TweenPosition(UDim2.new(0.02, 0, 0.02, 0), "Out", "Quad", 0.2)
                    ToggleOuter.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                end
            end
            
            UpdateToggle()
            
            ToggleButton.MouseButton1Click:Connect(function()
                isToggled = not isToggled
                UpdateToggle()
                if callback then
                    task.spawn(callback, isToggled)
                end
            end)
            
            table.insert(Tabs[tabName].Elements, ToggleFrame)
            
            local ToggleObj = {}
            function ToggleObj:Set(value)
                isToggled = value
                UpdateToggle()
            end
            function ToggleObj:Get()
                return isToggled
            end
            function ToggleObj:Toggle()
                isToggled = not isToggled
                UpdateToggle()
                if callback then
                    task.spawn(callback, isToggled)
                end
            end
            
            return ToggleObj
        end
        
        function TabFunctions:AddSlider(text, min, max, defaultValue, callback)
            min = min or 0
            max = max or 100
            defaultValue = defaultValue or min
            callback = callback or function() end
            
            local SliderFrame = CreateRoundedFrame("SliderFrame", Page,
                UDim2.new(0.95, 0, 0, 60),
                UDim2.new(0, 0, 0, 0),
                theme.BackgroundColor, 0.03
            )
            
            local InfoLabel = Instance.new("TextLabel")
            InfoLabel.Parent = SliderFrame
            InfoLabel.BackgroundTransparency = 1
            InfoLabel.Size = UDim2.new(0.9, 0, 0, 20)
            InfoLabel.Position = UDim2.new(0.05, 0, 0, 5)
            InfoLabel.Font = Enum.Font.GothamSemibold
            InfoLabel.Text = text
            InfoLabel.TextColor3 = theme.TextColor
            InfoLabel.TextSize = 14
            InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Parent = SliderFrame
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Size = UDim2.new(0.2, 0, 0, 20)
            ValueLabel.Position = UDim2.new(0.75, 0, 0, 5)
            ValueLabel.Font = Enum.Font.GothamSemibold
            ValueLabel.Text = tostring(defaultValue)
            ValueLabel.TextColor3 = theme.SecondaryColor
            ValueLabel.TextSize = 14
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            
            local Track = CreateRoundedFrame("Track", SliderFrame,
                UDim2.new(0.9, 0, 0, 8),
                UDim2.new(0.05, 0, 0.6, 0),
                Color3.fromRGB(60, 60, 60), 4
            )
            
            local Fill = CreateRoundedFrame("Fill", Track,
                UDim2.new((defaultValue - min) / (max - min), 0, 1, 0),
                UDim2.new(0, 0, 0, 0),
                theme.SecondaryColor, 4
            )
            
            local SliderButton = Instance.new("TextButton")
            SliderButton.Parent = Track
            SliderButton.BackgroundTransparency = 1
            SliderButton.Size = UDim2.new(1, 0, 1, 0)
            SliderButton.Text = ""
            
            local dragging = false
            
            local function UpdateSlider(value)
                local clamped = math.clamp(value, min, max)
                local percent = (clamped - min) / (max - min)
                Fill.Size = UDim2.new(percent, 0, 1, 0)
                ValueLabel.Text = tostring(math.floor(clamped))
                callback(clamped)
            end
            
            SliderButton.MouseButton1Down:Connect(function()
                dragging = true
            end)
            
            game:GetService("UserInputService").InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
                    local relativeX = (mouse.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X
                    local value = min + (relativeX * (max - min))
                    UpdateSlider(value)
                end
            end)
            
            -- Set initial value
            UpdateSlider(defaultValue)
            
            table.insert(Tabs[tabName].Elements, SliderFrame)
            
            local SliderObj = {}
            function SliderObj:Set(value)
                UpdateSlider(value)
            end
            function SliderObj:Get()
                return tonumber(ValueLabel.Text)
            end
            
            return SliderObj
        end
        
        function TabFunctions:AddDropdown(text, options, defaultValue, callback)
            options = options or {}
            callback = callback or function() end
            
            local DropdownFrame = CreateRoundedFrame("DropdownFrame", Page,
                UDim2.new(0.95, 0, 0, 40),
                UDim2.new(0, 0, 0, 0),
                theme.BackgroundColor, 0.03
            )
            DropdownFrame.ClipsDescendants = true
            
            local InfoLabel = Instance.new("TextLabel")
            InfoLabel.Parent = DropdownFrame
            InfoLabel.BackgroundTransparency = 1
            InfoLabel.Size = UDim2.new(0.6, 0, 1, 0)
            InfoLabel.Position = UDim2.new(0.05, 0, 0, 0)
            InfoLabel.Font = Enum.Font.GothamSemibold
            InfoLabel.Text = text
            InfoLabel.TextColor3 = theme.TextColor
            InfoLabel.TextSize = 14
            InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local SelectedLabel = Instance.new("TextLabel")
            SelectedLabel.Parent = DropdownFrame
            SelectedLabel.BackgroundTransparency = 1
            SelectedLabel.Size = UDim2.new(0.3, 0, 1, 0)
            SelectedLabel.Position = UDim2.new(0.65, 0, 0, 0)
            SelectedLabel.Font = Enum.Font.GothamSemibold
            SelectedLabel.Text = defaultValue or "Select..."
            SelectedLabel.TextColor3 = theme.TextSecondary
            SelectedLabel.TextSize = 14
            SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Parent = DropdownFrame
            DropdownButton.BackgroundTransparency = 1
            DropdownButton.Size = UDim2.new(1, 0, 0, 40)
            DropdownButton.Text = ""
            
            local OptionsFrame = CreateRoundedFrame("OptionsFrame", DropdownFrame,
                UDim2.new(1, -10, 0, 0),
                UDim2.new(0, 5, 1, 5),
                Color3.fromRGB(40, 40, 40), 0.03
            )
            OptionsFrame.Visible = false
            
            local OptionsList = Instance.new("UIListLayout")
            OptionsList.Parent = OptionsFrame
            OptionsList.SortOrder = Enum.SortOrder.LayoutOrder
            OptionsList.Padding = UDim.new(0, 2)
            
            local isOpen = false
            
            local function UpdateHeight()
                if isOpen then
                    local totalHeight = 40 + (#options * 30) + 10
                    DropdownFrame:TweenSize(
                        UDim2.new(0.95, 0, 0, totalHeight),
                        "Out", "Quad", 0.2
                    )
                else
                    DropdownFrame:TweenSize(
                        UDim2.new(0.95, 0, 0, 40),
                        "Out", "Quad", 0.2
                    )
                end
            end
            
            local function CreateOption(optionText)
                local OptionButton = Instance.new("TextButton")
                OptionButton.Parent = OptionsFrame
                OptionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                OptionButton.Size = UDim2.new(1, 0, 0, 28)
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.Text = optionText
                OptionButton.TextColor3 = theme.TextColor
                OptionButton.TextSize = 13
                OptionButton.AutoButtonColor = false
                
                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 3)
                Corner.Parent = OptionButton
                
                -- Hover effects
                OptionButton.MouseEnter:Connect(function()
                    game.TweenService:Create(OptionButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                    }):Play()
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    game.TweenService:Create(OptionButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    }):Play()
                end)
                
                OptionButton.MouseButton1Click:Connect(function()
                    SelectedLabel.Text = optionText
                    isOpen = false
                    OptionsFrame.Visible = false
                    UpdateHeight()
                    callback(optionText)
                end)
            end
            
            -- Create options
            for _, option in ipairs(options) do
                CreateOption(option)
            end
            
            DropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                OptionsFrame.Visible = isOpen
                UpdateHeight()
            end)
            
            -- Close dropdown when clicking elsewhere
            game:GetService("UserInputService").InputBegan:Connect(function(input)
                if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mousePos = game:GetService("Players").LocalPlayer:GetMouse()
                    if not DropdownFrame:IsDescendantOf(mousePos.Target) then
                        isOpen = false
                        OptionsFrame.Visible = false
                        UpdateHeight()
                    end
                end
            end)
            
            table.insert(Tabs[tabName].Elements, DropdownFrame)
            
            local DropdownObj = {}
            function DropdownObj:SetOptions(newOptions)
                OptionsFrame:ClearAllChildren()
                options = newOptions or {}
                for _, option in ipairs(options) do
                    CreateOption(option)
                end
            end
            function DropdownObj:GetSelected()
                return SelectedLabel.Text
            end
            function DropdownObj:SetSelected(value)
                SelectedLabel.Text = value
            end
            
            return DropdownObj
        end
        
        function TabFunctions:AddTextBox(placeholder, callback)
            local TextBoxFrame = CreateRoundedFrame("TextBoxFrame", Page,
                UDim2.new(0.95, 0, 0, 40),
                UDim2.new(0, 0, 0, 0),
                theme.BackgroundColor, 0.03
            )
            
            local TextBox = Instance.new("TextBox")
            TextBox.Parent = TextBoxFrame
            TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            TextBox.Size = UDim2.new(0.9, 0, 0.7, 0)
            TextBox.Position = UDim2.new(0.05, 0, 0.15, 0)
            TextBox.Font = Enum.Font.Gotham
            TextBox.PlaceholderText = placeholder or "Enter text..."
            TextBox.Text = ""
            TextBox.TextColor3 = theme.TextColor
            TextBox.TextSize = 14
            TextBox.ClearTextOnFocus = false
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 3)
            Corner.Parent = TextBox
            
            TextBox.FocusLost:Connect(function(enterPressed)
                if enterPressed and callback then
                    task.spawn(callback, TextBox.Text)
                    TextBox.Text = ""
                end
            end)
            
            table.insert(Tabs[tabName].Elements, TextBoxFrame)
            return TextBox
        end
        
        function TabFunctions:AddKeybind(text, defaultKey, callback)
            defaultKey = defaultKey or Enum.KeyCode.E
            callback = callback or function() end
            
            local KeybindFrame = CreateRoundedFrame("KeybindFrame", Page,
                UDim2.new(0.95, 0, 0, 40),
                UDim2.new(0, 0, 0, 0),
                theme.BackgroundColor, 0.03
            )
            
            local InfoLabel = Instance.new("TextLabel")
            InfoLabel.Parent = KeybindFrame
            InfoLabel.BackgroundTransparency = 1
            InfoLabel.Size = UDim2.new(0.6, 0, 1, 0)
            InfoLabel.Position = UDim2.new(0.05, 0, 0, 0)
            InfoLabel.Font = Enum.Font.GothamSemibold
            InfoLabel.Text = text
            InfoLabel.TextColor3 = theme.TextColor
            InfoLabel.TextSize = 14
            InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local KeyLabel = Instance.new("TextButton")
            KeyLabel.Parent = KeybindFrame
            KeyLabel.BackgroundColor3 = theme.SecondaryColor
            KeyLabel.Size = UDim2.new(0.2, 0, 0.7, 0)
            KeyLabel.Position = UDim2.new(0.75, 0, 0.15, 0)
            KeyLabel.Font = Enum.Font.GothamSemibold
            KeyLabel.Text = defaultKey.Name
            KeyLabel.TextColor3 = theme.TextColor
            KeyLabel.TextSize = 14
            KeyLabel.AutoButtonColor = false
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 3)
            Corner.Parent = KeyLabel
            
            local listening = false
            local currentKey = defaultKey
            
            local function StartListening()
                listening = true
                KeyLabel.Text = "..."
                KeyLabel.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            end
            
            local function StopListening(newKey)
                listening = false
                currentKey = newKey or currentKey
                KeyLabel.Text = currentKey.Name
                KeyLabel.BackgroundColor3 = theme.SecondaryColor
            end
            
            KeyLabel.MouseButton1Click:Connect(function()
                if not listening then
                    StartListening()
                end
            end)
            
            game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
                if listening then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        StopListening(input.KeyCode)
                    end
                elseif input.KeyCode == currentKey and not gameProcessed then
                    callback()
                end
            end)
            
            table.insert(Tabs[tabName].Elements, KeybindFrame)
            
            local KeybindObj = {}
            function KeybindObj:SetKey(keyCode)
                currentKey = keyCode
                KeyLabel.Text = keyCode.Name
            end
            function KeybindObj:GetKey()
                return currentKey
            end
            
            return KeybindObj
        end
        
        function TabFunctions:Clear()
            for _, element in ipairs(Tabs[tabName].Elements) do
                element:Destroy()
            end
            Tabs[tabName].Elements = {}
        end
        
        return TabFunctions
    end
    
    return OrionLib
end

return Orion
