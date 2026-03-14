--[[
    FICHIER : Main.lua
    PROJET  : OMNI-PROJECT | BLOX FRUITS
    VERSION : v4.4 (Ultra-Fusion & Ghost-Protocol Sync)
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
UI:ShowLoadingScreen("OMNI-PROJECT : RESTAURATION v4.4...")

local savedData = Saver:Load()
if savedData then
    for key, value in pairs(savedData) do
        Ops.Config[key] = value
    end
end

-- Lancement immédiat des services actifs persistants (Ghost-Protocol Safe)
task.spawn(function()
    if Ops.Config.FastAttack then pcall(function() Ops:EnableFastAttack() end) end
    if Ops.Config.AutoClicker then pcall(function() Ops:StartAutoClick() end) end
    if Ops.Config.MagneticMob then pcall(function() Ops:StartMagneticMob() end) end
    if Ops.Config.SniperEnabled then 
        pcall(function() 
            Ops:InitFruitSniper() 
        end) 
    end
end)

UI:Notify("Système", "Protocole ***Ghost-Elite*** restauré. 🚀")

-- [ 3. CRÉATION DE L'INTERFACE ] -- 🎨
local MainWin = UI:CreateWindow("OMNI-ELITE | BLOX FRUITS")

-- Initialisation de la console de logs
Logger:Init(MainWin.MainFrame)
Logger:AddLog("✅ ***Moteur v4.4 (GC-Based)*** chargé.", Color3.fromRGB(0, 255, 255))

-- [ 4. ONGLET COMBAT ] -- ⚔️
local CombatTab = MainWin:CreateTab("⚔️ Combat")

CombatTab:CreateToggle("Fast Attack (GC-Bypass)", "FastAttack", function(state)
    Ops.Config.FastAttack = state
    if state then 
        Ops:EnableFastAttack() 
        Logger:AddLog("Combat : Fast Attack ***Activé*** ⚡", Color3.fromRGB(0, 255, 150))
    else
        Logger:AddLog("Combat : Fast Attack ***Désactivé***", Color3.fromRGB(200, 200, 200))
    end
end)

CombatTab:CreateToggle("Magnetic Mob (Safe Bring)", "MagneticMob", function(state)
    Ops.Config.MagneticMob = state
    if state then 
        Ops:StartMagneticMob()
        Logger:AddLog("🧲 Magnétisme : ***Activé*** (Radius: " .. Ops.Config.AttackDistance .. ")", Color3.fromRGB(255, 150, 0))
    else
        Logger:AddLog("🧲 Magnétisme : ***Désactivé***", Color3.fromRGB(200, 200, 200))
    end
end)

CombatTab:CreateToggle("Auto-Clicker (Ghost)", "AutoClicker", function(state)
    Ops.Config.AutoClicker = state
    if state then 
        Ops:StartAutoClick()
        Logger:AddLog("Clicker : ***Actif*** 🖱️", Color3.fromRGB(0, 255, 255))
    end
end)

CombatTab:CreateSlider("Distance Radius", "AttackDistance", 5, 100, Ops.Config.AttackDistance or 15, function(value)
    Ops.Config.AttackDistance = value
end)

-- [ 5. ONGLET FARMING ] -- 🍎
local FarmTab = MainWin:CreateTab("🍎 Farming")

FarmTab:CreateToggle("Fruit Sniper (Ghost Collect)", "SniperEnabled", function(state)
    Ops.Config.SniperEnabled = state
    if state then
        Logger:AddLog("Sniper : ***Recherche active*** 🍓", Color3.fromRGB(255, 100, 255))
        Ops:InitFruitSniper()
    end
end)

-- [ 6. ONGLET MOUVEMENT ] -- ✈️
local MoveTab = MainWin:CreateTab("✈️ Mouvement")

-- Ghost Mode synchronisé avec la config
MoveTab:CreateToggle("Ghost Mode (Noclip)", "MagneticMob", function(state)
    -- On utilise la même clé que MagneticMob car il inclut déjà le Noclip sécurisé
    Ops.Config.MagneticMob = state
    local status = state and "***Activé*** 👻" or "***Désactivé***"
    Logger:AddLog("Mouvement : Ghost-Noclip " .. status, Color3.fromRGB(200, 200, 255))
end)

MoveTab:CreateSlider("Vitesse Ghost-Fly", "Speed", 100, 1000, Ops.Config.Speed or 300, function(value)
    Ops.Config.Speed = value
end)

-- [ 7. PARAMÈTRES & SYSTÈME ] -- ⚙️
local ConfTab = MainWin:CreateTab("⚙️ Paramètres")

ConfTab:CreateButton("💾 Sauvegarder Config", function()
    Saver:Save(Ops.Config)
    UI:Notify("Système", "Configuration v4.4 ***Sauvegardée*** ✅")
    Logger:AddLog("💾 Manuel : État de la config exporté.", Color3.fromRGB(100, 255, 100))
end)

ConfTab:CreateButton("🚀 Server Hop", function()
    Logger:AddLog("🌐 Reconnexion : Recherche d'un nouveau serveur...", Color3.fromRGB(255, 255, 0))
    Ops:SmartHop()
end)

ConfTab:CreateToggle("Anti-AFK Permanent", "AntiAFK", function(state)
    Ops.Config.AntiAFK = state
    if state then Logger:AddLog("Sécurité : Anti-AFK ***Vérifié***.", Color3.fromRGB(100, 255, 100)) end
end)

-- [ 8. FINALISATION ] -- ✨
Logger:AddLog("✨ ***OMNI-ELITE v4.4 PRÊT !*** Bonne chasse.", Color3.fromRGB(0, 255, 150))
print("--- [ OMNI-ELITE : GHOST-PROTOCOL INITIALIZED ] ---")