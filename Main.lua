--[[
    FICHIER : Main.lua
    PROJET  : OMNI-PROJECT | BLOX FRUITS
    VERSION : v5.9.3 (ULTIMATE FUSION & UI FIX)
    MISE À JOUR : Anti-Crash + All Tabs Visible + Geppo/Fly Fix
]]

-- [ 1. CHARGEMENT SÉCURISÉ & ATTENTE CPU ] -- 🛡️
if not game:IsLoaded() then game.Loaded:Wait() end

local Player = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Fonction d'attente optimisée pour éviter le freeze au lancement
local function SafeCharacterWait()
    local timeout = 0
    while not (Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")) and timeout < 30 do
        task.wait(0.5)
        timeout = timeout + 1
    end
    return Player.Character ~= nil
end

if not SafeCharacterWait() then 
    warn("⚠️ [OMNI] Temps d'attente personnage dépassé.")
    return 
end

-- [ 2. IMPORTATION DES MODULES & GLOBALES ] -- 📦
local Physics
pcall(function()
    Physics = _G.PhysicModule or loadstring(game:HttpGet("https://raw.githubusercontent.com/YuumaBoyz/omniui/refs/heads/main/PhysicModule.lua"))()
end)

_G.Functions = _G.Functions or {Config = {Speed = 300, AttackIncrement = 3}}
_G.SaveManager = _G.SaveManager or {Save = function() end, Load = function() return {} end}
_G.Logger = _G.Logger or {AddLog = function() end, Init = function() end}
_G.FruitSniper = _G.FruitSniper or {Config = {}}
_G.SafeRemoteFire = _G.SafeRemoteFire or function(...) end

-- Correctif de sécurité physique (Anti-Crash)
if not Player.Character:FindFirstChild("Busy") then
    local b = Instance.new("BoolValue", Player.Character)
    b.Name = "Busy"; b.Value = false
end

_G.CanDoubleJump = function()
    local busy = Player.Character:FindFirstChild("Busy")
    return busy and (busy.Value == false) or true
end

-- Vérification UI
local UI = _G.Library
if not UI then 
    print("❌ Echec critique : Library UI introuvable.")
    return 
end

local Ops = _G.Functions
local Saver = _G.SaveManager
local Logger = _G.Logger
local Sniper = _G.FruitSniper

-- [ 3. CRÉATION DE L'INTERFACE (PRIORITÉ ABSOLUE) ] -- 🎨
-- On crée les onglets d'abord pour garantir qu'ils apparaissent tous
local MainWin = UI:CreateWindow("OMNI-ELITE | v5.9.3 🛡️")

local CombatTab   = MainWin:CreateTab("⚔️ Combat")
local FarmTab     = MainWin:CreateTab("🌾 Farming")
local FruitTab    = MainWin:CreateTab("🍎 Fruits")
local MoveTab     = MainWin:CreateTab("✈️ Mouvement")
local SettingsTab = MainWin:CreateTab("⚙️ Paramètres")

-- [ 4. REMPLISSAGE DES ONGLETS ] -- 🛠️

-- --- ONGLET COMBAT ---
CombatTab:CreateToggle("Fast Attack (Heartbeat-Hook)", "FastAttack", function(state)
    Ops.Config.FastAttack = state
    Logger:AddLog("Combat : Fast Attack " .. (state and "***Activé*** ⚡" or "***Désactivé***."))
end)

CombatTab:CreateSlider("Attack Speed", "AttackIncrement", 1, 10, Ops.Config.AttackIncrement or 3, function(value)
    Ops.Config.AttackIncrement = value
end)

CombatTab:CreateToggle("Magnetic Mob", "MagneticMob", function(state)
    Ops.Config.MagneticMob = state
end)

CombatTab:CreateToggle("🛡️ Auto-Defense (Haki/Ken)", "AutoDefense", function(state)
    _G.AutoHaki = state; _G.AutoKen = state
end)

-- --- ONGLET FARMING ---
FarmTab:CreateToggle("🔥 Mode ELITE-FARM", "EliteFarm", function(state)
    Ops.Config.EliteFarm = state
    Logger:AddLog("Elite-Farm : " .. (state and "***Lancé*** 🌾" or "***Stoppé***."))
end)

FarmTab:CreateToggle("📊 Auto-Stats", "AutoStats", function(state)
    Ops.Config.AutoStats = state
end)

FarmTab:CreateDropdown("Cible Stats", {"Melee", "Defense", "Sword", "Blox Fruit"}, function(s)
    Ops.Config.TargetStat = s
end)

-- --- ONGLET FRUITS (PROTECTION ANTI-CRASH) ---
FruitTab:CreateToggle("Fruit Sniper (Safe-Collect)", "SniperEnabled", function(state)
    Sniper.Config.Enabled = state
    if state then 
        local success, err = pcall(function()
            _G.SafeRemoteFire("CollectedDragonEgg", true)
        end)
        if not success then
            Logger:AddLog("Sniper : ***Erreur Remote*** (Ignoré)", Color3.fromRGB(255, 100, 100))
        else
            Logger:AddLog("Sniper : ***Actif***")
        end
    else
        Logger:AddLog("Sniper : ***Veille***")
    end
end)

-- --- ONGLET MOUVEMENT ---
MoveTab:CreateSlider("Vitesse de Vol", "Speed", 50, 800, Ops.Config.Speed or 300, function(value)
    Ops.Config.Speed = value
end)

MoveTab:CreateToggle("Noclip", "Noclip", function(state)
    _G.Noclip = state
    Logger:AddLog("Physique : Noclip " .. (state and "***Activé*** 👻" or "***Désactivé***."))
end)

MoveTab:CreateToggle("Fly (Mode Vol)", "FlyEnabled", function(state)
    if _G.CanDoubleJump() and Physics then
        Physics:ToggleFly(state, Ops.Config.Speed)
        Logger:AddLog("Physique : Fly " .. (state and "***Activé*** 🦅" or "***Désactivé***."))
    else
        UI:Notify("Système", "⚠️ Action bloquée ou Module manquant")
    end
end)

MoveTab:CreateToggle("🛡️ Fly Safe-Bypass", "FlyBypass", function(state)
    _G.FlySafeMode = state
end)

MoveTab:CreateToggle("☁️ Infinite Geppo", "InfGeppo", function(state)
    _G.InfiniteGeppo = state
    Logger:AddLog("Mouvement : Geppo Illimité " .. (state and "***Activé*** ☁️"))
end)

-- --- ONGLET PARAMÈTRES ---
SettingsTab:CreateButton("Modifier le Raccourci UI", function()
    UI:Notify("Keybind", "Appuyez sur une touche...", 5)
    local capture; capture = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            MainWin:SetKeybind(input.KeyCode)
            UI:Notify("Système", "Nouveau raccourci : " .. input.KeyCode.Name, 3)
            capture:Disconnect()
        end
    end)
end)

SettingsTab:CreateButton("🚀 Force Server Hop", function()
    if Ops.SmartHop then Ops:SmartHop() else UI:Notify("Erreur", "Module non détecté.") end
end)

SettingsTab:CreateButton("💾 Sauvegarder Config", function()
    Saver:Save(Ops.Config)
    UI:Notify("Système", "Configuration enregistrée ✅")
end)

-- [ 5. DÉMARRAGE DES SERVICES EN ARRIÈRE-PLAN ] -- ✨
task.spawn(function()
    pcall(function()
        UI:ShowLoadingScreen("OMNI-PROJECT : RESTAURATION...")
        local savedData = Saver:Load()
        if savedData then
            for k, v in pairs(savedData) do Ops.Config[k] = v end
        end
        if Ops.Init then Ops:Init() end
    end)
end)

-- Initialisation Console Logs
pcall(function()
    Logger:Init(MainWin.MainFrame)
    Logger:AddLog("✅ ***Moteur v5.9.3 (Fusion)*** prêt.", Color3.fromRGB(0, 255, 150))
end)

UI:Notify("Système", "Protocole ***Omni-Elite*** v5.9.3 chargé. 🚀")
print("--- [ OMNI-ELITE : V5.9.3 FINAL SYSTEM INITIALIZED ] ---")