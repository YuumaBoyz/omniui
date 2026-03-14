--[[
    MODULE  : MagneticMob.lua
    VERSION : v2.7 (Aimbot Bridge)
]]

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Player = game:GetService("Players").LocalPlayer

_G.MagneticMob = _G.MagneticMob or false
_G.MagnetDistance = 300
_G.AttackPos = Vector3.new(0, 0, -10) 
_G.MagneticTarget = nil -- Liaison pour l'Aimbot

local function NeutralizeMob(mob)
    pcall(function()
        local root = mob:FindFirstChild("HumanoidRootPart")
        local hum = mob:FindFirstChildOfClass("Humanoid")
        if root and hum then
            root.CanCollide = false
            root.Velocity = Vector3.new(0, 0, 0)
            hum.PlatformStand = true 
        end
    end)
end

RunService.Heartbeat:Connect(function()
    local isFlying = _G.Physics and _G.Physics.Flying
    if not _G.MagneticMob then 
        _G.MagneticTarget = nil 
        return 
    end

    local character = Player.Character
    local myRoot = character and character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return end

    for _, mob in pairs(enemies:GetChildren()) do
        local mobRoot = mob:FindFirstChild("HumanoidRootPart")
        local mobHum = mob:FindFirstChildOfClass("Humanoid")

        if mobRoot and mobHum and mobHum.Health > 0 then
            local dist = (mobRoot.Position - myRoot.Position).Magnitude
            if dist <= _G.MagnetDistance then
                _G.MagneticTarget = mob -- On définit la cible prioritaire pour l'Aimbot
                NeutralizeMob(mob)
                
                local offset = isFlying and Vector3.new(0, -5, -10) or _G.AttackPos
                mobRoot.CFrame = myRoot.CFrame * CFrame.new(offset)
            end
        end
    end
end)