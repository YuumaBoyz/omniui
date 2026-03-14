--[[
    FICHIER : OmniFunctions.lua
    VERSION : v5.4 (Omni-Fusion & Physics Master)
    LOGIQUE : Neutralisation complète + Heartbeat Sync + Elite Farm
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local Functions = {
    Config = {
        -- Mouvement & Sniper
        Speed = 300,
        SniperEnabled = false,
        
        -- Combat & Core
        FastAttack = false,
        AttackIncrement = 3,
        AutoClicker = false,
        MagneticMob = false,
        AttackDistance = 10,
        
        -- Elite Farm
        EliteFarm = false,
        AutoStats = false,
        TargetStat = "Melee", 
        WeaponType = "Melee" 
    },
    Player = Players.LocalPlayer,
    LastRemoteTick = 0,
    Framework = nil,
    Controller = nil 
}

-- [ 1. ACCÈS SÉCURISÉ AU FRAMEWORK & CONTROLLER ] -- 🧠
local function GetCombatController()
    if Functions.Controller then return Functions.Controller end
    local success, controller = pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "activeController") then 
                Functions.Controller = v.activeController
                return v.activeController 
            end
        end
    end)
    return success and controller or nil
end

-- [ 2. OPTIMISATION FPS : DISABLE DAMAGE INDICATORS ] -- 📉
local function OptimizeVisuals(state)
    pcall(function()
        local mainUI = Functions.Player.PlayerGui:FindFirstChild("Main")
        if mainUI and mainUI:FindFirstChild("DamageIndicators") then
            mainUI.DamageIndicators.Visible = not state
        end
    end)
end

-- [ 3. NEUTRALISEUR DE PHYSIQUE (ANTI-FLING) ] -- 🛡️
local function NeutralizePhysics(mob)
    local root = mob:FindFirstChild("HumanoidRootPart")
    local hum = mob:FindFirstChildOfClass("Humanoid")
    
    if root and hum then
        -- On rend le mob immatériel pour éviter les glitchs de collision
        root.CanCollide = false
        root.Size = Vector3.new(0.001, 0.001, 0.001)
        root.Velocity = Vector3.new(0, 0, 0)
        
        -- Paralysie totale
        hum.PlatformStand = true 
        hum.WalkSpeed = 0
        
        for _, part in pairs(mob:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end

-- [ 4. REMOTE SECURITY : DEBOUNCE 0.1s ] -- 🛡️
local function SafeRemote(action, ...)
    local now = tick()
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

-- [ 5. MOUVEMENT : SAFE-TWEEN ] -- ✈️
function Functions:SafeTween(targetCFrame)
    pcall(function()
        local char = self.Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local distance = (targetCFrame.p - root.Position).Magnitude
        if distance < 10 then root.CFrame = targetCFrame return end

        local info = TweenInfo.new(distance / self.Config.Speed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(root, info, {CFrame = targetCFrame})
        
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

-- [ 6. DYNAMIC QUEST FINDER ] -- 🔍
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

-- [ 7. CŒUR DU SYSTÈME : HEARTBEAT CORE ] -- ⚔️🧲
-- Synchronisation parfaite Combat + Magnet (Physics Safe)
RunService.Heartbeat:Connect(function()
    local char = Functions.Player.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    -- GESTION DU FAST ATTACK --
    if Functions.Config.FastAttack then
        pcall(function()
            local controller = GetCombatController()
            if controller then
                controller.timeToNextAttack = 0
                controller.attacking = false
                controller.increment = Functions.Config.AttackIncrement or 3
                controller.hitboxMagnitude = 60
                
                -- Anti-Animation
                if char:FindFirstChild("Humanoid") then
                    for _, t in pairs(char.Humanoid:GetPlayingAnimationTracks()) do
                        if t.Name:find("Attack") or t.Name:find("Slash") then t:Stop(0) end
                    end
                end
            end
        end)
    end

    -- GESTION DU MAGNETIC MOB (ANTI-FLING) --
    if Functions.Config.MagneticMob then
        pcall(function()
            local enemies = Workspace:FindFirstChild("Enemies")
            if enemies then
                for _, mob in pairs(enemies:GetChildren()) do
                    local mobRoot = mob:FindFirstChild("HumanoidRootPart")
                    local mobHum = mob:FindFirstChildOfClass("Humanoid")

                    if mobRoot and mobHum and mobHum.Health > 0 then
                        local dist = (mobRoot.Position - myRoot.Position).Magnitude
                        if dist <= 350 then
                            NeutralizePhysics(mob)
                            -- Regroupement précis devant le joueur
                            mobRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -Functions.Config.AttackDistance)
                        end
                    end
                end
            end
        end)
    end
end)

-- [ 8. AUTO-CLICKER & ELITE FARM ] -- 🖱️🌾
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

function Functions:StartEliteFarm()
    task.spawn(function()
        while true do
            task.wait(0.5)
            if not self.Config.EliteFarm then continue end

            pcall(function()
                local char = self.Player.Character
                if not char or char.Humanoid.Health <= 0 then return end

                local questUI = self.Player.PlayerGui.Main:FindFirstChild("Quest")
                if not questUI or not questUI.Visible then
                    local targetNpc = self:GetDynamicQuest()
                    if targetNpc then
                        self:SafeTween(targetNpc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                        SafeRemote("StartQuest", "BanditQuest1", 1) 
                    end
                else
                    OptimizeVisuals(true)
                    self.Config.FastAttack = true
                    self.Config.AutoClicker = true
                    self.Config.MagneticMob = true
                end
            end)
        end
    end)
end

-- [ 9. INITIALISATION ] -- ⚡
function Functions:Init()
    print("--- [ OMNI-FUNCTIONS v5.4 FUSION LOADED ] ---")
    self:StartAutoClick()
    self:StartEliteFarm()
end

_G.Functions = Functions
return Functions