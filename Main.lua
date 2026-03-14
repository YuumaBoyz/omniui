--[[
    FICHIER : Main.lua
    PROJET  : OMNI-PROJECT | BLOX FRUITS
    VERSION : v6.2.3 (STABLE MASTER UNIFIED)
    PATCH   : Fruit Sniper Integration + UI Tabs Fix + Pre-Launch Cleanup
]]

-- [ 0. NETTOYAGE PRÉVENTIF ] -- 🧹
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("OmniUI_Elite") then
    CoreGui.OmniUI_Elite:Destroy()
end

if not game:IsLoaded() then game.Loaded:Wait() end

-- [ 1. CONFIGURATION & GLOBALES ] -- ⚙️
_G.Functions = _G.Functions or {Config = {
    AutoFarm = false,
    AutoQuest = false,
    SelectWeapon = "Melee",
    Speed = 300,
    FastAttack = false,
    AimbotEnabled = false,
    AutoStats = false,
    TargetStat = "Melee",
    FruitSniper = false -- Initialisation Sniper
}}

_G.Logger = _G.Logger or {AddLog = function(msg, color) print("[OMNI]: "..tostring(msg)) end, Init = function() end}

-- [ 2. CHARGEMENT DES MODULES ] -- 📦
local function LoadModule(name, url)
    local success, result = pcall(function() return loadstring(game:HttpGet(url))() end)
    if not success then warn("⚠️ Échec du chargement : " .. name) end
    return success and result or nil
end

local Physics = LoadModule("Physics", "https://raw.githubusercontent.com/YuumaBoyz/omniui/refs/heads/main/PhysicModule.lua")
local SaveManager = LoadModule("SaveManager", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/OmniSaveManager.lua")
local AutoStatsMod = LoadModule("AutoStats", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/AutoStats.lua")
local ServerHopMod = LoadModule("ServerHop", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/ServerHop.lua")
local FruitSniperMod = LoadModule("FruitSniper", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/FruitSniper.lua")
_G.Aimbot = LoadModule("Aimbot", "https://raw.githubusercontent.com/YuumaBoyz/omniui/refs/heads/main/OmniAimbot.lua")

-- [ 3. INTERFACE UTILISATEUR ] -- 🎨
local UI = _G.Library
if not UI then return warn("❌ Library manquante.") end

local MainWin = UI:CreateWindow("OMNI-ELITE | v6.2.3 🛡️")

local Tabs = {
    Combat   = MainWin:CreateTab("⚔️ Combat"),
    Farming  = MainWin:CreateTab("🌾 Farming"),
    Fruits   = MainWin:CreateTab("🍎 Fruits"), -- Onglet activé
    Move     = MainWin:CreateTab("✈️ Mouvement"),
    Settings = MainWin:CreateTab("⚙️ Paramètres")
}

-- [ 4. INJECTION DES COMMANDES UI ] -- 🛠️
task.spawn(function()
    -- --- SECTION : FARMING & STATS ---
    Tabs.Farming:CreateToggle("🔥 Start Auto-Farm", "AutoFarm", function(state) _G.Functions.Config.AutoFarm = state end)
    Tabs.Farming:CreateToggle("📜 Auto-Quest", "AutoQuest", function(state) _G.Functions.Config.AutoQuest = state end)
    
    Tabs.Farming:CreateSeparator("📊 Auto-Stats")
    Tabs.Farming:CreateToggle("📈 Auto-Distribute Points", "AutoStats", function(state) 
        _G.Functions.Config.AutoStats = state 
    end)
    Tabs.Farming:CreateDropdown("Stat à augmenter", {"Melee", "Defense", "Sword", "Blox Fruit"}, function(v) 
        _G.Functions.Config.TargetStat = v 
    end)

    -- --- SECTION : FRUITS ---
    pcall(function()
        Tabs.Fruits:CreateToggle("🍎 Auto-Collect Fruits", "FruitSniper", function(state) 
            _G.Functions.Config.FruitSniper = state 
            if state then _G.Logger:AddLog("🎯 Sniper de fruits activé", Color3.fromRGB(255, 150, 0)) end
        end)
    end)

    -- --- SECTION : MOUVEMENT ---
    Tabs.Move:CreateSlider("Vitesse de Vol", "Speed", 50, 800, _G.Functions.Config.Speed, function(v) _G.Functions.Config.Speed = v end)
    Tabs.Move:CreateToggle("Fly (Mode Vol)", "FlyEnabled", function(state)
        if Physics and Physics.ToggleFly then Physics:ToggleFly(state, _G.Functions.Config.Speed) end
    end)

    -- --- SECTION : SETTINGS ---
    Tabs.Settings:CreateButton("🌐 Server Hop (Low Servers)", function()
        if _G.Functions.SmartHop then _G.Functions.SmartHop() else UI:Notify("Erreur", "Module non chargé.") end
    end)
    
    Tabs.Settings:CreateButton("💾 Save Configuration", function()
        if SaveManager then SaveManager:Save(_G.Functions.Config) end
        UI:Notify("Système", "Configuration enregistrée !")
    end)

    _G.Logger:Init(MainWin.MainFrame)
    _G.Logger:AddLog("✅ ***Protocole v6.2.3 Initialisé***", Color3.fromRGB(0, 255, 150))
end)

-- [ 5. BOUCLE DE FARMING ] -- 🔄
task.spawn(function()
    while task.wait() do
        if _G.Functions.Config.AutoFarm then
            -- Ta logique de farm habituelle ici
        end
    end
end)

UI:Notify("Système", "Omni-Elite v6.2.3 Ready. 🚀")