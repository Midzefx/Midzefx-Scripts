--==================================================
-- FREE UGC OBBY (AFK OR PLAY) | WindUI | by Midzefx
--==================================================

if not game:IsLoaded() then game.Loaded:Wait() end

---------------- GUI ----------------
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "FREE UGC OBBY (AFK OR PLAY)",
    Author = "by Midzefx",
    Folder = "FreeUGCObbyMidzefx",
    Size = UDim2.fromOffset(520, 420),
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.K,
})

local MainTab = Window:Tab({ Title = "Main", Icon = "play" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })
local CreditTab = Window:Tab({ Title = "Credits", Icon = "user" })

---------------- SERVICES ----------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")

local LP = Players.LocalPlayer
local checkpoints = workspace:WaitForChild("Checkpoints")

---------------- STATES ----------------
local AutoWalk = false
local AutoAds = false
local AntiAFK = false
local TweenSpeed = 120

--==================================================
-- AUTO REJOIN
--==================================================
local function AutoRejoin()
    task.wait(3)
    TeleportService:Teleport(game.PlaceId, LP)
end

game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(v)
    if v.Name == "ErrorPrompt" then
        AutoRejoin()
    end
end)

--==================================================
-- AUTO WALK
--==================================================
local MAX_STAGE = 999
_G.LastStage = _G.LastStage or 1
_G.LastCheckpoint = _G.LastCheckpoint

local function UpdateFromCheckpoint()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for i = 1, MAX_STAGE do
        local cp = checkpoints:FindFirstChild(tostring(i))
        if cp and (hrp.Position - cp.Position).Magnitude < 20 then
            _G.LastStage = i
            _G.LastCheckpoint = cp
        end
    end
end

local function SyncStage()
    pcall(function()
        RS.MainRemote:FireServer({ Request = "SetStage", Stage = _G.LastStage })
    end)
end

task.spawn(function()
    while task.wait(0.05) do
        if not AutoWalk then continue end
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if not hrp or not hum then continue end

        hum.MaxHealth = math.huge
        hum.Health = math.huge

        UpdateFromCheckpoint()
        SyncStage()

        local nextStage = _G.LastStage + 1
        local cp = checkpoints:FindFirstChild(tostring(nextStage))
        if cp then
            local dist = (hrp.Position - cp.Position).Magnitude
            local tween = TweenService:Create(
                hrp,
                TweenInfo.new(dist / TweenSpeed, Enum.EasingStyle.Linear),
                {CFrame = cp.CFrame + Vector3.new(0,3,0)}
            )
            tween:Play()
            tween.Completed:Wait()
        end
    end
end)

--==================================================
-- AUTO WATCH ADS
--==================================================
task.spawn(function()
    while task.wait(2) do
        if AutoAds then
            pcall(function()
                RS.MainRemote:FireServer({ Request = "Ad" })
            end)
        end
    end
end)

--==================================================
-- ANTI AFK
--==================================================
LP.Idled:Connect(function()
    if AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

--==================================================
-- REDEEM CODES
--==================================================
local Codes = {
    "450K","500K","600K","FREEUGCDROP","400K","550K",
    "GAMDISBACK","JANUARY2026","DAILYREWARDS","WELCOME","STARTER"
}

local function RedeemAll()
    for _,c in ipairs(Codes) do
        pcall(function()
            RS.MainRemote:FireServer({ Request="RedeemCode", CodeStr=c })
        end)
    end
    WindUI:Notify({ Title = "Redeem", Content = "All codes sent!", Duration = 3, Icon = "check" })
end

--==================================================
-- MAIN TAB
--==================================================
MainTab:Toggle({
    Title = "Auto Walk",
    Desc = "Tween through checkpoints",
    Value = false,
    Callback = function(v) AutoWalk = v end,
})

MainTab:Slider({
    Title = "Tween Speed",
    Desc = "Studs/sec (higher = faster)",
    Value = { Min = 20, Max = 120, Default = 100 },
    Step = 5,
    Callback = function(v) TweenSpeed = v end,
})

MainTab:Toggle({
    Title = "Auto Watch Ads",
    Value = false,
    Callback = function(v) AutoAds = v end,
})

MainTab:Toggle({
    Title = "Anti AFK",
    Value = false,
    Callback = function(v) AntiAFK = v end,
})

MainTab:Button({
    Title = "Redeem Codes",
    Desc = "Redeem all UGC codes",
    Callback = function() RedeemAll() end,
})

--==================================================
-- SETTINGS TAB
--==================================================
SettingsTab:Keybind({
    Title = "UI Toggle Key",
    Desc = "Key to open / close UI",
    Value = "K",
    Callback = function(v)
        pcall(function()
            Window:SetToggleKey(Enum.KeyCode[v])
        end)
    end,
})

--==================================================
-- CREDITS
--==================================================
CreditTab:Paragraph({ Title = "Created by", Desc = "Midzefx" })
CreditTab:Paragraph({ Title = "UI", Desc = "WindUI" })
CreditTab:Paragraph({ Title = "Game", Desc = "FREE UGC OBBY (AFK OR PLAY)" })

WindUI:Notify({ Title = "Loaded", Content = "FREE UGC OBBY by Midzefx | Press K for UI", Duration = 4, Icon = "check" })
