--[[
    MODULE : Combat&PhysicsGuard.lua
    LOGIQUE : Dynamic Framework Detection & State Fallback
]]

local Player = game:GetService("Players").LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")

-- Récupération dynamique du Framework
local function GetCombatFramework()
    local framework = PlayerScripts:FindFirstChild("CombatFramework")
    
    if not framework then
        -- Tentative de recherche par classe si le nom a changé
        for _, v in pairs(PlayerScripts:GetChildren()) do
            if v:IsA("ModuleScript") and v.Name:find("Combat") then
                return v
            end
        end
        -- Timeout de 5 secondes avant abandon
        local startTime = tick()
        while not framework and tick() - startTime < 5 do
            framework = PlayerScripts:FindFirstChild("CombatFramework")
            task.wait(0.5)
        end
    end
    return framework
end

-- Logique du Double Jump avec gestion du Busy State
local function CanDoubleJump()
    local char = Player.Character
    if not char then return false end
    
    -- Si 'Busy' n'est pas trouvé, FindFirstChild renvoie nil (considéré comme false)
    local isBusy = char:FindFirstChild("Busy")
    
    -- Logique : Si pas de Busy ou Busy.Value == false, on peut sauter
    if not isBusy or (isBusy:IsA("BoolValue") and isBusy.Value == false) then
        return true
    end
    
    return false
end