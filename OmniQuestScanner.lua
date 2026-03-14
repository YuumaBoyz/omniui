--[[
    FICHIER : OmniQuestScanner.lua
    VERSION : v5.8 (Elite-Scan & Distance Guard)
]]

local QuestScanner = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

function QuestScanner:GetBestQuest()
    local Player = Players.LocalPlayer
    local PlayerLevel = Player.Data.Level.Value
    local BestNPC, MinDist = nil, math.huge
    local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    
    if not myRoot then return nil end

    for _, npc in pairs(Workspace:GetDescendants()) do
        -- 🔍 Scan intelligent par nom et contenu
        if npc:IsA("Model") and (npc.Name:find("Quest") or npc:FindFirstChild("Quest")) then
            local root = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
            if root then
                local dist = (myRoot.Position - root.Position).Magnitude
                local levelReq = npc.Name:match("%d+")
                
                -- ✅ Filtre : Niveau requis + proximité relative
                if levelReq and tonumber(levelReq) <= PlayerLevel then
                    if dist < MinDist then 
                        MinDist = dist
                        BestNPC = npc 
                    end
                end
            end
        end
    end
    return BestNPC
end

task.spawn(function()
    while true do
        task.wait(1)
        local Ops = _G.Functions
        -- 🛡️ Sécurité : On ne farm que si EliteFarm est ON et si on n'est pas "Busy"
        if Ops and Ops.Config.EliteFarm and _G.CanDoubleJump() then
            pcall(function()
                local questUI = Players.LocalPlayer.PlayerGui.Main:FindFirstChild("Quest")
                if not questUI or not questUI.Visible then
                    local target = QuestScanner:GetBestQuest()
                    if target then
                        local dist = (Players.LocalPlayer.Character.HumanoidRootPart.Position - target.PrimaryPart.Position).Magnitude
                        
                        -- 🚀 Protection : Si trop loin (> 2500), on attend ou on hop
                        if dist < 2500 then
                            if _G.Logger then _G.Logger:AddLog("🌾 ***[FARM]*** : Direction -> " .. target.Name, Color3.fromRGB(255, 255, 0)) end
                            Ops:MoveTo(target.PrimaryPart.CFrame * CFrame.new(0, 0, 3))
                            _G.SafeRemoteFire("StartQuest", target.Name, 1)
                        end
                    end
                end
            end)
        end
    end
end)

return QuestScanner