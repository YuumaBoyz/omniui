--[[
    MODULE  : AutoClicker.lua
    VERSION : v2.7 (Fusion Performance)
    LOGIQUE : VirtualUser + CombatFramework Cache + Anti-Stun Recovery
]]

local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Configuration Globales
_G.AutoClick = _G.AutoClick or true
_G.AntiStun = true
local Config = _G.Functions and _G.Functions.Config or { WeaponType = "Melee" }

-- [ 1. RÉCUPÉRATION DU CONTROLLER (CACHE OPTIMISÉ) ] --
local ActiveController = nil
local function GetActiveController()
    if ActiveController then return ActiveController end
    
    -- On ne scanne la mémoire que si le cache est vide
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "activeController") then
            ActiveController = v.activeController
            return ActiveController
        end
    end
    return nil
end

-- [ 2. MAINTENANCE DU PERSONNAGE ] -- 🔨
local function ForceEquipWeapon()
    local character = Player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local backpack = Player:FindFirstChild("Backpack")
    
    if humanoid and backpack then
        -- Anti-Stun : Nettoyage des états et dossiers bloquants
        if _G.AntiStun then
            humanoid.PlatformStand = false
            humanoid.Sit = false
            local stunFolder = character:FindFirstChild("Stun") or character:FindFirstChild("Busy")
            if stunFolder then stunFolder:Destroy() end
        end

        -- Auto-Equip : Force l'outil si les mains sont vides
        if not character:FindFirstChildOfClass("Tool") then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and (tool.ToolTip == Config.WeaponType or Config.WeaponType == "All") then
                    pcall(function() humanoid:EquipTool(tool) end)
                    break
                end
            end
        end
    end
end

-- [ 3. LOGIQUE DE COMBAT HYBRIDE ] -- 🧵
task.spawn(function()
    while true do
        task.wait(0.05) -- Cadence optimisée (20Hz)

        if _G.AutoClick then
            pcall(function()
                local character = Player.Character
                if not character then return end

                -- A. Maintenance (Anti-Stun + Equip)
                ForceEquipWeapon()

                -- B. Simulation d'attaque si outil en main
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    -- Simulation Physique (Anti-AFK & Trigger)
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(851, 158), workspace.CurrentCamera.CFrame)

                    -- Appel direct au Framework via le Cache
                    local controller = GetActiveController()
                    if controller and controller.attack then
                        task.spawn(function() 
                            controller:attack() 
                        end)
                    end
                end
            end)
        end
    end
end)

-- Reset du cache si le joueur meurt (pour retrouver le nouveau controller)
Player.CharacterAdded:Connect(function()
    ActiveController = nil
end)

print("✅ [OMNI-PROJECT] AutoClicker v2.7 (Fusion) chargé avec succès. 🚀")