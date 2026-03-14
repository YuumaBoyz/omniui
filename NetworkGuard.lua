--[[
    MODULE : NetworkGuard.lua
    LOGIQUE : Silenced Remote Calls
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")

local function SafeRemoteFire(remoteName, ...)
    if not Remotes then return end -- Sécurité si le dossier Remotes est absent
    
    local remote = Remotes:FindFirstChild(remoteName)
    if remote and remote:IsA("RemoteEvent") then
        remote:FireServer(...)
    end
    -- Si inexistant, ignore silencieusement.
end

-- Exemple d'utilisation pour CollectedDragonEgg
-- SafeRemoteFire("CollectedDragonEgg", true)