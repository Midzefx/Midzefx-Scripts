-- THRESHOLD Episode 2 | WindUI | PC + Mobile
-- Client-side only by default. Server tab is opt-in risky single-fire.
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
WindUI:SetNotificationLower(true)

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer

-- run-id so re-execute without live-reload kills old loops
local G = getgenv()
G.__THRESHOLD_EP2 = G.__THRESHOLD_EP2 or {}
G.__THRESHOLD_EP2.runId = (G.__THRESHOLD_EP2.runId or 0) + 1
local MY_RUN = G.__THRESHOLD_EP2.runId
local F = G.__THRESHOLD_EP2.flags or {}
G.__THRESHOLD_EP2.flags = F
local function alive() return G.__THRESHOLD_EP2.runId == MY_RUN end
-- live-reload STATE if present (auto-cleanup, no stacking)
local LS = nil
pcall(function() if typeof(STATE) == "table" then LS = STATE end end)
local function connect(sig, fn)
	if LS and LS.connect then return LS.connect(sig, fn) end
	return sig:Connect(fn)
end

local function notify(t, c)
	pcall(function() WindUI:Notify({ Title = t, Content = c, Duration = 3 }) end)
end
local function char() return LP.Character end
local function hum()
	local c = char()
	if c then return c:FindFirstChildOfClass("Humanoid") end
	return nil
end
local function hrp()
	local c = char()
	if c then return c:FindFirstChild("HumanoidRootPart") end
	return nil
end

local Window = WindUI:CreateWindow({
	Title = "THRESHOLD Ep2",
	Author = "PC + Mobile",
	Folder = "ThresholdEp2",
	Size = UDim2.fromOffset(520, 420),
	MinSize = Vector2.new(460, 320),
	Theme = "Dark",
	Resizable = true,
	AutoScale = true,
	HideSearchBar = false,
	ToggleKey = Enum.KeyCode.K,
	Topbar = { Height = 44, ButtonsType = "Mac" },
	OpenButton = {
		Title = "Threshold",
		Icon = "ghost",
		CornerRadius = UDim.new(0, 12),
		StrokeThickness = 2,
		Enabled = true,
		Draggable = true,
		OnlyMobile = false,
		Scale = 0.8,
		Color = ColorSequence.new(Color3.fromHex("#30FF6A"), Color3.fromHex("#2f9bff")),
	},
	User = { Enabled = true, Anonymous = true },
})

local MoveTab = Window:Tab({ Title = "Movement", Icon = "move" })
local VisTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local IntTab = Window:Tab({ Title = "Interact", Icon = "hand" })
local HorrTab = Window:Tab({ Title = "Horror", Icon = "ghost" })
local ServTab = Window:Tab({ Title = "Server", Icon = "server" })

-- state
F.speed = F.speed or 16
F.flySpeed = F.flySpeed or 35
F.infSprint = F.infSprint or false
F.jumpOn = F.jumpOn or false
F.fly = F.fly or false
F.noclip = F.noclip or false
F.bright = F.bright or false
F.noFX = F.noFX or false
F.noOverlay = F.noOverlay or false
F.lockFOV = F.lockFOV or false
F.fov = F.fov or 70
F.instantE = F.instantE or false
F.reach = F.reach or 17
F.espBat = F.espBat or false
F.espPlr = F.espPlr or false
F.calmHUD = F.calmHUD or false
F.muteHorror = F.muteHorror or false
F.noShake = F.noShake or false

local function applySpeed()
	local h = hum()
	pcall(function()
		LP:SetAttribute("BaseWalkSpeed", F.speed)
		LP:SetAttribute("WalkSpeedMult", 1)
	end)
	if h then pcall(function() h.WalkSpeed = F.speed end) end
end
connect(LP.CharacterAdded, function()
	task.wait(1)
	if alive() then applySpeed() end
end)

-- Movement
MoveTab:Slider({
	Title = "WalkSpeed",
	Desc = "BaseWalkSpeed (Keeper-safe)",
	Step = 1, Width = 200,
	Value = { Min = 16, Max = 60, Default = F.speed },
	Callback = function(v) F.speed = v applySpeed() end,
})
MoveTab:Toggle({ Title = "Infinite Sprint", Desc = "Locks speed while moving", Value = F.infSprint,
	Callback = function(s) F.infSprint = s notify("Sprint", s and "ON" or "OFF") end })
MoveTab:Toggle({ Title = "Enable Jump", Desc = "Game sets Jump 0 — re-enables", Value = F.jumpOn,
	Callback = function(s) F.jumpOn = s notify("Jump", s and "ON" or "OFF") end })
MoveTab:Toggle({ Title = "Fly (joystick safe)", Desc = "Move=fly dir, Jump=up", Value = F.fly,
	Callback = function(s) F.fly = s notify("Fly", s and "ON — joystick + jump" or "OFF") end })
MoveTab:Slider({
	Title = "Fly Speed", Step = 1, Width = 200,
	Value = { Min = 10, Max = 100, Default = F.flySpeed },
	Callback = function(v) F.flySpeed = v end,
})
MoveTab:Toggle({ Title = "Noclip", Value = F.noclip,
	Callback = function(s) F.noclip = s end })
MoveTab:Button({ Title = "Fly Up +6", Callback = function()
	local r = hrp() if r then r.CFrame = r.CFrame + Vector3.new(0, 6, 0) end
end })
MoveTab:Button({ Title = "Fly Down -6", Callback = function()
	local r = hrp() if r then r.CFrame = r.CFrame + Vector3.new(0, -6, 0) end
end })

task.spawn(function()
	while alive() do
		local dt = RunService.RenderStepped:Wait()
		if not alive() then break end
		local h, r = hum(), hrp()
		if h and r then
			if F.infSprint and h.MoveDirection.Magnitude > 0.1 then
				pcall(function() h.WalkSpeed = F.speed end)
			end
			if F.jumpOn then
				pcall(function()
					h.JumpPower = 50 h.JumpHeight = 7.2
					h:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
				end)
			end
			if F.noclip and char() then
				for _, p in ipairs(char():GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
			end
			if F.fly then
				pcall(function()
					h.PlatformStand = true
					local mv = h.MoveDirection
					local up = 0
					if h.Jump then up = 1 end
					if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.C) then up = -1 end
					local delta = (mv * F.flySpeed + Vector3.new(0, up * F.flySpeed * 0.8, 0)) * dt
					r.CFrame = r.CFrame + delta
					r.AssemblyLinearVelocity = Vector3.zero
					r.AssemblyAngularVelocity = Vector3.zero
				end)
			else
				local h2 = hum()
				if h2 then pcall(function() h2.PlatformStand = false end) end
			end
		end
	end
end)

-- Visuals
VisTab:Toggle({ Title = "Fullbright", Desc = "Bright + far fog", Value = F.bright,
	Callback = function(s) F.bright = s end })
VisTab:Toggle({ Title = "No Blur / Bloom / DOF", Value = F.noFX,
	Callback = function(s) F.noFX = s end })
VisTab:Toggle({ Title = "Hide Fear Overlays", Desc = "Ep2Overlay, tunnel, vignette", Value = F.noOverlay,
	Callback = function(s) F.noOverlay = s end })
VisTab:Slider({
	Title = "Field of View", Step = 1, Width = 200,
	Value = { Min = 70, Max = 120, Default = F.fov },
	Callback = function(v) F.fov = v pcall(function() Workspace.CurrentCamera.FieldOfView = v end) end,
})
VisTab:Toggle({ Title = "Lock FOV", Value = F.lockFOV, Callback = function(s) F.lockFOV = s end })

task.spawn(function()
	while alive() do
		task.wait(0.5)
		if not alive() then break end
		if F.bright then
			pcall(function()
				Lighting.Brightness = 2 Lighting.ClockTime = 14
				Lighting.FogStart = 0 Lighting.FogEnd = 100000
				Lighting.Ambient = Color3.new(1,1,1)
				Lighting.OutdoorAmbient = Color3.new(1,1,1)
				Lighting.GlobalShadows = false
			end)
		end
		if F.noFX then
			pcall(function()
				for _, v in ipairs(Lighting:GetChildren()) do
					if v:IsA("BlurEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect")
					or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then v.Enabled = false end
					if v:IsA("Atmosphere") then v.Density = 0 end
				end
			end)
		end
		if F.noOverlay then
			pcall(function()
				local pg = LP:FindFirstChild("PlayerGui") if pg then
					for _, n in ipairs({"Ep2Overlay","Ep2TunnelFX","Ep2TunnelBlack","Ep2ParkingVignette","CutsceneBars","TheCut","Ep2DeathCard"}) do
						local g = pg:FindFirstChild(n)
						if g then
							if g:IsA("ScreenGui") or g:IsA("BillboardGui") then g.Enabled = false
							elseif g:IsA("GuiObject") then g.Visible = false end
						end
					end
				end
			end)
		end
		if F.lockFOV then pcall(function() Workspace.CurrentCamera.FieldOfView = F.fov end) end
	end
end)

-- Interact
IntTab:Toggle({ Title = "Instant Interact", Desc = "HoldDuration = 0", Value = F.instantE,
	Callback = function(s) F.instantE = s end })
IntTab:Slider({
	Title = "Interact Distance", Step = 1, Width = 200,
	Value = { Min = 10, Max = 50, Default = F.reach },
	Callback = function(v) F.reach = v end,
})
IntTab:Toggle({ Title = "ESP Batteries", Value = F.espBat, Callback = function(s) F.espBat = s end })
IntTab:Toggle({ Title = "ESP Players", Value = F.espPlr, Callback = function(s) F.espPlr = s end })
IntTab:Button({ Title = "TP to Nearest Battery", Callback = function()
	local r = hrp() if not r then return end
	local best, bd = nil, 1e9
	for _, d in ipairs(Workspace:GetDescendants()) do
		if d:IsA("ProximityPrompt") and string.find(string.lower(d.Parent and d.Parent.Name or ""), "battery", 1, true) then
			local m = d.Parent:IsA("BasePart") and d.Parent or d.Parent:FindFirstChildOfClass("BasePart")
			local part = m or d:FindFirstAncestorOfClass("BasePart")
			if part then
				local dist = (part.Position - r.Position).Magnitude
				if dist < bd then bd = dist best = part end
			end
		end
	end
	for _, f in ipairs(Workspace:GetDescendants()) do
		if f.Name == "_Ep2Batteries" then
			for _, h in ipairs(f:GetDescendants()) do
				if h:IsA("BasePart") then
					local dist = (h.Position - r.Position).Magnitude
					if dist < bd then bd = dist best = h end
				end
			end
		end
	end
	if best then r.CFrame = best.CFrame + Vector3.new(0, 3, 0) notify("TP", "Battery") else notify("TP", "None found") end
end })

local function tunePrompt(p)
	if F.instantE then pcall(function() p.HoldDuration = 0 end) end
	pcall(function() p.MaxActivationDistance = F.reach end)
end
for _, p in ipairs(Workspace:GetDescendants()) do if p:IsA("ProximityPrompt") then tunePrompt(p) end end
connect(Workspace.DescendantAdded, function(d)
	if d:IsA("ProximityPrompt") then task.wait(0.1) tunePrompt(d) end
end)
task.spawn(function()
	while alive() do
		task.wait(1)
		if not alive() then break end
		if F.instantE then
			for _, p in ipairs(Workspace:GetDescendants()) do
				if p:IsA("ProximityPrompt") and p.HoldDuration ~= 0 then pcall(function() p.HoldDuration = 0 end) end
			end
		end
	end
end)
task.spawn(function()
	while alive() do
		task.wait(2)
		if not alive() then break end
		pcall(function()
			if F.espBat then
				local folder = Workspace:FindFirstChild("_Ep2Batteries")
				if folder then for _, h in ipairs(folder:GetDescendants()) do
					if h:IsA("BasePart") and not h:FindFirstChild("__TH_ESP") then
						local hl = Instance.new("Highlight") hl.Name = "__TH_ESP"
						hl.FillColor = Color3.fromHex("#30FF6A") hl.OutlineColor = Color3.new(1,1,1)
						hl.FillTransparency = 0.5 hl.Parent = h hl.Adornee = h
						if LS then LS.onCleanup(function() pcall(function() hl:Destroy() end) end) end
					end
				end end
			else
				for _, h in ipairs(Workspace:GetDescendants()) do
					if h:IsA("Highlight") and h.Name == "__TH_ESP" then h:Destroy() end
				end
			end
			if F.espPlr then
				for _, pl in ipairs(Players:GetPlayers()) do
					if pl ~= LP and pl.Character and not pl.Character:FindFirstChild("__TH_PESP") then
						local hl = Instance.new("Highlight") hl.Name = "__TH_PESP"
						hl.FillColor = Color3.fromHex("#2f9bff") hl.FillTransparency = 0.6 hl.Parent = pl.Character
						if LS then LS.onCleanup(function() pcall(function() hl:Destroy() end) end) end
					end
				end
			else
				for _, pl in ipairs(Players:GetPlayers()) do
					if pl.Character then local h = pl.Character:FindFirstChild("__TH_PESP") if h then h:Destroy() end end
				end
			end
		end)
	end
end)

-- Horror (visual only)
HorrTab:Toggle({ Title = "Calm Sanity HUD", Desc = "Forces 100% MIND STABLE text", Value = F.calmHUD,
	Callback = function(s) F.calmHUD = s end })
HorrTab:Toggle({ Title = "Mute Horror Stingers", Value = F.muteHorror, Callback = function(s) F.muteHorror = s end })
HorrTab:Toggle({ Title = "No Camera Shake Scripts", Desc = "Disables Ep2CameraFeel", Value = F.noShake,
	Callback = function(s)
		F.noShake = s
		pcall(function()
			local ps = LP:FindFirstChild("PlayerScripts")
			if ps then local f = ps:FindFirstChild("Ep2CameraFeel") if f then f.Disabled = s end end
		end)
	end })
HorrTab:Button({ Title = "Skip Cutscene (solo)", Desc = "Vote + tap Skip", Callback = function()
	pcall(function()
		local rs = game:GetService("ReplicatedStorage")
		local v = rs:FindFirstChild("SkipVote")
		if v then v:FireServer("cutscene:skip") end
		local pg = LP:FindFirstChild("PlayerGui")
		if pg then
			for _, g in ipairs(pg:GetDescendants()) do
				if g:IsA("TextButton") and (g.Name == "Skip" or g.Name == "Advance") and g.Visible then
					pcall(function() g:Activate() end)
				end
			end
		end
		notify("Skip", "Sent")
	end)
end })
task.spawn(function()
	while alive() do
		task.wait(0.5)
		if not alive() then break end
		if F.calmHUD then pcall(function()
			local pg = LP:FindFirstChild("PlayerGui") if not pg then return end
			local hud = pg:FindFirstChild("Ep2SanityHUD") if not hud then return end
			for _, d in ipairs(hud:GetDescendants()) do
				if d:IsA("TextLabel") then
					if d.Name == "Value" then d.Text = "100%" end
					if d.Name == "Status" then d.Text = "MIND STABLE" end
				end
			end
		end) end
		if F.muteHorror then pcall(function()
			for _, d in ipairs(game:GetDescendants()) do
				if d:IsA("Sound") then
					local n = string.lower(d.Name)
					if string.find(n, "sanity", 1, true) or string.find(n, "tinnitus", 1, true)
					or string.find(n, "jumpscare", 1, true) or string.find(n, "lunge", 1, true) then
						d.Volume = 0
					end
				end
			end
		end) end
	end
end)

-- Server (risky single-fire)
ServTab:Dropdown({
	Title = "Chapter", Values = {"road","tostore","store","storedone","runout","tunnelout","findeli","getout","tovan","danny"},
	Value = "runout",
	Callback = function(v) G.__THRESHOLD_EP2.chapter = v end,
})
ServTab:Button({ Title = "Fire Ep2Jump Chapter", Desc = "Dev teleport, may be ignored", Callback = function()
	local ch = G.__THRESHOLD_EP2.chapter or "runout"
	WindUI:Popup({ Title = "Fire Ep2Jump?", Content = "Fires ('chapter','"..tostring(ch).."'). May skip progress.",
		Buttons = {
			{ Title = "Cancel", Variant = "Tertiary" },
			{ Title = "Fire", Variant = "Primary", Callback = function()
				pcall(function()
					game:GetService("ReplicatedStorage"):FindFirstChild("Ep2Jump"):FireServer("chapter", ch)
				end)
				notify("Ep2Jump", tostring(ch))
			end },
		} })
end })
ServTab:Button({ Title = "Try Free Battery (UseItem)", Callback = function()
	task.spawn(function()
		local ok, res = pcall(function()
			return game:GetService("ReplicatedStorage"):FindFirstChild("UseItem"):InvokeServer("batteries")
		end)
		notify("UseItem", "ok="..tostring(ok).." res="..tostring(res))
	end)
end })
ServTab:Button({ Title = "Try Car Done (Ep2Story)", Callback = function()
	pcall(function() game:GetService("ReplicatedStorage"):FindFirstChild("Ep2Story"):FireServer("car", "done") end)
	notify("Ep2Story", "car done sent")
end })
ServTab:Button({ Title = "Try Tunnel Done (Ep2Story)", Callback = function()
	pcall(function() game:GetService("ReplicatedStorage"):FindFirstChild("Ep2Story"):FireServer("tunnel", "done") end)
	notify("Ep2Story", "tunnel done sent")
end })
ServTab:Button({ Title = "Try Cut Done True", Callback = function()
	pcall(function() game:GetService("ReplicatedStorage"):FindFirstChild("CutEvent"):FireServer("done", true) end)
	notify("CutEvent", "done true sent")
end })

applySpeed()
notify("THRESHOLD Ep2", "PC+Mobile loaded — K or Threshold button")
