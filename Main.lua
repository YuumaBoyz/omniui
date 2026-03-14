--[[
    FICHIER : Main.lua
    PROJET  : OMNI-PROJECT | BLOX FRUITS
    VERSION : v5.9.8 (STABLE UNIFIED)
    PATCH   : UI Recovery + Aimbot Sync + Anti-Nil Guard
]]

-- [ 1. INITIALISATION & ATTENTE SÉCURISÉE ] -- 🛡️
if not game:IsLoaded() then game.Loaded:Wait() end

local Player = game:GetService("Players").LocalPlayer
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

-- [ 2. SYSTÈME DE RÉCUPÉRATION UI (ANTI-BLOCK) ] -- 🩹
local function PatchUI()
    pcall(function()
        local OmniUI = CoreGui:FindFirstChild("OmniUI_Elite") or CoreGui:FindFirstChildOfClass("ScreenGui")
        if OmniUI then
            for _, Canvas in pairs(OmniUI:GetDescendants()) do
                if Canvas:IsA("CanvasGroup") and not Canvas:FindFirstChild("BlocksInteraction") then
                    local b = Instance.new("BoolValue", Canvas)
                    b.Name = "BlocksInteraction"
                    b.Value = false
                end
            end
        end
    end)
end

-- [ 3. MODULES & CHARGEMENT ROBUSTE ] -- 📦
local function LoadModule(name, url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success then return result end
    warn("⚠️ Erreur Module : " .. name)
    return nil
end

local SaveManager = LoadModule("SaveManager", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/OmniSaveManager.lua")
local Physics = LoadModule("Physics", "https://raw.githubusercontent.com/YuumaBoyz/omniui/refs/heads/main/PhysicModule.lua")
_G.Aimbot = LoadModule("Aimbot", "https://raw.githubusercontent.com/YuumaBoyz/omniui/refs/heads/main/OmniAimbot.lua")

-- Initialisation des Globales
_G.Functions = _G.Functions or {Config = {
    Speed = 300, 
    AttackIncrement = 3, 
    AttackDistance = 10,
    EliteFarm = false,
    AutoStats = false,
    TargetStat = "Melee",
    MagneticMob = false,
    FastAttack = false,
    AimbotEnabled = false
}}

_G.Logger = _G.Logger or {AddLog = function(msg, color) print("[LOG]: " .. tostring(msg)) end, Init = function() end}
_G.Noclip = false
_G.InfiniteGeppo = false

-- Récupération Library
local UI = _G.Library
if not UI then warn("❌ Library manquante.") return end

-- [ 4. STRUCTURE DE L'INTERFACE ] -- 🎨
local MainWin = UI:CreateWindow("OMNI-ELITE | v5.9.8 🛡️")
PatchUI() -- Force le patch immédiatement

local Tabs = {
    Combat   = MainWin:CreateTab("⚔️ Combat"),
    Farming  = MainWin:CreateTab("🌾 Farming"),
    Fruits   = MainWin:CreateTab("🍎 Fruits"),
    Move     = MainWin:CreateTab("✈️ Mouvement"),
    Settings = MainWin:CreateTab("⚙️ Paramètres")
}

-- [ 5. INJECTION DES FONCTIONNALITÉS ] -- 🛠️
task.spawn(function()
    task.wait(0.5)

    -- --- SECTION : COMBAT ---
    pcall(function()
        Tabs.Combat:CreateToggle("Fast Attack (Heartbeat)", "FastAttack", function(state) _G.Functions.Config.FastAttack = state end)
        
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
                UI:Notify("Erreur", "Module Physics absent.")
            end
        end)
        
        Tabs.Move:CreateToggle("☁️ Infinite Geppo", "InfGeppo", function(state) _G.InfiniteGeppo = state end)
        
        Tabs.Move:CreateToggle("👻 Noclip (Ghost)", "Noclip", function(state) _G.Noclip = state end)
    end)

    -- --- SECTION : PARAMÈTRES ---
    pcall(function()
        Tabs.Settings:CreateButton("💾 Sauvegarder Config", function() 
            if SaveManager then SaveManager:Save(_G.Functions.Config) end
            UI:Notify("Sauvegarde", "Configuration enregistrée !")
        end)
    end)

    _G.Logger:Init(MainWin.MainFrame)
    _G.Logger:AddLog("✅ ***Omni-Elite v5.9.8 Synced***", Color3.fromRGB(0, 255, 150))
end)

-- [ 6. LOGIQUE DE SÉCURITÉ & SERVICES ] -- ✨
RunService.Stepped:Connect(function()
    -- Geppo Nil-Safe
    if _G.InfiniteGeppo and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end
    
    -- Noclip Nil-Safe
    if _G.Noclip and Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- [ 7. CHARGEMENT FINAL ] -- 🚀
task.spawn(function()
    if SaveManager then
        local data = SaveManager:Load()
        if data then 
            for k, v in pairs(data) do _G.Functions.Config[k] = v end 
        end
    end
    if _G.Aimbot then _G.Aimbot.Enabled = _G.Functions.Config.AimbotEnabled end
end)

UI:Notify("Système", "Protocole ***Omni-Elite v5.9.8*** stable. 🚀")