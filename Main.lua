--[[
    FICHIER : Main.lua
    UTILITÉ : Contrôleur Principal avec Persistance & Logs en temps réel
    VERSION : Elite Fusion (Optimisée pour OmniUILibrary v2 & OmniLogger)
]]

local UI = _G.Library
local Ops = _G.Functions
local Saver = _G.SaveManager
local Logger = _G.Logger -- Assumé chargé via le Loader

-- [ 1. CHARGEMENT INITIAL ] -- 💾
UI:ShowLoadingScreen("RESTAURATION DE LA SESSION...")

local savedData = Saver:Load()
if savedData then
    for key, value in pairs(savedData) do
        Ops.Config[key] = value
    end
end

-- Lancement immédiat des fonctions actives en arrière-plan
if Ops.Config.FastAttack then task.spawn(function() Ops:EnableFastAttack() end) end
if Ops.Config.AutoClicker then task.spawn(function() Ops:StartAutoClick() end) end
if Ops.Config.SniperEnabled then task.spawn(function() Ops:InitFruitSniper() end) end

UI:Notify("Système", "Bienvenue ! Vos réglages ont été ***restaurés***. 🚀")

-- [ 2. CRÉATION DE LA FENÊTRE ] -- 🎨
local MainWin = UI:CreateWindow("OMNI ELITE | BLOX FRUITS")

-- [ 3. INITIALISATION DU LOGGER ] -- 📜
-- On l'injecte dans la MainFrame pour qu'il soit visible sur tous les onglets
Logger:Init(MainWin.MainFrame)
Logger:AddLog("✅ ***Système prêt.*** En attente d'ordres...", Color3.fromRGB(0, 255, 255))

-- [ 4. ONGLET COMBAT ] -- ⚔️
local CombatTab = MainWin:CreateTab("⚔️ Combat")

CombatTab:CreateToggle("Fast Attack (No Animation)", "FastAttack", function(state)
    if state then 
        Ops:EnableFastAttack() 
        Logger:AddLog("Combat : Fast Attack ***Activé*** ⚡", Color3.fromRGB(255, 255, 255))
    else
        Logger:AddLog("Combat : Fast Attack ***Désactivé***", Color3.fromRGB(200, 200, 200))
    end
end)

CombatTab:CreateToggle("Auto-Clicker (Farm)", "AutoClicker", function(state)
    if state then 
        Ops:StartAutoClick()
        Logger:AddLog("Auto-Click : ***Démarré*** 🖱️", Color3.fromRGB(255, 255, 255))
    end
end)

CombatTab:CreateSlider("Distance d'attaque", "AttackDistance", 5, 50, 15, function(value)
    -- Synchro auto via configKey
end)

-- [ 5. ONGLET FARMING ] -- 🍎
local FarmTab = MainWin:CreateTab("🍎 Farming")

FarmTab:CreateToggle("Fruit Sniper (Auto-Collect)", "SniperEnabled", function(state)
    if state then
        Logger:AddLog("Sniper : Recherche de fruits ***lancée***... 🍓", Color3.fromRGB(255, 100, 255))
        Ops:InitFruitSniper()
    end
end)

FarmTab:CreateSlider("Vitesse du Sniper", "Speed", 100, 1000, 300, function(value)
    -- Synchro auto via configKey
end)

-- [ 6. ONGLET MOUVEMENT ] -- ✈️
local MoveTab = MainWin:CreateTab("✈️ Mouvement")

MoveTab:CreateToggle("Ghost Mode (Noclip)", "GhostMode", function(state)
    local status = state and "***Activé*** 👻" or "***Désactivé***"
    Logger:AddLog("Mouvement : Mode Fantôme " .. status, Color3.fromRGB(200, 200, 255))
end)

-- [ 7. ONGLET PARAMÈTRES ] -- ⚙️
local ConfTab = MainWin:CreateTab("⚙️ Config")

ConfTab:CreateDropdown("Priorité de Farm", {"Fruits Uniquement", "Level Uniquement", "Mixte"}, function(selected)
    Ops.Config.FarmPriority = selected
    Logger:AddLog("Config : Priorité réglée sur ***" .. selected .. "***", Color3.fromRGB(255, 255, 255))
end)

ConfTab:CreateToggle("Anti-AFK (Permanent)", "AntiAFK", function(state)
    if state then
        Logger:AddLog("Sécurité : ***Anti-AFK*** maintenu.", Color3.fromRGB(100, 255, 100))
    end
end)