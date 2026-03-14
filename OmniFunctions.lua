--[[
    FICHIER : OmniFunctions.lua
    VERSION : v6.1 (Optimisée pour v6.2.3)
    LOGIQUE : Core Logic + Human Mimic + Magnetic Mob + Silent Aura + Anti-AFK
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

-- [ 0. SYNCHRONISATION GLOBALE ] -- 🔗
local Functions = _G.Functions or {}
Functions.Player = Players.LocalPlayer
Functions.LastRemoteTick = 0
Functions.Controller = nil
Functions.LastPauseTick = tick()

-- [ 1. MODULE : SÉCURITÉ & RÉSEAU ] -- 🛡️
local function IsBusy(character)
    local busyValue = character:FindFirstChild("Busy")
    return busyValue and busyValue:IsA("ValueBase") and busyValue.Value or false
end

-- Remote ultra-sécurisée pour éviter les kicks
local function SafeRemote(action, ...)
    local now = tick()
    if (now - Functions.LastRemoteTick) < 0.1 then 
        task.wait(0.1 - (now - Functions.LastRemoteTick)) 
    end
    
    local success, response = pcall(function(...)
        local re = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("Modules")
        local comm = re and (re:FindFirstChild("CommF_") or re:FindFirstChild("RE"))
        
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

-- [ 2. HUMAN MIMIC (Anti-Ban Pattern) ] -- 🎭
function Functions:RunHumanMimic()
    task.spawn(function()
        while task.wait(10) do
            -- On utilise self.Config pour pointer vers _G.Functions.Config
            if self.Config.AutoFarm and (tick() - self.LastPauseTick) >= 7200 then
                self.Config.Paused = true
                if _G.Logger then _G.Logger:AddLog("🎭 ***[MIMIC]*** : Pause anti-pattern (5 min)", Color3.fromRGB(255, 200, 0)) end
                
                -- Petit mouvement aléatoire pour simuler une présence
                task.wait(300) 
                
                self.LastPauseTick = tick()
                self.Config.Paused = false
                if _G.Logger then _G.Logger:AddLog("✅ ***[MIMIC]*** : Reprise du farm", Color3.fromRGB(0, 255, 150)) end
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

    -- 1. Silent Kill Aura (Augmente la Hitbox)
    local tool = char:FindFirstChildOfClass("Tool")
    if Functions.Config.FastAttack and tool and tool:FindFirstChild("Handle") then
        tool.Handle.Size = Vector3.new(25, 25, 25)
        tool.Handle.CanCollide = false
    end

    -- 2. Fast Attack Sync
    if Functions.Config.FastAttack and not IsBusy(char) then
        local c = GetCombatController()
        if c then 
            c.timeToNextAttack = 0
            c.attacking = false
            c.increment = 3 
        end
    end

    -- 3. Magnetic Mob v2.5 (Ghost Fusion)
    if Functions.Config.MagneticMob then
        local enemies = workspace:FindFirstChild("Enemies")
        if enemies then
            for _, mob in pairs(enemies:GetChildren()) do
                local mRoot = mob:FindFirstChild("HumanoidRootPart")
                local mHum = mob:FindFirstChildOfClass("Humanoid")
                
                if mRoot and mHum and mHum.Health > 0 then
                    local dist = (mRoot.Position - myRoot.Position).Magnitude
                    if dist <= 350 then
                        mRoot.CanCollide = false
                        mRoot.Velocity = Vector3.new(0, 0, 0)
                        mHum.PlatformStand = true -- Paralysie totale
                        
                        -- Positionnement devant le joueur pour le farm
                        mRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -5)

                        -- SYNC AIMBOT : On donne la cible à l'Aimbot pour les skills
                        if _G.Aimbot and _G.Aimbot.Enabled then
                            _G.Aimbot.Target = mob
                        end
                    end
                end
            end
        end
    end
end)

-- [ 4. MOUVEMENT (Tween) ] -- ✈️
function Functions:MoveTo(targetCFrame)
    if self.Config.Paused then return end 
    local char = self.Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local distance = (targetCFrame.p - root.Position).Magnitude
    local info = TweenInfo.new(distance / self.Config.Speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, info, {CFrame = targetCFrame})
    
    -- Noclip pendant le trajet
    local noclip = RunService.Stepped:Connect(function()
        if char then 
            for _, p in pairs(char:GetDescendants()) do 
                if p:IsA("BasePart") then p.CanCollide = false end 
            end 
        end
    end)

    tween:Play()
    tween.Completed:Wait()
    noclip:Disconnect()
end

-- [ 5. INITIALISATION ] -- ⚡
function Functions:Init()
    InitAntiAFK()
    self:RunHumanMimic()
    
    -- Boucle d'Auto-Clicker (Aura de dégâts)
    task.spawn(function()
        while true do
            task.wait(0.01)
            if self.Config.FastAttack and not self.Config.Paused then
                local char = self.Player.Character
                local c = GetCombatController()
                if char and not IsBusy(char) and c and char:FindFirstChildOfClass("Tool") then
                    pcall(function() c:attack() end)
                end
            end
        end
    end)
    
    if _G.Logger then _G.Logger:AddLog("⚡ ***Omni-Functions v6.1*** chargée.") end
end

_G.Functions = Functions
return Functions