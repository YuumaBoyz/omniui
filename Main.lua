--[[
    OMNI-PROJECT | BLOX FRUITS 
    VERSION : v6.5.0 (ERROR-FREE EDITION)
]]

-- [ 0. ATTENTE DU CHARGEMENT ] -- ⏳
if not game:IsLoaded() then game.Loaded:Wait() end

-- [ 1. INITIALISATION DES GLOBALES ] -- ⚙️
_G.Functions = {Config = {
    AutoFarm = false, AutoQuest = false, FastAttack = false,
    AutoClick = false, TargetStat = "Melee", Speed = 300
}}

-- [ 2. LOADER AVEC VÉRIFICATION DE DISPONIBILITÉ ] -- 📦
local function SafeLoad(name, url)
    local success, result = pcall(function() return loadstring(game:HttpGet(url))() end)
    if success and result then return result end
    warn("⚠️ Erreur de chargement sur : " .. name)
    return nil
end

-- Chargement de la librairie en priorité absolue
_G.Library = SafeLoad("Library", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/OmniUILibrary.lua")
repeat task.wait() until _G.Library -- Sécurité anti-nil

-- [ 3. CONSTRUCTION DE L'INTERFACE ] -- 🎨
local UI = _G.Library
local MainWin = UI:CreateWindow("OMNI-ELITE | PREMIUM 🛡️")

-- Chargement du Logger APRÈS la création de la fenêtre
_G.Logger = SafeLoad("Logger", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/OmniLogger.lua")
if _G.Logger then _G.Logger:Init(MainWin.MainFrame) end

-- [ 4. DÉFINITION DES ONGLETS ] -- 🛠️
local Tabs = {
    Combat   = MainWin:CreateTab("⚔️ Combat"),
    Farming  = MainWin:CreateTab("🌾 Farming"),
    Move     = MainWin:CreateTab("✈️ Mouvement"),
    Settings = MainWin:CreateTab("⚙️ Paramètres")
}

-- [ 5. INJECTION DES MODULES DE COMBAT ] -- 🥊
_G.FastAttackModule = SafeLoad("FastAttack", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/FastAttack.lua")
_G.AutoSkill = SafeLoad("AutoSkill", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/AutoSkill.lua")

Tabs.Combat:CreateToggle("⚡ Fast Attack Overdrive", "FastAttack", function(state) _G.FastAttack = state end)
Tabs.Combat:CreateToggle("🖱️ Auto-Clicker", "AutoClick", function(state) _G.AutoClick = state end)
Tabs.Combat:CreateToggle("🪄 Auto-Skill (Z,X,C,V)", "AutoSkill", function(state) if _G.AutoSkill then _G.AutoSkill.Enabled = state end end)

-- [ 6. SECTION FARMING (CORRECTIF MÉTHODES) ] -- 🚜
Tabs.Farming:CreateToggle("🔥 Auto-Farm", "AutoFarm", function(state) _G.Functions.Config.AutoFarm = state end)

-- Correction 'CreateSeparator' : Si la méthode n'existe pas, on utilise un Label vide
if pcall(function() Tabs.Farming:CreateSeparator() end) == false then
    Tabs.Farming:CreateLabel("──────────────")
end

Tabs.Farming:CreateDropdown("Stat à monter", {"Melee", "Defense", "Sword", "Blox Fruit"}, function(v) _G.Functions.Config.TargetStat = v end)
Tabs.Farming:CreateToggle("📈 Auto-Stats", "AutoStats", function(state) _G.AutoStats = state end)

-- [ 7. MOUVEMENT & SETTINGS ] -- ✈️
_G.Physics = SafeLoad("Physics", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/PhysicModule.lua")

Tabs.Move:CreateSlider("Vitesse", "FlySpeed", 50, 800, 300, function(v) _G.Functions.Config.Speed = v end)
Tabs.Move:CreateToggle("✈️ Fly", "Fly", function(state) if _G.Physics then _G.Physics:ToggleFly(state, _G.Functions.Config.Speed) end end)

Tabs.Settings:CreateButton("🌐 Server Hop", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/YuumaBoyz/omniui/main/ServerHop.lua"))() end)

if _G.Logger then _G.Logger:AddLog("✅ ***Omni-Elite v6.5.0 : Prêt***", Color3.fromRGB(0, 255, 150)) end