--[[
    FICHIER : Main.lua
    PROJET  : OMNI-PROJECT | BLOX FRUITS
    VERSION : v5.0 (Shielded-Protocol & Ultra-Fusion)
    UTILITÉ : Contrôleur Principal & Liaison Inter-Modules
]]

-- [ 1. CHARGEMENT SÉCURISÉ IMPÉRATIF ] -- 🛡️
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local Player = game:GetService("Players").LocalPlayer

-- Attente stricte du Personnage ET du HumanoidRootPart pour éviter les erreurs 'nil'
repeat 
    task.wait(0.5) 
until Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")

-- [ 2. VÉRIFICATION DES DÉPENDANCES ] -- 🔍
local function CheckGlobals()
    local dependencies = {
        {_G.Library, "OmniUILibrary"},
        {_G.Functions, "OmniFunctions"},
        {_G.SaveManager, "SaveManager"},
        {_G.Logger, "OmniLogger"}
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

-- Aliases pour la clarté du code
local UI     = _G.Library
local Ops    = _G.Functions
local Saver  = _G.SaveManager
local Logger = _G.Logger

-- [ 3. CHARGEMENT ET RESTAURATION ] -- 💾
UI:ShowLoadingScreen("OMNI-PROJECT : RESTAURATION v5.0...")

local savedData = Saver:Load()
if savedData then
    for key, value in pairs(savedData) do
        Ops.Config[key] = value
    end
end

-- Lancement immédiat des services persistants (Sécurisé par pcall)
task.spawn(function()
    pcall(function()
        if Ops.Config.FastAttack then Ops:EnableFastAttack() end
        if Ops.Config.AutoClicker then Ops:StartAutoClick() end
        if Ops.Config.MagneticMob then Ops:StartMagneticMob() end
        if Ops.Config.EliteFarm then Ops:StartEliteFarm() end
    end)
end)

-- [ 4. CRÉATION DE L'INTERFACE ] -- 🎨
local MainWin = UI:CreateWindow("OMNI-ELITE | v5.0")

-- Initialisation de la console de logs
Logger:Init(MainWin.MainFrame)
Logger:AddLog("✅ ***Moteur v5.0 (Shielded)*** initialisé.", Color3.fromRGB(0, 255, 255))

-- [ 5. ONGLET COMBAT ] -- ⚔️
local CombatTab = MainWin:CreateTab("⚔️ Combat")

CombatTab:CreateToggle("Fast Attack (GC-Safe)", "FastAttack", function(state)
    Ops.Config.FastAttack = state
    if state then 
        local success, err = pcall(function() Ops:EnableFastAttack() end)
        if success then
            Logger:AddLog("Combat : Fast Attack ***Activé*** ⚡", Color3.fromRGB(0, 255, 150))
        else
            warn("Erreur FastAttack: " .. err)
        end
    end
end)

CombatTab:CreateToggle("Magnetic Mob (Safe Bring)", "MagneticMob", function(state)
    Ops.Config.MagneticMob = state
    if state then pcall(function() Ops:StartMagneticMob() end) end
end)

CombatTab:CreateToggle("Auto-Clicker (Ghost)", "AutoClicker", function(state)
    Ops.Config.AutoClicker = state
    if state then pcall(function() Ops:StartAutoClick() end) end
end)

CombatTab:CreateSlider("Distance Radius", "AttackDistance", 5, 100, Ops.Config.AttackDistance or 15, function(value)
    Ops.Config.AttackDistance = value
end)

-- [ 6. ONGLET FARMING ] -- 🍎
local FarmTab = MainWin:CreateTab("🍎 Farming")

FarmTab:CreateToggle("🔥 Mode ELITE-FARM (Full Auto)", "EliteFarm", function(state)
    Ops.Config.EliteFarm = state
    if state then 
        Logger:AddLog("Elite-Farm : ***Cycle dynamique lancé*** 🌾", Color3.fromRGB(0, 255, 150))
        pcall(function() 
            Ops:StartEliteFarm() 
            Ops:EnableFastAttack() 
        end)
    else
        Logger:AddLog("Elite-Farm : ***Cycle stoppé***.", Color3.fromRGB(200, 200, 200))
    end
end)

FarmTab:CreateToggle("📊 Auto-Stats (Points)", "AutoStats", function(state)
    Ops.Config.AutoStats = state
end)

FarmTab:CreateDropdown("Cible Stats", {"Melee", "Defense", "Sword", "Blox Fruit"}, function(s)
    Ops.Config.TargetStat = s
end)

FarmTab:CreateDropdown("Arme Prioritaire", {"Melee", "Sword", "Blox Fruit"}, function(s)
    Ops.Config.WeaponType = s
end)

FarmTab:CreateToggle("Fruit Sniper", "SniperEnabled", function(state)
    Ops.Config.SniperEnabled = state
    if state then pcall(function() Ops:InitFruitSniper() end) end
end)

-- [ 7. ONGLET MOUVEMENT ] -- ✈️
local MoveTab = MainWin:CreateTab("✈️ Mouvement")

MoveTab:CreateToggle("Ghost Noclip", "MagneticMob", function(state)
    Ops.Config.MagneticMob = state
    Logger:AddLog("Mouvement : Ghost-Noclip " .. (state and "Activé" or "Désactivé"), Color3.fromRGB(200, 200, 255))
end)

MoveTab:CreateSlider("Vitesse Safe-Tween", "Speed", 100, 1000, Ops.Config.Speed or 300, function(value)
    Ops.Config.Speed = value
end)

-- [ 8. PARAMÈTRES & SYSTÈME ] -- ⚙️
local ConfTab = MainWin:CreateTab("⚙️ Paramètres")

ConfTab:CreateButton("💾 Sauvegarder Config", function()
    Saver:Save(Ops.Config)
    UI:Notify("Système", "Configuration v5.0 ***Sauvegardée*** ✅")
end)

ConfTab:CreateButton("🚀 Server Hop", function()
    Ops:SmartHop()
end)

ConfTab:CreateToggle("Anti-AFK Permanent", "AntiAFK", function(state)
    Ops.Config.AntiAFK = state
end)

-- [ 9. FINALISATION ] -- ✨
UI:Notify("Système", "Protocole ***Omni-Elite*** prêt. 🚀")
Logger:AddLog("✨ ***OMNI-ELITE v5.0 PRÊT !*** Bonne chasse.", Color3.fromRGB(0, 255, 150))
print("--- [ OMNI-ELITE : V5.0 FINAL INITIALIZED ] ---")