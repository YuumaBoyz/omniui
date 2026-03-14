--[[
    FICHIER : OmniFunctions.lua
    VERSION : v5.7 (Triple-A Scanner + Physics Master + Anti-AFK)
    LOGIQUE : Neutralisation complète + Heartbeat Sync + Scanner Récursif
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

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
    Controller = nil 
}

-- [ 1. MODULE : ANTI-AFK & SÉCURITÉ ] -- 🛡️
local function InitAntiAFK()
    Functions.Player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
        if _G.Logger then
            _G.Logger:AddLog("🛡️ ***[SYSTEM]*** : Anti-AFK activé (Reset Idle)", Color3.fromRGB(255, 150, 0))
        end
    end)
end

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
_G.SafeRemoteFire = SafeRemote

-- [ 2. TRIPLE-A DYNAMIC SCANNER ] -- 🔍
function Functions:GetDynamicQuest()
    local PlayerLevel = self.Player.Data.Level.Value
    local BestNPC = nil
    local MinDist = math.huge
    local myRoot = self.Player.Character and self.Player.Character:FindFirstChild("HumanoidRootPart")
    
    if not myRoot then return nil end

    -- Scan récursif intelligent (Workspace)
    for _, npc in pairs(Workspace:GetDescendants()) do
        if npc:IsA("Model") and (npc.Name:find("Quest") or npc:FindFirstChild("Quest")) then
            local root = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
            if root then
                local dist = (myRoot.Position - root.Position).Magnitude
                local levelReq = npc.Name:match("%d+")
                
                if levelReq and tonumber(levelReq) <= PlayerLevel then
                    if dist < MinDist then
                        MinDist = dist
                        BestNPC = npc
                    end
                end
            end
        end
    end
    
    -- Fallback NPCs Folder
    if not BestNPC and Workspace:FindFirstChild("NPCs") then
        for _, npc in pairs(Workspace.NPCs:GetChildren()) do
            local npcLevel = tonumber(npc.Name:match("%d+")) or 0
            if PlayerLevel >= npcLevel then BestNPC = npc end
        end
    end
    return BestNPC
end

-- [ 3. PHYSIQUE & OPTIMISATION ] -- 📉🛡️
local function OptimizeVisuals(state)
    pcall(function()
        local mainUI = Functions.Player.PlayerGui:FindFirstChild("Main")
        if mainUI and mainUI:FindFirstChild("DamageIndicators") then
            mainUI.DamageIndicators.Visible = not state
        end
    end)
end

local function GetCombatController()
    if Functions.Controller then return Functions.Controller end
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "activeController") then 
                Functions.Controller = v.activeController
            end
        end
    end)
    return Functions.Controller
end

local function NeutralizePhysics(mob)
    local root = mob:FindFirstChild("HumanoidRootPart")
    local hum = mob:FindFirstChildOfClass("Humanoid")
    if root and hum then
        root.CanCollide = false
        root.Size = Vector3.new(0.001, 0.001, 0.001)
        root.Velocity = Vector3.new(0, 0, 0)
        hum.PlatformStand = true 
        hum.WalkSpeed = 0
        for _, part in pairs(mob:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end

-- [ 4. HEARTBEAT SYNC CORE ] -- ⚔️💓
RunService.Heartbeat:Connect(function()
    local char = Functions.Player.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    if Functions.Config.FastAttack then
        local c = GetCombatController()
        if c then
            c.timeToNextAttack = 0
            c.attacking = false
            c.increment = Functions.Config.AttackIncrement or 3
            c.hitboxMagnitude = 60
            if char:FindFirstChild("Humanoid") then
                for _, t in pairs(char.Humanoid:GetPlayingAnimationTracks()) do
                    if t.Name:find("Attack") or t.Name:find("Slash") then t:Stop(0) end
                end
            end
        end
    end

    if Functions.Config.MagneticMob then
        local enemies = Workspace:FindFirstChild("Enemies")
        if enemies then
            for _, mob in pairs(enemies:GetChildren()) do
                local mRoot = mob:FindFirstChild("HumanoidRootPart")
                if mRoot and mob:FindFirstChildOfClass("Humanoid") and mob.Humanoid.Health > 0 then
                    if (mRoot.Position - myRoot.Position).Magnitude <= 350 then
                        NeutralizePhysics(mob)
                        mRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -Functions.Config.AttackDistance)
                    end
                end
            end
        end
    end
end)

-- [ 5. MOUVEMENT & ELITE FARM ] -- ✈️🌾
function Functions:MoveTo(targetCFrame)
    if typeof(targetCFrame) == "Vector3" then targetCFrame = CFrame.new(targetCFrame) end
    local char = self.Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local distance = (targetCFrame.p - root.Position).Magnitude
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
end

function Functions:StartEliteFarm()
    task.spawn(function()
        while true do
            task.wait(0.5)
            if not self.Config.EliteFarm then continue end

            pcall(function()
                local questUI = self.Player.PlayerGui.Main:FindFirstChild("Quest")
                if not questUI or not questUI.Visible then
                    local targetNpc = self:GetDynamicQuest()
                    if targetNpc then
                        if _G.Logger then _G.Logger:AddLog("🔍 [SCAN] : PNJ trouvé -> " .. targetNpc.Name) end
                        self:MoveTo(targetNpc.PrimaryPart.CFrame * CFrame.new(0, 0, 3))
                        _G.SafeRemoteFire("StartQuest", targetNpc.Name, 1)
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

-- [ 6. INITIALISATION ] -- ⚡
function Functions:Init()
    print("--- [ OMNI-FUNCTIONS v5.7 FINAL FUSION LOADED ] ---")
    InitAntiAFK()
    
    task.spawn(function()
        while true do
            task.wait(0.01)
            if self.Config.AutoClicker then
                local c = GetCombatController()
                if c and self.Player.Character:FindFirstChildOfClass("Tool") then
                    task.spawn(function() c:attack() end)
                end
            end
        end
    end)
    
    self:StartEliteFarm()
end

_G.Functions = Functions
return Functions