--[[
    FICHIER : OmniFunctions.lua
    VERSION : v6.1 (Elite Evolution + Ghost Magnet)
    LOGIQUE : Fusion Intégrale + Human Mimic + Silent Aura + Ghost Magnet v2.5 + Fruit Sniper
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
        MagneticMob = false, -- Activé via UI
        AttackDistance = 10,
        EliteFarm = false,
        AutoStats = false,
        TargetStat = "Melee", 
        WeaponType = "Melee",
        FruitSniper = false,
        Paused = false 
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

-- [ 2. MODULES AVANCÉS (HUMAN MIMIC & SNIPER) ] -- 🎭
function Functions:RunHumanMimic()
    task.spawn(function()
        while task.wait(10) do
            if self.Config.EliteFarm and (tick() - self.LastPauseTick) >= 7200 then
                self.Config.Paused = true
                if _G.Logger then _G.Logger:AddLog("🎭 ***[MIMIC]*** : Pause anti-pattern (5 min)", Color3.fromRGB(255, 200, 0)) end
                self:MoveTo(CFrame.new(-20, 50, 0))
                
                local startPause = tick()
                while (tick() - startPause) < 300 do
                    workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * CFrame.Angles(0, math.rad(math.random(-1,1)), 0)
                    if math.random(1, 100) > 95 then 
                        local char = self.Player.Character
                        if char and char:FindFirstChild("Humanoid") then char.Humanoid.Jump = true end 
                    end
                    task.wait(math.random(2, 5))
                end
                
                self.LastPauseTick = tick()
                self.Config.Paused = false
                if _G.Logger then _G.Logger:AddLog("✅ ***[MIMIC]*** : Reprise", Color3.fromRGB(0, 255, 150)) end
            end
        end
    end)
end

function Functions:RunFruitSniper()
    task.spawn(function()
        while task.wait(0.5) do
            if self.Config.FruitSniper then 
                for _, fruit in pairs(Workspace:GetChildren()) do
                    if fruit:IsA("Tool") and (fruit.Name:find("Fruit") or fruit:FindFirstChild("Handle")) then
                        local root = self.Player.Character and self.Player.Character:FindFirstChild("HumanoidRootPart")
                        if root and fruit:FindFirstChild("Handle") then
                            firetouchinterest(root, fruit.Handle, 0)
                            firetouchinterest(root, fruit.Handle, 1)
                            
                            if _G.Logger then 
                                _G.Logger:AddLog("🍎 ***[SNIPER]*** : Fruit récupéré !", Color3.fromRGB(0, 255, 150)) 
                            end
                        end
                    end
                end
            end
        end
    end)
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

    -- 1. Silent Kill Aura
    local tool = char:FindFirstChildOfClass("Tool")
    if Functions.Config.AutoClicker and tool and tool:FindFirstChild("Handle") then
        tool.Handle.Size = (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or Functions.Config.AutoClicker) and Vector3.new(25, 25, 25) or Vector3.new(1, 1, 1)
        tool.Handle.CanCollide = false
    end

    -- 2. Fast Attack Sync
    if Functions.Config.FastAttack and not IsBusy(char) then
        local c = GetCombatController()
        if c then c.timeToNextAttack, c.attacking, c.increment = 0, false, Functions.Config.AttackIncrement or 3 end
    end

    -- 3. Magnetic Mob v2.5 (Ghost Fusion)
    if Functions.Config.MagneticMob then
        local enemies = Workspace:FindFirstChild("Enemies")
        if enemies then
            for _, mob in pairs(enemies:GetChildren()) do
                local mRoot = mob:FindFirstChild("HumanoidRootPart")
                local mHum = mob:FindFirstChildOfClass("Humanoid")
                
                if mRoot and mHum and mHum.Health > 0 then
                    local dist = (mRoot.Position - myRoot.Position).Magnitude
                    if dist <= 350 then
                        -- Neutralisation Physique & Anti-Fling
                        mRoot.CanCollide = false
                        mRoot.Velocity = Vector3.new(0, 0, 0)
                        mHum.PlatformStand = true -- Paralysie totale
                        
                        if mRoot.Size.X > 0.1 then 
                            mRoot.Size = Vector3.new(0.01, 0.01, 0.01) 
                        end
                        
                        -- Positionnement CFrame (Aligné sur le joueur)
                        mRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -Functions.Config.AttackDistance)
                    end
                end
            end
        end
    end
end)

-- [ 4. MOUVEMENT ] -- ✈️
function Functions:MoveTo(targetCFrame)
    if self.Config.Paused then return end 
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
    print("--- [ OMNI-FUNCTIONS v6.1 ELITE LOADED ] ---")
    InitAntiAFK()
    self:RunHumanMimic()
    self:RunFruitSniper()
    
    task.spawn(function()
        while true do
            task.wait(0.01)
            if self.Config.AutoClicker and not self.Config.Paused then
                local char = self.Player.Character
                local c = GetCombatController()
                if char and not IsBusy(char) and c and char:FindFirstChildOfClass("Tool") then
                    pcall(function() c:attack() end)
                end
            end
        end
    end)
end

_G.Functions = Functions
return Functions