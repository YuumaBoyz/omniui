--[[
    OMNI UI LIBRARY : ELITE EDITION (v2.4)
    LOGIQUE : Persistance JSON + CanvasGroup Animations + Multi-Select + Global Keybind
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local Library = {}
local Player = Players.LocalPlayer

-- [ CONFIGURATION DES THÈMES ] --
local Theme = {
    Main = Color3.fromRGB(20, 20, 25),
    Accent = Color3.fromRGB(0, 255, 150),
    Text = Color3.fromRGB(255, 255, 255),
    Dark = Color3.fromRGB(15, 15, 20),
    Element = Color3.fromRGB(30, 30, 35)
}

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

-- [ 1. STRUCTURE PRINCIPALE ] --
function Library:CreateWindow(titleText)
    local sg = Instance.new("ScreenGui")
    sg.Name = "OmniUI_Elite"
    sg.Parent = (RunService:IsStudio() and Player.PlayerGui) or CoreGui
    sg.ResetOnSpawn = false

    -- Utilisation de CanvasGroup pour des animations de transparence fluides
    local MainFrame = Instance.new("CanvasGroup", sg)
    MainFrame.Size = UDim2.new(0, 550, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
    MainFrame.BackgroundColor3 = Theme.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.GroupTransparency = 0
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    
    -- [ ⌨️ SYSTÈME DE KEYBIND ] --
    local Window = { 
        MainFrame = MainFrame, 
        Visible = true, 
        Keybind = Enum.KeyCode.RightControl 
    }

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Window.Keybind then
            Window.Visible = not Window.Visible
            
            local targetTransparency = Window.Visible and 0 or 1
            
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                GroupTransparency = targetTransparency
            }):Play()

            -- Désactive les clics quand invisible
            MainFrame.BlocksInteraction = not Window.Visible 
            
            if _G.Logger then 
                _G.Logger:AddLog("⌨️ ***UI " .. (Window.Visible and "Affichée" or "Masquée") .. "*** (" .. tostring(Window.Keybind.Name) .. ")", Color3.fromRGB(200, 200, 200)) 
            end
        end
    end)

    function Window:SetKeybind(newKey)
        Window.Keybind = newKey
    end

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
    TitleBar.TextColor3 = Theme.Text
    TitleBar.Font = Enum.Font.GothamBold
    TitleBar.TextSize = 16
    TitleBar.TextXAlignment = Enum.TextXAlignment.Left
    TitleBar.BackgroundColor3 = Theme.Dark
    Instance.new("UICorner", TitleBar)
    
    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Size = UDim2.new(0, 130, 1, -40)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    
    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Size = UDim2.new(1, -145, 1, -55)
    PageContainer.Position = UDim2.new(0, 135, 0, 45)
    PageContainer.BackgroundTransparency = 1

    local tabs = {}
    local firstTab = true

    function Window:CreateTab(tabName)
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(1, 0, 0, 40)
        TabBtn.Text = tabName
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.TextSize = 14
        TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        TabBtn.BorderSizePixel = 0

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.Visible = firstTab
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)

        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)

        if firstTab then
            TabBtn.TextColor3 = Theme.Text
            TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            firstTab = false
        end

        tabs[TabBtn] = Page

        TabBtn.Activated:Connect(function()
            for btn, p in pairs(tabs) do
                p.Visible = false
                TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundColor3 = Color3.fromRGB(25, 25, 30)}):Play()
            end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = Theme.Text, BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
        end)

        local TabElements = {}

        -- [ 🔄 MULTI-SELECT DROPDOWN ] --
        function TabElements:CreateMultiDropdown(text, options, configKey)
            local Config = _G.Functions.Config
            Config[configKey] = Config[configKey] or {}

            local DropFrame = Instance.new("Frame", Page)
            DropFrame.Size = UDim2.new(0.95, 0, 0, 35)
            DropFrame.BackgroundColor3 = Theme.Element
            Instance.new("UICorner", DropFrame)

            local Label = Instance.new("TextLabel", DropFrame)
            Label.Size = UDim2.new(1, -40, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Text = text .. " (Multi)"
            Label.TextColor3 = Theme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1

            local Container = Instance.new("Frame", Page)
            Container.Size = UDim2.new(0.9, 0, 0, 0)
            Container.ClipsDescendants = true
            Container.Visible = false
            Container.BackgroundTransparency = 1
            local ContainerLayout = Instance.new("UIListLayout", Container)
            ContainerLayout.Padding = UDim.new(0, 3)

            local OpenBtn = Instance.new("TextButton", DropFrame)
            OpenBtn.Size = UDim2.new(1, 0, 1, 0)
            OpenBtn.BackgroundTransparency = 1
            OpenBtn.Text = ""

            OpenBtn.Activated:Connect(function()
                local isOpening = not Container.Visible
                Container.Visible = true
                local targetSize = isOpening and UDim2.new(0.9, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 5) or UDim2.new(0.9, 0, 0, 0)
                
                TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
                task.delay(isOpening and 0 or 0.3, function() if not isOpening then Container.Visible = false end end)
            end)

            for _, opt in pairs(options) do
                local OptBtn = Instance.new("TextButton", Container)
                OptBtn.Size = UDim2.new(1, 0, 0, 30)
                OptBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                OptBtn.Text = (Config[configKey][opt] and "✅ " or "") .. opt
                OptBtn.TextColor3 = Config[configKey][opt] and Theme.Accent or Color3.fromRGB(200, 200, 200)
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 13
                Instance.new("UICorner", OptBtn)

                OptBtn.Activated:Connect(function()
                    Config[configKey][opt] = not Config[configKey][opt]
                    OptBtn.Text = (Config[configKey][opt] and "✅ " or "") .. opt
                    TweenService:Create(OptBtn, TweenInfo.new(0.2), {TextColor3 = Config[configKey][opt] and Theme.Accent or Color3.fromRGB(200, 200, 200)}):Play()
                    SafeSave()
                end)
            end
        end

        -- [ 🟢 TOGGLE ] --
        function TabElements:CreateToggle(text, configKey, callback)
            local initialValue = GetConfigValue(configKey, false)
            local ToggleFrame = Instance.new("Frame", Page)
            ToggleFrame.Size = UDim2.new(0.95, 0, 0, 35)
            ToggleFrame.BackgroundColor3 = Theme.Element
            Instance.new("UICorner", ToggleFrame)

            local Label = Instance.new("TextLabel", ToggleFrame)
            Label.Size = UDim2.new(0.8, 0, 1, 0)
            Label.Position = UDim2.new(0.05, 0, 0, 0)
            Label.Text = text
            Label.TextColor3 = Theme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1

            local Button = Instance.new("TextButton", ToggleFrame)
            Button.Size = UDim2.new(0, 38, 0, 20)
            Button.Position = UDim2.new(0.95, -40, 0.5, -10)
            Button.Text = ""
            Button.BackgroundColor3 = initialValue and Theme.Accent or Color3.fromRGB(150, 50, 50)
            Instance.new("UICorner", Button).CornerRadius = UDim.new(1, 0)

            local state = initialValue
            Button.Activated:Connect(function()
                state = not state
                if _G.Functions and _G.Functions.Config then _G.Functions.Config[configKey] = state end
                TweenService:Create(Button, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                    BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(150, 50, 50)
                }):Play()
                pcall(callback, state)
                SafeSave()
            end)
        end

        return TabElements
    end
    return Window
end

_G.Library = Library
return Library