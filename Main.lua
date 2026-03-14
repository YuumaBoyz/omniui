--[[
    FICHIER : Main.lua
    PROJET  : OMNI-PROJECT | BLOX FRUITS
    VERSION : v4.8 (Elite-Auto & Safety-First)
    UTILITÉ : Contrôleur Principal & Liaison Inter-Modules
]]

-- [ 1. PROTOCOLE D'INITIALISATION & SÉCURITÉ ] -- 🛡️
if not game:IsLoaded() then game.Loaded:Wait() end

local function CheckGlobals()
    local dependencies = {
        {_G.Library, "OmniUILibrary"},
        {_G.Functions, "OmniFunctions"},
        {_G.SaveManager, "SaveManager"},
        {_G.Logger, "OmniLogger"}
    }
    
    for _, dep in ipairs(dependencies) do
        if not dep[1] then
            warn("❌ [OMNI-ELITE ERROR] : " .. dep[2] .. " est manquant !")
            return false
        end
    end
    return true
end

if not CheckGlobals() then return end

-- Aliases
local UI     = _G.Library
local Ops    = _G.Functions
local Saver  = _G.SaveManager
local Logger = _G.Logger
local Player = game:GetService("Players").LocalPlayer

-- Attente du personnage avant affichage
local function EnsureCharacter()
    local char = Player.Character or Player.CharacterAdded:Wait()
    char:WaitForChild("HumanoidRootPart", 10)
    return char
end

EnsureCharacter()

-- [ 2. CHARGEMENT ET RESTAURATION ] -- 💾
UI:ShowLoadingScreen("OMNI-PROJECT : INITIALISATION v4.8...")

local savedData = Saver:Load()
if savedData then
    for key, value in pairs(savedData) do
        Ops.Config[key] = value
    end
end

-- Lancement des services persistants
task.spawn(function()
    if Ops.Config.FastAttack then pcall(function() Ops:EnableFastAttack() end) end
    if Ops.Config.AutoClicker then pcall(function() Ops:StartAutoClick() end) end
    if Ops.Config.MagneticMob then pcall(function() Ops:StartMagneticMob() end) end
    if Ops.Config.EliteFarm then pcall(function() Ops:StartEliteFarm() end) end
end)

UI:Notify("Système", "Protocole ***Omni-Elite*** prêt. 🚀")

-- [ 3. CRÉATION DE L'INTERFACE ] -- 🎨
local MainWin = UI:CreateWindow("OMNI-ELITE | v4.8")

-- Initialisation de la console de logs
Logger:Init(MainWin.MainFrame)
Logger:AddLog("✅ ***Moteur v4.8 (Immortal)*** chargé.", Color3.fromRGB(0, 255, 255))

-- [ 4. ONGLET COMBAT ] -- ⚔️
local CombatTab = MainWin:CreateTab("⚔️ Combat")

CombatTab:CreateToggle("Fast Attack (GC-Bypass)", "FastAttack", function(state)
    Ops.Config.FastAttack = state
    if state then 
        Ops:EnableFastAttack() 
        Logger:AddLog("Combat : Fast Attack ***Activé*** ⚡", Color3.fromRGB(0, 255, 150))
    end
end)

CombatTab:CreateToggle("Magnetic Mob (Safe Bring)", "MagneticMob", function(state)
    Ops.Config.MagneticMob = state
    if state then Ops:StartMagneticMob() end
end)

CombatTab:CreateToggle("Auto-Clicker (Ghost)", "AutoClicker", function(state)
    Ops.Config.AutoClicker = state
    if state then Ops:StartAutoClick() end
end)

CombatTab:CreateSlider("Distance Radius", "AttackDistance", 5, 100, Ops.Config.AttackDistance or 15, function(value)
    Ops.Config.AttackDistance = value
end)

-- [ 5. ONGLET FARMING ] -- 🍎
local FarmTab = MainWin:CreateTab("🍎 Farming")

FarmTab:CreateToggle("🔥 Mode ELITE-FARM (Full Auto)", "EliteFarm", function(state)
    Ops.Config.EliteFarm = state
    if state then 
        Logger:AddLog("Elite-Farm : ***Démarrage du cycle dynamique*** 🌾", Color3.fromRGB(0, 255, 150))
        Ops:StartEliteFarm() 
        Ops:EnableFastAttack() 
    else
        Logger:AddLog("Elite-Farm : ***Arrêt du cycle***", Color3.fromRGB(200, 200, 200))
    end
end)

FarmTab:CreateToggle("📊 Auto-Stats (Points)", "AutoStats", function(state)
    Ops.Config.AutoStats = state
    if state then Logger:AddLog("Stats : ***Attribution automatique*** active.", Color3.fromRGB(100, 255, 255)) end
end)

FarmTab:CreateDropdown("Cible Stats", {"Melee", "Defense", "Sword", "Blox Fruit"}, function(s)
    Ops.Config.TargetStat = s
    Logger:AddLog("Stats : Cible définie sur ***" .. s .. "***", Color3.fromRGB(255, 255, 255))
end)

FarmTab:CreateDropdown("Arme Prioritaire", {"Melee", "Sword", "Blox Fruit"}, function(s)
    Ops.Config.WeaponType = s
end)

FarmTab:CreateToggle("Fruit Sniper", "SniperEnabled", function(state)
    Ops.Config.SniperEnabled = state
    if state then Ops:InitFruitSniper() end
end)

-- [ 6. ONGLET MOUVEMENT ] -- ✈️
local MoveTab = MainWin:CreateTab("✈️ Mouvement")

MoveTab:CreateToggle("Ghost Noclip", "MagneticMob", function(state)
    Ops.Config.MagneticMob = state
    local status = state and "***Activé*** 👻" or "***Désactivé***"
    Logger:AddLog("Mouvement : Ghost-Noclip " .. status, Color3.fromRGB(200, 200, 255))
end)

MoveTab:CreateSlider("Vitesse Safe-Tween", "Speed", 100, 1000, Ops.Config.Speed or 300, function(value)
    Ops.Config.Speed = value
end)

-- [ 7. PARAMÈTRES & SYSTÈME ] -- ⚙️
local ConfTab = MainWin:CreateTab("⚙️ Paramètres")

ConfTab:CreateButton("💾 Sauvegarder Config", function()
    Saver:Save(Ops.Config)
    UI:Notify("Système", "Configuration v4.8 ***Sauvegardée*** ✅")
end)

ConfTab:CreateButton("🚀 Server Hop", function()
    Logger:AddLog("🌐 Reconnexion : Changement de serveur...", Color3.fromRGB(255, 255, 0))
    Ops:SmartHop()
end)

ConfTab:CreateToggle("Anti-AFK Permanent", "AntiAFK", function(state)
    Ops.Config.AntiAFK = state
end)

-- [ 8. FINALISATION ] -- ✨
Logger:AddLog("✨ ***OMNI-ELITE v4.8 PRÊT !*** Bonne chasse.", Color3.fromRGB(0, 255, 150))
print("--- [ OMNI-ELITE : V4.8 INITIALIZED ] ---")