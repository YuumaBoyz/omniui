--[[
    FICHIER : Main.lua
    PROJET  : OMNI-ELITE | BLOX FRUITS
    VERSION : Elite Fusion v3.9 (Sync & Dropdown Stable)
    UTILITÉ : Contrôleur Principal & Liaison Inter-Modules
]]

-- [ 1. SÉCURITÉ ET VÉRIFICATION DES DÉPENDANCES ] -- 🛡️
local function CheckGlobals()
    local dependencies = {
        {_G.Library, "OmniUILibrary"},
        {_G.Functions, "OmniFunctions"},
        {_G.SaveManager, "SaveManager"},
        {_G.Logger, "OmniLogger"}
    }
    
    for _, dep in ipairs(dependencies) do
        if not dep[1] then
            warn("❌ [OMNI-ELITE ERROR] : " .. dep[2] .. " est manquant (nil) !")
            return false
        end
    end
    return true
end

if not CheckGlobals() then return end

-- Aliases pour la clarté
local UI     = _G.Library
local Ops    = _G.Functions
local Saver  = _G.SaveManager
local Logger = _G.Logger

-- [ 2. CHARGEMENT ET RESTAURATION ] -- 💾
UI:ShowLoadingScreen("OMNI-PROJECT : RESTAURATION...")

local savedData = Saver:Load()
if savedData then
    for key, value in pairs(savedData) do
        -- Injection directe dans la config active
        Ops.Config[key] = value
    end
end

-- Lancement immédiat des services actifs persistants
task.spawn(function()
    if Ops.Config.FastAttack then pcall(function() Ops:EnableFastAttack() end) end
    if Ops.Config.AutoClicker then pcall(function() Ops:StartAutoClick() end) end
    if Ops.Config.SniperEnabled then 
        pcall(function() 
            Ops:InitFruitSniper() 
            Ops:StartSmartScan()
        end) 
    end
end)

UI:Notify("Système", "Bienvenue ! Vos réglages ont été ***restaurés***. 🚀")

-- [ 3. CRÉATION DE L'INTERFACE ] -- 🎨
local MainWin = UI:CreateWindow("OMNI-ELITE | BLOX FRUITS")

-- Initialisation de la console de logs (Attachée à la Frame principale)
Logger:Init(MainWin.MainFrame)
Logger:AddLog("✅ ***Système initialisé.*** Prêt pour la chasse.", Color3.fromRGB(0, 255, 255))

-- [ 4. ONGLET COMBAT ] -- ⚔️
local CombatTab = MainWin:CreateTab("⚔️ Combat")

CombatTab:CreateToggle("Fast Attack (No Animation)", "FastAttack", function(state)
    local success, err = pcall(function()
        if state then 
            Ops:EnableFastAttack() 
            Logger:AddLog("Combat : Fast Attack ***Activé*** ⚡", Color3.fromRGB(255, 255, 255))
        else
            Logger:AddLog("Combat : Fast Attack ***Désactivé***", Color3.fromRGB(200, 200, 200))
        end
    end)
    if not success then Logger:AddLog("⚠️ Erreur Combat : " .. tostring(err), Color3.fromRGB(255, 0, 0)) end
end)

CombatTab:CreateToggle("Auto-Clicker (Farm)", "AutoClicker", function(state)
    pcall(function()
        if state then 
            Ops:StartAutoClick()
            Logger:AddLog("Auto-Click : ***Démarré*** 🖱️", Color3.fromRGB(255, 255, 255))
        end
    end)
end)

CombatTab:CreateSlider("Distance d'attaque", "AttackDistance", 5, 50, Ops.Config.AttackDistance or 15, function(value)
    Ops.Config.AttackDistance = value
end)

-- [ 5. ONGLET FARMING ] -- 🍎
local FarmTab = MainWin:CreateTab("🍎 Farming")

FarmTab:CreateToggle("Fruit Sniper (Auto-Collect)", "SniperEnabled", function(state)
    pcall(function()
        if state then
            Logger:AddLog("Sniper : Mode ***Elite Scan*** activé. 🍓", Color3.fromRGB(255, 100, 255))
            Ops:InitFruitSniper()
            Ops:StartSmartScan()
        else
            Logger:AddLog("Sniper : Arrêt de la recherche.", Color3.fromRGB(200, 200, 200))
        end
    end)
end)

FarmTab:CreateSlider("Vitesse du Sniper", "Speed", 100, 1000, Ops.Config.Speed or 300, function(value)
    Ops.Config.Speed = value
end)

-- [ 6. ONGLET MOUVEMENT ] -- ✈️
local MoveTab = MainWin:CreateTab("✈️ Mouvement")

MoveTab:CreateToggle("Ghost Mode (Noclip)", "GhostMode", function(state)
    pcall(function()
        local status = state and "***Activé*** 👻" or "***Désactivé***"
        Logger:AddLog("Mouvement : Mode Fantôme " .. status, Color3.fromRGB(200, 200, 255))
    end)
end)

-- [ 7. ONGLET PARAMÈTRES ] -- ⚙️
local ConfTab = MainWin:CreateTab("⚙️ Paramètres")

-- Dropdown synchronisé (Ne crash plus avec l'UI Library v2.1 Fixed)
ConfTab:CreateDropdown("Priorité de Farm", {"Fruits", "Level", "Mixte"}, function(selected)
    Ops.Config.FarmPriority = selected
    Logger:AddLog("Config : Priorité -> ***" .. selected .. "***", Color3.fromRGB(255, 255, 255))
end)

ConfTab:CreateButton("💾 Force Save Config", function()
    pcall(function()
        Saver:Save(Ops.Config)
        UI:Notify("Système", "Configuration ***Sauvegardée*** avec succès ! ✅")
        Logger:AddLog("💾 Manuel : Sauvegarde effectuée.", Color3.fromRGB(100, 255, 100))
    end)
end)

ConfTab:CreateButton("🚀 Hop New Server", function()
    pcall(function()
        Logger:AddLog("⚠️ Manuel : Forçage du Server Hop...", Color3.fromRGB(255, 255, 0))
        Ops:SmartHop()
    end)
end)

ConfTab:CreateButton("📋 Copier les Logs (Presse-papier)", function()
    local success, err = pcall(function() return Ops:CopyLogsToClipboard() end)
    if success then
        UI:Notify("Debug System", "Logs copiés ! ✅", 5)
        Logger:AddLog("📋 ***Presse-papier*** : Logs copiés avec succès.", Color3.fromRGB(0, 255, 150))
    else
        UI:Notify("Erreur", "Impossible de copier : " .. tostring(err), 5)
        Logger:AddLog("❌ ***Erreur copie***. Voir console F9.", Color3.fromRGB(255, 50, 50))
    end
end)

ConfTab:CreateToggle("Anti-AFK (Permanent)", "AntiAFK", function(state)
    pcall(function()
        if state then
            Logger:AddLog("Sécurité : ***Anti-AFK*** maintenu.", Color3.fromRGB(100, 255, 100))
        end
    end)
end)

-- [ 8. FINALISATION ] -- ✨
task.wait(0.1)
print([[
  ___________________________________________
 /                                           \
|   ✅ OMNI-ELITE : Système prêt !            |
|   Version : Elite Fusion v3.9               |
 \___________________________________________/
]])
Logger:AddLog("✨ ***OMNI-ELITE est prêt !*** Bonne chasse.", Color3.fromRGB(0, 255, 150))