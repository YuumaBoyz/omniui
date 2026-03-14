--[[
    OMNI-PROJECT | BLOX FRUITS 
    VERSION : v6.4.0 (FULL INTEGRATION)
    STATUS  : READY 🚀
]]

-- [ 0. PROTECTION ] -- 🛡️
if not game:IsLoaded() then game.Loaded:Wait() end

-- [ 1. CONFIGURATION GLOBALE ] -- ⚙️
_G.Functions = {Config = {
    AutoFarm = false,
    AutoQuest = false,
    FastAttack = false,
    AutoClick = false,
    TargetStat = "Melee",
    Speed = 300,
    Distance = 60
}}

-- [ 2. CHARGEMENT DES MODULES ] -- 📦
local function LoadModule(name, url)
    local success, result = pcall(function() return loadstring(game:HttpGet(url))() end)
    if success and result then return result end
    warn("❌ Error loading: " .. name) return nil
end

_G.Library = LoadModule("Library", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/OmniUILibrary.lua")
_G.Logger = LoadModule("Logger", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/OmniLogger.lua")

-- Initialisation de l'interface
local UI = _G.Library
if not UI then return end
local MainWin = UI:CreateWindow("OMNI-ELITE | PREMIUM 🛡️")
if _G.Logger then _G.Logger:Init(MainWin.MainFrame) end

-- Chargement du reste des modules
_G.Aimbot = LoadModule("Aimbot", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/OmniAimbot.lua")
_G.FastAttackModule = LoadModule("FastAttack", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/FastAttack.lua")
_G.AutoSkill = LoadModule("AutoSkill", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/AutoSkill.lua")
_G.Physics = LoadModule("Physics", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/PhysicModule.lua")
_G.QuestScanner = LoadModule("QuestScanner", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/OmniQuestScanner.lua")
_G.StatsMod = LoadModule("AutoStats", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/AutoStats.lua")
_G.Sniper = LoadModule("FruitSniper", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/FruitSniper.lua")
_G.Magnet = LoadModule("MagneticMob", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/MagneticMob.lua")

-- [ 3. TABS ] -- 🎨
local Tabs = {
    Combat   = MainWin:CreateTab("⚔️ Combat"),
    Farming  = MainWin:CreateTab("🌾 Farming"),
    Fruits   = MainWin:CreateTab("🍎 Fruits"),
    Move     = MainWin:CreateTab("✈️ Mouvement"),
    Settings = MainWin:CreateTab("⚙️ Paramètres")
}

-- [ 4. SECTION : COMBAT ] -- 🥊
Tabs.Combat:CreateToggle("⚡ Fast Attack Overdrive", "FastAttack", function(state) _G.FastAttack = state end)
Tabs.Combat:CreateToggle("🖱️ Auto-Clicker", "AutoClick", function(state) _G.AutoClick = state end)
Tabs.Combat:CreateToggle("🎯 Omni-Aimbot", "Aimbot", function(state) if _G.Aimbot then _G.Aimbot.Enabled = state end end)
Tabs.Combat:CreateToggle("🪄 Auto-Skill (Z,X,C,V)", "AutoSkill", function(state) if _G.AutoSkill then _G.AutoSkill.Enabled = state end end)
Tabs.Combat:CreateToggle("🛡️ Auto-Defense", "AutoDefense", function(state) _G.AutoDefense = state end)

-- [ 5. SECTION : FARMING ] -- 🚜
Tabs.Farming:CreateToggle("🔥 Start Auto-Farm", "AutoFarm", function(state) _G.Functions.Config.AutoFarm = state end)
Tabs.Farming:CreateToggle("📜 Auto-Quest Scanner", "AutoQuest", function(state) _G.Functions.Config.AutoQuest = state end)
Tabs.Farming:CreateToggle("🧲 Magnetic Mob", "Magnet", function(state) _G.MagneticMob = state end)
Tabs.Farming:CreateSeparator("📊 Statistiques")
Tabs.Farming:CreateDropdown("Stat à monter", {"Melee", "Defense", "Sword", "Blox Fruit"}, function(v) _G.Functions.Config.TargetStat = v end)
Tabs.Farming:CreateToggle("📈 Auto-Stats", "AutoStats", function(state) _G.AutoStats = state end)

-- [ 6. SECTION : FRUITS ] -- 🍎
Tabs.Fruits:CreateToggle("🎯 Fruit Sniper", "FruitSniper", function(state) _G.FruitSniper = state end)
Tabs.Fruits:CreateButton("📦 Store Fruits", function() if _G.Sniper then _G.Sniper:StoreAll() end end)

-- [ 7. SECTION : MOUVEMENT ] -- ✈️
Tabs.Move:CreateSlider("Vitesse", "FlySpeed", 50, 800, 300, function(v) _G.Functions.Config.Speed = v end)
Tabs.Move:CreateToggle("✈️ Fly", "Fly", function(state) if _G.Physics then _G.Physics:ToggleFly(state, _G.Functions.Config.Speed) end end)
Tabs.Move:CreateToggle("👻 NoClip", "NoClip", function(state) if _G.Physics then _G.Physics:ToggleNoClip(state) end end)

-- [ 8. SECTION : SETTINGS ] -- ⚙️
Tabs.Settings:CreateButton("🌐 Server Hop (Low Player)", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/YuumaBoyz/omniui/main/ServerHop.lua"))() end)
Tabs.Settings:CreateButton("💾 Save Config", function() if _G.SaveManager then _G.SaveManager:Save() end end)

_G.Logger:AddLog("✨ ***Omni-Project v6.4.0 Chargé avec succès***", Color3.fromRGB(0, 255, 150))
UI:Notify("Système", "Protocole Omni-Elite activé. Bonne chasse ! 🚀")