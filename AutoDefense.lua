--[[
    MODULE  : AutoDefense.lua
    VERSION : v3.0 (Fusion Performance)
    LOGIQUE : VirtualUser + Combat Cache + Haki Automator + Anti-Stun
]]

local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

-- Configuration Globales
_G.AutoClick = _G.AutoClick or true
_G.AutoHaki = _G.AutoHaki or true
_G.AutoKen = _G.AutoKen or true
_G.AntiStun = true

local Config = _G.Functions and _G.Functions.Config or { WeaponType = "Melee" }
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- [ 1. RÉCUPÉRATION DU CONTROLLER (CACHE OPTIMISÉ) ] -- ⚡
local ActiveController = nil
local function GetActiveController()
    if ActiveController then return ActiveController end
    
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "activeController") then
            ActiveController = v.activeController
            return ActiveController
        end
    end
    return nil
end

-- [ 2. MAINTENANCE DU PERSONNAGE ] -- 🔨
local function ForceEquipAndClean(char)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local backpack = Player:FindFirstChild("Backpack")
    
    if humanoid and backpack then
        -- Anti-Stun : Nettoyage des dossiers bloquants
        if _G.AntiStun then
            humanoid.PlatformStand = false
            humanoid.Sit = false
            local stun = char:FindFirstChild("Stun") or char:FindFirstChild("Busy")
            if stun then stun:Destroy() end
        end

        -- Auto-Equip : Force l'outil selon la config
        if not char:FindFirstChildOfClass("Tool") then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and (tool.ToolTip == Config.WeaponType or Config.WeaponType == "All") then
                    pcall(function() humanoid:EquipTool(tool) end)
                    break
                end
            end
        end
    end
end

-- [ 3. LOGIQUE DE PROTECTION (HAKI) ] -- 🛡️
local function HandleShield(char)
    if not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then return end

    pcall(function()
        -- Buso Haki (Armement)
        if _G.AutoHaki and not char:FindFirstChild("IronBody") then
            CommF:InvokeServer("Buso")
        end

        -- Ken Haki (Observation)
        if _G.AutoKen and not char:FindFirstChild("Kenshoku") then
            CommF:InvokeServer("Ken")
        end
    end)
end

-- [ 4. BOUCLE PRINCIPALE HYBRIDE ] -- 🧵
task.spawn(function()
    while true do
        task.wait(0.05) -- Cadence de combat 20Hz

        if _G.AutoClick then
            local char = Player.Character
            if char then
                -- A. Maintenance & Haki (Priorité Défensive)
                ForceEquipAndClean(char)
                HandleShield(char)

                -- B. Simulation de Combat
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    -- Anti-AFK & Click Physique
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(851, 158), workspace.CurrentCamera.CFrame)

                    -- Damage Framework Hook
                    local controller = GetActiveController()
                    if controller and controller.attack then
                        task.spawn(function() 
                            controller:attack() 
                        end)
                    end
                end
            end
        end
    end
end)

-- Reset du cache au respawn
Player.CharacterAdded:Connect(function()
    ActiveController = nil
end)

print("✅ [OMNI-PROJECT] AutoDefense v3.0 (Combat Fusion) chargé ! 🛡️⚡")