--[[
    MODULE  : ServerHop.lua
    LOGIQUE : HTTP API Search + TeleportService
]]

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"

local function GetRandomServer()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(Api))
    end)
    
    if success and result then
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                return server.id
            end
        end
    end
    return nil
end

_G.Functions.SmartHop = function()
    _G.Logger:AddLog("🚀 ***Changement de serveur...***", Color3.fromRGB(255, 255, 255))
    local serverId = GetRandomServer()
    if serverId then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId)
    else
        _G.Library:Notify("Système", "Aucun serveur trouvé, réessai...")
    end
end