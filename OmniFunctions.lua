--[[
    FICHIER : OmniFunctions.lua
    LOGIQUE : Immortal-Fusion + Dynamic Auto-Farm
    VERSION : v4.8 (Dynamic-Quest & Safe-Movement)
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
}

-- [ 1. SECURITY & UTILS ] -- 🛡️
local function SafeRemote(action, ...)
    local now = tick()
    if (now - Functions.LastRemoteTick) < 0.25 then task.wait(0.25) end
    local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
    if remote then
        Functions.LastRemoteTick = tick()
        return remote:InvokeServer(action, ...)
    end
end

local function GetCombatController()
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "activeController") then return v.activeController end
    end
end

-- [ 2. MOUVEMENT : SAFE-TWEEN ] -- ✈️
function Functions:SafeTween(targetCFrame)
    local char = self.Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local distance = (targetCFrame.p - root.Position).Magnitude
    if distance < 10 then root.CFrame = targetCFrame return end

    local info = TweenInfo.new(distance / self.Config.Speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, info, {CFrame = targetCFrame})
    
    -- Ghost Mode pendant le vol
    local noclip = RunService.Stepped:Connect(function()
        for _, p in pairs(char:GetChildren()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)

    tween:Play()
    tween.Completed:Wait()
    noclip:Disconnect()
end

-- [ 3. DYNAMIC QUEST FINDER ] -- 🔍
-- Cette fonction trouve la quête sans liste manuelle !
function Functions:GetDynamicQuest()
    local myLevel = self.Player.Data.Level.Value
    local bestQuest, bestNpc, mobName, questPos
    local maxLevelFound = -1

    -- On cherche dans les NPCs de quêtes du jeu
    for _, npc in pairs(Workspace.NPCs:GetChildren()) do
        if npc.Name:find("Quest Giver") then
            -- Extraction du niveau via le nom ou dialogue (logique Blox Fruit)
            -- Note : Ici on utilise une logique de proximité/nom pour l'exemple
            -- La plupart des Quest Givers ont des IDs de niveau croissants
            local npcLevel = tonumber(npc.Name:match("%d+")) or 0 
            
            if myLevel >= npcLevel and npcLevel > maxLevelFound then
                maxLevelFound = npcLevel
                bestNpc = npc
            end
        end
    end
    
    -- Fallback sur le dernier NPC de quête valide
    return bestNpc
end

-- [ 4. MODULE ELITE FARM (IMMORTAL) ] -- 🌾
function Functions:StartEliteFarm()
    task.spawn(function()
        while true do
            task.wait(1)
            if not self.Config.EliteFarm then continue end

            local char = self.Player.Character
            if not char or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
                self.Player.CharacterAdded:Wait()
                task.wait(2)
                continue
            end

            -- Vérification quête active via l'UI du jeu
            local questUI = self.Player.PlayerGui.Main:FindFirstChild("Quest")
            if not questUI or not questUI.Visible then
                -- 1. Trouver et aller au NPC
                local targetNpc = self:GetDynamicQuest()
                if targetNpc then
                    self:SafeTween(targetNpc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                    task.wait(0.5)
                    -- Simulation d'acceptation (Adapté aux Remotes Blox Fruit)
                    SafeRemote("StartQuest", "BanditQuest1", 1) -- Exemple, le nom est souvent lié au NPC
                end
            else
                -- 2. Localiser les mobs de la quête
                local targetMobName = questUI.Container.QuestTitle.Title.Text:match("Defeat %d+ (.+)")
                -- Nettoyage du nom (ex: "Bandits (Lv. 5)" -> "Bandit")
                targetMobName = targetMobName and targetMobName:gsub(" %s*%(.*%)", ""):sub(1, -2) 

                local targetMob = nil
                for _, m in pairs(Workspace.Enemies:GetChildren()) do
                    if m.Name:find(targetMobName or "") and m:FindFirstChild("HumanoidRootPart") then
                        targetMob = m
                        break
                    end
                end

                if targetMob then
                    -- 3. Farm !
                    self.Config.FastAttack = true
                    self.Config.MagneticMob = true
                    self.Config.AutoClicker = true
                    
                    -- Positionnement au-dessus du mob (Safe Farm)
                    root = char.HumanoidRootPart
                    root.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)
                    
                    -- Auto-Stats
                    if self.Config.AutoStats then
                        local p = self.Player.Data.StatsPoints.Value
                        if p > 0 then SafeRemote("AddPoint", self.Config.TargetStat, p) end
                    end
                end
            end
        end
    end)
end

-- [ 5. CORE LOOPS (RE-INJECTED) ] -- ⚔️
function Functions:EnableFastAttack()
    task.spawn(function()
        while true do
            task.wait()
            if not self.Config.FastAttack then continue end
            pcall(function()
                local c = GetCombatController()
                if c then c.attackInterval = 0 c.hitboxMagnitude = 60 end
                for _, t in pairs(self.Player.Character.Humanoid:GetPlayingAnimationTracks()) do
                    if t.Name:find("Attack") or t.Name:find("Slash") then t:Stop() end
                end
            end)
        end
    end)
end

_G.Functions = Functions
return Functions