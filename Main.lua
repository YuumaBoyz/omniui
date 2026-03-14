--[[
    FICHIER : Main.lua
    PROJET  : OMNI-PROJECT | BLOX FRUITS
    VERSION : v5.9.6 (AIMBOT INTEGRATION)
    MISE À JOUR : Full PhysicModule + OmniAimbot + UI Recovery
]]

-- [ 1. INITIALISATION & ATTENTE SÉCURISÉE ] -- 🛡️
if not game:IsLoaded() then game.Loaded:Wait() end

local Player = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local function SafeCharacterWait()
    local timeout = 0
    while not (Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")) and timeout < 20 do
        task.wait(0.5)
        timeout = timeout + 1
    end
    return Player.Character ~= nil
end

if not SafeCharacterWait() then return end

-- [ 2. MODULES & GLOBALES ] -- 📦
local SaveManager = _G.SaveManager or loadstring(game:HttpGet("https://raw.githubusercontent.com/YuumaBoyz/omniui/main/OmniSaveManager.lua"))()

-- Chargement du PhysicModule
local Physics
pcall(function()
    Physics = _G.PhysicModule or loadstring(game:HttpGet("https://raw.githubusercontent.com/YuumaBoyz/omniui/refs/heads/main/PhysicModule.lua"))()
end)

-- *** NOUVEAU : Chargement de l'Aimbot *** 🎯
pcall(function()
    _G.Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/YuumaBoyz/omniui/refs/heads/main/OmniAimbot.lua"))()
end)

_G.Functions = _G.Functions or {Config = {
    Speed = 300, 
    AttackIncrement = 3, 
    AttackDistance = 10,
    EliteFarm = false,
    AutoStats = false,
    TargetStat = "Melee",
    MagneticMob = false,
    FastAttack = false,
    AimbotEnabled = false -- Valeur par défaut
}}

_G.Logger = _G.Logger or {AddLog = function(msg, color) print("[LOG]: " .. tostring(msg)) end, Init = function() end}
_G.FruitSniper = _G.FruitSniper or {Config = {Enabled = false}}
_G.SafeRemoteFire = _G.SafeRemoteFire or function(...) end

-- États de mouvement
_G.Noclip = false
_G.InfiniteGeppo = false

-- Récupération de la Library UI
local UI = _G.Library
if not UI then 
    warn("❌ Library UI manquante.") 
    return 
end

-- [ 3. STRUCTURE DE L'INTERFACE ] -- 🎨
local MainWin = UI:CreateWindow("OMNI-ELITE | v5.9.6 🛡️")

-- HOT-FIX : Récupération UI
pcall(function()
    local OmniUI = CoreGui:FindFirstChild("OmniUI_Elite")
    if OmniUI then
        local Canvas = OmniUI:FindFirstChildOfClass("CanvasGroup")
        if Canvas and not Canvas:FindFirstChild("BlocksInteraction") then
            local Fixer = Instance.new("Frame", Canvas)
            Fixer.Name = "BlocksInteraction"; Fixer.Visible = false
        end
    end
end)

local Tabs = {
    Combat   = MainWin:CreateTab("⚔️ Combat"),
    Farming  = MainWin:CreateTab("🌾 Farming"),
    Fruits   = MainWin:CreateTab("🍎 Fruits"),
    Move     = MainWin:CreateTab("✈️ Mouvement"),
    Settings = MainWin:CreateTab("⚙️ Paramètres")
}

-- [ 4. INJECTION DES FONCTIONNALITÉS ] -- 🛠️
task.spawn(function()
    task.wait(0.5)

    -- --- SECTION : COMBAT ---
    pcall(function()
        Tabs.Combat:CreateToggle("Fast Attack (Heartbeat)", "FastAttack", function(state) _G.Functions.Config.FastAttack = state end)
        
        -- *** INTEGRATION AIMBOT *** 🎯
        Tabs.Combat:CreateToggle("🎯 Aimbot Skill (Auto-Lock)", "AimbotEnabled", function(state)
            if _G.Aimbot then
                _G.Aimbot.Enabled = state
                _G.Logger:AddLog(state and "🎯 Aimbot Activé" or "⚪ Aimbot Désactivé", state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(200, 200, 200))
            else
                UI:Notify("Erreur", "Module Aimbot non chargé.")
            end
        end)

        Tabs.Combat:CreateSlider("Attack Speed", "AttackIncrement", 1, 10, _G.Functions.Config.AttackIncrement, function(v) _G.Functions.Config.AttackIncrement = v end)
        Tabs.Combat:CreateToggle("🧲 Magnetic Mob", "MagneticMob", function(state) _G.Functions.Config.MagneticMob = state end)
    end)

    -- --- SECTION : MOUVEMENT ---
    pcall(function()
        Tabs.Move:CreateSlider("Vitesse de Vol", "Speed", 50, 800, _G.Functions.Config.Speed, function(v) 
            _G.Functions.Config.Speed = v 
            if _G.Flying and Physics and Physics.UpdateSpeed then Physics:UpdateSpeed(v) end
        end)
        
        Tabs.Move:CreateToggle("Fly (Mode Vol)", "FlyEnabled", function(state)
            if Physics and Physics.ToggleFly then 
                Physics:ToggleFly(state, _G.Functions.Config.Speed) 
            else
                UI:Notify("Erreur", "PhysicModule non détecté.")
            end
        end)
        
        Tabs.Move:CreateToggle("☁️ Infinite Geppo", "InfGeppo", function(state) _G.InfiniteGeppo = state end)
        
        Tabs.Move:CreateToggle("👻 Noclip (Ghost)", "Noclip", function(state) 
            _G.Noclip = state 
            if not state and Player.Character then
                for _, v in pairs(Player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = true end
                end
            end
        end)
    end)

    -- --- SECTION : PARAMÈTRES ---
    pcall(function()
        Tabs.Settings:CreateButton("💾 Sauvegarder Config", function() 
            SaveManager:Save(_G.Functions.Config) 
            UI:Notify("Sauvegarde", "Configuration enregistrée !")
        end)
    end)

    _G.Logger:Init(MainWin.MainFrame)
    _G.Logger:AddLog("✅ ***Omni-Elite v5.9.6 Sync***", Color3.fromRGB(0, 255, 150))
end)

-- [ 5. LOGIQUE CORE & SERVICES ] -- ✨
RunService.Stepped:Connect(function()
    if _G.InfiniteGeppo and Player.Character then
        pcall(function() Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
    
    if _G.Noclip and Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Chargement Auto des données
task.spawn(function()
    local data = SaveManager:Load()
    if data then 
        for k, v in pairs(data) do _G.Functions.Config[k] = v end 
    end
    -- Appliquer l'état de l'Aimbot si déjà activé dans la config
    if _G.Aimbot then _G.Aimbot.Enabled = _G.Functions.Config.AimbotEnabled end
end)

UI:Notify("Système", "Protocole ***Omni-Elite*** prêt. 🚀")