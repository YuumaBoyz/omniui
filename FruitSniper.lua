--[[
    MODULE  : FruitSniper.lua (VERSION v6.1)
    LOGIQUE : Anti-Player Tool Filter + Force Equip + Inventory Check
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

local Sniper = {
    Config = {
        Enabled = true,
        AutoStore = true,
        AntiCamper = true, -- Check 30 studs
        TeleportSafeDist = 5
    },
    IsCollecting = false
}

-- [ 1. VÉRIFICATION DE L'INVENTAIRE (Anti-Stuck) ] --
local function HasFruitInInventory(fruitName)
    local cleanName = fruitName:gsub(" Fruit", "")
    -- Vérification dans le dossier Data (Blox Fruits standard)
    local inventory = Player:FindFirstChild("Data") and Player.Data:FindFirstChild("Inventory")
    if inventory and inventory:FindFirstChild(cleanName) then
        return true
    end
    -- Vérification visuelle dans le Backpack
    if Player.Backpack:FindFirstChild(fruitName) then return true end
    return false
end

-- [ 2. FILTRE ANTI-FAUX POSITIFS ] --
local function IsValidFruit(obj)
    if not obj:IsA("Tool") or not obj:FindFirstChild("Handle") then return false end
    
    -- Un fruit au sol n'a PAS de scripts de combat (contrairement aux outils des joueurs)
    local combatScripts = {"Combat", "Attack", "Skill", "LocalScript"}
    for _, name in pairs(combatScripts) do
        if obj:FindFirstChild(name) then return false end
    end
    
    -- Vérifie si c'est bien un fruit (Blox Fruits met souvent un attribut ou un nom spécifique)
    return obj.Name:find("Fruit") or obj:FindFirstChild("ReturnName")
end

-- [ 3. LOGIQUE DE COLLECTE SÉCURISÉE ] --
function Sniper:Collect(fruit)
    if self.IsCollecting or not self.Config.Enabled then return end
    if not IsValidFruit(fruit) then return end

    -- Vérification Anti-Stuck : Déjà possédé ?
    if HasFruitInInventory(fruit.Name) then
        if _G.Logger then _G.Logger:AddLog("ℹ️ ***[SNIPER]*** : " .. fruit.Name .. " déjà possédé. Ignoré.", Color3.fromRGB(200, 200, 200)) end
        return
    end

    local handle = fruit.Handle
    local char = Player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not hum then return end

    -- Mode Anti-Camper
    if self.Config.AntiCamper then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if (p.Character.HumanoidRootPart.Position - handle.Position).Magnitude < 30 then
                    if _G.Logger then _G.Logger:AddLog("⚠️ ***[SNIPER]*** : Joueur trop proche. Collecte annulée.", Color3.fromRGB(255, 50, 50)) end
                    return
                end
            end
        end
    end

    self.IsCollecting = true
    if _G.Functions then _G.Functions.Config.Paused = true end

    -- TP et Ramassage
    _G.Functions:MoveTo(handle.CFrame * CFrame.new(0, self.Config.TeleportSafeDist, 0))
    task.wait(0.3)
    firetouchinterest(root, handle, 0)
    firetouchinterest(root, handle, 1)
    task.wait(0.2)

    -- FORCE EQUIP (Crucial pour le Store)
    local toolInChar = char:FindFirstChild(fruit.Name) or Player.Backpack:FindFirstChild(fruit.Name)
    if toolInChar then
        hum:EquipTool(toolInChar)
        task.wait(0.3) -- Délai pour que le serveur valide l'équipement
        
        if self.Config.AutoStore then
            local fruitName = fruit.Name:gsub(" Fruit", "")
            if _G.SafeRemoteFire then
                _G.SafeRemoteFire("StoreFruit", fruitName, toolInChar)
            else
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fruitName, toolInChar)
            end
            if _G.Logger then _G.Logger:AddLog("💾 ***[SNIPER]*** : " .. fruitName .. " stocké avec succès !", Color3.fromRGB(0, 255, 150)) end
        end
    end

    self.IsCollecting = false
    if _G.Functions then _G.Functions.Config.Paused = false end
end

-- [ 4. DÉTECTION ] --
Workspace.ChildAdded:Connect(function(child)
    task.wait(0.2)
    if IsValidFruit(child) then
        Sniper:Collect(child)
    end
end)

-- Scan de secours
task.spawn(function()
    while task.wait(5) do
        if Sniper.Config.Enabled and not Sniper.IsCollecting then
            for _, item in pairs(Workspace:GetChildren()) do
                if IsValidFruit(item) then Sniper:Collect(item) end
            end
        end
    end
end)

_G.FruitSniper = Sniper
return Sniper