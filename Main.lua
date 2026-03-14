--[[
    FICHIER : Main.lua
    PROJET  : OMNI-PROJECT | BLOX FRUITS
    VERSION : v5.9.5 (ULTIMATE UI RECOVERY)
    MISE À JOUR : Async Injection + Safe-Bypass + UI Fix
]]

-- [ 1. INITIALISATION & ATTENTE SÉCURISÉE ] -- 🛡️
if not game:IsLoaded() then game.Loaded:Wait() end

local Player = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")

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
local Physics
pcall(function()
    Physics = _G.PhysicModule or loadstring(game:HttpGet("https://raw.githubusercontent.com/YuumaBoyz/omniui/refs/heads/main/PhysicModule.lua"))()
end)

_G.Functions = _G.Functions or {Config = {Speed = 300, AttackIncrement = 3}}
_G.SaveManager = _G.SaveManager or {Save = function() end, Load = function() return {} end}
_G.Logger = _G.Logger or {AddLog = function() end, Init = function() end}
_G.FruitSniper = _G.FruitSniper or {Config = {}}
_G.SafeRemoteFire = _G.SafeRemoteFire or function(...) end

-- Correctif Busy (Anti-Crash)
if not Player.Character:FindFirstChild("Busy") then
    local b = Instance.new("BoolValue", Player.Character); b.Name = "Busy"; b.Value = false
end

_G.CanDoubleJump = function()
    local busy = Player.Character:FindFirstChild("Busy")
    return busy and (busy.Value == false) or true
end

local UI = _G.Library
if not UI then warn("❌ Library UI manquante.") return end

-- [ 3. STRUCTURE DE L'INTERFACE (INSTANTANÉE) ] -- 🎨
local MainWin = UI:CreateWindow("OMNI-ELITE | v5.9.5 🛡️")

local Tabs = {
    Combat   = MainWin:CreateTab("⚔️ Combat"),
    Farming  = MainWin:CreateTab("🌾 Farming"),
    Fruits   = MainWin:CreateTab("🍎 Fruits"),
    Move     = MainWin:CreateTab("✈️ Mouvement"),
    Settings = MainWin:CreateTab("⚙️ Paramètres")
}

-- [ 4. INJECTION DES FONCTIONNALITÉS (ASYNCHRONE) ] -- 🛠️
task.spawn(function()
    task.wait(0.5) -- Délai de sécurité pour le rendu de l'UI

    -- --- COMBAT ---
    pcall(function()
        Tabs.Combat:CreateToggle("Fast Attack (Heartbeat)", "FastAttack", function(state) _G.Functions.Config.FastAttack = state end)
        Tabs.Combat:CreateSlider("Attack Speed", "AttackIncrement", 1, 10, _G.Functions.Config.AttackIncrement or 3, function(v) _G.Functions.Config.AttackIncrement = v end)
        Tabs.Combat:CreateToggle("🛡️ Auto-Defense (Haki/Ken)", "AutoDefense", function(state) _G.AutoHaki = state; _G.AutoKen = state end)
    end)

    -- --- FARMING ---
    pcall(function()
        Tabs.Farming:CreateToggle("🔥 Mode ELITE-FARM", "EliteFarm", function(state) _G.Functions.Config.EliteFarm = state end)
        Tabs.Farming:CreateToggle("📊 Auto-Stats", "AutoStats", function(state) _G.Functions.Config.AutoStats = state end)
        Tabs.Farming:CreateDropdown("Cible Stats", {"Melee", "Defense", "Sword", "Blox Fruit"}, function(s) _G.Functions.Config.TargetStat = s end)
    end)

    -- --- FRUITS ---
    pcall(function()
        Tabs.Fruits:CreateToggle("Fruit Sniper (Safe)", "SniperEnabled", function(state)
            _G.FruitSniper.Config.Enabled = state
            if state then task.spawn(function() pcall(function() _G.SafeRemoteFire("CollectedDragonEgg", true) end) end) end
        end)
    end)

    -- --- MOUVEMENT ---
    pcall(function()
        Tabs.Move:CreateSlider("Vitesse de Vol", "Speed", 50, 800, _G.Functions.Config.Speed or 300, function(v) _G.Functions.Config.Speed = v end)
        Tabs.Move:CreateToggle("Fly (Mode Vol)", "FlyEnabled", function(state)
            if _G.CanDoubleJump() and Physics then Physics:ToggleFly(state, _G.Functions.Config.Speed) end
        end)
        Tabs.Move:CreateToggle("☁️ Infinite Geppo", "InfGeppo", function(state) _G.InfiniteGeppo = state end)
        Tabs.Move:CreateToggle("👻 Noclip", "Noclip", function(state) _G.Noclip = state end)
    end)

    -- --- PARAMÈTRES ---
    pcall(function()
        Tabs.Settings:CreateButton("Modifier Keybind", function()
            UI:Notify("Keybind", "Appuyez sur une touche...")
            local c; c = UserInputService.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.Keyboard then MainWin:SetKeybind(i.KeyCode); c:Disconnect() end
            end)
        end)
        SettingsTab:CreateButton("💾 Sauvegarder Config", function() _G.SaveManager:Save(_G.Functions.Config) end)
    end)

    -- Initialisation Logs
    pcall(function()
        _G.Logger:Init(MainWin.MainFrame)
        _G.Logger:AddLog("✅ ***Moteur v5.9.5 injecté***", Color3.fromRGB(0, 255, 150))
    end)
end)

-- [ 5. DÉMARRAGE SERVICES ] -- ✨
task.spawn(function()
    pcall(function()
        local data = _G.SaveManager:Load()
        if data then for k,v in pairs(data) do _G.Functions.Config[k] = v end end
        if _G.Functions.Init then _G.Functions:Init() end
    end)
end)

UI:Notify("Système", "Protocole ***Omni-Elite*** prêt. 🚀")