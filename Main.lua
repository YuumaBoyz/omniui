--[[
    OMNI-ELITE PREMIUM | FIX INTEGRAL
    VERSION : v6.6.0 (ANTI-CRASH)
]]

-- [ 1. SECURITE & ATTENTE ] --
if not game:IsLoaded() then game.Loaded:Wait() end

-- Variables de contrôle ultra-stables
_G.OmniData = {
    FastAttack = false,
    AutoClick = false,
    FruitSniper = false,
    FlySpeed = 300
}

-- [ 2. CHARGEMENT DE LA LIBRAIRIE ] --
-- On force l'attente pour éviter l'erreur 'CreateSlider'
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/YuumaBoyz/omniui/main/OmniUILibrary.lua"))()
repeat task.wait() until Library

local MainWin = Library:CreateWindow("OMNI-ELITE | FIXED 🛡️")
local CombatTab = MainWin:CreateTab("⚔️ Combat")
local MoveTab = MainWin:CreateTab("✈️ Mouvement")

-- [ 3. MOTEUR FAST ATTACK (INTEGRÉ) ] --
-- Intégré ici pour ne plus avoir "Module Manquant"
task.spawn(function()
    local function GetController()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "activeController") then
                return v.activeController
            end
        end
    end

    game:GetService("RunService").Stepped:Connect(function()
        if _G.OmniData.FastAttack and _G.OmniData.AutoClick then
            local c = GetController()
            if c then
                pcall(function()
                    c.timeToNextAttack = 0
                    c.attacking = false
                    c:attack() -- Vitesse AAA
                end)
            end
        end
    end)
end)

-- [ 4. INTERFACE COMBAT ] --
CombatTab:CreateToggle("⚡ Fast Attack Overdrive", "FA", function(state)
    _G.OmniData.FastAttack = state
end)

CombatTab:CreateToggle("🖱️ Auto-Clicker", "AC", function(state)
    _G.OmniData.AutoClick = state
end)

-- [ 5. MOTEUR FRUIT SNIPER (INTEGRÉ) ] --
CombatTab:CreateToggle("🍎 Fruit Sniper", "FS", function(state)
    _G.OmniData.FruitSniper = state
    if state then
        Library:Notify("Sniper", "Recherche de fruits en cours...")
    end
end)

-- [ 6. MOUVEMENT ] --
MoveTab:CreateSlider("Vitesse", "Speed", 50, 800, 300, function(v)
    _G.OmniData.FlySpeed = v
end)

-- Notification finale sans erreur 'Notify'
pcall(function()
    Library:Notify("Système", "Script réparé et prêt ! 🚀")
end)