--[[
    OMNI UI LIBRARY : ELITE EDITION (v2.3)
    MISE À JOUR : Ajout du Multi-Select Dropdown 🔄
    LOGIQUE : Persistance JSON + ScrollingFrame Auto-Adaptatif
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local Library = {}
local Player = Players.LocalPlayer

-- [ HELPERS INTERNES ] --
local function GetConfigValue(key, default)
    if _G.Functions and _G.Functions.Config and _G.Functions.Config[key] ~= nil then
        return _G.Functions.Config[key]
    end
    return default
end

local function SafeSave()
    if _G.SaveManager and _G.Functions and _G.Functions.Config then
        _G.SaveManager:Save(_G.Functions.Config)
    end
end

-- [ 1. NOTIFICATION NATIVE ] -- 🔔
function Library:Notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5
        })
    end)
end

-- [ 2. STRUCTURE DE LA FENÊTRE ] -- 🎨
function Library:CreateWindow(titleText)
    local sg = Instance.new("ScreenGui")
    sg.Name = "OmniUI"
    sg.Parent = (RunService:IsStudio() and Player.PlayerGui) or CoreGui
    sg.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame", sg)
    MainFrame.Size = UDim2.new(0, 550, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    Instance.new("UICorner", MainFrame)
    
    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    local TitleBar = Instance.new("TextLabel", MainFrame)
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.Text = "   " .. titleText
    TitleBar.TextColor3 = Color3.new(1, 1, 1)
    TitleBar.Font = Enum.Font.GothamBold
    TitleBar.TextSize = 16
    TitleBar.TextXAlignment = Enum.TextXAlignment.Left
    TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Instance.new("UICorner", TitleBar)
    
    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Size = UDim2.new(0, 130, 1, -40)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TabContainer.BorderSizePixel = 0

    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Size = UDim2.new(1, -140, 1, -50)
    PageContainer.Position = UDim2.new(0, 140, 0, 50)
    PageContainer.BackgroundTransparency = 1

    local Window = { MainFrame = MainFrame }
    local tabs = {}
    local firstTab = true

    function Window:CreateTab(tabName)
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.Text = tabName
        TabBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.TextSize = 14
        TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        TabBtn.BorderSizePixel = 0

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Name = tabName .. "Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 4
        Page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
        Page.Visible = firstTab
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)

        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        if firstTab then
            TabBtn.TextColor3 = Color3.new(1, 1, 1)
            TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            firstTab = false
        end

        tabs[TabBtn] = Page

        TabBtn.Activated:Connect(function()
            for btn, p in pairs(tabs) do
                p.Visible = false
                btn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
                btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            end
            Page.Visible = true
            TabBtn.TextColor3 = Color3.new(1, 1, 1)
            TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        end)

        local TabElements = {}

        -- [ 🚀 MULTI-SELECT DROPDOWN ] -- New v2.3
        function TabElements:CreateMultiDropdown(text, options, configKey)
            local Config = _G.Functions.Config
            Config[configKey] = Config[configKey] or {}

            local DropFrame = Instance.new("Frame", Page)
            DropFrame.Size = UDim2.new(1, -10, 0, 35)
            DropFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            Instance.new("UICorner", DropFrame)

            local Label = Instance.new("TextLabel", DropFrame)
            Label.Size = UDim2.new(1, -40, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Text = text .. " (Multi)"
            Label.TextColor3 = Color3.new(1, 1, 1)
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1

            local Container = Instance.new("Frame", Page)
            Container.Size = UDim2.new(1, -20, 0, #options * 32)
            Container.Visible = false
            Container.BackgroundTransparency = 1
            local ContainerLayout = Instance.new("UIListLayout", Container)
            ContainerLayout.Padding = UDim.new(0, 2)

            local OpenBtn = Instance.new("TextButton", DropFrame)
            OpenBtn.Size = UDim2.new(1, 0, 1, 0)
            OpenBtn.BackgroundTransparency = 1
            OpenBtn.Text = ""

            OpenBtn.Activated:Connect(function()
                Container.Visible = not Container.Visible
            end)

            for _, opt in pairs(options) do
                local OptBtn = Instance.new("TextButton", Container)
                OptBtn.Size = UDim2.new(1, 0, 0, 30)
                OptBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                OptBtn.Text = (Config[configKey][opt] and "✅ " or "") .. opt
                OptBtn.TextColor3 = Config[configKey][opt] and Color3.new(0, 1, 0.6) or Color3.new(0.8, 0.8, 0.8)
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 13
                Instance.new("UICorner", OptBtn)

                OptBtn.Activated:Connect(function()
                    Config[configKey][opt] = not Config[configKey][opt]
                    OptBtn.Text = (Config[configKey][opt] and "✅ " or "") .. opt
                    OptBtn.TextColor3 = Config[configKey][opt] and Color3.new(0, 1, 0.6) or Color3.new(0.8, 0.8, 0.8)
                    SafeSave()
                end)
            end
        end

        -- [ 🟢 TOGGLE ] --
        function TabElements:CreateToggle(text, configKey, callback)
            local initialValue = GetConfigValue(configKey, false)
            local ToggleFrame = Instance.new("Frame", Page)
            ToggleFrame.Size = UDim2.new(1, -10, 0, 35)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            Instance.new("UICorner", ToggleFrame)

            local Label = Instance.new("TextLabel", ToggleFrame)
            Label.Size = UDim2.new(0.8, 0, 1, 0)
            Label.Position = UDim2.new(0.05, 0, 0, 0)
            Label.Text = text
            Label.TextColor3 = Color3.new(1, 1, 1)
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1

            local Button = Instance.new("TextButton", ToggleFrame)
            Button.Size = UDim2.new(0, 40, 0, 20)
            Button.Position = UDim2.new(0.95, -40, 0.5, -10)
            Button.Text = ""
            Button.BackgroundColor3 = initialValue and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(150, 50, 50)
            Instance.new("UICorner", Button).CornerRadius = UDim.new(1, 0)

            local state = initialValue
            Button.Activated:Connect(function()
                state = not state
                if _G.Functions and _G.Functions.Config then _G.Functions.Config[configKey] = state end
                TweenService:Create(Button, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                    BackgroundColor3 = state and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(150, 50, 50)
                }):Play()
                pcall(callback, state)
                SafeSave()
            end)
        end

        -- [ 🎚️ SLIDER ] --
        function TabElements:CreateSlider(text, configKey, min, max, default, callback)
            local initialValue = GetConfigValue(configKey, default)
            local SliderFrame = Instance.new("Frame", Page)
            SliderFrame.Size = UDim2.new(1, -10, 0, 50)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            Instance.new("UICorner", SliderFrame)

            local Label = Instance.new("TextLabel", SliderFrame)
            Label.Size = UDim2.new(1, -20, 0, 20)
            Label.Position = UDim2.new(0, 10, 0, 5)
            Label.Text = text .. " : " .. tostring(initialValue)
            Label.TextColor3 = Color3.new(1, 1, 1)
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1

            local Track = Instance.new("Frame", SliderFrame)
            Track.Size = UDim2.new(1, -20, 0, 8)
            Track.Position = UDim2.new(0, 10, 0, 35)
            Track.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            Instance.new("UICorner", Track)

            local Fill = Instance.new("Frame", Track)
            local startRatio = math.clamp((initialValue - min) / (max - min), 0, 1)
            Fill.Size = UDim2.new(startRatio, 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
            Instance.new("UICorner", Fill)

            local SliderBtn = Instance.new("TextButton", Track)
            SliderBtn.Size = UDim2.new(1, 0, 2, 0)
            SliderBtn.Position = UDim2.new(0, 0, -0.5, 0)
            SliderBtn.BackgroundTransparency = 1
            SliderBtn.Text = ""

            local dragging = false
            SliderBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then 
                    dragging = false 
                    SafeSave()
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local percentage = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (max - min) * percentage)
                    Label.Text = text .. " : " .. tostring(value)
                    if _G.Functions and _G.Functions.Config then _G.Functions.Config[configKey] = value end
                    Fill.Size = UDim2.new(percentage, 0, 1, 0)
                    pcall(callback, value)
                end
            end)
        end

        -- [ 🚀 DROPDOWN ] --
        function TabElements:CreateDropdown(text, options, callback)
            local DropFrame = Instance.new("Frame", Page)
            DropFrame.Size = UDim2.new(1, -10, 0, 35)
            DropFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            Instance.new("UICorner", DropFrame)

            local Label = Instance.new("TextLabel", DropFrame)
            Label.Size = UDim2.new(1, 0, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Text = text .. " : " .. tostring(options[1] or "None")
            Label.TextColor3 = Color3.new(1, 1, 1)
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1

            local OpenBtn = Instance.new("TextButton", DropFrame)
            OpenBtn.Size = UDim2.new(1, 0, 1, 0)
            OpenBtn.BackgroundTransparency = 1
            OpenBtn.Text = ""

            OpenBtn.Activated:Connect(function()
                local currentOption = Label.Text:split(" : ")[2]
                local currentIdx = table.find(options, currentOption) or 0
                local nextIdx = (currentIdx % #options) + 1
                local selected = options[nextIdx]
                
                Label.Text = text .. " : " .. tostring(selected)
                pcall(callback, selected)
                SafeSave()
            end)
            
            return {
                Set = function(val) Label.Text = text .. " : " .. tostring(val) end
            }
        end

        -- [ 🚀 BUTTON ] --
        function TabElements:CreateButton(text, callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.Size = UDim2.new(1, -10, 0, 35)
            Btn.Text = text
            Btn.TextColor3 = Color3.new(1, 1, 1)
            Btn.Font = Enum.Font.GothamSemibold
            Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            Instance.new("UICorner", Btn)
            
            Btn.Activated:Connect(function()
                pcall(callback)
            end)
        end

        return TabElements
    end
    return Window
end

_G.Library = Library
return Library