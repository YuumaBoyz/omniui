--[[
    FICHIER : AutoSkill.lua
    LOGIQUE : Z, X, C (Spam) + V (Ultimate en cas de danger)
]]

local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local AutoSkill = {
    Enabled = false,
    ManaThreshold = 20,
    HpThresholdForV = 40, -- Utilise V si la vie tombe sous 40%
    Skills = {"Z", "X", "C"}
}

function AutoSkill:UseKey(key)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
end

function AutoSkill:Init()
    task.spawn(function()
        while task.wait(0.5) do
            if self.Enabled and _G.CurrentTargetPart then
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local stats = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Energy")
                local maxEnergy = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("MaxEnergy")

                if hum and stats and maxEnergy then
                    local energyPercent = (stats.Value / maxEnergy.Value) * 100
                    local hpPercent = (hum.Health / hum.MaxHealth) * 100
                    
                    -- Logique Z, X, C
                    if energyPercent >= self.ManaThreshold then
                        for _, skill in pairs(self.Skills) do
                            if not self.Enabled or not _G.CurrentTargetPart then break end
                            self:UseKey(skill)
                            task.wait(0.3)
                        end
                    end

                    -- Logique de survie (Touche V)
                    if hpPercent <= self.HpThresholdForV then
                        self:UseKey("V")
                        if _G.Logger then 
                            _G.Logger:AddLog("🛡️ ***ULTIMATE ACTIVÉ (Low HP)***", Color3.fromRGB(255, 50, 50)) 
                        end
                    end
                end
            end
        end
    end)
end

_G.AutoSkill = AutoSkill
return AutoSkill