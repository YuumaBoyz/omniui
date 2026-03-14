--[[
    FICHIER : OmniFunctions.lua
    UTILITÉ : Moteur Logique (Mouvement, Sniper, Combat, Server Hop & Debug)
    VERSION : Elite Fusion v3.7 (Robust Framework & Clipboard)
]]

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LogService = game:GetService("LogService")

local Functions = {
    Config = {
        -- Mouvement & Sniper
        Speed = 300,
        SniperEnabled = false,
        WhiteList = {"Leopard Fruit", "Dragon Fruit", "Dough Fruit", "Kitsune Fruit"},
        Rarities = {"Rare", "Legendary", "Mythical"},
        
        -- Combat
        FastAttack = false,
        AutoClicker = false,
        AttackDistance = 15,
        AntiAFK = true
    },
    Player = Players.LocalPlayer,
    DebugLogs = {} -- Stockage des logs pour exportation
}

-- [ 0. SYSTÈME DE CAPTURE DE DEBUG ] -- 🛠️
LogService.MessageOut:Connect(function(message, messageType)
    local timestamp = os.date("%H:%M:%S")
    local prefix = "[" .. timestamp .. "] [" .. tostring(messageType) .. "] "
    table.insert(Functions.DebugLogs, prefix .. message)
    
    -- Limitation de la table pour économiser la mémoire (500 entrées max)
    if #Functions.DebugLogs > 500 then
        table.remove(Functions.DebugLogs, 1)
    end
end)

-- Fonction pour le Copier-Coller direct (Presse-papier)
function Functions:CopyLogsToClipboard()
    local success, err = pcall(function()
        local content = "--- OMNI-ELITE DEBUG EXPORT (" .. os.date("%d/%m/%Y %H:%M:%S") .. ") ---\n\n"
        content = content .. table.concat(self.DebugLogs, "\n")
        
        if setclipboard then
            setclipboard(content)
            -- Backup fichier si supporté
            if writefile then pcall(function() writefile("OMNI_DEBUG_LOGS.txt", content) end) end
        else
            error("L'exécuteur ne supporte pas setclipboard")
        end
    end)
    return success, err
end

-- [ 1. MOTEUR GHOST-MOVEMENT ] -- ✈️
function Functions:GhostMove(targetCFrame, instant)
    local char = self.Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart

    if instant then
        root.Velocity = Vector3.new(0,0,0)
        root.CFrame = targetCFrame
        return
    end

    local bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0,0,0)

    local noclip = RunService.Stepped:Connect(function()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)

    while (root.Position - targetCFrame.p).Magnitude > 10 and self.Config.SniperEnabled do
        bv.Velocity = (targetCFrame.p - root.Position).Unit * self.Config.Speed
        task.wait()
    end

    bv:Destroy()
    noclip:Disconnect()
end

-- [ 2. MODULE FRUIT SNATCHER (INSTANT) ] -- 🍓
function Functions:InitFruitSniper()
    Workspace.ChildAdded:Connect(function(child)
        if not self.Config.SniperEnabled then return end
        if child:IsA("Tool") and string.find(child.Name, "Fruit") then
            local handle = child:WaitForChild("Handle", 2)
            if handle then
                if _G.Logger then _G.Logger:AddLog("🎯 FRUIT APPARU : ***" .. child.Name .. "***", Color3.fromRGB(255, 150, 0)) end
                self:GhostMove(handle.CFrame, true)
                
                firetouchinterest(self.Player.Character.HumanoidRootPart, handle, 0)
                firetouchinterest(self.Player.Character.HumanoidRootPart, handle, 1)
                
                task.wait(0.3)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", child.Name, child)
            end
        end
    end)
end

-- [ 3. SMART SERVER HOPPER ] -- 🚀
function Functions:SmartHop()
    if _G.Logger then _G.Logger:AddLog("🌐 Recherche d'un serveur frais...", Color3.fromRGB(200, 200, 200)) end
    local sfUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(sfUrl))
    end)

    if success and result.data then
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, self.Player)
                return
            end
        end
    end
    if _G.Logger then _G.Logger:AddLog("❌ Échec du Hop. Nouvelle tentative...", Color3.fromRGB(255, 50, 50)) end
end

function Functions:StartSmartScan()
    task.spawn(function()
        while task.wait(5) do
            if not self.Config.SniperEnabled then break end
            
            local fruitFound = false
            for _, item in pairs(Workspace:GetChildren()) do
                if item:IsA("Tool") and string.find(item.Name, "Fruit") then
                    for _, elite in pairs(self.Config.WhiteList) do
                        if item.Name:find(elite) then
                            if _G.Logger then _G.Logger:AddLog("💎 FRUIT ÉLITE DÉTECTÉ : ***" .. item.Name .. "***. Hop annulé.", Color3.fromRGB(255, 0, 0)) end
                            return 
                        end
                    end
                    fruitFound = true 
                    self:GhostMove(item.Handle.CFrame, true)
                end
            end
            
            if not fruitFound then
                if _G.Logger then _G.Logger:AddLog("⏳ Serveur vide. Server Hop dans 1s...", Color3.fromRGB(150, 150, 150)) end
                task.wait(1)
                self:SmartHop()
            end
        end
    end)
end

-- [ 4. MODULE FAST ATTACK & COMBAT ] -- ⚡
function Functions:EnableFastAttack()
    task.spawn(function()
        -- On attend activement que le Framework soit chargé par le jeu
        local playerScripts = self.Player:WaitForChild("PlayerScripts", 10)
        local combatPath = playerScripts:WaitForChild("CombatFramework", 5)
        
        if not combatPath then 
            warn("⚠️ OMNI-DEBUG : CombatFramework introuvable.")
            return 
        end

        local success, CombatFramework = pcall(require, combatPath)
        local _, CameraShaker = pcall(require, game:GetService("ReplicatedStorage").Util.CameraShaker)
        
        if CameraShaker then pcall(function() CameraShaker:Stop() end) end
        if not success then return end
        
        while task.wait() do
            if self.Config.FastAttack then
                pcall(function()
                    if CombatFramework.activeController then
                        CombatFramework.activeController.hitboxMagnitude = 50
                        CombatFramework.activeController.active = true
                        CombatFramework.activeController.focusStart = 0
                    end
                end)
            end
        end
    end)
end

function Functions:StartAutoClick()
    task.spawn(function()
        local VirtualUser = game:GetService("VirtualUser")
        while task.wait(0.1) do
            if self.Config.AutoClicker then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0,0))
                
                if self.Config.FastAttack then
                    local hum = self.Player.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        for _, anim in pairs(hum:GetPlayingAnimationTracks()) do
                            if anim.Name:find("Attack") or anim.Name:find("Slash") then anim:Stop() end
                        end
                    end
                end
            end
        end
    end)
end

-- [ EXPORTATION GLOBALE ] --
_G.Functions = Functions
return Functions