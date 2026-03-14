--[[
    FICHIER : Main.lua
    PROJET  : OMNI-PROJECT | BLOX FRUITS
    VERSION : v6.2.0 (STABLE MASTER UNIFIED)
    PATCH   : Auto-Quest + Aimbot Sync + UI Recovery + Nil-Safety
]]

-- [ 1. INITIALISATION & SECURITÉ ] -- 🛡️
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

-- [ 2. SYSTÈME ANTI-CRASH UI ] -- 🩹
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

-- [ 3. MODULES & CHARGEMENT ] -- 📦
local function LoadModule(name, url)
    local success, result = pcall(function() return loadstring(game:HttpGet(url))() end)
    if not success then warn("⚠️ Échec du chargement : " .. name) end
    return success and result or nil
end

local Physics = LoadModule("Physics", "https://raw.githubusercontent.com/YuumaBoyz/omniui/refs/heads/main/PhysicModule.lua")
local SaveManager = LoadModule("SaveManager", "https://raw.githubusercontent.com/YuumaBoyz/omniui/main/OmniSaveManager.lua")
_G.Aimbot = LoadModule("Aimbot", "https://raw.githubusercontent.com/YuumaBoyz/omniui/refs/heads/main/OmniAimbot.lua")

-- Initialisation des Globales de Configuration
_G.Functions = _G.Functions or {Config = {
    AutoFarm = false,
    AutoQuest = false,
    SelectWeapon = "Melee",
    Speed = 300,
    AttackIncrement = 3,
    FastAttack = false,
    AimbotEnabled = false,
    MagneticMob = false
}}

_G.Logger = _G.Logger or {AddLog = function(msg, color) print("[OMNI]: "..tostring(msg)) end, Init = function() end}
_G.Noclip = false
_G.InfiniteGeppo = false

-- Récupération Library
local UI = _G.Library
if not UI then warn("❌ Library manquante.") return end

-- [ 4. STRUCTURE DE L'INTERFACE ] -- 🎨
local MainWin = UI:CreateWindow("OMNI-ELITE | v6.2.0 🛡️")
PatchUI()

local Tabs = {
    Combat   = MainWin:CreateTab("⚔️ Combat"),
    Farming  = MainWin:CreateTab("🌾 Farming"),
    Fruits   = MainWin:CreateTab("🍎 Fruits"),
    Move     = MainWin:CreateTab("✈️ Mouvement"),
    Settings = MainWin:CreateTab("⚙️ Paramètres")
}

-- [ 5. LOGIQUE DE QUÊTE (LEVEL-BASED) ] -- 📜
local function GetQuestData()
    local level = Player.Data.Level.Value
    if level < 10 then return {"Bandit", "Bandit Quest 1", 1}
    elseif level < 15 then return {"Monkey", "Monkey Quest 1", 1}
    else return {"Bandit", "Bandit Quest 1", 1} end -- Valeur par défaut
end

-- [ 6. INJECTION DES FONCTIONNALITÉS ] -- 🛠️
task.spawn(function()
    task.wait(0.5)

    -- --- SECTION : COMBAT ---
    pcall(function()
        Tabs.Combat:CreateToggle("Fast Attack (Heartbeat)", "FastAttack", function(state) _G.Functions.Config.FastAttack = state end)
        
        Tabs.Combat:CreateToggle("🎯 Aimbot Skill (Auto-Lock)", "AimbotEnabled", function(state)
            if _G.Aimbot then
                _G.Aimbot.Enabled = state
                _G.Logger:AddLog(state and "🎯 Aimbot Activé" or "⚪ Aimbot Désactivé")
            else
                UI:Notify("Erreur", "Module Aimbot non chargé.")
            end
        end)
        
        Tabs.Combat:CreateToggle("🧲 Magnetic Mob", "MagneticMob", function(state) _G.Functions.Config.MagneticMob = state end)
    end)

    -- --- SECTION : FARMING ---
    pcall(function()
        Tabs.Farming:CreateToggle("🔥 Start Auto-Farm", "AutoFarm", function(state) 
            _G.Functions.Config.AutoFarm = state 
            if state then _G.Logger:AddLog("🌾 Cycle de Farm Lancé", Color3.fromRGB(0, 255, 100)) end
        end)
        
        Tabs.Farming:CreateToggle("📜 Auto-Quest (PNJ)", "AutoQuest", function(state) 
            _G.Functions.Config.AutoQuest = state 
        end)

        Tabs.Farming:CreateDropdown("Arme à utiliser", {"Melee", "Sword", "Fruit"}, function(v) 
            _G.Functions.Config.SelectWeapon = v 
        end)
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
    _G.Logger:AddLog("✅ ***Omni-Elite Unified READY***", Color3.fromRGB(0, 255, 150))
end)

-- [ 7. BOUCLE PRINCIPALE (CORE EXECUTION) ] -- 🔄
task.spawn(function()
    while task.wait() do
        if _G.Functions.Config.AutoFarm then
            pcall(function()
                local questInfo = GetQuestData()
                local myQuest = Player.PlayerGui.Main:FindFirstChild("Quest")

                -- 1. Auto-Quest Check
                if _G.Functions.Config.AutoQuest and (not myQuest or not myQuest.Visible) then
                    _G.Logger:AddLog("Cherche Quête : " .. questInfo[2])
                    -- Optionnel : Code de téléportation vers le PNJ ici
                end

                -- 2. Recherche & Ciblage Mob
                for _, mob in pairs(workspace.Enemies:GetChildren()) do
                    if (mob.Name == questInfo[1] or not _G.Functions.Config.AutoQuest) and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                            -- Téléportation de Farm
                            Player.Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)
                            
                            -- Équipement automatique
                            local tool = Player.Backpack:FindFirstChild(_G.Functions.Config.SelectWeapon) or Player.Character:FindFirstChild(_G.Functions.Config.SelectWeapon)
                            if tool and not Player.Character:FindFirstChild(tool.Name) then
                                Player.Character.Humanoid:EquipTool(tool)
                            end

                            -- Synchronisation Aimbot
                            if _G.Aimbot and _G.Aimbot.Enabled then 
                                _G.Aimbot.Target = mob 
                            end
                            break
                        end
                    end
                end
            end)
        end
    end
end)

-- [ 8. SERVICES & ANTI-NIL GUARDS ] -- ✨
RunService.Stepped:Connect(function()
    pcall(function()
        if _G.Noclip and Player.Character then
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end)

UI:Notify("Système", "Protocole ***Omni-Elite v6.2.0*** opérationnel. 🚀")