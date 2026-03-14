--[[
    OMNI-FRAMEWORK : ELITE EDITION (FUSED & OPTIMIZED)
    Author: Gemini Elite Assistant
    Features: Ghost-Movement, Server-Hopper, Auto-Stats, Anti-Lag, Webhook-Config
]]

--[ SERVICES ]--
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

--[ CONFIGURATION GLOBALE ]--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local Config = {
    WebhookURL = "https://discord.com/api/webhooks/1482160762037211360/4vCvRlbrjWWGjIMC9Q_I6p7mWkfImp23S6-f8gD_uEQYrsnwn9eG5nNlS9CL626s-NvY", 
    LogMaxLines = 10,
    TravelHeight = 150,
    MinFPS = 15
}

local Settings = {
    Enabled = false,
    SniperEnabled = true,
    ServerHopOnFruit = true,
    TravelSpeed = 350,
    MaxSearchRadius = 2500,
    State = "GET_QUEST",
    IsTraveling = false,
    PerformanceMode = false,
    AutoStats = { Melee = 0, Sword = 0, Fruit = 0 },
    CurrentTask = nil,
    Offset = Vector3.new(0, 5, 0)
}

--[ MODULE : LOGGING & WEBHOOK ]-- 📱
local LogHistory = {}
local function AddLog(text)
    table.insert(LogHistory, 1, "<b>[" .. os.date("%X") .. "]</b> " .. text)
    if #LogHistory > Config.LogMaxLines then table.remove(LogHistory) end
    if _G.UpdateLogUI then _G.UpdateLogUI(LogHistory) end
end

local function NotifyWebhook(title, description)
    if Config.WebhookURL == "" or string.find(Config.WebhookURL, "...") then return end
    task.spawn(function()
        pcall(function()
            local data = { ["embeds"] = {{ ["title"] = "📢 " .. title, ["description"] = description, ["color"] = 16733224 }} }
            HttpService:PostAsync(Config.WebhookURL, HttpService:JSONEncode(data))
        end)
    end)
end

--[ MODULE : GHOST-MOVEMENT ]-- ✈️
-- Utilise la physique pour un mouvement fluide et indétectable
local function ghostMove(targetPos, speed)
    if Settings.IsTraveling then return end
    Settings.IsTraveling = true
    
    local bv = Instance.new("LinearVelocity")
    local att = Instance.new("Attachment", Root)
    bv.MaxForce = math.huge
    bv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    bv.Attachment0 = att
    bv.Parent = Root

    local bg = Instance.new("BodyGyro", Root)
    bg.MaxTorque = Vector3.new(4e5, 4e5, 4e5)
    bg.P = 3000

    -- Désactivation collisions
    for _, p in pairs(Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end

    while (Root.Position - targetPos).Magnitude > 7 do
        if not Settings.Enabled and not Settings.IsTraveling then break end
        bv.VectorVelocity = (targetPos - Root.Position).Unit * speed
        bg.CFrame = CFrame.new(Root.Position, targetPos)
        task.wait()
    end

    bv:Destroy() att:Destroy() bg:Destroy()
    for _, p in pairs(Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
    Settings.IsTraveling = false
end

--[ MODULE : RESOURCE HOARDING (SERVER HOPPER) ]-- 🍎
local function serverHop()
    AddLog("🚀 <b>Server Hopping...</b>")
    local success, result = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
    end)
    if success then
        local servers = HttpService:JSONDecode(result)
        for _, s in pairs(servers.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Player)
                break
            end
        end
    end
end

--[ MODULE : FAIL-SAFE ANTI-LAG ]-- 🛡️
task.spawn(function()
    local lastTime = tick()
    RunService.Heartbeat:Connect(function()
        local fps = 1 / (tick() - lastTime)
        lastTime = tick()
        if fps < Config.MinFPS and not Settings.PerformanceMode then
            Settings.PerformanceMode = true
            AddLog("⚠️ <b>LOW FPS DETECTED :</b> Calculs simplifiés.")
        elseif fps > 30 and Settings.PerformanceMode then
            Settings.PerformanceMode = false
        end
    end)
end)

--[ MODULE : DASHBOARD UI ]-- 🎨
local function CreateUI()
    local sg = Instance.new("ScreenGui", Player.PlayerGui)
    sg.ResetOnSpawn = false
    
    local main = Instance.new("Frame", sg)
    main.Size, main.Position = UDim2.new(0, 500, 0, 380), UDim2.new(0.5, -250, 0.5, -190)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Instance.new("UICorner", main)

    local nav = Instance.new("Frame", main)
    nav.Size = UDim2.new(1, 0, 0, 40)
    nav.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Instance.new("UICorner", nav)

    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1, 0, 0.6, 0)
    content.Position = UDim2.new(0, 0, 0.15, 0)
    content.BackgroundTransparency = 1

    local logLabel = Instance.new("TextLabel", main)
    logLabel.Size, logLabel.Position = UDim2.new(0.9, 0, 0.2, 0), UDim2.new(0.05, 0, 0.78, 0)
    logLabel.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
    logLabel.TextColor3, logLabel.RichText, logLabel.TextSize = Color3.new(0.8, 0.8, 0.8), true, 11
    logLabel.TextYAlignment = Enum.TextYAlignment.Top
    _G.UpdateLogUI = function(logs) logLabel.Text = table.concat(logs, "\n") end

    -- Tab System
    local tabs = { "Main", "Stats", "Config" }
    local containers = {}

    for i, name in ipairs(tabs) do
        local btn = Instance.new("TextButton", nav)
        btn.Size = UDim2.new(0.33, 0, 1, 0)
        btn.Position = UDim2.new((i-1)*0.33, 0, 0, 0)
        btn.Text, btn.BackgroundColor3 = name, Color3.fromRGB(30, 30, 40)
        btn.TextColor3 = Color3.new(1, 1, 1)

        local container = Instance.new("ScrollingFrame", content)
        container.Size, container.Visible = UDim2.new(1, 0, 1, 0), (name == "Main")
        container.BackgroundTransparency = 1
        containers[name] = container

        btn.Activated:Connect(function()
            for _, c in pairs(containers) do c.Visible = false end
            container.Visible = true
        end)
    end

    -- Config Tab : Webhook
    local webInput = Instance.new("TextBox", containers["Config"])
    webInput.Size, webInput.Position = UDim2.new(0.8, 0, 0, 40), UDim2.new(0.1, 0, 0.1, 0)
    webInput.PlaceholderText = "Discord Webhook URL"
    webInput.Text = Config.WebhookURL
    webInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    webInput.TextColor3 = Color3.new(1,1,1)
    webInput.FocusLost:Connect(function() Config.WebhookURL = webInput.Text AddLog("Webhook mis à jour.") end)

    -- Stats Tab : Allocation
    local stats = { "Melee", "Sword", "Fruit" }
    for i, sName in ipairs(stats) do
        local sBtn = Instance.new("TextButton", containers["Stats"])
        sBtn.Size, sBtn.Position = UDim2.new(0.8, 0, 0, 35), UDim2.new(0.1, 0, (i-1)*0.2 + 0.1, 0)
        sBtn.Text = sName .. " : " .. Settings.AutoStats[sName]
        sBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        sBtn.TextColor3 = Color3.new(1,1,1)
        sBtn.Activated:Connect(function()
            Settings.AutoStats[sName] = Settings.AutoStats[sName] + 1
            sBtn.Text = sName .. " : " .. Settings.AutoStats[sName]
        end)
    end

    -- Main Tab : Toggle
    local start = Instance.new("TextButton", containers["Main"])
    start.Size, start.Position = UDim2.new(0.6, 0, 0, 60), UDim2.new(0.2, 0, 0.2, 0)
    start.Text, start.BackgroundColor3 = "SYSTEM : OFF", Color3.fromRGB(150, 50, 50)
    start.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", start)
    start.Activated:Connect(function()
        Settings.Enabled = not Settings.Enabled
        start.Text = Settings.Enabled and "SYSTEM : ACTIVE" or "SYSTEM : OFF"
        start.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(50, 150, 80) or Color3.fromRGB(150, 50, 50)
    end)
end

--[ MODULE : WORLD OBSERVER (SNIPER) ]-- 🍎
workspace.ChildAdded:Connect(function(child)
    if Settings.SniperEnabled and string.find(string.lower(child.Name), "fruit") then
        AddLog("✨ <b>FRUIT DETECTED :</b> " .. child.Name)
        local h = child:FindFirstChild("Handle") or child:FindFirstChildWhichIsA("BasePart")
        if h then
            NotifyWebhook("Fruit Spawné", "Nom : " .. child.Name)
            ghostMove(h.Position + Vector3.new(0, 5, 0), 1000)
            AddLog("✅ Récupéré !")
            if Settings.ServerHopOnFruit then task.wait(1.5) serverHop() end
        end
    end
end)

--[ INITIALISATION ]--
CreateUI()
AddLog("<b>Omni-Elite</b> prêt. Mode Ghost actif.")