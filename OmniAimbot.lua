--[[
    FICHIER : OmniAimbot.lua
    PROJET  : OMNI-PROJECT | BLOX FRUITS
    VERSION : v1.0.2 (SKILL LOCK EDITION)
    LOGIQUE : Prediction Vector + Target Lock + Mouse Redirection
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local Aimbot = {
    Enabled = false,
    Range = 500,
    TeamCheck = false,
    Target = nil
}

-- [ FONCTION : TROUVER LA CIBLE LA PLUS PROCHE ] -- 🔍
local function GetClosestTarget()
    local closest = nil
    local maxDist = Aimbot.Range

    -- Chercher dans les Mobs et les Joueurs
    local potentialTargets = {}
    
    -- Ajout des Mobs (Enemies)
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            table.insert(potentialTargets, v)
        end
    end
    
    -- Ajout des Joueurs (si PvP activé dans tes besoins futurs)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(potentialTargets, v.Character)
        end
    end

    for _, char in pairs(potentialTargets) do
        local screenPos, onScreen = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
        if onScreen then
            local dist = (char.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist < maxDist then
                maxDist = dist
                closest = char
            end
        end
    end
    return closest
end

-- [ BOUCLE DE REDIRECTION (MOUSE OVERRIDE) ] -- 🖱️
-- On utilise un hook sur le moteur de rendu pour forcer la position du curseur
RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        Aimbot.Target = GetClosestTarget()
        
        if Aimbot.Target and Aimbot.Target:FindFirstChild("HumanoidRootPart") then
            -- On "ment" au jeu en disant que la souris est sur la cible
            local targetPos = Aimbot.Target.HumanoidRootPart.Position
            
            -- Hook technique : On définit une globale que tes skills utiliseront
            _G.CurrentTargetPart = Aimbot.Target.HumanoidRootPart
        else
            _G.CurrentTargetPart = nil
        end
    end
end)

-- [ EXPORT DU MODULE ] --
_G.Aimbot = Aimbot
return Aimbot