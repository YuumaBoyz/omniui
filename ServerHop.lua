--[[
    MODULE  : ServerHop.lua
    VERSION : v2.0 (Deep Search & Error Handling)
]]

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId
local ApiUrl = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"

-- Liste des serveurs testés pour éviter les boucles
local ServersVisited = {}

local function GetBestServer(cursor)
    local url = ApiUrl .. (cursor and "&cursor=" .. cursor or "")
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    
    if success and result and result.data then
        for _, server in pairs(result.data) do
            if type(server) == "table" and server.playing and server.maxPlayers then
                if server.playing < server.maxPlayers and server.id ~= game.JobId and not ServersVisited[server.id] then
                    return server.id
                end
            end
        end
        
        -- Si aucun serveur trouvé sur cette page, on check la page suivante
        if result.nextPageCursor then
            return GetBestServer(result.nextPageCursor)
        end
    end
    return nil
end

_G.Functions.SmartHop = function()
    if _G.Logger then 
        _G.Logger:AddLog("📡 ***Recherche d'un nouveau serveur...***", Color3.fromRGB(200, 255, 255)) 
    end

    local serverId = GetBestServer()
    
    if serverId then
        ServersVisited[serverId] = true -- On marque comme testé
        
        -- Protection Anti-Crash avant TP
        pcall(function()
            if _G.SaveManager then _G.SaveManager:Save(_G.Functions.Config) end
            TeleportService:TeleportToPlaceInstance(PlaceId, serverId, game.Players.LocalPlayer)
        end)
    else
        if _G.Library then 
            _G.Library:Notify("Système", "Aucun serveur disponible. Nouvelle tentative dans 5s.") 
        end
        task.wait(5)
        _G.Functions.SmartHop()
    end
end

-- Gestion des erreurs de téléportation (Serveur plein entre-temps)
TeleportService.TeleportInitFailed:Connect(function()
    _G.Functions.SmartHop()
end)

return _G.Functions.SmartHop