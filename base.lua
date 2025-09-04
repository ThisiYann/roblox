-- iYann Store Simple UI Library
local iYannStore = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Default Theme
local Theme = {
    Background = Color3.fromRGB(25, 25, 25),
    Topbar = Color3.fromRGB(34, 34, 34),
    TextColor = Color3.fromRGB(240, 240, 240),
    ElementBackground = Color3.fromRGB(35, 35, 35),
    ElementHover = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(0, 146, 214)
}

-- Create main window
function iYannStore:CreateWindow(settings)
    local window = {}
    window.Name = settings.Name or "iYann Store"
    
    -- Create GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "iYannStoreGUI"
    screenGui.Parent = game:GetService("CoreGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "Main"
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.Size = UDim2.new(1, 0, 0, 30)
    topbar.BackgroundColor3 = Theme.Topbar
    topbar.BorderSizePixel = 0
    topbar.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = window.Name
    title.TextColor3 = Theme.TextColor
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.Gotham
    title.Parent = topbar
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "Close"
    closeButton.Text = "X"
    closeButton.TextColor3 = Theme.TextColor
    closeButton.BackgroundTransparency = 1
    closeButton.Size = UDim2.new(0, 30, 1, 0)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = topbar
    
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "Tabs"
    tabContainer.Size = UDim2.new(1, 0, 1, -30)
    tabContainer.Position = UDim2.new(0, 0, 0, 30)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    -- Make draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Close button
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Tab functions
    function window:CreateTab(tabName)
        local tab = {}
        
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName
        tabButton.Text = tabName
        tabButton.Size = UDim2.new(0, 80, 0, 25)
        tabButton.Position = UDim2.new(0, (#tabContainer:GetChildren() - 1) * 85, 0, 5)
        tabButton.BackgroundColor3 = Theme.ElementBackground
        tabButton.TextColor3 = Theme.TextColor
        tabButton.BorderSizePixel = 0
        tabButton.Parent = tabContainer
        
        local contentFrame = Instance.new("ScrollingFrame")
        contentFrame.Name = tabName .. "Content"
        contentFrame.Size = UDim2.new(1, -10, 1, -40)
        contentFrame.Position = UDim2.new(0, 5, 0, 35)
        contentFrame.BackgroundTransparency = 1
        contentFrame.ScrollBarThickness = 5
        contentFrame.Visible = false
        contentFrame.Parent = tabContainer
        
        local uiListLayout = Instance.new("UIListLayout")
        uiListLayout.Padding = UDim.new(0, 5)
        uiListLayout.Parent = contentFrame
        
        -- Show first tab by default
        if #tabContainer:GetChildren() == 2 then -- First tab
            contentFrame.Visible = true
            tabButton.BackgroundColor3 = Theme.Accent
        end
        
        tabButton.MouseButton1Click:Connect(function()
            -- Hide all content frames
            for _, child in ipairs(tabContainer:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
                if child:IsA("TextButton") and child ~= tabButton then
                    child.BackgroundColor3 = Theme.ElementBackground
                end
            end
            
            -- Show this tab's content
            contentFrame.Visible = true
            tabButton.BackgroundColor3 = Theme.Accent
        end)
        
        -- Button element
        function tab:CreateButton(buttonSettings)
            local button = Instance.new("TextButton")
            button.Name = buttonSettings.Name
            button.Text = buttonSettings.Name
            button.Size = UDim2.new(1, -10, 0, 30)
            button.Position = UDim2.new(0, 5, 0, 0)
            button.BackgroundColor3 = Theme.ElementBackground
            button.TextColor3 = Theme.TextColor
            button.BorderSizePixel = 0
            button.Parent = contentFrame
            
            button.MouseEnter:Connect(function()
                button.BackgroundColor3 = Theme.ElementHover
            end)
            
            button.MouseLeave:Connect(function()
                button.BackgroundColor3 = Theme.ElementBackground
            end)
            
            button.MouseButton1Click:Connect(function()
                pcall(buttonSettings.Callback)
            end)
            
            return button
        end
        
        -- Toggle element
        function tab:CreateToggle(toggleSettings)
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Name = toggleSettings.Name
            toggleFrame.Size = UDim2.new(1, -10, 0, 30)
            toggleFrame.BackgroundTransparency = 1
            toggleFrame.Parent = contentFrame
            
            local toggleText = Instance.new("TextLabel")
            toggleText.Name = "Text"
            toggleText.Text = toggleSettings.Name
            toggleText.Size = UDim2.new(0.7, 0, 1, 0)
            toggleText.TextColor3 = Theme.TextColor
            toggleText.BackgroundTransparency = 1
            toggleText.TextXAlignment = Enum.TextXAlignment.Left
            toggleText.Parent = toggleFrame
            
            local toggleButton = Instance.new("TextButton")
            toggleButton.Name = "Toggle"
            toggleButton.Text = toggleSettings.CurrentValue and "ON" or "OFF"
            toggleButton.Size = UDim2.new(0.3, 0, 1, 0)
            toggleButton.Position = UDim2.new(0.7, 0, 0, 0)
            toggleButton.BackgroundColor3 = toggleSettings.CurrentValue and Theme.Accent or Theme.ElementBackground
            toggleButton.TextColor3 = Theme.TextColor
            toggleButton.BorderSizePixel = 0
            toggleButton.Parent = toggleFrame
            
            toggleButton.MouseButton1Click:Connect(function()
                toggleSettings.CurrentValue = not toggleSettings.CurrentValue
                toggleButton.Text = toggleSettings.CurrentValue and "ON" or "OFF"
                toggleButton.BackgroundColor3 = toggleSettings.CurrentValue and Theme.Accent or Theme.ElementBackground
                pcall(toggleSettings.Callback, toggleSettings.CurrentValue)
            end)
            
            return toggleFrame
        end
        
        -- Slider element
        function tab:CreateSlider(sliderSettings)
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Name = sliderSettings.Name
            sliderFrame.Size = UDim2.new(1, -10, 0, 50)
            sliderFrame.BackgroundTransparency = 1
            sliderFrame.Parent = contentFrame
            
            local sliderText = Instance.new("TextLabel")
            sliderText.Name = "Text"
            sliderText.Text = sliderSettings.Name
            sliderText.Size = UDim2.new(1, 0, 0, 20)
            sliderText.TextColor3 = Theme.TextColor
            sliderText.BackgroundTransparency = 1
            sliderText.TextXAlignment = Enum.TextXAlignment.Left
            sliderText.Parent = sliderFrame
            
            local sliderBar = Instance.new("Frame")
            sliderBar.Name = "Bar"
            sliderBar.Size = UDim2.new(1, 0, 0, 10)
            sliderBar.Position = UDim2.new(0, 0, 0, 25)
            sliderBar.BackgroundColor3 = Theme.ElementBackground
            sliderBar.BorderSizePixel = 0
            sliderBar.Parent = sliderFrame
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Name = "Fill"
            sliderFill.Size = UDim2.new((sliderSettings.CurrentValue - sliderSettings.Min) / (sliderSettings.Max - sliderSettings.Min), 0, 1, 0)
            sliderFill.BackgroundColor3 = Theme.Accent
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderBar
            
            local sliderValue = Instance.new("TextLabel")
            sliderValue.Name = "Value"
            sliderValue.Text = tostring(sliderSettings.CurrentValue)
            sliderValue.Size = UDim2.new(1, 0, 0, 15)
            sliderValue.Position = UDim2.new(0, 0, 0, 35)
            sliderValue.TextColor3 = Theme.TextColor
            sliderValue.BackgroundTransparency = 1
            sliderValue.TextXAlignment = Enum.TextXAlignment.Right
            sliderValue.Parent = sliderFrame
            
            local dragging = false
            sliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            
            sliderBar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local xPos = math.clamp(input.Position.X - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
                    local value = math.floor(sliderSettings.Min + (xPos / sliderBar.AbsoluteSize.X) * (sliderSettings.Max - sliderSettings.Min))
                    
                    sliderFill.Size = UDim2.new(xPos / sliderBar.AbsoluteSize.X, 0, 1, 0)
                    sliderValue.Text = tostring(value)
                    pcall(sliderSettings.Callback, value)
                end
            end)
            
            return sliderFrame
        end
        
        return tab
    end
    
    return window
end

-- Auto-execute ketika script di-load
local Window = iYannStore:CreateWindow({
    Name = "iYann Store"
})

local MainTab = Window:CreateTab("Main")
local PlayerTab = Window:CreateTab("Player")

-- Contoh button
MainTab:CreateButton({
    Name = "Print Hello",
    Callback = function()
        print("Hello from iYann Store!")
    end
})

-- Contoh toggle
MainTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Callback = function(value)
        print("Auto Farm:", value)
    end
})

-- Contoh slider
PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 100,
    CurrentValue = 16,
    Callback = function(value)
        print("Walk Speed set to:", value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 200,
    CurrentValue = 50,
    Callback = function(value)
        print("Jump Power set to:", value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
    end
})

return iYannStore
