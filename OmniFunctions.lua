--[[
    FICHIER : OmniFunctions.lua
    VERSION : v6.0 (Elite Evolution)
    LOGIQUE : Fusion Intégrale + Human Mimic + Silent Aura + Smart Skills
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local Functions = {
    Config = {
        Speed = 300,
        FastAttack = false,
        AttackIncrement = 3,
        AutoClicker = false,
        MagneticMob = false,
        AttackDistance = 10,
        EliteFarm = false,
        AutoStats = false,
        TargetStat = "Melee", 
        WeaponType = "Melee",
        Paused = false -- Flag pour le Human Mimic
    },
    Player = Players.LocalPlayer,
    LastRemoteTick = 0,
    Controller = nil,
    Cooldowns = {Z = 0, X = 0, C = 0, V = 0},
    LastPauseTick = tick()
}

-- [ 1. MODULE : SÉCURITÉ & RÉSEAU ] -- 🛡️
local function IsBusy(character)
    local busyValue = character:FindFirstChild("Busy")
    return busyValue and busyValue:IsA("ValueBase") and busyValue.Value or false
end

local function SafeRemote(action, ...)
    local now = tick()
    if (now - Functions.LastRemoteTick) < 0.1 then 
        task.wait(0.1 - (now - Functions.LastRemoteTick)) 
    end
    
    local success, response = pcall(function(...)
        local re = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("Modules")
        local comm = re and (re:FindFirstChild("CommF_") or re:FindFirstChild("RE"))
        
        if action == "CollectedDragonEgg" and (not comm or not comm:FindFirstChild("CollectedDragonEgg")) then
            return nil 
        end

        if comm and comm:IsA("RemoteFunction") then
            Functions.LastRemoteTick = tick()
            return comm:InvokeServer(unpack({...}))
        elseif comm and comm:IsA("RemoteEvent") then
            Functions.LastRemoteTick = tick()
            comm:FireServer(unpack({...}))
            return true
        end
    end, action, ...)
    return success and response or nil
end
_G.SafeRemoteFire = SafeRemote

local function InitAntiAFK()
    Functions.Player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
    end)
end

-- [ 2. MODULES AVANCÉS (HUMAN MIMIC & SKILLS) ] -- 🎭
function Functions:RunHumanMimic()
    task.spawn(function()
        while task.wait(10) do
            -- Toutes les 120 minutes de farm
            if self.Config.EliteFarm and (tick() - self.LastPauseTick) >= 7200 then
                self.Config.Paused = true
                if _G.Logger then _G.Logger:AddLog("🎭 ***[MIMIC]*** : Pause anti-pattern (5 min)", Color3.fromRGB(255, 200, 0)) end
                
                -- Téléportation vers une zone neutre (Middle Town)
                self:MoveTo(CFrame.new(-20, 50, 0))
                
                local startPause = tick()
                while (tick() - startPause) < 300 do
                    -- Simulation d'activité humaine
                    workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * CFrame.Angles(0, math.rad(math.random(-1,1)), 0)
                    if math.random(1, 100) > 95 then 
                        local char = self.Player.Character
                        if char and char:FindFirstChild("Humanoid") then char.Humanoid.Jump = true end 
                    end
                    task.wait(math.random(2, 5))
                end
                
                self.LastPauseTick = tick()
                self.Config.Paused = false
                if _G.Logger then _G.Logger:AddLog("✅ ***[MIMIC]*** : Reprise du protocole", Color3.fromRGB(0, 255, 150)) end
            end
        end
    end)
end

function Functions:GetLowestMasteryTool()
    local bestTool, lowestMastery = nil, math.huge
    local target = self.Config.WeaponType or "Melee"
    
    for _, item in pairs(self.Player.Backpack:GetChildren()) do
        if item:IsA("Tool") and (item:GetAttribute("Type") == target or item.Name:find(target)) then
            local mastery = item:GetAttribute("Mastery") or 0
            if mastery < lowestMastery then
                lowestMastery = mastery
                bestTool = item
            end
        end
    end
    return bestTool
end

-- [ 3. PHYSIQUE & COMBAT CORE ] -- ⚔️
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

RunService.Heartbeat:Connect(function()
    local char = Functions.Player.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not myRoot or Functions.Config.Paused then return end

    -- 1. Silent Kill Aura (Hitbox Expander)
    local tool = char:FindFirstChildOfClass("Tool")
    if Functions.Config.AutoClicker and tool and tool:FindFirstChild("Handle") then
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or Functions.Config.AutoClicker then
            tool.Handle.Size = Vector3.new(25, 25, 25)
            tool.Handle.CanCollide = false
        else
            tool.Handle.Size = Vector3.new(1, 1, 1)
        end
    end

    -- 2. Fast Attack Sync
    if Functions.Config.FastAttack and not IsBusy(char) then
        local c = GetCombatController()
        if c then
            c.timeToNextAttack, c.attacking = 0, false
            c.increment = Functions.Config.AttackIncrement or 3
        end
    end

    -- 3. Smart Skill Rotation
    local keys = {"V", "C", "X", "Z"}
    for _, key in ipairs(keys) do
        local enemies = Workspace:FindFirstChild("Enemies")
        if enemies and (tick() - (Functions.Cooldowns[key] or 0)) > 2.5 then
            for _, mob in pairs(enemies:GetChildren()) do
                if mob:FindFirstChild("HumanoidRootPart") and (mob.HumanoidRootPart.Position - myRoot.Position).Magnitude < 30 then
                    task.delay(math.random(1,3)/10, function()
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode[key], false, game)
                        Functions.Cooldowns[key] = tick()
                    end)
                    break
                end
            end
        end
    end

    -- 4. Magnetic Mob
    if Functions.Config.MagneticMob then
        local enemies = Workspace:FindFirstChild("Enemies")
        if enemies then
            for _, mob in pairs(enemies:GetChildren()) do
                local mRoot = mob:FindFirstChild("HumanoidRootPart")
                if mRoot and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                    if (mRoot.Position - myRoot.Position).Magnitude <= 350 then
                        mRoot.CanCollide = false
                        mRoot.Velocity = Vector3.new(0,0,0)
                        mRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -Functions.Config.AttackDistance)
                    end
                end
            end
        end
    end
end)

-- [ 4. MOUVEMENT TWEEN ] -- ✈️
function Functions:MoveTo(targetCFrame)
    if self.Config.Paused then return end -- Bloque le mouvement si en pause Mimic
    
    local char = self.Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local distance = (targetCFrame.p - root.Position).Magnitude
    local info = TweenInfo.new(distance / self.Config.Speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, info, {CFrame = targetCFrame})
    
    local noclip = RunService.Stepped:Connect(function()
        if char then for _, p in pairs(char:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end end
    end)

    tween:Play()
    tween.Completed:Wait()
    noclip:Disconnect()
end

-- [ 5. INITIALISATION ] -- ⚡
function Functions:Init()
    print("--- [ OMNI-FUNCTIONS v6.0 ELITE LOADED ] ---")
    InitAntiAFK()
    self:RunHumanMimic() -- Active la routine anti-pattern
    
    task.spawn(function()
        while true do
            task.wait(0.01)
            if self.Config.AutoClicker and not self.Config.Paused then
                local char = self.Player.Character
                if char and not IsBusy(char) then
                    local c = GetCombatController()
                    if c and char:FindFirstChildOfClass("Tool") then
                        pcall(function() c:attack() end)
                    end
                end
            end
        end
    end)
end

_G.Functions = Functions
return Functions