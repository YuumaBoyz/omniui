--[[
    MODULE  : PhysicModule.lua
    LOGIQUE : Gestion du Fly et Noclip
]]

local Physics = {}
local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")

-- Fonction de notification sécurisée
local function SendNotification(title, msg)
    -- On vérifie si la librairie et la méthode Notify existent
    if _G.Library and _G.Library.Notify then
        _G.Library:Notify(title, msg)
    else
        -- Fallback simple si l'UI n'est pas encore chargée
        print("[" .. tostring(title) .. "]: " .. tostring(msg))
    end
end

function Physics:ToggleFly(state, speed)
    self.Flying = state
    self.Speed = speed or 300
    
    if state then
        SendNotification("Physique", "Mode Vol Activé ✈️") -- Utilise la fonction sécurisée
        self:StartFlyLoop()
    else
        SendNotification("Physique", "Mode Vol Désactivé 🛑")
    end
end

function Physics:StartFlyLoop()
    task.spawn(function()
        while self.Flying and task.wait() do
            pcall(function()
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    -- Logique de vol simplifiée
                    root.Velocity = Vector3.new(0, 0.1, 0) 
                end
            end)
        end
    end)
end

return Physics