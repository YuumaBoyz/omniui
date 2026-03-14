--[[
    MODULE  : FruitSniper.lua
    VERSION : v1.0 (Auto-Collect & Notify)
    LOGIQUE : Workspace Scanner + Tween TP
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Configuration locale (synchronisée avec _G si disponible)
_G.Functions = _G.Functions or {}
_G.Functions.Config = _G.Functions.Config or {}
_G.Functions.Config.FruitSniper = false

local function Notify(title, msg)
    if _G.Library then
        _G.Library:Notify(title, msg)
    else
        print("[" .. title .. "]: " .. msg)
    end
end

-- [ 1. LOGIQUE DE TÉLÉPORTATION ] -- ✈️
local function TweenToFruit(targetCFrame)
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local distance = (Player.Character.HumanoidRootPart.Position - targetCFrame.Position).Magnitude
    local speed = 300 -- Vitesse du sniper
    local info = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
    
    local tween = TweenService:Create(Player.Character.HumanoidRootPart, info, {CFrame = targetCFrame})
    tween:Play()
    return tween
end

-- [ 2. SCANNER DE FRUITS ] -- 🔍
task.spawn(function()
    while true do
        task.wait(1)
        
        if _G.Functions.Config.FruitSniper then
            pcall(function()
                for _, obj in pairs(workspace:GetChildren()) do
                    -- Dans Blox Fruits, les fruits au sol contiennent souvent "Fruit" dans leur nom
                    if obj:IsA("Tool") or (obj:IsA("Model") and obj.Name:find("Fruit")) then
                        local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart")
                        
                        if handle then
                            _G.Logger:AddLog("🍎 Fruit détecté : " .. obj.Name, Color3.fromRGB(255, 100, 100))
                            Notify("Fruit Sniper", "Récupération de : " .. obj.Name)
                            
                            local tw = TweenToFruit(handle.CFrame)
                            if tw then tw.Completed:Wait() end
                            
                            task.wait(0.5) -- Temps pour ramasser
                        end
                    end
                end
            end)
        end
    end
end)

print("✅ [OMNI-PROJECT] Fruit-Sniper v1.0 prêt. 🎯")
return true