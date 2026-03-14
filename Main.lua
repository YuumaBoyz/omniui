--[[
    FICHIER : Main.lua
    PROJET  : OMNI-PROJECT | BLOX FRUITS
    VERSION : v5.9 (PHYSICS & GEPPO UPDATE)
    MISE À JOUR : Safe-Bypass Fly + Infinite Geppo + Keybind Fix
]]

-- [ 1. CHARGEMENT SÉCURISÉ IMPÉRATIF ] -- 🛡️
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local Player = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Attente du Personnage ET du HumanoidRootPart
repeat 
    task.wait(0.5) 
until Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")

-- [ 2. IMPORTATION DES MODULES EXTERNES ] -- 📦
-- Note : Assure-toi que ton PhysicModule est bien chargé en amont ou via cette URL
local Physics = _G.PhysicModule or loadstring(game:HttpGet("https://raw.githubusercontent.com/TonRepo/PhysicModule.lua"))()

-- [ 3. CORRECTIF DE SÉCURITÉ PHYSIQUE (ANTI-CRASH) ] -- 🛠️
if not Player.Character:FindFirstChild("Busy") then
    local b = Instance.new("BoolValue", Player.Character)
    b.Name = "Busy"
    b.Value = false
end

_G.CanDoubleJump = function()
    local busy = Player.Character:FindFirstChild("Busy")
    return busy and (busy.Value == false) or true
end

-- [ 4. VÉRIFICATION ET FALLBACK DES DÉPENDANCES ] -- 🔍
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

local UI     = _G.Library
local Ops    = _G.Functions
local Saver  = _G.SaveManager
local Logger = _G.Logger
local Sniper = _G.FruitSniper

-- [ 5. CHARGEMENT ET RESTAURATION ] -- 💾
pcall(function()
    UI:ShowLoadingScreen("OMNI-PROJECT : INITIALISATION v5.9...")
    local savedData = Saver:Load()
    if savedData then
        for key, value in pairs(savedData) do
            Ops.Config[key] = value
        end
    end
end)

-- Lancement des services persistants
task.spawn(function()
    pcall(function()
        if Ops.Init then Ops:Init() end
        if _G.AutoDefense and _G.AutoDefense.Start then _G.AutoDefense:Start() end
    end)
end)

-- [ 6. CRÉATION DE L'INTERFACE ] -- 🎨
local MainWin = UI:CreateWindow("OMNI-ELITE | v5.9 🛡️")

-- Initialisation de la console de logs
pcall(function()
    Logger:Init(MainWin.MainFrame)
    Logger:AddLog("✅ ***Moteur v5.9 (Physics Update)*** prêt.", Color3.fromRGB(0, 255, 150))
end)

-- [ 7. ONGLET COMBAT ] -- ⚔️
local CombatTab = MainWin:CreateTab("⚔️ Combat")

CombatTab:CreateToggle("Fast Attack (Heartbeat-Hook)", "FastAttack", function(state)
    Ops.Config.FastAttack = state
    Logger:AddLog("Combat : Fast Attack " .. (state and "***Activé*** ⚡" or "***Désactivé***."))
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
end)

-- [ 8. ONGLET FARMING ] -- 🌾
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

-- [ 9. ONGLET FRUITS ] -- 🍎
local FruitTab = MainWin:CreateTab("🍎 Fruits")

FruitTab:CreateToggle("Fruit Sniper (Safe-Collect)", "SniperEnabled", function(state)
    Sniper.Config.Enabled = state
    if state then _G.SafeRemoteFire("CollectedDragonEgg", true) end
    Logger:AddLog("Sniper : " .. (state and "***Actif***" or "***Veille***"))
end)

-- [ 10. ONGLET MOUVEMENT ] -- ✈️
local MoveTab = MainWin:CreateTab("✈️ Mouvement")

MoveTab:CreateSlider("Vitesse de Vol", "Speed", 50, 800, Ops.Config.Speed or 300, function(value)
    Ops.Config.Speed = value
end)

MoveTab:CreateToggle("Noclip (Passe-Murailles)", "Noclip", function(state)
    _G.Noclip = state
    Logger:AddLog("Physique : Noclip " .. (state and "***Activé*** 👻" or "***Désactivé***."))
end)

MoveTab:CreateToggle("Fly (Mode Vol)", "FlyEnabled", function(state)
    if _G.CanDoubleJump() then
        Physics:ToggleFly(state, Ops.Config.Speed)
        Logger:AddLog("Physique : Fly " .. (state and "***Activé*** 🦅" or "***Désactivé***."))
    else
        UI:Notify("Système", "⚠️ Action bloquée : Joueur occupé")
    end
end)

MoveTab:CreateToggle("🛡️ Fly Safe-Bypass", "FlyBypass", function(state)
    _G.FlySafeMode = state
    Logger:AddLog("Sécurité : Safe-Bypass " .. (state and "***Activé*** ✅" or "***Désactivé*** ⚠️"))
end)

MoveTab:CreateToggle("☁️ Infinite Geppo", "InfGeppo", function(state)
    _G.InfiniteGeppo = state
    Logger:AddLog("Mouvement : Geppo Illimité " .. (state and "***Activé*** ☁️" or "***Désactivé***."))
end)

-- [ 11. PARAMÈTRES & SYSTÈME ] -- ⚙️
local SettingsTab = MainWin:CreateTab("⚙️ Paramètres")

SettingsTab:CreateButton("Modifier le Raccourci UI", function()
    UI:Notify("Keybind", "Appuyez sur une touche pour changer le raccourci...", 5)
    
    local capture
    capture = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            MainWin:SetKeybind(input.KeyCode)
            UI:Notify("Système", "Nouveau raccourci : " .. input.KeyCode.Name, 3)
            capture:Disconnect()
        end
    end)
end)

SettingsTab:CreateButton("🚀 Force Server Hop", function()
    if Ops.SmartHop then 
        Ops:SmartHop() 
    else
        UI:Notify("Erreur", "Module ServerHop non détecté.")
    end
end)

SettingsTab:CreateButton("💾 Sauvegarder Config", function()
    Saver:Save(Ops.Config)
    UI:Notify("Système", "Configuration enregistrée ✅")
    Logger:AddLog("Système : Configuration ***Sauvegardée***.")
end)

-- [ 12. FINALISATION ] -- ✨
UI:Notify("Système", "Protocole ***Omni-Elite*** v5.9 prêt. 🚀")
Logger:AddLog("🚀 ***Système prêt.*** Keybind : " .. MainWin.Keybind.Name, Color3.fromRGB(0, 255, 150))
print("--- [ OMNI-ELITE : V5.9 FINAL SYSTEM INITIALIZED ] ---")