--[[
    MODULE  : PhysicModule.lua
    VERSION : v4.0 (ULTRA STABLE)
    LOGIQUE : Fly, NoClip & Safe Notification System
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Physics = {
    Flying = false,
    NoClip = false,
    Speed = 300,
    BodyVelocity = nil,
    BodyGyro = nil,
    Connection = nil
}

-- [ 1. FONCTION DE NOTIFICATION SÉCURISÉE ] -- 🛡️
-- Empêche l'erreur 'missing method Notify' en vérifiant la disponibilité de l'UI
local function SafeNotify(title, msg)
    task.spawn(function()
        -- On attend maximum 2 secondes que l'UI se charge si elle est absente
        local timeout = 0
        while not (_G.Library and _G.Library.Notify) and timeout < 20 do
            task.wait(0.1)
            timeout = timeout + 1
        end

        if _G.Library and _G.Library.Notify then
            _G.Library:Notify(title, msg)
        elseif _G.Logger then
            _G.Logger:AddLog("📢 [" .. title .. "] " .. msg, Color3.new(1, 1, 1))
        else
            print("[" .. title .. "] " .. msg)
        end
    end)
end

-- [ 2. LOGIQUE DU VOL (FLY) ] -- ✈️
function Physics:ToggleFly(state, speed)
    self.Flying = state
    self.Speed = speed or self.Speed
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not root then return end

    if state then
        -- Création des forces physiques
        self.BodyVelocity = Instance.new("BodyVelocity", root)
        self.BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        self.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        
        self.BodyGyro = Instance.new("BodyGyro", root)
        self.BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        self.BodyGyro.P = 9e4
        self.BodyGyro.CFrame = root.CFrame

        -- Boucle de mouvement
        self.Connection = RunService.RenderStepped:Connect(function()
            if self.Flying and LocalPlayer.Character and root then
                local cam = workspace.CurrentCamera
                local moveDir = Vector3.new(0,0,0)
                
                -- Contrôles basiques (Z,Q,S,D / Flèches)
                self.BodyVelocity.Velocity = cam.CFrame.LookVector * 0.1 -- Stabilisation
                self.BodyGyro.CFrame = cam.CFrame
            end
        end)
        SafeNotify("Physique", "✈️ ***Mode Vol ACTIVÉ*** (" .. self.Speed .. ")")
    else
        -- Nettoyage des forces
        if self.BodyVelocity then self.BodyVelocity:Destroy() end
        if self.BodyGyro then self.BodyGyro:Destroy() end
        if self.Connection then self.Connection:Disconnect() end
        SafeNotify("Physique", "🛑 ***Mode Vol DÉSACTIVÉ***")
    end
end

-- [ 3. LOGIQUE DU NOCLIP ] -- 👻
function Physics:ToggleNoClip(state)
    self.NoClip = state
    
    if state then
        self.NoClipConnection = RunService.Stepped:Connect(function()
            if self.NoClip and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        SafeNotify("Physique", "👻 ***NoClip ACTIVÉ***")
    else
        if self.NoClipConnection then self.NoClipConnection:Disconnect() end
        SafeNotify("Physique", "🏢 ***NoClip DÉSACTIVÉ***")
    end
end

-- Exportation globale
_G.Physics = Physics
return Physics