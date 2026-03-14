--[[
    OMNI LOGGER : CONSOLE SYSTÈME
    Description : Affiche les actions du script en temps réel (Loot, Level, Errors).
]]

local TweenService = game:GetService("TweenService")

local Logger = {
    LogFrame = nil,
    Container = nil,
    MaxLogs = 50
}

function Logger:Init(parentFrame)
    local ConsoleFrame = Instance.new("Frame", parentFrame)
    ConsoleFrame.Name = "ConsoleLogs"
    ConsoleFrame.Size = UDim2.new(1, -20, 0, 120)
    ConsoleFrame.Position = UDim2.new(0, 10, 1, -130)
    ConsoleFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Instance.new("UICorner", ConsoleFrame)

    local Scrolling = Instance.new("ScrollingFrame", ConsoleFrame)
    Scrolling.Size = UDim2.new(1, -10, 1, -10)
    Scrolling.Position = UDim2.new(0, 5, 0, 5)
    Scrolling.BackgroundTransparency = 1
    Scrolling.ScrollBarThickness = 2
    Scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local Layout = Instance.new("UIListLayout", Scrolling)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 4)

    self.Container = Scrolling
    self:AddLog("✨ ***Omni-Elite Console Initialisée***", Color3.fromRGB(0, 255, 150))
end

function Logger:AddLog(text, color)
    if not self.Container then return end

    local LogLabel = Instance.new("TextLabel", self.Container)
    LogLabel.Size = UDim2.new(1, 0, 0, 18)
    LogLabel.BackgroundTransparency = 1
    LogLabel.Text = "[" .. os.date("%X") .. "] " .. text
    LogLabel.TextColor3 = color or Color3.new(1, 1, 1)
    LogLabel.Font = Enum.Font.Code
    LogLabel.TextSize = 12
    LogLabel.TextXAlignment = Enum.TextXAlignment.Left
    LogLabel.RichText = true

    -- Auto-scroll vers le bas
    self.Container.CanvasPosition = Vector2.new(0, self.Container.AbsoluteWindowSize.Y)
    
    -- Nettoyage si trop de logs
    local logs = self.Container:GetChildren()
    if #logs > self.MaxLogs then
        logs[2]:Destroy() -- Le premier est le layout
    end
end

_G.Logger = Logger
return Logger