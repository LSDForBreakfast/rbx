-- Enhanced executor-compatible UI Library
local isStudio = game:GetService("RunService"):IsStudio()
local Players = game:FindService("Players")

-- Safe service fetching for executors
local function getService(serviceName)
    local success, result = pcall(function()
        return game:GetService(serviceName)
    end)
    if not success then
        return game:FindService(serviceName) or error("Failed to get service: " .. serviceName)
    end
    return result
end

local UIS = getService("UserInputService")
local TweenService = getService("TweenService")
local CoreGui = getService("CoreGui")

-- Safe parent detection for executors
local function getSafeParent()
    if isStudio then
        local player = Players.LocalPlayer
        if player then
            return player:WaitForChild("PlayerGui")
        end
    else
        -- Try multiple possible parents
        local attempts = {
            function()
                local player = Players.LocalPlayer
                if player then
                    local pg = player:FindFirstChild("PlayerGui")
                    if pg then return pg end
                    pg = player:WaitForChild("PlayerGui", 2)
                    return pg
                end
            end,
            function()
                return CoreGui
            end,
            function()
                return game:GetService("StarterGui")
            end
        }
        
        for _, attempt in ipairs(attempts) do
            local success, result = pcall(attempt)
            if success and result then
                return result
            end
        end
    end
    return CoreGui -- Ultimate fallback
end

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

-- Safe instance creation
local function mk(className, props)
    local success, inst = pcall(function()
        return Instance.new(className)
    end)
    
    if not success then
        error("Failed to create instance of type: " .. className)
    end
    
    if props then
        for k, v in pairs(props) do
            if k == "Parent" then
                -- Parent will be set last
            else
                pcall(function()
                    inst[k] = v
                end)
            end
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
-- Window with better executor handling
--////////////////////////////
function Lib:CreateWindow(opts)
    opts = opts or {}
    local title = opts.Title or "xixur.ltd"
    local parent = opts.Parent or getSafeParent()

    -- Create ScreenGui with executor-safe settings
    local sg = mk("ScreenGui", {
        Name = "xixurUILib_" .. tostring(math.random(1, 10000)),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    })

    -- Delay parent assignment for executor compatibility
    task.spawn(function()
        pcall(function()
            sg.Parent = parent
        end)
    end)

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

    local content = mk("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 1, -52),
        Position = UDim2.fromOffset(8, 48),
        Parent = root,
    })

    -- Window object with enhanced memory management
    local window = setmetatable({
        ScreenGui = sg,
        Root = root,
        TopBar = topInner,
        Content = content,
        TabsRow = tabsRow,
        ActiveTab = nil,
        Tabs = {},
        _connections = {},
        _components = {},
    }, Lib)

    -- Enhanced dragging with executor safety
    do
        local dragging = false
        local dragStart, startPos
        
        local function onInputBegan(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = root.Position
            end
        end
        
        local function onInputChanged(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                pcall(function()
                    local delta = input.Position - dragStart
                    root.Position = UDim2.new(
                        startPos.X.Scale, 
                        startPos.X.Offset + delta.X, 
                        startPos.Y.Scale, 
                        startPos.Y.Offset + delta.Y
                    )
                end)
            end
        end
        
        local function onInputEnded(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end

        local conn1 = topInner.InputBegan:Connect(onInputBegan)
        local conn2 = UIS.InputChanged:Connect(onInputChanged)
        local conn3 = UIS.InputEnded:Connect(onInputEnded)
        
        window._connections[#window._connections + 1] = conn1
        window._connections[#window._connections + 1] = conn2
        window._connections[#window._connections + 1] = conn3
    end

    -- Enhanced destroy method
    function window:Destroy()
        -- Destroy all tabs first
        for name, tab in pairs(self.Tabs) do
            if tab.Destroy then
                pcall(tab.Destroy, tab)
            end
        end
        
        -- Disconnect all connections
        for _, conn in ipairs(self._connections) do
            if conn then
                pcall(function() conn:Disconnect() end)
            end
        end
        
        -- Destroy all components
        for _, component in ipairs(self._components) do
            if component and component.Destroy then
                pcall(component.Destroy, component)
            end
        end
        
        -- Destroy UI hierarchy
        if self.ScreenGui then
            pcall(function() self.ScreenGui:Destroy() end)
        end
        
        -- Clear references
        for k in pairs(self) do
            self[k] = nil
        end
    end

    -- Add toggle visibility method
    function window:ToggleVisibility()
        if self.ScreenGui then
            self.ScreenGui.Enabled = not self.ScreenGui.Enabled
        end
    end

    -- Add keybind to toggle UI (F5 by default)
    local toggleConn = UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.F5 then
            window:ToggleVisibility()
        end
    end)
    table.insert(window._connections, toggleConn)

    return window
end

--////////////////////////////
-- Tab with memory management
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
        _components = {},
    }, Tab)

    window.Tabs[name] = t
    table.insert(window._components, t)

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

    -- Enhanced destroy method for Tab
    function t:Destroy()
        -- Disconnect all connections
        for _, conn in ipairs(self._connections) do
            if conn then
                pcall(function() conn:Disconnect() end)
            end
        end
        
        -- Destroy UI elements
        pcall(function()
            if self.Frame then
                self.Frame:Destroy()
            end
            if self.Button then
                self.Button:Destroy()
            end
        end)
        
        -- Remove from window
        if self.Window then
            self.Window.Tabs[self.Name] = nil
            if self.Window.ActiveTab == self then
                self.Window.ActiveTab = nil
            end
        end
        
        -- Clear references
        for k in pairs(self) do
            self[k] = nil
        end
    end

    return t
end

--////////////////////////////
-- Components with memory management
--////////////////////////////
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

-- Checkbox component
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
    local connections = {}

    local function setState(v)
        state = v and true or false
        fill.Visible = state
        pcall(callback, state)
    end

    local boxConn = box.MouseButton1Click:Connect(function() 
        setState(not state) 
    end)
    table.insert(connections, boxConn)
    
    local labelConn = label.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            setState(not state)
        end
    end)
    table.insert(connections, labelConn)

    local keybindConn = UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == keybind then
            setState(not state)
        end
    end)
    table.insert(connections, keybindConn)
    
    table.insert(self._connections, boxConn)
    table.insert(self._connections, labelConn)
    table.insert(self._connections, keybindConn)

    local checkboxObj = {
        Set = function(v) setState(v) end,
        Get = function() return state end,
        SetKeybind = function(newKey)
            keybind = newKey
            pillText.Text = ("key: %s"):format(tostring(keybind):gsub("Enum.KeyCode.", ""))
        end,
        _connections = connections,
        _ui = row,
    }

    function checkboxObj:Destroy()
        for _, conn in ipairs(self._connections) do
            if conn then
                pcall(function() conn:Disconnect() end)
            end
        end
        if self._ui then
            pcall(function() self._ui:Destroy() end)
        end
        for k in pairs(self) do
            self[k] = nil
        end
    end

    setState(default)

    return checkboxObj
end

-- Slider component
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
    local connections = {}

    local function clamp(x) return math.clamp(x, min, max) end
    local function formatValue(x)
        if isInt then
            return ("%d%s"):format(x, suffix)
        else
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
        pcall(callback, val, fromDrag)
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
    table.insert(connections, barConn)

    local inputChangedConn = UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromMouse()
        end
    end)
    table.insert(connections, inputChangedConn)

    local inputEndedConn = UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    table.insert(connections, inputEndedConn)

    table.insert(self._connections, barConn)
    table.insert(self._connections, inputChangedConn)
    table.insert(self._connections, inputEndedConn)

    local sliderObj = {
        Set = function(x) setValue(x, false) end,
        Get = function() return val end,
        _connections = connections,
        _ui = wrap,
    }
    
    function sliderObj:Destroy()
        for _, conn in ipairs(self._connections) do
            if conn then
                pcall(function() conn:Disconnect() end)
            end
        end
        if self._ui then
            pcall(function() self._ui:Destroy() end)
        end
        for k in pairs(self) do
            self[k] = nil
        end
    end

    setValue(default, false)

    return sliderObj
end

-- Add button component
function Tab:AddButton(opts)
    opts = opts or {}
    local text = opts.Text or "Button"
    local callback = opts.Callback or function() end
    
    local btn = mk("TextButton", {
        Name = "Button",
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.CardBg,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Code,
        TextSize = 13,
        AutoButtonColor = false,
        Parent = self.Panel,
    })
    addCorner(btn, 6)
    addStroke(btn, 1)
    
    local conn = btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    
    table.insert(self._connections, conn)
    
    return {
        Destroy = function()
            if conn then
                pcall(function() conn:Disconnect() end)
            end
            if btn then
                pcall(function() btn:Destroy() end)
            end
        end
    }
end

-- Library cleanup function
function Lib:Cleanup()
    if self.Destroy then
        self:Destroy()
    end
end

return Lib
