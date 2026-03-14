--[[
    FICHIER : Main.lua
    VERSION : v6.2.3 (FIXED MODULE LOADING)
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
    FruitSniper = false
}}

_G.Logger = _G.Logger or {AddLog = function(msg, color) print("[OMNI]: "..tostring(msg)) end, Init = function() end}

-- [ 2. CHARGEMENT SÉCURISÉ DES MODULES ] -- 📦
local function LoadModule(name, url)
    local success, result = pcall(function() return loadstring(game:HttpGet(url))() end)
    if success and result then
        _G.Logger:AddLog("✅ Module chargé : " .. name, Color3.fromRGB(0, 255, 100))
        return result
    else
        warn("⚠️ Échec du chargement : " .. name)
        return nil
    end
end

-- Correction CRITIQUE : Assignation aux variables globales
_G.AutoSkill = LoadModule("AutoSkill", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/AutoSkill.lua")
if _G.AutoSkill then _G.AutoSkill:Init() end
_G.Physics = LoadModule("Physics", "https://raw.githubusercontent.com/YuumaBoyz/omniui/refs/heads/main/PhysicModule.lua")
_G.SaveManager = LoadModule("SaveManager", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/OmniSaveManager.lua")
_G.AutoStatsMod = LoadModule("AutoStats", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/AutoStats.lua")
_G.ServerHopMod = LoadModule("ServerHop", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/ServerHop.lua")
_G.FruitSniperMod = LoadModule("FruitSniper", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/FruitSniper.lua")
_G.Aimbot = LoadModule("Aimbot", "https://raw.githubusercontent.com/YuumaBoyz/omniui/refs/heads/main/OmniAimbot.lua")

-- [ 3. INTERFACE UTILISATEUR ] -- 🎨
local UI = _G.Library
if not UI then return warn("❌ Library manquante.") end

local MainWin = UI:CreateWindow("OMNI-ELITE | v6.2.3 🛡️")

local Tabs = {
    Combat   = MainWin:CreateTab("⚔️ Combat"),
    Farming  = MainWin:CreateTab("🌾 Farming"),
    Fruits   = MainWin:CreateTab("🍎 Fruits"),
    Move     = MainWin:CreateTab("✈️ Mouvement"),
    Settings = MainWin:CreateTab("⚙️ Paramètres")
}

-- [ 4. INJECTION DES COMMANDES UI ] -- 🛠️
task.spawn(function()

    Tabs.Combat:CreateToggle("🪄 Auto-Skill (Z, X, C)", "AutoSkill", function(state)
        if _G.AutoSkill then 
            _G.AutoSkill.Enabled = state 
            _G.Logger:AddLog(state and "🪄 Auto-Skill ACTIVÉ" or "🛑 Auto-Skill DÉSACTIVÉ", state and Color3.new(0,1,0) or Color3.new(1,0,0))
        end
    end)
    -- --- SECTION : FARMING ---
    Tabs.Farming:CreateToggle("🔥 Start Auto-Farm", "AutoFarm", function(state) _G.Functions.Config.AutoFarm = state end)
    
    -- --- SECTION : MOUVEMENT ---
    Tabs.Move:CreateSlider("Vitesse", "Speed", 50, 800, _G.Functions.Config.Speed, function(v) _G.Functions.Config.Speed = v end)
    Tabs.Move:CreateToggle("Fly (Mode Vol)", "FlyEnabled", function(state)
        -- On utilise _G.Physics pour être sûr de pointer le bon module
        if _G.Physics and _G.Physics.ToggleFly then 
            _G.Physics:ToggleFly(state, _G.Functions.Config.Speed) 
        else
            UI:Notify("Erreur", "PhysicModule non disponible.")
        end
    end)

    -- --- SECTION : SETTINGS ---
    Tabs.Settings:CreateButton("💾 Save Configuration", function()
        if _G.SaveManager then 
            _G.SaveManager:Save(_G.Functions.Config) 
            UI:Notify("Système", "Configuration enregistrée !")
        end
    end)

    _G.Logger:Init(MainWin.MainFrame)
    _G.Logger:AddLog("✅ ***Protocole v6.2.3 Initialisé***", Color3.fromRGB(0, 255, 150))
end)

UI:Notify("Système", "Omni-Elite v6.2.3 Ready. 🚀")