--[[
    FICHIER : Main.lua
    PROJET  : OMNI-PROJECT | BLOX FRUITS
    VERSION : v5.8 (ULTIMATE FUSION)
    UTILITÉ : Contrôleur Principal + Protection Réseau & Physique + UI
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

-- [ 2. CORRECTIF DE SÉCURITÉ PHYSIQUE (ANTI-CRASH) ] -- 🛠️
-- Correction du bug "Busy is not a valid member" pour le Noclip et Combat
if not Player.Character:FindFirstChild("Busy") then
    local b = Instance.new("BoolValue", Player.Character)
    b.Name = "Busy"
    b.Value = false
end

-- Fonction globale pour vérifier l'état sans crash (utilisée par les autres modules)
_G.CanDoubleJump = function()
    local busy = Player.Character:FindFirstChild("Busy")
    return busy and (busy.Value == false) or true
end

-- [ 3. VÉRIFICATION ET FALLBACK DES DÉPENDANCES ] -- 🔍
-- Sécurité v5.8 : Si un module manque, on crée un substitut pour éviter le crash
_G.Functions = _G.Functions or {Config = {Speed = 300, AttackIncrement = 3}}
_G.SaveManager = _G.SaveManager or {Save = function() end, Load = function() return {} end}
_G.Logger = _G.Logger or {AddLog = function() end, Init = function() end}
_G.FruitSniper = _G.FruitSniper or {Config = {}}
_G.SafeRemoteFire = _G.SafeRemoteFire or function(...) warn("NetworkGuard non chargé") end

local function CheckDependencies()
    local missing = {}
    if not _G.Library then table.insert(missing, "OmniUILibrary") end
    if not _G.Functions.Init then table.insert(missing, "OmniFunctions") end
    
    if #missing > 0 then
        warn("⚠️ [OMNI-WARN] Modules manquants : " .. table.concat(missing, ", "))
        if not _G.Library then return false end
    end
    return true
end

if not CheckDependencies() then 
    print("❌ Echec critique : Library UI introuvable.")
    return 
end

-- Aliases
local UI     = _G.Library
local Ops    = _G.Functions
local Saver  = _G.SaveManager
local Logger = _G.Logger
local Sniper = _G.FruitSniper

-- [ 4. CHARGEMENT ET RESTAURATION ] -- 💾
pcall(function()
    UI:ShowLoadingScreen("OMNI-PROJECT : INITIALISATION v5.8...")
    local savedData = Saver:Load()
    if savedData then
        for key, value in pairs(savedData) do
            Ops.Config[key] = value
        end
    end
end)

-- Lancement des services persistants (MOTEUR)
task.spawn(function()
    pcall(function()
        -- Lancement obligatoire du moteur de fonctions
        if Ops.Init then 
            Ops:Init() 
        end
        if _G.AutoDefense and _G.AutoDefense.Start then 
            _G.AutoDefense:Start() 
        end
    end)
end)

-- [ 5. CRÉATION DE L'INTERFACE ] -- 🎨
local MainWin = UI:CreateWindow("OMNI-ELITE | v5.8 🛡️")

-- Initialisation de la console de logs
pcall(function()
    Logger:Init(MainWin.MainFrame)
    Logger:AddLog("✅ ***Moteur v5.8 (Ultimate Fusion)*** prêt.", Color3.fromRGB(0, 255, 150))
end)

-- [ 6. ONGLET COMBAT ] -- ⚔️
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
    Logger:AddLog("Défense : Modes auto " .. (state and "***ON***" or "***OFF***"), Color3.fromRGB(100, 100, 255))
end)

-- [ 7. ONGLET FARMING ] -- 🌾
local FarmTab = MainWin:CreateTab("🌾 Farming")

FarmTab:CreateToggle("🔥 Mode ELITE-FARM (Full Auto)", "EliteFarm", function(state)
    Ops.Config.EliteFarm = state
    Logger:AddLog("Elite-Farm : " .. (state and "***Lancé*** 🌾" or "***Stoppé***."))
end)

FarmTab:CreateToggle("📊 Auto-Stats Distribution", "AutoStats", function(state)
    Ops.Config.AutoStats = state
end)

FarmTab:CreateDropdown("Cible Stats", {"Melee", "Defense", "Sword", "Blox Fruit"}, function(s)
    Ops.Config.TargetStat = s
end)

-- [ 8. ONGLET FRUITS ] -- 🍎
local FruitTab = MainWin:CreateTab("🍎 Fruits")

FruitTab:CreateToggle("Fruit Sniper (Safe-Collect)", "SniperEnabled", function(state)
    Sniper.Config.Enabled = state
    if state then _G.SafeRemoteFire("CollectedDragonEgg", true) end
    Logger:AddLog("Sniper : " .. (state and "***Actif***" or "***Veille***"))
end)

FruitTab:CreateButton("🚀 Force Server Hop", function()
    if Ops.SmartHop then Ops:SmartHop() end
end)

-- [ 9. ONGLET MOUVEMENT ] -- ✈️
local MoveTab = MainWin:CreateTab("✈️ Mouvement")

MoveTab:CreateSlider("Vitesse Safe-Tween", "Speed", 100, 1000, Ops.Config.Speed or 300, function(value)
    Ops.Config.Speed = value
end)

MoveTab:CreateToggle("Noclip (Anti-Busy Check)", "Noclip", function(state)
    -- Utilisation de la fonction globale sécurisée
    if _G.CanDoubleJump() then
        _G.Noclip = state
        Logger:AddLog("Mouvement : Noclip " .. (state and "***Actif***" or "***Off***"))
    else
        UI:Notify("Système", "⚠️ Action bloquée : Joueur occupé")
        _G.Noclip = false
    end
end)

-- [ 10. PARAMÈTRES ] -- ⚙️
local ConfTab = MainWin:CreateTab("⚙️ Paramètres")

ConfTab:CreateButton("💾 Sauvegarder Config", function()
    Saver:Save(Ops.Config)
    UI:Notify("Système", "Configuration v5.8 enregistrée ✅")
end)

-- [ 11. FINALISATION ] -- ✨
UI:Notify("Système", "Protocole ***Omni-Elite*** v5.8 prêt. 🚀")
print("--- [ OMNI-ELITE : V5.8 FINAL SYSTEM INITIALIZED ] ---")