--[[
    FICHIER : OmniFunctions.lua
    UTILITÉ : Moteur Logique (Mouvement Ghost, Fruit Sniper & Combat Elite)
]]

local Functions = {
    -- Regroupement de toutes les configurations
    Config = {
        -- Mouvement & Sniper
        Speed = 300,
        SniperEnabled = false,
        -- Combat
        FastAttack = false,
        AutoClicker = false,
        AttackDistance = 15
    },
    Player = game.Players.LocalPlayer
}

-- [ 1. MOTEUR GHOST-MOVEMENT ] -- ✈️
function Functions:GhostMove(targetPos)
    local char = self.Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart

    local bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0,0,0)

    -- Noclip (Traverser les murs pendant le vol)
    local noclip = game:GetService("RunService").Stepped:Connect(function()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)

    while (root.Position - targetPos).Magnitude > 10 and (self.Config.SniperEnabled or self.Config.AutoClicker) do
        bv.Velocity = (targetPos - root.Position).Unit * self.Config.Speed
        task.wait()
    end

    bv:Destroy()
    noclip:Disconnect()
end

-- [ 2. MODULE FRUIT SNIPER ] -- 🍓
function Functions:InitFruitSniper()
    task.spawn(function()
        while task.wait(1) do
            if self.Config.SniperEnabled then
                for _, item in pairs(game.Workspace:GetChildren()) do
                    if item:IsA("Tool") and (item.Name:find("Fruit") or item:FindFirstChild("Handle")) then
                        print("🍓 [OMNI] : Fruit détecté -> " .. item.Name)
                        self:GhostMove(item.Handle.Position)
                        break 
                    end
                end
            end
        end
    end)
end

-- [ 3. MODULE FAST ATTACK ] -- ⚡
function Functions:EnableFastAttack()
    task.spawn(function()
        -- Importation des modules internes de Blox Fruit
        local CombatFramework = require(game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework)
        local CameraShaker = require(game:GetService("ReplicatedStorage").Util.CameraShaker)
        
        CameraShaker:Stop() -- Désactive les tremblements pour plus de confort
        
        while task.wait() do
            if self.Config.FastAttack then
                pcall(function()
                    -- Bypass du délai d'attaque
                    CombatFramework.activeController.hitboxMagnitude = 50
                    CombatFramework.activeController.active = true
                    CombatFramework.activeController.blocking = false
                    CombatFramework.activeController.focusStart = 0
                end)
            end
        end
    end)
end

-- [ 4. MODULE AUTO-CLICKER ] -- 🖱️
function Functions:StartAutoClick()
    task.spawn(function()
        local VirtualUser = game:GetService("VirtualUser")
        while task.wait(0.1) do
            if self.Config.AutoClicker then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0,0))
                
                -- Suppression des animations si Fast Attack est ON
                if self.Config.FastAttack then
                    local char = self.Player.Character
                    if char and char:FindFirstChildOfClass("Tool") then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        for _, anim in pairs(hum:GetPlayingAnimationTracks()) do
                            if anim.Name:find("Attack") or anim.Name:find("Slash") then
                                anim:Stop()
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- Exportation pour le Loader
_G.Functions = Functions
return Functions