--[[
    MODULE  : FruitSniper.lua
    LOGIQUE : Détection instantanée & Repositionnement CFrame
    OPTIMISATION : Recherche de latence réseau & Automation
]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local FruitSniper = {
    Enabled = false,
    PriorityFruits = {"Dragon", "Leopard", "Dough", "Kitsune"}, -- Filtre de priorité
    AutoStore = true,
    Scanning = false
}

-- [ 1. SYSTÈME DE NOTIFICATION SÉCURISÉ ] -- 🛡️
-- Prévient l'erreur "attempt to call missing method 'Notify'"
local function DispatchNotification(title, message)
    task.spawn(function()
        local timeout = 0
        -- Attente de l'initialisation de l'UI
        while not (_G.Library and _G.Library.Notify) and timeout < 30 do
            task.wait(0.1)
            timeout = timeout + 1
        end

        if _G.Library and _G.Library.Notify then
            _G.Library:Notify(title, message)
        elseif _G.Logger then
            _G.Logger:AddLog("🍎 [SNIPER] " .. message, Color3.fromRGB(255, 150, 0))
        end
    end)
end

-- [ 2. LOGIQUE DE CAPTURE (BYPASS INTERPOLATION) ] -- ⚡
local function CaptureFruit(fruitInstance)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    
    if root and fruitInstance:IsA("BasePart") or fruitInstance:FindFirstChild("Handle") then
        local targetPos = fruitInstance:IsA("BasePart") and fruitInstance.CFrame or fruitInstance.Handle.CFrame
        
        -- Déplacement instantané par manipulation de CFrame (Outrepasse la latence)
        root.CFrame = targetPos
        task.wait(0.1) -- Temps de synchronisation réseau
        
        -- Interception des RemoteEvents pour le stockage
        local storeRemote = game:GetService("ReplicatedStorage"):FindFirstChild("StoreFruit", true)
        if storeRemote and storeRemote:IsA("RemoteFunction") or storeRemote:IsA("RemoteEvent") then
            storeRemote:FireServer(fruitInstance.Name, fruitInstance)
        end
        
        DispatchNotification("SNIPER", "***" .. fruitInstance.Name .. "*** capturé et stocké ! ✅")
    end
end

-- [ 3. SCANNER DE WORKSPACE ULTRA-RAPIDE ] -- 🔍
function FruitSniper:StartScanner()
    if self.Scanning then return end
    self.Scanning = true
    
    -- Listener sur les nouvelles instances (Apparition instantanée)
    Workspace.DescendantAdded:Connect(function(descendant)
        if self.Enabled and (descendant.Name:find("Fruit") or table.find(self.PriorityFruits, descendant.Name)) then
            CaptureFruit(descendant)
        end
    end)

    -- Balayage initial par itérateur optimisé
    task.spawn(function()
        while task.wait(1) do
            if self.Enabled then
                for _, obj in pairs(Workspace:GetChildren()) do
                    if obj.Name:find("Fruit") and obj:IsA("Tool") then
                        CaptureFruit(obj)
                    end
                end
            end
        end
    end)
end

-- [ 4. INITIALISATION ] -- ⚙️
function FruitSniper:Init()
    self:StartScanner()
    -- Message de confirmation dans la console OmniLogger
    if _G.Logger then
        _G.Logger:AddLog("✅ ***Moteur FruitSniper v4.0 Prêt***", Color3.fromRGB(255, 200, 0))
    end
end

_G.FruitSniperModule = FruitSniper
return FruitSniper