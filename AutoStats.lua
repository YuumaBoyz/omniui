--[[
    MODULE  : AutoStats.lua
    VERSION : v1.0 (Level-Up Sync)
    LOGIQUE : Remote Invocation & Point Distribution
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

-- On récupère la configuration du module principal
local Config = _G.Functions and _G.Functions.Config or { AutoStats = true, TargetStat = "Melee" }

-- [ 1. LOGIQUE DE DISTRIBUTION ] -- 📈
task.spawn(function()
    while true do
        task.wait(1) -- Vérification chaque seconde pour ne pas lagger

        if Config.AutoStats then
            pcall(function()
                -- On récupère les points disponibles
                local points = Player.Data.StatsPoints.Value
                
                if points > 0 then
                    -- Correspondance entre le nom UI et le nom interne du Remote
                    local statMap = {
                        ["Melee"] = "Melee",
                        ["Defense"] = "Defense",
                        ["Sword"] = "Sword",
                        ["Blox Fruit"] = "Demon Fruit" -- Nom interne dans Blox Fruits
                    }

                    local target = statMap[Config.TargetStat] or "Melee"
                    
                    -- Envoi de la requête au serveur pour dépenser TOUS les points
                    -- CommF_ "AddStats" prend en paramètres : (Nom de la stat, Nombre de points)
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", target, points)
                end
            end)
        end
    end
end)

print("✅ [OMNI-PROJECT] Auto-Stats v1.0 activé. 📊")