--[[
    FICHIER : OmniAimbot.lua
    VERSION : v1.1.0 (MAGNET SYNC EDITION)
    LOGIQUE : Priorité au Magnet + Target Lock + Skill Redirection
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Aimbot = {
    Enabled = false,
    Range = 500,
    Target = nil
}

-- [ FONCTION : DÉTECTION INTELLIGENTE ] -- 🔍
local function GetBestTarget()
    -- PRIORITÉ 1 : La cible déjà verrouillée par le MagneticMob
    if _G.MagneticTarget and _G.MagneticTarget:FindFirstChild("Humanoid") and _G.MagneticTarget.Humanoid.Health > 0 then
        return _G.MagneticTarget
    end

    -- PRIORITÉ 2 : La cible la plus proche (si pas de Magnet)
    local closest = nil
    local maxDist = Aimbot.Range
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position

    if not myPos then return nil end

    -- Scan des ennemis
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, v in pairs(enemies:GetChildren()) do
            local root = v:FindFirstChild("HumanoidRootPart")
            local hum = v:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local dist = (root.Position - myPos).Magnitude
                if dist < maxDist then
                    maxDist = dist
                    closest = v
                end
            end
        end
    end
    
    return closest
end

-- [ BOUCLE DE REDIRECTION ] -- 🖱️
RunService.RenderStepped:Connect(function()
    if not Aimbot.Enabled then 
        _G.CurrentTargetPart = nil
        return 
    end

    Aimbot.Target = GetBestTarget()
    
    if Aimbot.Target and Aimbot.Target:FindFirstChild("HumanoidRootPart") then
        -- On définit la globale pour que tes skills (Z, X, C, V) s'orientent ici
        _G.CurrentTargetPart = Aimbot.Target.HumanoidRootPart
        
        -- Optionnel : Force la caméra à regarder légèrement la cible si besoin
        -- Camera.CFrame = CFrame.new(Camera.CFrame.Position, Aimbot.Target.HumanoidRootPart.Position)
    else
        _G.CurrentTargetPart = nil
    end
end)

_G.Aimbot = Aimbot
return Aimbot