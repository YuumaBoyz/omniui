--[[
    MODULE  : FastAttack.lua
    VERSION : v3.5 (Hook & FPS Overdrive)
]]

local RunService = game:GetService("RunService")
local Player = game:GetService("Players").LocalPlayer

local FastAttack = {
    Enabled = false,
    Distance = 65,
    Increment = 3, -- Triple hit par cycle
    Controller = nil
}

local function GetActiveController()
    if FastAttack.Controller then return FastAttack.Controller end
    -- Scan sécurisé pour Blox Fruits
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "activeController") then
            FastAttack.Controller = v.activeController
            return v.activeController
        end
    end
    return nil
end

local function StripAnimations()
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, track in pairs(hum:GetPlayingAnimationTracks()) do
            if track.Name:find("Attack") or track.Name:find("Slash") then
                track:Stop(0)
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not _G.FastAttack and not FastAttack.Enabled then return end
    if not _G.AutoClick then return end

    pcall(function()
        local controller = GetActiveController()
        if controller then
            -- Manipulation Premium : On "reset" le cooldown à chaque frame
            controller.timeToNextAttack = 0
            controller.attacking = false
            controller.hitboxMagnitude = FastAttack.Distance
            
            -- Multiplication des dégâts (Ghost Hits)
            for i = 1, FastAttack.Increment do
                controller:attack()
            end
            
            StripAnimations()
        end
    end)
end)

return FastAttack