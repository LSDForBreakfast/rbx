-- Example 1: Basic usage in exploit/client
local LunarUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/LunarUI.lua"))()

local window = LunarUI.Window({
    Title = "Exploit UI Example",
    Size = UDim2.new(0, 350, 0, 400)
})

local mainSection = window:AddSection("Main")

local button = mainSection:Button({
    Text = "Print Hello",
    Callback = function()
        print("Hello from LunarUI!")
        LunarUI.Notify("Success", "Button clicked!", 3)
    end
})

local toggle = mainSection:Toggle({
    Text = "Enable Feature",
    Default = false,
    Callback = function(state)
        print("Toggle state:", state)
    end
})

local slider = mainSection:Slider({
    Text = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

mainSection:Label("Welcome to LunarUI!")

-- Example 2: Studio plugin usage
if game:GetService("RunService"):IsStudio() then
    local toolbar = plugin:CreateToolbar("LunarUI")
    local button = toolbar:CreateButton("Show UI", "Open LunarUI", "rbxassetid://4458901886")
    
    button.Click:Connect(function()
        local window = LunarUI.Window({
            Title = "Studio Plugin",
            Parent = plugin:CreateToolbar("Temp").Parent -- Plugin GUI
        })
        
        local section = window:AddSection("Tools")
        section:Button({
            Text = "Generate Parts",
            Callback = function()
                for i = 1, 10 do
                    local part = Instance.new("Part")
                    part.Size = Vector3.new(4, 4, 4)
                    part.Position = Vector3.new(i * 5, 5, 0)
                    part.Parent = workspace
                end
            end
        })
    end)
end