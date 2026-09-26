-- ANMU HORROR Hub | Smooth Clean UI (WindUI)
-- Features: ESP (Monster, Keys, Codes, Wardrobes, Lighters, Wrench) + Movement (Unlimited Stamina, WalkSpeed, Sprint Speed, Fake Hold-Sprint)

local cloneref = (cloneref or clonereference or function(i) return i end)
local Players = cloneref(game:GetService("Players"))
local Workspace = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local UserInputService = cloneref(game:GetService("UserInputService"))

local LocalPlayer = Players.LocalPlayer

-- Load WindUI
local WindUI
do
    local ok, res = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)
    if ok and res then
        WindUI = res
    else
        warn("[ANMU Hub] Failed to load WindUI: " .. tostring(res))
        return
    end
end

-- State
local State = {
    ESP = {
        Monster = false,
        Keys = false,
        Codes = false,
        Wardrobes = false,
        Lighters = false,
        Wrench = false,
        ShowDistance = true,
        MaxDistance = 800,
    },
    Movement = {
        UnlimitedStamina = false,
        WalkEnabled = false,
        WalkSpeed = 16,
        SprintEnabled = false,
        SprintSpeed = 24,
        FakeSprintEnabled = false,
        FakeSprintKey = Enum.KeyCode.LeftShift,
        FakeSprintSpeed = 26,
        _fakeHolding = false,
        ShowMobileButton = UserInputService.TouchEnabled,
        MobileToggleMode = false,
        _mobileToggleOn = false,
        _sprintPress = nil,
    },
    UI = {
        ShowHubButton = true,
    },
}

-- ESP Config
local ESPConfig = {
    Monster = { Color = Color3.fromHex("#FF3B3B"), Label = "MONSTER" },
    Keys = { Color = Color3.fromHex("#FFC800"), Label = "KEY" },
    Codes = { Color = Color3.fromHex("#00E5FF"), Label = "CODE" },
    Wardrobes = { Color = Color3.fromHex("#2EFF6A"), Label = "WARDROBE" },
    Lighters = { Color = Color3.fromHex("#FF8A00"), Label = "LIGHTER" },
    Wrench = { Color = Color3.fromHex("#B366FF"), Label = "WRENCH" },
}

local espFolderName = "ANMU_Hub_ESP"
local function getEspFolder()
    local f = CoreGui:FindFirstChild(espFolderName)
    if not f then
        f = Instance.new("Folder")
        f.Name = espFolderName
        f.Parent = CoreGui
    end
    return f
end

local espCache = {} -- [instance] = {highlight, billboard, label, anchor, category}

local function getAnchor(obj)
    if obj:IsA("BasePart") then
        return obj
    end
    if obj:IsA("Model") then
        if obj.PrimaryPart and obj.PrimaryPart:IsA("BasePart") then
            return obj.PrimaryPart
        end
        local hrp = obj:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:IsA("BasePart") then return hrp end
        -- Wardrobes: prefer big body part over hinges
        if obj.Name == "LemariHidePlace" then
            local lemari = obj:FindFirstChild("Lemari", true)
            if lemari then
                for _, d in ipairs(lemari:GetDescendants()) do
                    if d:IsA("BasePart") and d.Name == "Part" then
                        return d
                    end
                end
                local b = lemari:FindFirstChildWhichIsA("BasePart", true)
                if b then return b end
            end
        end
        local handle = obj:FindFirstChild("Handle") or obj:FindFirstChild("lighter") or obj:FindFirstChild("Mask")
        if handle and handle:IsA("BasePart") then return handle end
        local first = obj:FindFirstChildWhichIsA("BasePart", true)
        if first then return first end
        -- fallback bounding box (wardrobes with no direct part)
        local ok, _ = pcall(function() return obj:GetBoundingBox() end)
        if ok then
            -- return first descendant part anyway
            for _, d in ipairs(obj:GetDescendants()) do
                if d:IsA("BasePart") then return d end
            end
        end
    end
    return nil
end

local function getCategory(obj)
    local n = obj.Name
    local ln = string.lower(n)
    -- Monster (exact Model in Workspace)
    if n == "Monster" and obj:IsA("Model") then
        return "Monster"
    end
    -- Keys: Key666, Key91, generic Key%d
    if obj:IsA("Model") and (ln:match("^key%d+") or n == "Key") then
        return "Keys"
    end
    -- Codes: Code1..Code4 (Part with CodePrompt)
    if ln:match("^code%d+") or ln == "code" then
        return "Codes"
    end
    if obj:FindFirstChild("CodePrompt", true) and (obj:IsA("BasePart") or obj:IsA("Model")) then
        -- avoid false positive on shelf models that contain codes as children:
        -- only if the object itself is named Code*
        if ln:find("code") and not ln:find("prompt") then
            return "Codes"
        end
    end
    -- Wrench
    if n == "Wrench" or ln == "wrench" then
        return "Wrench"
    end
    -- Lighter: Korek_Lighter
    if n == "Korek_Lighter" or n == "lighter" or ln:find("korek") or (ln:find("lighter") and obj:IsA("Model")) then
        return "Lighters"
    end
    -- Wardrobes: LemariHidePlace ONLY (not generic Lemari shelf)
    if n == "LemariHidePlace" then
        return "Wardrobes"
    end
    return nil
end

local function createESP(obj, category)
    if espCache[obj] then return espCache[obj] end
    local cfg = ESPConfig[category]
    if not cfg then return nil end
    local anchor = getAnchor(obj)
    if not anchor then return nil end

    local hl = Instance.new("Highlight")
    hl.Name = "ANMU_ESP_HL"
    hl.Adornee = obj:IsA("Model") and obj or obj
    hl.FillColor = cfg.Color
    hl.OutlineColor = cfg.Color
    hl.FillTransparency = 0.55
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = getEspFolder()

    local bb = Instance.new("BillboardGui")
    bb.Name = "ANMU_ESP_BB"
    bb.Adornee = anchor
    bb.Size = UDim2.fromOffset(200, 50)
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop = true
    bb.Parent = getEspFolder()

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextColor3 = cfg.Color
    label.TextStrokeTransparency = 0.2
    label.Text = cfg.Label
    label.Parent = bb

    local entry = { highlight = hl, billboard = bb, label = label, anchor = anchor, category = category, cfg = cfg, obj = obj }
    espCache[obj] = entry
    -- auto cleanup when instance removed
    task.spawn(function()
        local ok = pcall(function() return obj.AncestryChanged:Wait() end)
        if ok then
            -- will be cleaned on next refresh if not valid; also destroy now if destroyed
            task.wait(0.2)
            if not obj:IsDescendantOf(game) then
                removeESP(obj)
            end
        end
    end)
    return entry
end

function removeESP(obj)
    local e = espCache[obj]
    if e then
        pcall(function() e.highlight:Destroy() end)
        pcall(function() e.billboard:Destroy() end)
        espCache[obj] = nil
    end
end

local function clearAllESP()
    for obj, _ in pairs(espCache) do
        removeESP(obj)
    end
end

local function isESPEnabled(category)
    return State.ESP[category] == true
end

local function refreshESP()
    local folder = getEspFolder()
    -- remove disabled / invalid
    for obj, entry in pairs(espCache) do
        local shouldKeep = false
        if obj and typeof(obj) == "Instance" and obj:IsDescendantOf(game) then
            local cat = getCategory(obj)
            if cat and cat == entry.category and isESPEnabled(cat) then
                -- re-resolve anchor in case PrimaryPart changed
                local a = getAnchor(obj)
                if a then
                    entry.anchor = a
                    entry.billboard.Adornee = a
                    shouldKeep = true
                end
            end
        end
        if not shouldKeep then
            removeESP(obj)
        end
    end

    -- quick exit if all off
    if not (State.ESP.Monster or State.ESP.Keys or State.ESP.Codes or State.ESP.Wardrobes or State.ESP.Lighters or State.ESP.Wrench) then
        return
    end

    -- scan targets: limit to known containers for speed + fallback global Monster
    local toScan = {}
    local function push(inst)
        if inst then table.insert(toScan, inst) end
    end
    push(Workspace:FindFirstChild("Kamar"))
    push(Workspace:FindFirstChild("LemariLuar"))
    push(Workspace:FindFirstChild("Brankas"))
    push(Workspace:FindFirstChild("Monster"))
    -- Build may contain wardrobes? Kamar covers most; also scan top-level Workspace for Monster only (cheap)
    -- Full descendant scan of those containers
    for _, root in ipairs(toScan) do
        local ok, desc = pcall(function() return root:GetDescendants() end)
        if not ok then continue end
        -- include root itself (Monster model)
        local list
        if root.Name == "Monster" then
            list = { root }
        else
            list = desc
            -- also check root if it matches (e.g. wardrobes at top of LemariLuar are children, covered)
        end
        for _, v in ipairs(list) do
            -- fast name prefilter
            local nm = v.Name
            local match = false
            if nm == "Monster" or nm == "Wrench" or nm == "LemariHidePlace" or nm == "Korek_Lighter" or nm == "lighter" then
                match = true
            elseif string.sub(nm, 1, 3) == "Key" or string.sub(nm, 1, 4) == "Code" then
                match = true
            end
            if match then
                local cat = getCategory(v)
                if cat and isESPEnabled(cat) and not espCache[v] then
                    -- avoid tagging child parts of already-tagged models (e.g. Handle inside Key model)
                    -- only tag Model for Keys/Wrench/Lighter/Monster/Wardrobe, BasePart for Codes
                    local valid = false
                    if cat == "Codes" and v:IsA("BasePart") then valid = true end
                    if (cat == "Monster" or cat == "Keys" or cat == "Wrench" or cat == "Lighters" or cat == "Wardrobes") and v:IsA("Model") then valid = true end
                    if valid then
                        pcall(createESP, v, cat)
                    end
                end
            end
            if #list > 60000 then break end
        end
    end
    -- Monster may be outside those (it IS Workspace.Monster, already pushed). Done.
end

-- distance + label updater (every frame, cheap)
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hpos = hrp and hrp.Position or nil
    for _, entry in pairs(espCache) do
        local ok, apos = pcall(function() return entry.anchor.Position end)
        if ok and apos and hpos then
            local dist = (hpos - apos).Magnitude
            if dist > State.ESP.MaxDistance then
                entry.billboard.Enabled = false
                entry.highlight.Enabled = false
            else
                entry.billboard.Enabled = true
                entry.highlight.Enabled = true
                if State.ESP.ShowDistance then
                    entry.label.Text = string.format("%s [%dm]", entry.cfg.Label, math.floor(dist + 0.5))
                else
                    entry.label.Text = entry.cfg.Label
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        local ok, err = pcall(refreshESP)
        if not ok then warn("[ANMU ESP] " .. tostring(err)) end
        task.wait(1)
    end
end)

-- Movement logic
-- Fake sprint has top priority: while held (or tap-toggled on mobile),
-- force WalkSpeed every frame, ignoring IsSprinting / server stamina.
-- Release (or second tap) restores normal behaviour.
local function fakeSprintActive()
    if not State.Movement.FakeSprintEnabled then return false end
    if State.Movement._fakeHolding then return true end
    if State.Movement.MobileToggleMode and State.Movement._mobileToggleOn then return true end
    return false
end
local function applyMovement()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if fakeSprintActive() then
            if hum.WalkSpeed ~= State.Movement.FakeSprintSpeed then
                hum.WalkSpeed = State.Movement.FakeSprintSpeed
            end
        else
            local sprinting = LocalPlayer:GetAttribute("IsSprinting") == true
            if State.Movement.WalkEnabled or State.Movement.SprintEnabled then
                if sprinting and State.Movement.SprintEnabled then
                    if hum.WalkSpeed ~= State.Movement.SprintSpeed then
                        hum.WalkSpeed = State.Movement.SprintSpeed
                    end
                elseif State.Movement.WalkEnabled then
                    if hum.WalkSpeed ~= State.Movement.WalkSpeed then
                        hum.WalkSpeed = State.Movement.WalkSpeed
                    end
                end
            end
        end
    end
    if State.Movement.UnlimitedStamina then
        local max = LocalPlayer:GetAttribute("MaxStamina") or 130
        pcall(function()
            LocalPlayer:SetAttribute("Stamina", max)
        end)
    end
end
RunService.RenderStepped:Connect(applyMovement)

-- Hold-to-sprint input: hold key = sprint, release = stop.
-- Ignores keypresses while typing in a TextBox so UI input still works.
-- Track keyboard hold separately so touch button + keyboard don't fight each other.
State.Movement._keyHolding = false
State.Movement._buttonHolding = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode == State.Movement.FakeSprintKey then
        State.Movement._keyHolding = true
        State.Movement._fakeHolding = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == State.Movement.FakeSprintKey then
        State.Movement._keyHolding = false
        State.Movement._fakeHolding = State.Movement._buttonHolding or false
    end
    -- Only the finger that pressed the sprint button releases it.
    -- (Old code cleared on ANY touch end, which killed sprint when a
    -- second finger lifted after swiping the camera.)
    if State.Movement._sprintPress and input == State.Movement._sprintPress then
        State.Movement._sprintPress = nil
        State.Movement._buttonHolding = false
        State.Movement._fakeHolding = State.Movement._keyHolding or false
    end
end)

-- (keyboard + button share _fakeHolding = _keyHolding or _buttonHolding; handlers above keep it in sync)

-- Mobile sprint button (right side, right-thumb).
-- Distinct ⚡ look so it can't be confused with the game's RUN button.
-- Two modes: Hold (press-and-hold) or Tap (tap on/off — frees the thumb
-- so you can swipe the camera while sprinting). Drag the button to move it
-- out of your camera-swipe path.
local MobileGui, MobileBtn, MobileBtnLabel
local function getGuiParent()
    local ok, hui = pcall(function() return gethui() end)
    if ok and hui then return hui end
    return CoreGui
end
local function updateMobileBtnVisual()
    if not MobileBtn then return end
    pcall(function()
        local active = fakeSprintActive()
        MobileBtn.BackgroundColor3 = active and Color3.fromHex("#2EFF6A") or Color3.fromHex("#14141c")
        MobileBtnLabel.TextColor3 = active and Color3.fromHex("#0a0a0a") or Color3.fromHex("#ffffff")
        if State.Movement.MobileToggleMode then
            MobileBtnLabel.Text = active and "⚡\nSPRINT\nON" or "⚡\nTAP\nSPRINT"
        else
            MobileBtnLabel.Text = active and "⚡\nSPRINTING" or "⚡\nHOLD\nSPRINT"
        end
    end)
end
local function createMobileButton()
    if MobileGui then
        pcall(function() MobileGui.Enabled = true end)
        return
    end
    local gui = Instance.new("ScreenGui")
    gui.Name = "ANMU_Hub_MobileSprint"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999
    gui.Parent = getGuiParent()
    MobileGui = gui
    local btn = Instance.new("TextButton")
    btn.Name = "HoldSprint"
    btn.AnchorPoint = Vector2.new(1, 0.5)
    btn.Position = UDim2.new(1, -24, 0.45, 0)
    btn.Size = UDim2.fromOffset(80, 80)
    btn.BackgroundColor3 = Color3.fromHex("#14141c")
    btn.BackgroundTransparency = 0.08
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Font = Enum.Font.GothamBold
    btn.Text = ""
    btn.Parent = gui
    MobileBtn = btn
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromHex("#2EFF6A")
    stroke.Transparency = 0.15
    stroke.Parent = btn
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.LineHeight = 1.05
    label.TextColor3 = Color3.fromHex("#ffffff")
    label.Text = "⚡\nHOLD\nSPRINT"
    label.Parent = btn
    MobileBtnLabel = label
    -- Press tracks its OWN touch so a second finger swiping the camera
    -- never steals or kills the sprint hold. Drag repositions instead.
    local pressInput, pressStart, btnStart, dragged = nil, nil, nil, false
    btn.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseButton1 then return end
        if not State.Movement.FakeSprintEnabled then return end
        pressInput, pressStart, btnStart, dragged = input, input.Position, btn.Position, false
        if not State.Movement.MobileToggleMode then
            State.Movement._sprintPress = input
            State.Movement._buttonHolding = true
            State.Movement._fakeHolding = true
            updateMobileBtnVisual()
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input ~= pressInput then return end
        local t = input.UserInputType
        if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseMovement then return end
        if (input.Position - pressStart).Magnitude > 14 then
            dragged = true
            btn.Position = UDim2.new(
                btnStart.X.Scale, btnStart.X.Offset + (input.Position.X - pressStart.X),
                btnStart.Y.Scale, btnStart.Y.Offset + (input.Position.Y - pressStart.Y)
            )
            -- reposition drag cancels this press's sprint (tap-toggle flips nothing)
            if State.Movement._sprintPress == pressInput then
                State.Movement._sprintPress = nil
                State.Movement._buttonHolding = false
                State.Movement._fakeHolding = State.Movement._keyHolding or false
                updateMobileBtnVisual()
            end
        end
    end)
    local function finishPress(input)
        if input ~= pressInput then return end
        pressInput = nil
        if dragged then return end -- was a move, not a tap
        if State.Movement.MobileToggleMode then
            if State.Movement.FakeSprintEnabled then
                State.Movement._mobileToggleOn = not State.Movement._mobileToggleOn
                updateMobileBtnVisual()
            end
        else
            if State.Movement._sprintPress == input then
                State.Movement._sprintPress = nil
                State.Movement._buttonHolding = false
                State.Movement._fakeHolding = State.Movement._keyHolding or false
                updateMobileBtnVisual()
            end
        end
    end
    btn.InputEnded:Connect(finishPress)
    -- Mouse fallback for PC testing (no InputObject tracking needed there).
    btn.MouseButton1Down:Connect(function()
        if State.Movement.FakeSprintEnabled and not State.Movement.MobileToggleMode then
            State.Movement._buttonHolding = true
            State.Movement._fakeHolding = true
            updateMobileBtnVisual()
        end
    end)
    btn.MouseButton1Up:Connect(function()
        if not State.Movement.MobileToggleMode then
            State.Movement._buttonHolding = false
            State.Movement._fakeHolding = State.Movement._keyHolding or false
            updateMobileBtnVisual()
        end
    end)
    updateMobileBtnVisual()
end
local function destroyMobileButton()
    if MobileGui then pcall(function() MobileGui:Destroy() end) end
    MobileGui, MobileBtn, MobileBtnLabel = nil, nil, nil
    State.Movement._buttonHolding = false
    State.Movement._sprintPress = nil
    State.Movement._mobileToggleOn = false
end
-- keep button highlight in sync (holding state changes from keyboard too)
RunService.RenderStepped:Connect(updateMobileBtnVisual)
if State.Movement.ShowMobileButton then
    pcall(createMobileButton)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    -- reassert speeds on spawn happens via RenderStepped automatically
end)

-- UI
local Window = WindUI:CreateWindow({
    Title = "ANMU Hub",
    Icon = "ghost",
    Folder = "ANMUHub",
    Size = UDim2.fromOffset(520, 360),
    Theme = "Dark",
    Topbar = { Height = 44, ButtonsType = "Mac" },
    OpenButton = {
        Title = "ANMU Hub",
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        CornerRadius = UDim.new(1, 0),
        Scale = 0.6,
    },
})

Window:Tag({ Title = "v1.0", Color = Color3.fromHex("#1c1c1c"), Border = true })

-- Floating hub toggle for mobile (tap = hide/show, drag = move).
-- WindUI already has an OpenButton, but on touch it can be missed — this stays visible.
local HubToggleGui, HubToggleBtn
local function destroyHubToggle()
    if HubToggleGui then pcall(function() HubToggleGui:Destroy() end) end
    HubToggleGui, HubToggleBtn = nil, nil
end
local function createHubToggle()
    if HubToggleGui then
        pcall(function() HubToggleGui.Enabled = true end)
        return
    end
    local gui = Instance.new("ScreenGui")
    gui.Name = "ANMU_Hub_Toggle"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 1000
    gui.Parent = getGuiParent()
    HubToggleGui = gui
    local btn = Instance.new("TextButton")
    btn.Name = "HubToggle"
    btn.AnchorPoint = Vector2.new(0, 0)
    btn.Position = UDim2.new(0, 16, 0, 64)
    btn.Size = UDim2.fromOffset(52, 52)
    btn.BackgroundColor3 = Color3.fromHex("#14141c")
    btn.BackgroundTransparency = 0.05
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 24
    btn.TextColor3 = Color3.fromHex("#ffffff")
    btn.Text = "👻"
    btn.Parent = gui
    HubToggleBtn = btn
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromHex("#B366FF")
    stroke.Transparency = 0.2
    stroke.Parent = btn
    -- tap toggles, drag moves (so it never covers gameplay)
    local dragging, moved, dragStart, btnStart = false, false, nil, nil
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, moved = true, false
            dragStart = input.Position
            btnStart = btn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            if delta.Magnitude > 10 then moved = true end
            if moved then
                btn.Position = UDim2.new(
                    btnStart.X.Scale, btnStart.X.Offset + delta.X,
                    btnStart.Y.Scale, btnStart.Y.Offset + delta.Y
                )
            end
        end
    end)
    local function release(input)
        local t = input.UserInputType
        if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseButton1 then return end
        if dragging and not moved then
            pcall(function() Window:Toggle() end)
        end
        dragging = false
    end
    btn.InputEnded:Connect(release)
    UserInputService.InputEnded:Connect(function(input)
        if dragging then release(input) end
    end)
end
if State.UI.ShowHubButton then
    pcall(createHubToggle)
end

local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye", Border = true })
local MoveTab = Window:Tab({ Title = "Movement", Icon = "zap", Border = true })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings", Border = true })

-- ESP Section
ESPTab:Section({ Title = "ESP — ANMU Horror", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })

ESPTab:Toggle({ Title = "Monster ESP", Desc = "Highlights Workspace.Monster", Value = false, Callback = function(v) State.ESP.Monster = v end })
ESPTab:Toggle({ Title = "Keys ESP", Desc = "Key666 / Key91", Value = false, Callback = function(v) State.ESP.Keys = v end })
ESPTab:Toggle({ Title = "Codes ESP", Desc = "Code1 - Code4 notes", Value = false, Callback = function(v) State.ESP.Codes = v end })
ESPTab:Toggle({ Title = "Wardrobes ESP", Desc = "LemariHidePlace (19 hiding spots)", Value = false, Callback = function(v) State.ESP.Wardrobes = v end })
ESPTab:Toggle({ Title = "Lighters ESP", Desc = "Korek_Lighter", Value = false, Callback = function(v) State.ESP.Lighters = v end })
ESPTab:Toggle({ Title = "Wrench ESP", Desc = "Wrench tool", Value = false, Callback = function(v) State.ESP.Wrench = v end })

ESPTab:Space()

ESPTab:Toggle({ Title = "Show Distance", Value = true, Callback = function(v) State.ESP.ShowDistance = v end })

ESPTab:Slider({
    Title = "Max ESP Distance",
    Step = 10,
    Value = { Min = 100, Max = 2000, Default = 800 },
    Callback = function(v) State.ESP.MaxDistance = v end,
})

ESPTab:Space()

ESPTab:Button({
    Title = "Clear All ESP",
    Color = Color3.fromHex("#FF4830"),
    Justify = "Center",
    Callback = function()
        clearAllESP()
        WindUI:Notify({ Title = "ESP", Content = "Cleared all ESP", Duration = 3 })
    end,
})

-- Movement Section
MoveTab:Section({ Title = "Movement", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold })

MoveTab:Toggle({
    Title = "Unlimited Stamina",
    Desc = "Locks Stamina to MaxStamina (130)",
    Value = false,
    Callback = function(v)
        State.Movement.UnlimitedStamina = v
        WindUI:Notify({ Title = "Movement", Content = v and "Unlimited Stamina ON" or "Unlimited Stamina OFF", Duration = 2 })
    end,
})

MoveTab:Space()

MoveTab:Toggle({
    Title = "Enable WalkSpeed",
    Desc = "Override normal speed (default 10)",
    Value = false,
    Callback = function(v) State.Movement.WalkEnabled = v end,
})

MoveTab:Slider({
    Title = "WalkSpeed",
    Step = 1,
    Value = { Min = 10, Max = 60, Default = 16 },
    Callback = function(v) State.Movement.WalkSpeed = v end,
})

MoveTab:Space()

MoveTab:Toggle({
    Title = "Enable Sprint Speed",
    Desc = "Override sprint speed (default 20)",
    Value = false,
    Callback = function(v) State.Movement.SprintEnabled = v end,
})

MoveTab:Slider({
    Title = "Sprint Speed",
    Step = 1,
    Value = { Min = 20, Max = 100, Default = 24 },
    Callback = function(v) State.Movement.SprintSpeed = v end,
})

MoveTab:Space()

MoveTab:Toggle({
    Title = "Fake Sprint (Hold)",
    Desc = "Hold key to force speed. Keeps running even when stamina drains.",
    Value = false,
    Callback = function(v)
        State.Movement.FakeSprintEnabled = v
        if not v then
            State.Movement._fakeHolding = false
            State.Movement._buttonHolding = false
            State.Movement._sprintPress = nil
            State.Movement._mobileToggleOn = false
        end
        WindUI:Notify({ Title = "Movement", Content = v and "Fake Sprint ON — hold your key" or "Fake Sprint OFF", Duration = 2 })
    end,
})

MoveTab:Keybind({
    Title = "Fake Sprint Hold Key",
    Desc = "Hold this key to sprint, release to stop",
    Value = "LeftShift",
    Callback = function(v)
        local ok, code = pcall(function() return Enum.KeyCode[v] end)
        if ok and code then
            State.Movement.FakeSprintKey = code
            State.Movement._fakeHolding = false
        end
    end,
})

MoveTab:Slider({
    Title = "Fake Sprint Speed",
    Step = 1,
    Value = { Min = 16, Max = 100, Default = 26 },
    Callback = function(v) State.Movement.FakeSprintSpeed = v end,
})

MoveTab:Space()

MoveTab:Toggle({
    Title = "Show Mobile Sprint Button",
    Desc = "Big ⚡ circle on the right side for right-thumb (draggable)",
    Value = State.Movement.ShowMobileButton,
    Callback = function(v)
        State.Movement.ShowMobileButton = v
        if v then
            pcall(createMobileButton)
        else
            if MobileGui then pcall(function() MobileGui.Enabled = false end) end
            State.Movement._buttonHolding = false
        end
    end,
})

MoveTab:Toggle({
    Title = "Mobile Tap Mode (camera-friendly)",
    Desc = "Tap button to toggle sprint on/off — frees your thumb to swipe the camera",
    Value = State.Movement.MobileToggleMode,
    Callback = function(v)
        State.Movement.MobileToggleMode = v
        State.Movement._mobileToggleOn = false
        State.Movement._sprintPress = nil
        State.Movement._buttonHolding = false
        State.Movement._fakeHolding = State.Movement._keyHolding or false
        updateMobileBtnVisual()
    end,
})

-- Settings
SettingsTab:Section({ Title = "Settings", TextSize = 18 })

SettingsTab:Keybind({
    Title = "UI Toggle Key",
    Value = "RightShift",
    Callback = function(v)
        pcall(function() Window:SetToggleKey(Enum.KeyCode[v]) end)
    end,
})

SettingsTab:Space()

SettingsTab:Toggle({
    Title = "Show Hub Toggle Button",
    Desc = "Floating 👻 button (top-left, draggable) — tap to hide/show on mobile",
    Value = State.UI.ShowHubButton,
    Callback = function(v)
        State.UI.ShowHubButton = v
        if v then
            pcall(createHubToggle)
        else
            if HubToggleGui then pcall(function() HubToggleGui.Enabled = false end) end
        end
    end,
})

SettingsTab:Space()

SettingsTab:Button({
    Title = "Destroy UI",
    Color = Color3.fromHex("#FF4830"),
    Justify = "Center",
    Callback = function()
        clearAllESP()
        pcall(destroyMobileButton)
        pcall(destroyHubToggle)
        Window:Destroy()
    end,
})

WindUI:Notify({ Title = "ANMU Hub Loaded", Content = "ESP + Movement ready", Duration = 4 })
print("[ANMU Hub] Loaded")
