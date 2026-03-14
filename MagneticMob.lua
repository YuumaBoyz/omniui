--[[
    MODULE  : MagneticMob.lua
    VERSION : v2.5 (Ghost Magnet Fusion)
    LOGIQUE : Neutralisation Physique + Paralysie + Heartbeat Sync
]]

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Variables de contrôle (Liaison UI)
_G.MagneticMob = _G.MagneticMob or false
_G.MagnetDistance = 300
_G.AttackPos = Vector3.new(0, 0, -10) -- 10 studs devant toi

-- [ 1. NEUTRALISEUR DE PHYSIQUE & PARALYSIE ] -- 🧠
local function NeutralizeMob(mob)
    pcall(function()
        local root = mob:FindFirstChild("HumanoidRootPart")
        local hum = mob:FindFirstChildOfClass("Humanoid")
        
        if root and hum then
            -- Anti-Fling : Hitbox réduite et désactivation des collisions
            root.CanCollide = false
            -- On évite de mettre 0,0,0 pour ne pas casser certains scripts de jeu, 0.01 est plus sûr
            root.Size = Vector3.new(0.01, 0.01, 0.01) 
            
            -- Paralysie Totale
            hum.PlatformStand = true 
            hum.WalkSpeed = 0
            hum.JumpPower = 0
            
            -- Neutralisation de tous les membres
            for _, part in pairs(mob:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.Velocity = Vector3.new(0, 0, 0)
                    part.RotVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end)
end

-- [ 2. BOUCLE DE RENDU HAUTE PERFORMANCE ] -- 🚀
-- Heartbeat s'exécute après la simulation physique : parfait pour forcer le CFrame
RunService.Heartbeat:Connect(function()
    if not _G.MagneticMob then return end

    local character = Player.Character
    local myRoot = character and character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    -- Vérification du dossier Enemies (Standard Blox Fruits)
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return end

    pcall(function()
        for _, mob in pairs(enemies:GetChildren()) do
            local mobRoot = mob:FindFirstChild("HumanoidRootPart")
            local mobHum = mob:FindFirstChildOfClass("Humanoid")

            -- Filtre : Vie > 0 et Distance
            if mobRoot and mobHum and mobHum.Health > 0 then
                local dist = (mobRoot.Position - myRoot.Position).Magnitude
                
                if dist <= _G.MagnetDistance then
                    -- 1. Appliquer les correctifs "Fantôme"
                    NeutralizeMob(mob)
                    
                    -- 2. Téléportation forcée dans la zone de frappe
                    -- Utilisation de CFrame pour aligner l'orientation du mob sur la tienne
                    mobRoot.CFrame = myRoot.CFrame * CFrame.new(_G.AttackPos)
                end
            end
        end
    end)
end)

print("✅ [OMNI-PROJECT] MagneticMob v2.5 Fusion (Anti-Fling & Paralysis) prêt. 🚀")