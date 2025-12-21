-- LunarUI Library v1.0
-- Works in both client scripts (exploits) and Studio plugins

local LunarUI = {}
LunarUI.__index = LunarUI

-- Color palette
LunarUI.Colors = {
    Primary = Color3.fromRGB(25, 25, 35),
    Secondary = Color3.fromRGB(35, 35, 45),
    Accent = Color3.fromRGB(0, 170, 255),
    Text = Color3.fromRGB(240, 240, 240),
    Success = Color3.fromRGB(0, 200, 100),
    Warning = Color3.fromRGB(255, 165, 0),
    Error = Color3.fromRGB(255, 50, 50)
}

-- Fonts
LunarUI.Fonts = {
    Title = Enum.Font.GothamBold,
    Default = Enum.Font.Gotham,
    Mono = Enum.Font.Code
}

-- Check environment
LunarUI.IsStudio = game:GetService("RunService"):IsStudio()
LunarUI.IsClient = not LunarUI.IsStudio

-- Create base screen GUI
function LunarUI.CreateBase(parent)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LunarUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if LunarUI.IsStudio then
        -- For plugins, parent directly to plugin GUI
        screenGui.Parent = parent
    else
        -- For client, parent to CoreGui or PlayerGui
        screenGui.Parent = parent
    end
    
    return screenGui
end

-- Main Window Class
function LunarUI.Window(config)
    local window = {}
    setmetatable(window, LunarUI)
    
    -- Configuration
    window.Title = config.Title or "Lunar UI"
    window.Size = config.Size or UDim2.new(0, 400, 0, 500)
    window.Position = config.Position or UDim2.new(0.5, -200, 0.5, -250)
    window.Visible = config.Visible ~= false
    window.Theme = config.Theme or "Dark"
    
    -- Create UI
    window._screenGui = LunarUI.CreateBase(config.Parent or (LunarUI.IsStudio and plugin:CreateToolbar("Lunar").Parent or game.Players.LocalPlayer:WaitForChild("PlayerGui")))
    
    -- Main frame
    window._mainFrame = Instance.new("Frame")
    window._mainFrame.Name = "MainWindow"
    window._mainFrame.Size = window.Size
    window._mainFrame.Position = window.Position
    window._mainFrame.BackgroundColor3 = LunarUI.Colors.Primary
    window._mainFrame.BorderSizePixel = 0
    window._mainFrame.ClipsDescendants = true
    window._mainFrame.Visible = window.Visible
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = window._mainFrame
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = LunarUI.Colors.Secondary
    titleBar.BorderSizePixel = 0
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -40, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = window.Title
    titleText.TextColor3 = LunarUI.Colors.Text
    titleText.TextSize = 18
    titleText.Font = LunarUI.Fonts.Title
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0.5, -15)
    closeButton.BackgroundColor3 = LunarUI.Colors.Error
    closeButton.Text = "X"
    closeButton.TextColor3 = LunarUI.Colors.Text
    closeButton.TextSize = 14
    closeButton.Font = LunarUI.Fonts.Default
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    -- Content frame
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -60)
    contentFrame.Position = UDim2.new(0, 10, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 6
    contentFrame.ScrollBarImageColor3 = LunarUI.Colors.Secondary
    contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    -- UIListLayout for content
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = contentFrame
    
    -- Assemble window
    closeButton.Parent = titleBar
    titleText.Parent = titleBar
    titleBar.Parent = window._mainFrame
    contentFrame.Parent = window._mainFrame
    window._mainFrame.Parent = window._screenGui
    
    -- Drag functionality
    local dragging = false
    local dragStart, frameStart
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = window._mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            window._mainFrame.Position = UDim2.new(
                frameStart.X.Scale, 
                frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, 
                frameStart.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        window:Destroy()
    end)
    
    -- Toggle visibility
    closeButton.MouseButton1Click:Connect(function()
        window._mainFrame.Visible = false
    end)
    
    -- Methods
    function window:SetVisible(state)
        self._mainFrame.Visible = state
        return self
    end
    
    function window:Toggle()
        self._mainFrame.Visible = not self._mainFrame.Visible
        return self
    end
    
    function window:Destroy()
        if self._screenGui then
            self._screenGui:Destroy()
        end
    end
    
    function window:AddSection(title)
        local section = {}
        
        -- Section frame
        local sectionFrame = Instance.new("Frame")
        sectionFrame.Name = "Section"
        sectionFrame.Size = UDim2.new(1, 0, 0, 40)
        sectionFrame.BackgroundTransparency = 1
        sectionFrame.LayoutOrder = #contentFrame:GetChildren()
        
        -- Section title
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "SectionTitle"
        titleLabel.Size = UDim2.new(1, 0, 0, 25)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = "  " .. (title or "Section")
        titleLabel.TextColor3 = LunarUI.Colors.Text
        titleLabel.TextSize = 16
        titleLabel.Font = LunarUI.Fonts.Title
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Content for section elements
        local content = Instance.new("Frame")
        content.Name = "SectionContent"
        content.Size = UDim2.new(1, 0, 0, 0)
        content.Position = UDim2.new(0, 0, 0, 30)
        content.BackgroundTransparency = 1
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 8)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = content
        
        -- Assemble section
        titleLabel.Parent = sectionFrame
        content.Parent = sectionFrame
        sectionFrame.Parent = contentFrame
        
        -- Section methods
        function section:Button(config)
            local button = Instance.new("TextButton")
            button.Name = "Button"
            button.Size = UDim2.new(1, 0, 0, 35)
            button.BackgroundColor3 = LunarUI.Colors.Secondary
            button.Text = config.Text or "Button"
            button.TextColor3 = LunarUI.Colors.Text
            button.TextSize = 14
            button.Font = LunarUI.Fonts.Default
            button.LayoutOrder = #content:GetChildren()
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = button
            
            -- Hover effects
            button.MouseEnter:Connect(function()
                button.BackgroundColor3 = LunarUI.Colors.Accent
            end)
            
            button.MouseLeave:Connect(function()
                button.BackgroundColor3 = LunarUI.Colors.Secondary
            end)
            
            -- Click callback
            if config.Callback and type(config.Callback) == "function" then
                button.MouseButton1Click:Connect(config.Callback)
            end
            
            button.Parent = content
            return button
        end
        
        function section:Toggle(config)
            local toggle = Instance.new("Frame")
            toggle.Name = "Toggle"
            toggle.Size = UDim2.new(1, 0, 0, 25)
            toggle.BackgroundTransparency = 1
            toggle.LayoutOrder = #content:GetChildren()
            
            local state = config.Default or false
            
            -- Toggle button
            local toggleButton = Instance.new("TextButton")
            toggleButton.Name = "ToggleButton"
            toggleButton.Size = UDim2.new(0, 40, 0, 20)
            toggleButton.Position = UDim2.new(1, -45, 0, 2)
            toggleButton.BackgroundColor3 = state and LunarUI.Colors.Success or LunarUI.Colors.Secondary
            toggleButton.Text = ""
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 10)
            toggleCorner.Parent = toggleButton
            
            -- Toggle indicator
            local indicator = Instance.new("Frame")
            indicator.Name = "Indicator"
            indicator.Size = UDim2.new(0, 16, 0, 16)
            indicator.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            indicator.BackgroundColor3 = LunarUI.Colors.Text
            indicator.BorderSizePixel = 0
            
            local indicatorCorner = Instance.new("UICorner")
            indicatorCorner.CornerRadius = UDim.new(1, 0)
            indicatorCorner.Parent = indicator
            
            -- Label
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, -50, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = config.Text or "Toggle"
            label.TextColor3 = LunarUI.Colors.Text
            label.TextSize = 14
            label.Font = LunarUI.Fonts.Default
            label.TextXAlignment = Enum.TextXAlignment.Left
            
            -- Toggle functionality
            toggleButton.MouseButton1Click:Connect(function()
                state = not state
                toggleButton.BackgroundColor3 = state and LunarUI.Colors.Success or LunarUI.Colors.Secondary
                
                local tween = game:GetService("TweenService"):Create(
                    indicator,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}
                )
                tween:Play()
                
                if config.Callback and type(config.Callback) == "function" then
                    config.Callback(state)
                end
            end)
            
            -- Assemble toggle
            indicator.Parent = toggleButton
            label.Parent = toggle
            toggleButton.Parent = toggle
            toggle.Parent = content
            
            return {
                Set = function(val)
                    state = val
                    toggleButton.BackgroundColor3 = state and LunarUI.Colors.Success or LunarUI.Colors.Secondary
                    indicator.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                end,
                Get = function() return state end
            }
        end
        
        function section:Slider(config)
            local slider = Instance.new("Frame")
            slider.Name = "Slider"
            slider.Size = UDim2.new(1, 0, 0, 50)
            slider.BackgroundTransparency = 1
            slider.LayoutOrder = #content:GetChildren()
            
            local value = math.clamp(config.Default or config.Min or 0, config.Min or 0, config.Max or 100)
            
            -- Label
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.Text = string.format("%s: %.2f", config.Text or "Slider", value)
            label.TextColor3 = LunarUI.Colors.Text
            label.TextSize = 14
            label.Font = LunarUI.Fonts.Default
            label.TextXAlignment = Enum.TextXAlignment.Left
            
            -- Track
            local track = Instance.new("Frame")
            track.Name = "Track"
            track.Size = UDim2.new(1, 0, 0, 6)
            track.Position = UDim2.new(0, 0, 0, 25)
            track.BackgroundColor3 = LunarUI.Colors.Secondary
            track.BorderSizePixel = 0
            
            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(0, 3)
            trackCorner.Parent = track
            
            -- Fill
            local fill = Instance.new("Frame")
            fill.Name = "Fill"
            fill.Size = UDim2.new((value - (config.Min or 0)) / ((config.Max or 100) - (config.Min or 0)), 0, 1, 0)
            fill.BackgroundColor3 = LunarUI.Colors.Accent
            fill.BorderSizePixel = 0
            
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(0, 3)
            fillCorner.Parent = fill
            
            -- Handle
            local handle = Instance.new("TextButton")
            handle.Name = "Handle"
            handle.Size = UDim2.new(0, 16, 0, 16)
            handle.Position = UDim2.new(fill.Size.X.Scale, -8, 0.5, -8)
            handle.BackgroundColor3 = LunarUI.Colors.Text
            handle.Text = ""
            handle.ZIndex = 2
            
            local handleCorner = Instance.new("UICorner")
            handleCorner.CornerRadius = UDim.new(1, 0)
            handleCorner.Parent = handle
            
            -- Slider functionality
            local dragging = false
            
            local function updateValue(x)
                local relativeX = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                value = (config.Min or 0) + relativeX * ((config.Max or 100) - (config.Min or 0))
                if config.Precision then
                    value = math.floor(value / config.Precision) * config.Precision
                end
                
                fill.Size = UDim2.new(relativeX, 0, 1, 0)
                handle.Position = UDim2.new(relativeX, -8, 0.5, -8)
                label.Text = string.format("%s: %.2f", config.Text or "Slider", value)
                
                if config.Callback and type(config.Callback) == "function" then
                    config.Callback(value)
                end
            end
            
            handle.MouseButton1Down:Connect(function()
                dragging = true
            end)
            
            game:GetService("UserInputService").InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateValue(input.Position.X)
                end
            end)
            
            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    updateValue(input.Position.X)
                    dragging = true
                end
            end)
            
            -- Assemble slider
            fill.Parent = track
            handle.Parent = slider
            track.Parent = slider
            label.Parent = slider
            slider.Parent = content
            
            return {
                Set = function(val)
                    value = math.clamp(val, config.Min or 0, config.Max or 100)
                    local relativeX = (value - (config.Min or 0)) / ((config.Max or 100) - (config.Min or 0))
                    fill.Size = UDim2.new(relativeX, 0, 1, 0)
                    handle.Position = UDim2.new(relativeX, -8, 0.5, -8)
                    label.Text = string.format("%s: %.2f", config.Text or "Slider", value)
                end,
                Get = function() return value end
            }
        end
        
        function section:Label(text)
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.Text = text or "Label"
            label.TextColor3 = LunarUI.Colors.Text
            label.TextSize = 14
            label.Font = LunarUI.Fonts.Default
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.LayoutOrder = #content:GetChildren()
            label.Parent = content
            
            return label
        end
        
        return section
    end
    
    return window
end

-- Quick notification function
function LunarUI.Notify(title, message, duration)
    duration = duration or 5
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Notification"
    screenGui.Parent = game:GetService("CoreGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 80)
    frame.Position = UDim2.new(1, 10, 1, -90)
    frame.BackgroundColor3 = LunarUI.Colors.Primary
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = LunarUI.Colors.Text
    titleLabel.TextSize = 16
    titleLabel.Font = LunarUI.Fonts.Title
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 1, -40)
    messageLabel.Position = UDim2.new(0, 10, 0, 35)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = 14
    messageLabel.Font = LunarUI.Fonts.Default
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    
    titleLabel.Parent = frame
    messageLabel.Parent = frame
    frame.Parent = screenGui
    
    -- Animate in
    frame.Position = UDim2.new(1, 310, 1, -90)
    local tweenIn = game:GetService("TweenService"):Create(
        frame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, 10, 1, -90)}
    )
    tweenIn:Play()
    
    -- Auto-remove
    task.wait(duration)
    
    local tweenOut = game:GetService("TweenService"):Create(
        frame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {Position = UDim2.new(1, 310, 1, -90)}
    )
    tweenOut:Play()
    
    tweenOut.Completed:Wait()
    screenGui:Destroy()
end

return LunarUI