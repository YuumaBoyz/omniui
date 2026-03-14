--[[
    OMNI-PROJECT | BLOX FRUITS 
    VERSION : v6.3.0 (PREMIUM UNIFIED)
    STATUS  : STABLE & OPTIMIZED
]]

-- [ 0. PROTECTION ET NETTOYAGE ] -- 🛡️
local function SafelyDestroy(name)
    local ui = game:GetService("CoreGui"):FindFirstChild(name)
    if ui then ui:Destroy() end
end
SafelyDestroy("OmniUI_Elite")

if not game:IsLoaded() then game.Loaded:Wait() end

-- [ 1. INITIALISATION DES GLOBALES ] -- ⚙️
_G.Functions = {Config = {
    AutoFarm = false,
    FastAttack = false,
    AutoClick = false,
    Speed = 300,
    FruitSniper = false
}}

-- [ 2. CHARGEMENT SÉCURISÉ DES MODULES ] -- 📦
local function LoadModule(name, url)
    local success, result = pcall(function() 
        return loadstring(game:HttpGet(url))() 
    end)
    if success and result then
        if _G.Logger then _G.Logger:AddLog("✅ " .. name .. " injecté.", Color3.fromRGB(0, 255, 100)) end
        return result
    else
        warn("⚠️ Erreur sur " .. name .. " -> " .. tostring(result))
        return nil
    end
end

-- Ordre de chargement critique
_G.Logger = LoadModule("OmniLogger", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/OmniLogger.lua")
_G.Library = LoadModule("OmniUILibrary", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/OmniUILibrary.lua")

-- Suite des modules
_G.Physics = LoadModule("Physics", "https://raw.githubusercontent.com/YuumaBoyz/omniui/refs/heads/main/PhysicModule.lua")
_G.FastAttackModule = LoadModule("FastAttack", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/FastAttack.lua")
_G.AutoSkill = LoadModule("AutoSkill", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/AutoSkill.lua")
_G.Aimbot = LoadModule("Aimbot", "https://raw.githubusercontent.com/YuumaBoyz/omniui/refs/heads/main/OmniAimbot.lua")

-- [ 3. CONSTRUCTION DE L'INTERFACE ] -- 🎨
local UI = _G.Library
if not UI then return end

local MainWin = UI:CreateWindow("OMNI-ELITE | PREMIUM 🛡️")
local Tabs = {
    Combat   = MainWin:CreateTab("⚔️ Combat"),
    Farming  = MainWin:CreateTab("🌾 Farming"),
    Move     = MainWin:CreateTab("✈️ Mouvement"),
    Settings = MainWin:CreateTab("⚙️ Paramètres")
}

-- [ 4. CONFIGURATION DES ONGLETS ] -- 🛠️
-- Initialise le Logger dans la frame
if _G.Logger then _G.Logger:Init(MainWin.MainFrame) end

-- COMBAT
Tabs.Combat:CreateToggle("⚡ Fast Attack (Overdrive)", "FastAttack", function(state)
    _G.FastAttack = state
    if _G.FastAttackModule then _G.FastAttackModule.Enabled = state end
end)

Tabs.Combat:CreateToggle("🖱️ Auto-Clicker", "AutoClick", function(state)
    _G.AutoClick = state
end)

Tabs.Combat:CreateToggle("🪄 Auto-Skill (Z,X,C,V)", "AutoSkill", function(state)
    if _G.AutoSkill then _G.AutoSkill.Enabled = state end
end)

-- MOUVEMENT
Tabs.Move:CreateSlider("Vitesse de Vol", "FlySpeed", 50, 800, 300, function(v) _G.Functions.Config.Speed = v end)
Tabs.Move:CreateToggle("✈️ Activer le Vol", "Fly", function(state)
    if _G.Physics and _G.Physics.ToggleFly then 
        _G.Physics:ToggleFly(state, _G.Functions.Config.Speed) 
    end
end)

UI:Notify("Système", "Omni-Project Premium Ready ! 🚀")