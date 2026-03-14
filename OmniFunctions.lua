--[[
    FICHIER : OmniFunctions.lua
    LOGIQUE : Ultra-Fusion Ghost-Protocol
    VERSION : v4.4 (GC-Based, Safe-Bring & Global Engine)
]]

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LogService = game:GetService("LogService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Functions = {
    Config = {
        -- Mouvement & Sniper
        Speed = 300,
        SniperEnabled = false,
        WhiteList = {"Leopard Fruit", "Dragon Fruit", "Dough Fruit", "Kitsune Fruit"},
        
        -- Combat & Reverse Engineering
        FastAttack = false,
        AutoClicker = false,
        MagneticMob = false,
        AttackDistance = 15,
        AntiAFK = true
    },
    Player = Players.LocalPlayer,
    DebugLogs = {} 
}

-- [ 1. RÉCUPÉRATION MÉMOIRE (GETGC) ] -- 🧠
-- Méthode indétectable pour chasser le contrôleur sans 'require'
local function GetCombatController()
    local controller = nil
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "activeController") then
            controller = v.activeController
            break
        end
    end
    return controller
end

-- [ 2. MODULE COMBAT ÉLITE (GHOST ATTACK) ] -- ⚔️
function Functions:EnableFastAttack()
    task.spawn(function()
        while task.wait() do
            if self.Config.FastAttack then
                pcall(function()
                    local controller = GetCombatController()
                    if controller then
                        -- Manipulation directe des délais en mémoire vive
                        controller.attackInterval = 0
                        controller.hitboxMagnitude = 60
                    end
                    
                    -- No Animation : Arrêt propre des tracks de l'Humanoid
                    local char = self.Player.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        for _, track in pairs(hum:GetPlayingAnimationTracks()) do
                            if track.Name:find("Attack") or track.Name:find("Slash") then
                                track:Stop()
                            end
                        end
                    end
                end)
            end
        end
    end)
end

function Functions:StartAutoClick()
    task.spawn(function()
        while task.wait(0.01) do -- Loop haute fréquence
            if not self.Config.AutoClicker then break end
            
            pcall(function()
                local char = self.Player.Character
                if char and char:FindFirstChildOfClass("Tool") then
                    local controller = GetCombatController()
                    if controller then
                        -- Appel direct de la fonction interne (bypass input)
                        task.spawn(function() controller:attack() end)
                    end
                end
            end)
        end
    end)
end

-- [ 3. MAGNETIC-MOB (BOSS-SAFE & NOCLIP) ] -- 🧲
function Functions:StartMagneticMob()
    -- Activation du Noclip automatique pour éviter les morts par collision
    task.spawn(function()
        local noclipConn
        noclipConn = RunService.Stepped:Connect(function()
            if self.Config.MagneticMob and self.Player.Character then
                for _, part in pairs(self.Player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            else
                noclipConn:Disconnect()
            end
        end)
    end)

    task.spawn(function()
        while task.wait() do
            if not self.Config.MagneticMob then break end
            
            pcall(function()
                local root = self.Player.Character and self.Player.Character.HumanoidRootPart
                if not root then return end

                local radius = self.Config.AttackDistance or 50
                local enemyFolder = Workspace:FindFirstChild("Enemies") or Workspace
                
                for _, enemy in pairs(enemyFolder:GetChildren()) do
                    local enRoot = enemy:FindFirstChild("HumanoidRootPart")
                    local enHum = enemy:FindFirstChildOfClass("Humanoid")
                    
                    -- Filtre : Vivant + Pas un Boss (PV < 50k)
                    if enRoot and enHum and enHum.Health > 0 and enHum.MaxHealth < 50000 then
                        local dist = (enRoot.Position - root.Position).Magnitude
                        
                        if dist <= radius then
                            enRoot.CanCollide = false
                            enRoot.CFrame = root.CFrame * CFrame.new(0, 0, -5)
                            enRoot.Velocity = Vector3.new(0,0,0)
                        end
                    end
                end
            end)
        end
    end)
end

-- [ 4. MOTEUR MOUVEMENT & SNIPER ] -- ✈️
function Functions:GhostMove(targetCFrame, instant)
    local root = self.Player.Character and self.Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if instant then root.CFrame = targetCFrame return end

    local bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = (targetCFrame.p - root.Position).Unit * self.Config.Speed
    task.wait(0.1)
    bv:Destroy()
end

function Functions:InitFruitSniper()
    Workspace.ChildAdded:Connect(function(child)
        if self.Config.SniperEnabled and child:IsA("Tool") and child.Name:find("Fruit") then
            local h = child:WaitForChild("Handle", 2)
            if h then
                self:GhostMove(h.CFrame, true)
                firetouchinterest(self.Player.Character.HumanoidRootPart, h, 0)
                firetouchinterest(self.Player.Character.HumanoidRootPart, h, 1)
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", child.Name, child)
            end
        end
    end)
end

-- [ 5. SMART SERVER HOP ] -- 🚀
function Functions:SmartHop()
    local sfUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(sfUrl)) end)
    if success and result.data then
        for _, s in pairs(result.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, self.Player)
                return
            end
        end
    end
end

-- [ 6. EXPORTATION GLOBALE ] -- ✨
_G.Functions = Functions
return Functions