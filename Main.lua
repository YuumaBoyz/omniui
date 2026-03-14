--[[
    FICHIER : Main.lua
    PROJET  : OMNI-PROJECT | BLOX FRUITS
    VERSION : v5.5 (Ecosystem Integration)
    UTILITÉ : Contrôleur Principal & Liaison Inter-Modules
]]

-- [ 1. CHARGEMENT SÉCURISÉ IMPÉRATIF ] -- 🛡️
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local Player = game:GetService("Players").LocalPlayer

-- Attente du Personnage ET du HumanoidRootPart
repeat 
    task.wait(0.5) 
until Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")

-- [ 2. VÉRIFICATION DES DÉPENDANCES ] -- 🔍
local function CheckGlobals()
    local dependencies = {
        {_G.Library, "OmniUILibrary"},
        {_G.Functions, "OmniFunctions"},
        {_G.SaveManager, "SaveManager"},
        {_G.Logger, "OmniLogger"},
        {_G.FruitSniper, "FruitSniper"} -- Nouveau module Sniper
    }
    
    for _, dep in ipairs(dependencies) do
        if not dep[1] then
            warn("❌ [OMNI-ERROR] : " .. dep[2] .. " est manquant !")
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
local Sniper = _G.FruitSniper

-- [ 3. CHARGEMENT ET RESTAURATION ] -- 💾
UI:ShowLoadingScreen("OMNI-PROJECT : RESTAURATION v5.5...")

local savedData = Saver:Load()
if savedData then
    for key, value in pairs(savedData) do
        Ops.Config[key] = value
    end
end

-- Lancement immédiat des services persistants
task.spawn(function()
    pcall(function()
        Ops:Init() -- Lance Auto-Click, Elite-Farm et Heartbeat Core
        if _G.AutoDefense then _G.AutoDefense:Start() end
        if _G.AutoStats then _G.AutoStats:Start() end
    end)
end)

-- [ 4. CRÉATION DE L'INTERFACE ] -- 🎨
local MainWin = UI:CreateWindow("OMNI-ELITE | v5.5")

-- Initialisation de la console de logs
Logger:Init(MainWin.MainFrame)
Logger:AddLog("✅ ***Moteur v5.5 (Sniper-Ready)*** initialisé.", Color3.fromRGB(0, 255, 255))

-- [ 5. ONGLET COMBAT ] -- ⚔️
local CombatTab = MainWin:CreateTab("⚔️ Combat")

CombatTab:CreateToggle("Fast Attack (Heartbeat-Hook)", "FastAttack", function(state)
    Ops.Config.FastAttack = state
    Logger:AddLog("Combat : Fast Attack " .. (state and "***Activé*** ⚡" or "***Désactivé***."), state and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(200, 200, 200))
end)

CombatTab:CreateSlider("Attack Speed (Increment)", "AttackIncrement", 1, 10, Ops.Config.AttackIncrement or 3, function(value)
    Ops.Config.AttackIncrement = value
end)

CombatTab:CreateToggle("Magnetic Mob (Safe Bring)", "MagneticMob", function(state)
    Ops.Config.MagneticMob = state
end)

CombatTab:CreateToggle("Auto-Clicker (Ghost)", "AutoClicker", function(state)
    Ops.Config.AutoClicker = state
end)

CombatTab:CreateToggle("🛡️ Auto-Defense (Haki/Ken)", "AutoDefense", function(state)
    _G.AutoHaki = state
    _G.AutoKen = state
    Logger:AddLog("Défense : Haki Automatique " .. (state and "***ON***" or "***OFF***"), Color3.fromRGB(100, 100, 255))
end)

-- [ 6. ONGLET FARMING ] -- 🌾
local FarmTab = MainWin:CreateTab("🌾 Farming")

FarmTab:CreateToggle("🔥 Mode ELITE-FARM (Full Auto)", "EliteFarm", function(state)
    Ops.Config.EliteFarm = state
    Logger:AddLog("Elite-Farm : " .. (state and "***Cycle lancé*** 🌾" or "***Cycle stoppé***."), state and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(200, 200, 200))
end)

FarmTab:CreateToggle("📊 Auto-Stats Distribution", "AutoStats", function(state)
    Ops.Config.AutoStats = state
end)

FarmTab:CreateDropdown("Cible Stats", {"Melee", "Defense", "Sword", "Blox Fruit"}, function(s)
    Ops.Config.TargetStat = s
end)

FarmTab:CreateDropdown("Arme Prioritaire", {"Melee", "Sword", "Blox Fruit"}, function(s)
    Ops.Config.WeaponType = s
end)

-- [ 7. ONGLET FRUITS (SNIPER) ] -- 🍎
local FruitTab = MainWin:CreateTab("🍎 Fruits")

FruitTab:CreateToggle("Fruit Sniper (Auto-Collect)", "SniperEnabled", function(state)
    Sniper.Config.Enabled = state
    Logger:AddLog("Sniper : Détection des fruits " .. (state and "***Active*** 🔍" or "***Mise en veille***."), Color3.fromRGB(255, 100, 100))
end)

FruitTab:CreateToggle("Auto-Inventory (Store)", "AutoStore", function(state)
    Sniper.Config.AutoStore = state
end)

FruitTab:CreateButton("🚀 Force Server Hop", function()
    Ops:SmartHop()
end)

-- [ 8. ONGLET MOUVEMENT ] -- ✈️
local MoveTab = MainWin:CreateTab("✈️ Mouvement")

MoveTab:CreateSlider("Vitesse Safe-Tween", "Speed", 100, 1000, Ops.Config.Speed or 300, function(value)
    Ops.Config.Speed = value
end)

MoveTab:CreateToggle("Noclip (Tween-Safe)", "Noclip", function(state)
    _G.Noclip = state
end)

-- [ 9. PARAMÈTRES & SYSTÈME ] -- ⚙️
local ConfTab = MainWin:CreateTab("⚙️ Paramètres")

ConfTab:CreateButton("💾 Sauvegarder Config", function()
    Saver:Save(Ops.Config)
    UI:Notify("Système", "Configuration v5.5 ***Sauvegardée*** ✅")
end)

ConfTab:CreateButton("🔄 Reset Interface", function()
    UI:Notify("Système", "Rechargement de l'UI...")
    task.wait(0.5)
    -- Logique de refresh ici si nécessaire
end)

-- [ 10. FINALISATION ] -- ✨
UI:Notify("Système", "Protocole ***Omni-Elite*** v5.5 chargé. 🚀")
Logger:AddLog("✨ ***OMNI-ELITE v5.5 PRÊT !*** Bonne chasse.", Color3.fromRGB(0, 255, 150))
print("--- [ OMNI-ELITE : V5.5 FINAL ECOSYSTEM INITIALIZED ] ---")