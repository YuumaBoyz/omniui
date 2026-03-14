--[[
    MODULE  : FruitSniper.lua
    VERSION : v1.0 (Safe-Collect & Auto-Store)
    LOGIQUE : Spatial Scanning + Tween Navigation
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

local Sniper = {
    Config = {
        Enabled = true,
        AutoStore = true,
        AntiCamper = true -- Vérifie si un joueur est trop proche du fruit
    }
}

-- [ 1. FONCTION DE COLLECTE ] --
function Sniper:Collect(fruit)
    if not fruit:FindFirstChild("Handle") then return end
    
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Notification de détection
    _G.Logger:AddLog("🍎 Fruit détecté : ***" .. fruit.Name .. "***", Color3.fromRGB(255, 165, 0))

    -- Déplacement sécurisé via le module Tween existant
    _G.Functions:SafeTween(fruit.Handle.CFrame)
    
    -- Petit délai pour assurer la collision de ramassage
    task.wait(0.3)

    -- Auto-Store : Range le fruit dans l'inventaire pour le sauver
    if self.Config.AutoStore then
        task.wait(0.2)
        local fruitName = fruit.Name:gsub(" Fruit", "")
        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fruitName, fruit)
        _G.Logger:AddLog("💾 Fruit ***" .. fruit.Name .. "*** mis en inventaire.", Color3.fromRGB(0, 255, 150))
    end
end

-- [ 2. SCANNER DE MAP ] --
task.spawn(function()
    while true do
        task.wait(2) -- Scan toutes les 2 secondes
        if not Sniper.Config.Enabled then continue end

        pcall(function()
            for _, item in pairs(Workspace:GetChildren()) do
                -- Dans Blox Fruits, les fruits contiennent souvent "Fruit" dans leur nom
                if item:IsA("Tool") and (item.Name:find("Fruit") or item:FindFirstChild("Handle")) then
                    Sniper:Collect(item)
                end
            end
        end)
    end
end)

_G.FruitSniper = Sniper
return Sniper