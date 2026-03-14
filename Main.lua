--[[
    FICHIER : Main.lua
    PROJET  : OMNI-PROJECT | BLOX FRUITS
    VERSION : v5.9.5 (ULTIMATE UI RECOVERY)
    MISE À JOUR : Sync OmniSaveManager + Auto-Load Logic
]]

-- [ 1. INITIALISATION & ATTENTE SÉCURISÉE ] -- 🛡️
if not game:IsLoaded() then game.Loaded:Wait() end

local Player = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

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
-- Chargement du SaveManager en premier
local SaveManager = _G.SaveManager or loadstring(game:HttpGet("https://raw.githubusercontent.com/YuumaBoyz/omniui/main/OmniSaveManager.lua"))()

local Physics
pcall(function()
    Physics = _G.PhysicModule or loadstring(game:HttpGet("https://raw.githubusercontent.com/YuumaBoyz/omniui/refs/heads/main/PhysicModule.lua"))()
end)

-- Initialisation des tables avec valeurs par défaut
_G.Functions = _G.Functions or {Config = {
    Speed = 300, 
    AttackIncrement = 3, 
    AttackDistance = 10,
    EliteFarm = false,
    AutoStats = false,
    TargetStat = "Melee",
    MagneticMob = false,
    FastAttack = false
}}

_G.Logger = _G.Logger or {AddLog = function(msg, color) print("[LOG]: " .. tostring(msg)) end, Init = function() end}
_G.FruitSniper = _G.FruitSniper or {Config = {Enabled = false}}
_G.SafeRemoteFire = _G.SafeRemoteFire or function(...) end

-- Correctif Busy (Anti-Crash/Anti-Stun)
if not Player.Character:FindFirstChild("Busy") then
    local b = Instance.new("BoolValue", Player.Character); b.Name = "Busy"; b.Value = false
end

_G.CanDoubleJump = function()
    local busy = Player.Character:FindFirstChild("Busy")
    return busy and (busy.Value == false) or true
end

-- Récupération de la Library UI
local UI = _G.Library
if not UI then 
    warn("❌ Library UI manquante. Assurez-vous de charger la Library avant le Main.") 
    return 
end

-- [ 3. STRUCTURE DE L'INTERFACE ] -- 🎨
local MainWin = UI:CreateWindow("OMNI-ELITE | v5.9.5 🛡️")

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
        Tabs.Combat:CreateSlider("Attack Speed", "AttackIncrement", 1, 10, _G.Functions.Config.AttackIncrement, function(v) _G.Functions.Config.AttackIncrement = v end)
        Tabs.Combat:CreateToggle("🧲 Magnetic Mob (v2.5)", "MagneticMob", function(state) _G.Functions.Config.MagneticMob = state end)
        Tabs.Combat:CreateSlider("Distance Magnet", "MagnetDist", 5, 50, _G.Functions.Config.AttackDistance, function(v) _G.Functions.Config.AttackDistance = v end)
        Tabs.Combat:CreateToggle("🛡️ Auto-Defense (Haki/Ken)", "AutoDefense", function(state) _G.AutoHaki = state; _G.AutoKen = state end)
    end)

    -- --- SECTION : FARMING ---
    pcall(function()
        Tabs.Farming:CreateToggle("🔥 Mode ELITE-FARM", "EliteFarm", function(state) _G.Functions.Config.EliteFarm = state end)
        Tabs.Farming:CreateToggle("📊 Auto-Stats", "AutoStats", function(state) _G.Functions.Config.AutoStats = state end)
        Tabs.Farming:CreateDropdown("Cible Stats", {"Melee", "Defense", "Sword", "Blox Fruit"}, function(s) _G.Functions.Config.TargetStat = s end)
    end)

    -- --- SECTION : FRUITS ---
    pcall(function()
        Tabs.Fruits:CreateToggle("Fruit Sniper (Safe)", "SniperEnabled", function(state)
            _G.FruitSniper.Config.Enabled = state
            _G.Functions.Config.FruitSniper = state
            if state then _G.Logger:AddLog("🍎 Sniper activé", Color3.fromRGB(0, 255, 255)) end
        end)
        Tabs.Fruits:CreateButton("🍎 Collecter Fruits (Instant)", function()
            pcall(function() _G.SafeRemoteFire("CollectedDragonEgg", true) end)
        end)
    end)

    -- --- SECTION : MOUVEMENT ---
    pcall(function()
        Tabs.Move:CreateSlider("Vitesse de Vol", "Speed", 50, 800, _G.Functions.Config.Speed, function(v) _G.Functions.Config.Speed = v end)
        Tabs.Move:CreateToggle("Fly (Mode Vol)", "FlyEnabled", function(state)
            if Physics and Physics.ToggleFly then 
                Physics:ToggleFly(state, _G.Functions.Config.Speed) 
            else
                UI:Notify("Erreur", "Module Physique non chargé.")
            end
        end)
        Tabs.Move:CreateToggle("☁️ Infinite Geppo", "InfGeppo", function(state) _G.InfiniteGeppo = state end)
        Tabs.Move:CreateToggle("👻 Noclip", "Noclip", function(state) _G.Noclip = state end)
    end)

    -- --- SECTION : PARAMÈTRES ---
    pcall(function()
        Tabs.Settings:CreateButton("🔄 Server Hop (Recherche Serveur)", function()
            if _G.Functions.SmartHop then _G.Functions.SmartHop() else UI:Notify("Erreur", "Module ServerHop absent.") end
        end)
        Tabs.Settings:CreateButton("⌨️ Modifier Keybind", function()
            UI:Notify("Keybind", "Appuyez sur une touche pour l'UI...")
            local connection; connection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    MainWin:SetKeybind(input.KeyCode)
                    UI:Notify("Succès", "Nouveau Keybind : " .. tostring(input.KeyCode.Name))
                    connection:Disconnect()
                end
            end)
        end)
        -- Synchronisation directe avec le module SaveManager
        Tabs.Settings:CreateButton("💾 Sauvegarder Config", function() 
            SaveManager:Save(_G.Functions.Config) 
            UI:Notify("Sauvegarde", "Configuration enregistrée dans OmniElite_Config.json !")
        end)
    end)

    -- Initialisation des Logs dans l'UI
    pcall(function()
        _G.Logger:Init(MainWin.MainFrame)
        _G.Logger:AddLog("✅ ***Moteur v5.9.5 injecté***", Color3.fromRGB(0, 255, 150))
        _G.Logger:AddLog("💾 ***Config chargée***", Color3.fromRGB(200, 200, 255))
    end)
end)

-- [ 5. DÉMARRAGE DES SERVICES & CHARGEMENT AUTO ] -- ✨
task.spawn(function()
    pcall(function()
        -- Chargement de la config via OmniSaveManager
        local savedData = SaveManager:Load()
        if savedData then 
            for key, value in pairs(savedData) do 
                _G.Functions.Config[key] = value 
            end 
        end
        
        -- Lancement de la logique de combat/farm
        if _G.Functions.Init then 
            _G.Functions:Init() 
        end
    end)
end)

-- Boucle Physique (Stepped pour éviter les tremblements)
RunService.Stepped:Connect(function()
    if _G.InfiniteGeppo and Player.Character then
        pcall(function() Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
    if _G.Noclip and Player.Character then
        pcall(function()
            for _, v in pairs(Player.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
    end
end)

UI:Notify("Système", "Protocole ***Omni-Elite*** prêt. 🚀")