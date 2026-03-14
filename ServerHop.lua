-- Dans ServerHop.lua
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId

-- On s'assure que la table existe pour éviter les erreurs nil
_G.Functions = _G.Functions or {}

local function SmartHop()
    local ApiUrl = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(ApiUrl))
    end)

    if success and result and result.data then
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, game.Players.LocalPlayer)
                return
            end
        end
    end
    -- Si échec, on retente
    task.wait(2)
    SmartHop()
end

_G.Functions.SmartHop = SmartHop
return SmartHop