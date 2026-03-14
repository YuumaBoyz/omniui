--[[
    MODULE  : FastAttack.lua
    VERSION : v3.5 (Hook & FPS Overdrive)
    LOGIQUE : Framework Variable Manipulation + Animation Stripper
]]

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local FastAttack = {
    Enabled = _G.FastAttack or false,
    Distance = 60,
    Increment = 2, -- Valeur de sécurité pour éviter les Ghost Hits
    Controller = nil
}

-- [ 1. HOOK DYNAMIQUE DU CONTROLLER ] -- 🧠
local function GetActiveController()
    if FastAttack.Controller then return FastAttack.Controller end
    
    -- Scan de la mémoire via getgc (Exécuté uniquement si le cache est vide)
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "activeController") then
            FastAttack.Controller = v.activeController
            return v.activeController
        end
    end
    return nil
end

-- [ 2. STRIPPER D'ANIMATIONS ] -- ✂️
-- Supprime les animations de Slash/Attack pour économiser le CPU et booster la vitesse
local function StripAnimations()
    pcall(function()
        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, track in pairs(hum:GetPlayingAnimationTracks()) do
                if track.Name:find("Attack") or track.Name:find("Slash") then
                    track:Stop(0)
                end
            end
        end
    end)
end

-- [ 3. OPTIMISATION DU MOTEUR DE RENDU ] -- 📉
local function OptimizeVisuals()
    pcall(function()
        -- 1. Supprime les débris de combat (Slash effects, impacts)
        local Debris = Workspace:FindFirstChild("Debris")
        if Debris then Debris:ClearAllChildren() end
        
        -- 2. Désactive les indicateurs de dégâts UI
        local mainUI = Player.PlayerGui:FindFirstChild("Main")
        if mainUI and mainUI:FindFirstChild("DamageIndicators") then
            mainUI.DamageIndicators:ClearAllChildren() -- Nettoie les labels accumulés
        end
    end)
end

-- [ 4. CŒUR DU MODULE : MEMORY MANIPULATION ] -- 💓
RunService.Heartbeat:Connect(function()
    -- On vérifie à la fois la variable locale et le Toggle UI global
    if not _G.FastAttack and not FastAttack.Enabled then return end
    if not _G.AutoClick then return end

    pcall(function()
        local controller = GetActiveController()
        
        if controller then
            -- A. Manipulation des variables de temps (Suppression du Cooldown)
            controller.timeToNextAttack = 0
            controller.attacking = false
            controller.hitboxMagnitude = FastAttack.Distance
            
            -- B. Exécution des attaques multiples (Incrémentation)
            for i = 1, FastAttack.Increment do
                controller:attack()
            end
            
            -- C. Nettoyage instantané
            StripAnimations()
            OptimizeVisuals()
        end
    end)
end)

-- [ 5. GESTION DES ÉVÉNEMENTS ] -- ✨
Player.CharacterAdded:Connect(function()
    FastAttack.Controller = nil -- Reset du cache au respawn
end)

-- Exportation pour le Main.lua
_G.FastAttackModule = FastAttack
print("✅ [OMNI-PROJECT] FastAttack v3.5 (Overdrive) initialisé ! ⚡")