--[[
    MODULE : OMNI-PHYSICS (v1.3 ULTIMATE FUSION)
    RÔLE   : Gestion avancée du Fly (Bypass), Noclip et Infinite Geppo
    LOGIQUE : Jittering + Anti-Fall + Stepped Collision + State Hook
]]

local PhysicModule = {}
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Player = game:GetService("Players").LocalPlayer

-- États internes accessibles globalement
_G.Noclip = false
_G.Flying = false
_G.FlySafeMode = true
_G.InfiniteGeppo = false

-- [ 👻 LOGIQUE NOCLIP ] --
-- Désactive les collisions de manière cyclique pour éviter les resets du serveur
RunService.Stepped:Connect(function()
    if _G.Noclip and Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- [ ☁️ LOGIQUE INFINITE GEPPO ] --
-- Intercepte la requête de saut pour forcer l'état de saut même en l'air
UserInputService.JumpRequest:Connect(function()
    if _G.InfiniteGeppo and Player.Character then
        local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- [ 🦅 LOGIQUE FLY AVEC SAFE-BYPASS ] --
function PhysicModule:ToggleFly(state, speed)
    _G.Flying = state
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    
    -- [ Nettoyage si arrêt ] --
    if not state then
        if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
        if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end
        char.Humanoid.PlatformStand = false
        return
    end

    -- [ Initialisation de la Physique ] --
    local bg = Instance.new("BodyGyro", root)
    bg.Name = "FlyGyro"
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 9e4
    
    local bv = Instance.new("BodyVelocity", root)
    bv.Name = "FlyVelocity"
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)

    -- [ Boucle de Vol & Bypass ] --
    task.spawn(function()
        local bypassCount = 0
        
        while _G.Flying and char.Parent do
            local camera = workspace.CurrentCamera
            local direction = Vector3.new(0, 0, 0)
            
            -- Détection des touches ZQSD / WASD
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camera.CFrame.RightVector end
            
            -- [ 🛡️ PROTOCOLE SAFE-BYPASS ] --
            local finalVelocity = direction * (speed or 300)
            
            if _G.FlySafeMode then
                -- 1. Micro-Oscillation (Jittering)
                local jitter = Vector3.new(
                    math.random(-10, 10) / 1000, 
                    math.random(-10, 10) / 1000, 
                    math.random(-10, 10) / 1000
                )
                finalVelocity = finalVelocity + jitter
                
                -- 2. Anti-Fall Hack (Reset de vélocité cyclique)
                bypassCount = bypassCount + 1
                if bypassCount > 60 then 
                    bv.velocity = Vector3.new(0, -0.2, 0) 
                    bypassCount = 0
                    task.wait(0.015) 
                end
            end

            -- Application des forces
            bv.velocity = finalVelocity
            bg.cframe = camera.CFrame
            
            -- Évite les bugs d'animation et de physique
            char.Humanoid.PlatformStand = true
            
            RunService.RenderStepped:Wait() 
        end
        
        -- Cleanup final
        if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
        if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end
        char.Humanoid.PlatformStand = false
    end)
end

_G.PhysicModule = PhysicModule
return PhysicModule