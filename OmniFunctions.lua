--[[
    FICHIER : OmniFunctions.lua
    LOGIQUE : Immortal-Fusion + Dynamic Auto-Farm + Shielded Protocol
    VERSION : v5.0 (Final-Fusion & Anti-Crash)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local Functions = {
    Config = {
        -- Mouvement & Sniper
        Speed = 300,
        SniperEnabled = false,
        
        -- Combat & Core
        FastAttack = false,
        AutoClicker = false,
        MagneticMob = false,
        AttackDistance = 15,
        
        -- Elite Farm
        EliteFarm = false,
        AutoStats = false,
        TargetStat = "Melee",
        WeaponType = "Melee"
    },
    Player = Players.LocalPlayer,
    LastRemoteTick = 0,
    Framework = nil
}

-- [ 1. ACCÈS SÉCURISÉ AU FRAMEWORK (ANTI-CRASH) ] -- 🧠
local function GetCombatFramework()
    if Functions.Framework then return Functions.Framework end
    
    local success, result = pcall(function()
        local playerScripts = Functions.Player:WaitForChild("PlayerScripts", 10)
        -- Protection contre l'erreur 'not a valid member'
        return playerScripts:WaitForChild("CombatFramework", 20)
    end)

    if success and result then
        Functions.Framework = result
        return result
    else
        -- Notification non-bloquante
        if _G.Library then
            _G.Library:Notify("Système", "⚠️ Framework introuvable (Chargement lent...)", Color3.fromRGB(255, 100, 100))
        end
        return nil
    end
end

-- Récupération du Controller via GC
local function GetCombatController()
    local success, controller = pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "activeController") then 
                return v.activeController 
            end
        end
    end)
    return success and controller or nil
end

-- [ 2. REMOTE SECURITY : DEBOUNCE 0.1s ] -- 🛡️
local function SafeRemote(action, ...)
    local now = tick()
    -- Délai impératif de 0.1s pour éviter les détections
    if (now - Functions.LastRemoteTick) < 0.1 then
        task.wait(0.1 - (now - Functions.LastRemoteTick))
    end
    
    local success, response = pcall(function(...)
        local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if remote then
            Functions.LastRemoteTick = tick()
            return remote:InvokeServer(unpack({...}))
        end
    end, action, ...)

    return success and response or nil
end

-- [ 3. MOUVEMENT : SAFE-TWEEN ] -- ✈️
function Functions:SafeTween(targetCFrame)
    pcall(function()
        local char = self.Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local distance = (targetCFrame.p - root.Position).Magnitude
        if distance < 10 then root.CFrame = targetCFrame return end

        local info = TweenInfo.new(distance / self.Config.Speed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(root, info, {CFrame = targetCFrame})
        
        -- Noclip invisible pendant le trajet
        local noclip = RunService.Stepped:Connect(function()
            if char then
                for _, p in pairs(char:GetChildren()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)

        tween:Play()
        tween.Completed:Wait()
        noclip:Disconnect()
    end)
end

-- [ 4. DYNAMIC QUEST FINDER ] -- 🔍
function Functions:GetDynamicQuest()
    local myLevel = self.Player.Data.Level.Value
    local bestNpc = nil
    local maxLevelFound = -1

    pcall(function()
        for _, npc in pairs(Workspace.NPCs:GetChildren()) do
            if npc.Name:find("Quest Giver") then
                local npcLevel = tonumber(npc.Name:match("%d+")) or 0 
                if myLevel >= npcLevel and npcLevel > maxLevelFound then
                    maxLevelFound = npcLevel
                    bestNpc = npc
                end
            end
        end
    end)
    return bestNpc
end

-- [ 5. MODULE ELITE FARM (IMMORTAL) ] -- 🌾
function Functions:StartEliteFarm()
    task.spawn(function()
        while true do
            task.wait(1)
            if not self.Config.EliteFarm then continue end

            pcall(function()
                local char = self.Player.Character
                if not char or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
                    return 
                end

                local questUI = self.Player.PlayerGui.Main:FindFirstChild("Quest")
                if not questUI or not questUI.Visible then
                    -- 1. Aller chercher la quête
                    local targetNpc = self:GetDynamicQuest()
                    if targetNpc then
                        self:SafeTween(targetNpc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                        task.wait(0.5)
                        SafeRemote("StartQuest", "BanditQuest1", 1) -- Adaptatif via Remote
                    end
                else
                    -- 2. Farm les mobs
                    local title = questUI.Container.QuestTitle.Title.Text
                    local targetMobName = title:match("Defeat %d+ (.+)")
                    targetMobName = targetMobName and targetMobName:gsub(" %s*%(.*%)", ""):sub(1, -2) 

                    local targetMob = nil
                    for _, m in pairs(Workspace.Enemies:GetChildren()) do
                        if m.Name:find(targetMobName or "") and m:FindFirstChild("HumanoidRootPart") then
                            targetMob = m
                            break
                        end
                    end

                    if targetMob then
                        self.Config.FastAttack = true
                        self.Config.MagneticMob = true
                        
                        -- Positionnement "Sky-Farm" sécurisé
                        char.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)
                        
                        -- Auto-Stats
                        if self.Config.AutoStats then
                            local p = self.Player.Data.StatsPoints.Value
                            if p > 0 then SafeRemote("AddPoint", self.Config.TargetStat, p) end
                        end
                    end
                end
            end)
        end
    end)
end

-- [ 6. CORE COMBAT LOOPS ] -- ⚔️
function Functions:EnableFastAttack()
    task.spawn(function()
        while true do
            task.wait()
            if not self.Config.FastAttack then continue end
            
            pcall(function()
                local framework = GetCombatFramework()
                local c = GetCombatController()
                
                if c then 
                    c.attackInterval = 0 
                    c.hitboxMagnitude = 60 
                end
                
                -- Anti-Animation
                local char = self.Player.Character
                if char and char:FindFirstChild("Humanoid") then
                    for _, t in pairs(char.Humanoid:GetPlayingAnimationTracks()) do
                        if t.Name:find("Attack") or t.Name:find("Slash") then t:Stop() end
                    end
                end
            end)
        end
    end)
end

function Functions:StartAutoClick()
    task.spawn(function()
        while true do
            task.wait(0.01)
            if not self.Config.AutoClicker then continue end
            pcall(function()
                local c = GetCombatController()
                if c and self.Player.Character:FindFirstChildOfClass("Tool") then
                    task.spawn(function() c:attack() end)
                end
            end)
        end
    end)
end

-- [ 7. EXPORTATION ] -- ✨
_G.Functions = Functions
return Functions