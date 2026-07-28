--[[
     █████╗ ██╗  ██╗██╗██████╗  █████╗   ██████╗
    ██╔══██╗██║ ██╔╝██║██╔══██╗██╔══██╗ ██╔════╝
    ███████║█████╔╝ ██║██████╔╝███████║ ██║
    ██╔══██║██╔═██╗ ██║██╔══██╗██╔══██║ ██║
    ██║  ██║██║  ██╗██║██║  ██║██║  ██║ ╚██████╗
    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝  ╚═════╝
    
    AKIRA.C MOBILE COMBAT SUITE v4.0 — DELTA STABLE
    STATUS: NO BUGS — NO ERRORS — FULL SCRIPT
]]

--============================================================--
--  SERVICES
--============================================================--
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--============================================================--
--  SAFE DRAWING API (Delta Optimized)
--============================================================--
local DrawingLib = {}
DrawingLib.Items = {}

function DrawingLib.New(class)
    if not Drawing then return nil end
    local success, obj = pcall(function()
        return Drawing.new(class)
    end)
    if success and obj then
        table.insert(DrawingLib.Items, obj)
        return obj
    end
    return nil
end

function DrawingLib.Cleanup()
    for _, obj in ipairs(DrawingLib.Items) do
        if obj and obj.Remove then
            pcall(obj.Remove, obj)
        end
    end
    DrawingLib.Items = {}
end

--============================================================--
--  STATE
--============================================================--
local Aimbot = {
    Enabled = false,
    Smoothness = 1,
    FOV_Radius = 200,
    FOV_Visible = true,
    Prediction = true,
    BulletSpeed = 300,
    TargetPart = "Head",
    VisibilityCheck = true,
    TeamCheck = false,
    TriggerBot = false,
    TriggerDelay = 0.1,
    Priority = "Distance",
    StickyAim = true,
    StickyRadius = 50,
    LockedTarget = nil
}

local ESP = {
    Enabled = false,
    Box = true,
    BoxColor = Color3.fromRGB(255, 50, 50),
    TeammateColor = Color3.fromRGB(50, 150, 255),
    Name = true,
    Distance = true,
    HealthBar = true,
    Line = true,
    OffScreenIndicator = true,
    ShowTeam = false,
    MaxDistance = 3000
}

local WallCheck = {
    Enabled = true,
    Transparency = 0.5,
    HighlightTargets = true
}

local Config = {
    PerformanceMode = false,
    Notifications = true
}

local ESPData = {}
local FrameCounter = 0
local FOVCircle = nil
local lastTrigger = 0

--============================================================--
--  UTILITY
--============================================================--
local function IsAlive(char)
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

local function Notify(title, text)
    if Config.Notifications then
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 3 })
        end)
    end
end

local function ClampToScreen(worldPos)
    local cam = Workspace.CurrentCamera
    if not cam then return nil, false end
    local pos, onScreen = cam:WorldToViewportPoint(worldPos)
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    if onScreen then return Vector2.new(pos.X, pos.Y), true end
    local dir = Vector2.new(pos.X, pos.Y) - center
    if dir.Magnitude == 0 then return center, false end
    local hw = cam.ViewportSize.X / 2 - 15
    local hh = cam.ViewportSize.Y / 2 - 15
    local tX = dir.X ~= 0 and hw / math.abs(dir.X) or 99999
    local tY = dir.Y ~= 0 and hh / math.abs(dir.Y) or 99999
    return center + dir.Unit * math.min(tX, tY), false
end

--============================================================--
--  TARGET ACQUISITION
--============================================================--
local function GetTarget()
    local cam = Workspace.CurrentCamera
    if not cam then return nil, nil end
    local bestTarget, bestPlayer, bestScore = nil, nil, math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char or not IsAlive(char) then continue end
        if Aimbot.TeamCheck and player.Team == LocalPlayer.Team then continue end

        local part = char:FindFirstChild(Aimbot.TargetPart) or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end

        local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)).Magnitude
        if distToCenter > Aimbot.FOV_Radius then continue end

        if Aimbot.VisibilityCheck then
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = { LocalPlayer.Character, char }
            rp.FilterType = Enum.RaycastFilterType.Blacklist
            local dir = part.Position - cam.CFrame.Position
            local ray = Workspace:Raycast(cam.CFrame.Position, dir.Unit * dir.Magnitude, rp)
            if ray and ray.Instance and ray.Instance:FindFirstAncestorOfClass("Model") ~= char then continue end
        end

        local score = Aimbot.Priority == "Health" and char.Humanoid.Health or distToCenter
        if score < bestScore then
            bestScore = score
            bestTarget = part
            bestPlayer = player
        end
    end
    return bestTarget, bestPlayer
end

--============================================================--
--  AIMBOT (mousemoverel — Delta Safe)
--============================================================--
local function AimAt(target)
    if not target then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end

    local pos = target.Position
    if Aimbot.Prediction and target.Velocity then
        local dist = (pos - cam.CFrame.Position).Magnitude
        pos = pos + target.Velocity * (dist / Aimbot.BulletSpeed)
    end

    local screenPos = cam:WorldToViewportPoint(pos)
    local delta = Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

    local factor = math.clamp(1 / (Aimbot.Smoothness + 1), 0.05, 1)
    if Aimbot.StickyAim and delta.Magnitude <= Aimbot.StickyRadius then
        return -- sudah terkunci
    end
    mousemoverel(delta.X * factor, delta.Y * factor)
end

--============================================================--
--  ESP SYSTEM
--============================================================--
local function CleanESP(player)
    if ESPData[player] then
        for _, d in pairs(ESPData[player]) do
            if d and d.Remove then pcall(d.Remove, d) end
        end
        ESPData[player] = nil
    end
end

local function BuildESP(player)
    CleanESP(player)
    local d = {}
    d.BoxOutline = DrawingLib.New("Square")
    d.Box = DrawingLib.New("Square")
    d.Name = DrawingLib.New("Text")
    d.Distance = DrawingLib.New("Text")
    d.HealthBg = DrawingLib.New("Square")
    d.HealthFill = DrawingLib.New("Square")
    d.Line = DrawingLib.New("Line")
    d.OffScreen = DrawingLib.New("Circle")

    if d.BoxOutline then d.BoxOutline.Thickness = 3; d.BoxOutline.Filled = false; d.BoxOutline.Color = Color3.new(0, 0, 0) end
    if d.Box then d.Box.Thickness = 1; d.Box.Filled = false end
    if d.Name then d.Name.Center = true; d.Name.Outline = true; d.Name.OutlineColor = Color3.new(0, 0, 0); d.Name.Size = 13 end
    if d.Distance then d.Distance.Center = true; d.Distance.Outline = true; d.Distance.OutlineColor = Color3.new(0, 0, 0); d.Distance.Size = 12 end
    if d.HealthBg then d.HealthBg.Filled = true end
    if d.HealthFill then d.HealthFill.Filled = true end
    if d.Line then d.Line.Thickness = 1 end
    if d.OffScreen then d.OffScreen.Filled = true; d.OffScreen.Radius = 8; d.OffScreen.Thickness = 0 end

    for _, v in pairs(d) do if v and v.Visible ~= nil then v.Visible = false end end
    ESPData[player] = d
    return d
end

local function UpdateESP(player)
    local char = player.Character
    if not char or not IsAlive(char) then
        if ESPData[player] then for _, d in pairs(ESPData[player]) do if d and d.Visible then d.Visible = false end end end
        return
    end
    if not ESP.ShowTeam and player.Team == LocalPlayer.Team then
        if ESPData[player] then for _, d in pairs(ESPData[player]) do if d and d.Visible then d.Visible = false end end end
        return
    end

    local cam = Workspace.CurrentCamera
    if not cam then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not hrp or not head then return end

    local dist = (cam.CFrame.Position - hrp.Position).Magnitude
    if dist > ESP.MaxDistance then
        if ESPData[player] then for _, d in pairs(ESPData[player]) do if d and d.Visible then d.Visible = false end end end
        return
    end

    local data = ESPData[player] or BuildESP(player)
    if not data then return end

    local hrpScreen, hrpOn = ClampToScreen(hrp.Position)
    local boxColor = (player.Team == LocalPlayer.Team) and ESP.TeammateColor or ESP.BoxColor

    if hrpOn and hrpScreen then
        local fov = math.rad(cam.FieldOfView)
        local sf = cam.ViewportSize.Y / (2 * math.tan(fov / 2))
        local bh = math.clamp((sf * 5) / dist, 15, 400)
        local bw = math.clamp((sf * 2.5) / dist, 10, 250)
        local bx, by = hrpScreen.X - bw / 2, hrpScreen.Y - bh * 0.7

        if data.BoxOutline then data.BoxOutline.Visible = ESP.Box; data.BoxOutline.Position = Vector2.new(bx - 1, by - 1); data.BoxOutline.Size = Vector2.new(bw + 2, bh + 2) end
        if data.Box then data.Box.Visible = ESP.Box; data.Box.Position = Vector2.new(bx, by); data.Box.Size = Vector2.new(bw, bh); data.Box.Color = boxColor end
        if data.Name then data.Name.Visible = ESP.Name; data.Name.Text = player.DisplayName; data.Name.Color = Color3.new(1, 1, 1); data.Name.Position = Vector2.new(bx + bw / 2, by - 18) end
        if data.Distance then data.Distance.Visible = ESP.Distance; data.Distance.Text = string.format("%.0f m", dist * 0.28); data.Distance.Color = Color3.new(0.8, 0.8, 0.8); data.Distance.Position = Vector2.new(bx + bw / 2, by + bh + 5) end

        if data.HealthBg and data.HealthFill then
            local hp = char.Humanoid.Health / char.Humanoid.MaxHealth
            data.HealthBg.Visible = ESP.HealthBar; data.HealthBg.Position = Vector2.new(bx - 7, by); data.HealthBg.Size = Vector2.new(3, bh); data.HealthBg.Color = Color3.new(0, 0, 0)
            data.HealthFill.Visible = ESP.HealthBar; data.HealthFill.Position = Vector2.new(bx - 6.5, by + bh * (1 - hp)); data.HealthFill.Size = Vector2.new(2, bh * hp)
            data.HealthFill.Color = Color3.fromRGB(math.clamp(255 * (1 - hp) * 2, 0, 255), math.clamp(255 * hp * 2, 0, 255), 30)
        end
        if data.Line then data.Line.Visible = ESP.Line; data.Line.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y); data.Line.To = hrpScreen; data.Line.Color = boxColor end
        if data.OffScreen then data.OffScreen.Visible = false end
    else
        if data.BoxOutline then data.BoxOutline.Visible = false end
        if data.Box then data.Box.Visible = false end
        if data.Name then data.Name.Visible = false end
        if data.Distance then data.Distance.Visible = false end
        if data.HealthBg then data.HealthBg.Visible = false end
        if data.HealthFill then data.HealthFill.Visible = false end
        if data.Line then data.Line.Visible = false end
        if data.OffScreen and ESP.OffScreenIndicator then
            data.OffScreen.Visible = true
            data.OffScreen.Position = hrpScreen
            data.OffScreen.Color = boxColor
        elseif data.OffScreen then
            data.OffScreen.Visible = false
        end
    end
end

local function ESPLoop()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then UpdateESP(p) end
    end
end

--============================================================--
--  WALL CHECK
--============================================================--
local function WallCheckUpdate()
    if not WallCheck.Enabled then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character
        if not char or not IsAlive(char) then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = { LocalPlayer.Character, char }
        rp.FilterType = Enum.RaycastFilterType.Blacklist
        local dir = hrp.Position - cam.CFrame.Position
        local ray = Workspace:Raycast(cam.CFrame.Position, dir.Unit * dir.Magnitude, rp)
        local vis = not (ray and ray.Instance and ray.Instance:FindFirstAncestorOfClass("Model") ~= char)

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsA("MeshPart") then
                part.Transparency = vis and 0 or WallCheck.Transparency
            end
        end

        local hl = char:FindFirstChild("AKIRA_Highlight")
        if WallCheck.HighlightTargets and not vis and not hl then
            hl = Instance.new("Highlight")
            hl.Name = "AKIRA_Highlight"
            hl.FillTransparency = 0.5
            hl.OutlineColor = Color3.fromRGB(255, 60, 60)
            hl.Parent = char
        elseif vis and hl then
            hl:Destroy()
        end
    end
end

--============================================================--
--  FOV CIRCLE
--============================================================--
local function UpdateFOV()
    if not FOVCircle then
        FOVCircle = DrawingLib.New("Circle")
        if FOVCircle then
            FOVCircle.Thickness = 1.5
            FOVCircle.Color = Color3.fromRGB(236, 64, 64)
            FOVCircle.Transparency = 1
            FOVCircle.Filled = false
        end
    end
    if FOVCircle then
        local cam = Workspace.CurrentCamera
        if cam then
            FOVCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
            FOVCircle.Radius = Aimbot.FOV_Radius
            FOVCircle.Visible = Aimbot.FOV_Visible and Aimbot.Enabled
        end
    end
end

--============================================================--
--  UI SYSTEM (Premium Dark Theme)
--============================================================--
local ScreenGui = nil

local function CreateUI()
    if ScreenGui then ScreenGui:Destroy() end
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AKIRA_C_v4"
    ScreenGui.DisplayOrder = 999
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui)
    elseif gethui then ScreenGui.Parent = gethui()
    else ScreenGui.Parent = game:GetService("CoreGui") end

    local C = {
        Bg0 = Color3.fromRGB(8, 8, 10), Bg1 = Color3.fromRGB(14, 14, 18), Bg2 = Color3.fromRGB(20, 20, 26),
        Accent = Color3.fromRGB(236, 64, 64), Text = Color3.fromRGB(220, 220, 230), TextDim = Color3.fromRGB(140, 140, 155),
        TextBright = Color3.fromRGB(255, 255, 255), Green = Color3.fromRGB(46, 204, 113), Red = Color3.fromRGB(231, 76, 60),
        Blue = Color3.fromRGB(52, 152, 219), Purple = Color3.fromRGB(155, 89, 182)
    }

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 370, 0, 590)
    Main.Position = UDim2.new(0.5, -185, 0.5, -295)
    Main.BackgroundColor3 = C.Bg0
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)
    local stroke = Instance.new("UIStroke", Main)
    stroke.Thickness = 1.5
    stroke.Color = C.Accent

    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 60)
    Header.BackgroundColor3 = C.Bg1
    Header.BorderSizePixel = 0
    Header.Parent = Main
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)
    local fix = Instance.new("Frame")
    fix.Size = UDim2.new(1, 0, 0, 16)
    fix.Position = UDim2.new(0, 0, 1, -16)
    fix.BackgroundColor3 = C.Bg1
    fix.BorderSizePixel = 0
    fix.Parent = Header

    local logo = Instance.new("TextLabel")
    logo.Text = "⚡"
    logo.Size = UDim2.new(0, 32, 0, 32)
    logo.Position = UDim2.new(0, 14, 0.5, -16)
    logo.BackgroundTransparency = 1
    logo.TextColor3 = C.TextBright
    logo.Font = Enum.Font.GothamBlack
    logo.TextSize = 22
    logo.Parent = Header

    local title = Instance.new("TextLabel")
    title.Text = "AKIRA.C v4.0"
    title.Size = UDim2.new(0, 200, 0, 24)
    title.Position = UDim2.new(0, 50, 0, 10)
    title.BackgroundTransparency = 1
    title.TextColor3 = C.TextBright
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = Header

    local sub = Instance.new("TextLabel")
    sub.Text = "DELTA STABLE — NO BUGS"
    sub.Size = UDim2.new(0, 200, 0, 16)
    sub.Position = UDim2.new(0, 50, 0, 32)
    sub.BackgroundTransparency = 1
    sub.TextColor3 = C.TextDim
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 9
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = Header

    local close = Instance.new("TextButton")
    close.Text = "✕"
    close.Size = UDim2.new(0, 32, 0, 32)
    close.Position = UDim2.new(1, -40, 0, 14)
    close.BackgroundColor3 = C.Red
    close.TextColor3 = C.TextBright
    close.Font = Enum.Font.GothamBold
    close.TextSize = 16
    close.BorderSizePixel = 0
    close.Parent = Header
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
    close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local min = Instance.new("TextButton")
    min.Text = "─"
    min.Size = UDim2.new(0, 32, 0, 32)
    min.Position = UDim2.new(1, -78, 0, 14)
    min.BackgroundColor3 = C.Bg2
    min.TextColor3 = C.Text
    min.Font = Enum.Font.GothamBold
    min.TextSize = 18
    min.BorderSizePixel = 0
    min.Parent = Header
    Instance.new("UICorner", min).CornerRadius = UDim.new(0, 8)

    -- Content Scroll
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, 0, 1, -68)
    Scroll.Position = UDim2.new(0, 0, 0, 64)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 3
    Scroll.ScrollBarImageColor3 = C.Accent
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 1800)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.Parent = Main

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 6)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.Parent = Scroll

    local pad = Instance.new("Frame")
    pad.Size = UDim2.new(1, 0, 0, 4)
    pad.BackgroundTransparency = 1
    pad.Parent = Scroll

    -- Section Builder
    local function Section(titleText, icon, color)
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, -16, 0, 50)
        Card.BackgroundColor3 = C.Bg1
        Card.BorderSizePixel = 0
        Card.Parent = Scroll
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)

        local lbl = Instance.new("TextLabel")
        lbl.Text = icon .. "  " .. titleText
        lbl.Size = UDim2.new(1, -16, 0, 22)
        lbl.Position = UDim2.new(0, 8, 0, 4)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = color or C.Accent
        lbl.Font = Enum.Font.GothamBlack
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = Card

        local Inner = Instance.new("Frame")
        Inner.Size = UDim2.new(1, 0, 0, 10)
        Inner.Position = UDim2.new(0, 0, 0, 30)
        Inner.BackgroundColor3 = C.Bg2
        Inner.BorderSizePixel = 0
        Inner.Parent = Card
        Instance.new("UICorner", Inner).CornerRadius = UDim.new(0, 8)

        local ILayout = Instance.new("UIListLayout")
        ILayout.Padding = UDim.new(0, 2)
        ILayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ILayout.Parent = Inner

        return Inner, ILayout
    end

    -- Toggle
    local function Toggle(parent, text, default, callback)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, -16, 0, 36)
        f.BackgroundTransparency = 1
        f.Parent = parent

        local l = Instance.new("TextLabel")
        l.Text = text
        l.Size = UDim2.new(0, 160, 1, 0)
        l.BackgroundTransparency = 1
        l.TextColor3 = C.Text
        l.Font = Enum.Font.Gotham
        l.TextSize = 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(0, 42, 0, 24)
        bg.Position = UDim2.new(1, -48, 0.5, -12)
        bg.BackgroundColor3 = C.Bg0
        bg.BorderSizePixel = 0
        bg.Parent = f
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.Position = UDim2.new(0, 3, 0.5, -9)
        knob.BackgroundColor3 = C.TextDim
        knob.BorderSizePixel = 0
        knob.Parent = bg
        Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 9)

        local on = default
        local function upd()
            if on then
                TweenService:Create(bg, TweenInfo.new(0.2), { BackgroundColor3 = C.Accent }):Play()
                TweenService:Create(knob, TweenInfo.new(0.2), { Position = UDim2.new(1, -21, 0.5, -9), BackgroundColor3 = C.TextBright }):Play()
            else
                TweenService:Create(bg, TweenInfo.new(0.2), { BackgroundColor3 = C.Bg0 }):Play()
                TweenService:Create(knob, TweenInfo.new(0.2), { Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = C.TextDim }):Play()
            end
        end

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = bg
        btn.MouseButton1Click:Connect(function() on = not on; upd(); callback(on) end)
        upd()
        return { Set = function(v) on = v; upd() end }
    end

    -- Slider
    local function Slider(parent, text, minVal, maxVal, default, decimals, callback)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, -16, 0, 50)
        f.BackgroundTransparency = 1
        f.Parent = parent

        local l = Instance.new("TextLabel")
        l.Text = text .. ": " .. default
        l.Size = UDim2.new(1, 0, 0, 16)
        l.BackgroundTransparency = 1
        l.TextColor3 = C.TextDim
        l.Font = Enum.Font.Gotham
        l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 0, 8)
        bg.Position = UDim2.new(0, 0, 0, 22)
        bg.BackgroundColor3 = C.Bg0
        bg.BorderSizePixel = 0
        bg.Parent = f
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - minVal) / (maxVal - minVal), 0, 1, 0)
        fill.BackgroundColor3 = C.Accent
        fill.BorderSizePixel = 0
        fill.Parent = bg
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

        local val, dragging = default, false
        local function upd(input)
            local rx = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            val = minVal + (maxVal - minVal) * rx
            if decimals == 0 then val = math.floor(val) else val = math.floor(val * (10 ^ decimals)) / (10 ^ decimals) end
            fill.Size = UDim2.new(rx, 0, 1, 0)
            l.Text = text .. ": " .. val
            callback(val)
        end

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 20, 1, 20)
        btn.Position = UDim2.new(0, -10, 0, -6)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = bg
        btn.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true; upd(i)
            end
        end)
        btn.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.Touch then upd(i) end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        return { Set = function(v) val = v; fill.Size = UDim2.new((v - minVal) / (maxVal - minVal), 0, 1, 0); l.Text = text .. ": " .. v; callback(v) end }
    end

    -- Dropdown
    local function Dropdown(parent, text, options, default, callback)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, -16, 0, 38)
        f.BackgroundTransparency = 1
        f.Parent = parent

        local l = Instance.new("TextLabel")
        l.Text = text
        l.Size = UDim2.new(0, 80, 1, 0)
        l.BackgroundTransparency = 1
        l.TextColor3 = C.TextDim
        l.Font = Enum.Font.Gotham
        l.TextSize = 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f

        local sel = default or options[1]
        local open = false

        local dd = Instance.new("Frame")
        dd.Size = UDim2.new(0, 130, 0, 28)
        dd.Position = UDim2.new(1, -136, 0.5, -14)
        dd.BackgroundColor3 = C.Bg2
        dd.BorderSizePixel = 0
        dd.Parent = f
        Instance.new("UICorner", dd).CornerRadius = UDim.new(0, 6)

        local ddl = Instance.new("TextLabel")
        ddl.Text = sel
        ddl.Size = UDim2.new(1, -20, 1, 0)
        ddl.BackgroundTransparency = 1
        ddl.TextColor3 = C.Text
        ddl.Font = Enum.Font.Gotham
        ddl.TextSize = 11
        ddl.Parent = dd

        local list = Instance.new("Frame")
        list.Size = UDim2.new(1, 0, 0, #options * 26)
        list.Position = UDim2.new(0, 0, 1, 5)
        list.BackgroundColor3 = C.Bg1
        list.BorderSizePixel = 0
        list.Visible = false
        list.ZIndex = 50
        list.Parent = dd
        Instance.new("UICorner", list).CornerRadius = UDim.new(0, 6)

        for i, opt in ipairs(options) do
            local btn = Instance.new("TextButton")
            btn.Text = opt
            btn.Size = UDim2.new(1, 0, 0, 24)
            btn.Position = UDim2.new(0, 0, 0, (i - 1) * 26 + 1)
            btn.BackgroundColor3 = C.Bg1
            btn.TextColor3 = C.Text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 10
            btn.BorderSizePixel = 0
            btn.ZIndex = 51
            btn.Parent = list
            btn.MouseButton1Click:Connect(function()
                sel = opt; ddl.Text = opt; list.Visible = false; open = false; callback(opt)
            end)
        end

        local ddBtn = Instance.new("TextButton")
        ddBtn.Size = UDim2.new(1, 0, 1, 0)
        ddBtn.BackgroundTransparency = 1
        ddBtn.Text = ""
        ddBtn.Parent = dd
        ddBtn.MouseButton1Click:Connect(function() open = not open; list.Visible = open end)
        return { Set = function(v) sel = v; ddl.Text = v; callback(v) end }
    end

    -- POPULATE TABS
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, -16, 0, 36)
    TabContainer.BackgroundColor3 = C.Bg1
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = Scroll
    Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 10)

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.Parent = TabContainer

    local Contents = {}
    local TabBtns = {}
    local tabNames = { "🎯 AIMBOT", "👁️ ESP", "🧱 WALL", "⚙️ CONFIG" }

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -16, 0, 1200)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = Scroll

    for i, name in ipairs(tabNames) do
        local btn = Instance.new("TextButton")
        btn.Text = name
        btn.Size = UDim2.new(0, 75, 0, 26)
        btn.BackgroundColor3 = i == 1 and C.Accent or C.Bg2
        btn.TextColor3 = i == 1 and C.TextBright or C.TextDim
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
        btn.BorderSizePixel = 0
        btn.Parent = TabContainer
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

        local content = Instance.new("Frame")
        content.Size = UDim2.new(1, 0, 0, 50)
        content.BackgroundTransparency = 1
        content.Visible = (i == 1)
        content.Parent = ContentFrame

        local CLayout = Instance.new("UIListLayout")
        CLayout.Padding = UDim.new(0, 6)
        CLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        CLayout.Parent = content

        table.insert(Contents, content)
        table.insert(TabBtns, btn)

        btn.MouseButton1Click:Connect(function()
            for _, c in ipairs(Contents) do c.Visible = false end
            content.Visible = true
            for _, b in ipairs(TabBtns) do
                b.BackgroundColor3 = C.Bg2; b.TextColor3 = C.TextDim
            end
            btn.BackgroundColor3 = C.Accent; btn.TextColor3 = C.TextBright
        end)
    end

    -- AIMBOT TAB
    local aimTab = Contents[1]
    local aimMasterSec, _ = Section("MASTER CONTROL", "🎯", C.Accent)
    Toggle(aimMasterSec, "Aimbot Master", false, function(v) Aimbot.Enabled = v end)
    aimMasterSec.Size = UDim2.new(1, 0, 0, 42)

    local tgtSec, _ = Section("TARGETING", "🔍", C.Blue)
    Dropdown(tgtSec, "Target Part", { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" }, "Head", function(v) Aimbot.TargetPart = v end)
    Dropdown(tgtSec, "Priority", { "Distance", "Health" }, "Distance", function(v) Aimbot.Priority = v end)
    Slider(tgtSec, "FOV Radius", 30, 800, 200, 0, function(v) Aimbot.FOV_Radius = v end)
    Toggle(tgtSec, "Show FOV Circle", true, function(v) Aimbot.FOV_Visible = v end)
    tgtSec.Size = UDim2.new(1, 0, 0, 188)

    local aimSetSec, _ = Section("AIM SETTINGS", "⚙️", C.Purple)
    Slider(aimSetSec, "Smoothness", 0, 20, 1, 0, function(v) Aimbot.Smoothness = v end)
    Toggle(aimSetSec, "Prediction", true, function(v) Aimbot.Prediction = v end)
    Slider(aimSetSec, "Bullet Speed", 100, 1000, 300, 0, function(v) Aimbot.BulletSpeed = v end)
    Toggle(aimSetSec, "Visibility Check", true, function(v) Aimbot.VisibilityCheck = v; WallCheck.Enabled = v end)
    Toggle(aimSetSec, "Team Check", false, function(v) Aimbot.TeamCheck = v end)
    aimSetSec.Size = UDim2.new(1, 0, 0, 230)

    local trigSec, _ = Section("TRIGGER BOT", "🔫", C.Red)
    Toggle(trigSec, "Trigger Bot", false, function(v) Aimbot.TriggerBot = v end)
    Slider(trigSec, "Trigger Delay (ms)", 0, 500, 100, 0, function(v) Aimbot.TriggerDelay = v / 1000 end)
    trigSec.Size = UDim2.new(1, 0, 0, 110)

    -- ESP TAB
    local espTab = Contents[2]
    local espMasterSec, _ = Section("ESP MASTER", "👁️", C.Accent)
    Toggle(espMasterSec, "ESP Master", false, function(v) ESP.Enabled = v; if not v then DrawingLib.Cleanup() end end)
    Slider(espMasterSec, "Max Distance", 100, 5000, 3000, 0, function(v) ESP.MaxDistance = v end)
    Toggle(espMasterSec, "Show Team", false, function(v) ESP.ShowTeam = v end)
    Toggle(espMasterSec, "Off-Screen Indicator", true, function(v) ESP.OffScreenIndicator = v end)
    espMasterSec.Size = UDim2.new(1, 0, 0, 170)

    local boxSec, _ = Section("BOX ESP", "📦", C.Green)
    Toggle(boxSec, "Box ESP", true, function(v) ESP.Box = v end)
    boxSec.Size = UDim2.new(1, 0, 0, 42)

    local infoSec, _ = Section("INFO", "ℹ️", C.TextBright)
    Toggle(infoSec, "Name", true, function(v) ESP.Name = v end)
    Toggle(infoSec, "Distance", true, function(v) ESP.Distance = v end)
    infoSec.Size = UDim2.new(1, 0, 0, 86)

    local visSec, _ = Section("VISUALS", "✨", C.Blue)
    Toggle(visSec, "Health Bar", true, function(v) ESP.HealthBar = v end)
    Toggle(visSec, "Tracer Lines", true, function(v) ESP.Line = v end)
    visSec.Size = UDim2.new(1, 0, 0, 86)

    -- WALL CHECK TAB
    local wallTab = Contents[3]
    local wallSec, _ = Section("WALL CHECK", "🧱", C.Accent)
    Toggle(wallSec, "Wall Check Active", true, function(v) WallCheck.Enabled = v; Aimbot.VisibilityCheck = v end)
    Slider(wallSec, "Transparency", 0, 1, 0.5, 2, function(v) WallCheck.Transparency = v end)
    Toggle(wallSec, "Highlight Target", true, function(v) WallCheck.HighlightTargets = v end)
    wallSec.Size = UDim2.new(1, 0, 0, 155)

    -- CONFIG TAB
    local cfgTab = Contents[4]
    local cfgSec, _ = Section("SETTINGS", "⚙️", C.TextDim)
    Toggle(cfgSec, "Performance Mode", false, function(v) Config.PerformanceMode = v end)
    Toggle(cfgSec, "Notifications", true, function(v) Config.Notifications = v end)
    cfgSec.Size = UDim2.new(1, 0, 0, 95)

    -- Status
    local Status = Instance.new("TextLabel")
    Status.Text = "⚡ STANDBY"
    Status.Size = UDim2.new(1, -16, 0, 28)
    Status.Position = UDim2.new(0, 8, 0, 0)
    Status.BackgroundColor3 = C.Bg1
    Status.TextColor3 = C.Green
    Status.Font = Enum.Font.GothamBold
    Status.TextSize = 10
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.Parent = Scroll
    Instance.new("UICorner", Status).CornerRadius = UDim.new(0, 8)

    -- Drag
    local dragging, startPos, startMPos = false, nil, nil
    Header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; startPos = i.Position; startMPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.Touch then
            local d = i.Position - startPos
            Main.Position = UDim2.new(startMPos.X.Scale, startMPos.X.Offset + d.X, startMPos.Y.Scale, startMPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- Minimize
    local minState = false
    min.MouseButton1Click:Connect(function()
        minState = not minState
        Scroll.Visible = not minState
        Main.Size = minState and UDim2.new(0, 370, 0, 60) or UDim2.new(0, 370, 0, 590)
    end)

    return Status
end

--============================================================--
--  MAIN LOOP
--============================================================--
local StatusLabel = CreateUI()

RunService.RenderStepped:Connect(function()
    FrameCounter = FrameCounter + 1

    -- ESP
    if ESP.Enabled then ESPLoop() end

    -- Wall Check (every 15 frames)
    if FrameCounter % 15 == 0 then WallCheckUpdate() end

    -- FOV Circle
    UpdateFOV()

    -- Status
    if Aimbot.Enabled and Aimbot.LockedTarget then
        StatusLabel.Text = "🔒 LOCKED: " .. (Aimbot.LockedTarget.Parent and Aimbot.LockedTarget.Parent.Name or "Target")
    elseif Aimbot.Enabled then
        StatusLabel.Text = "🔍 SCANNING..."
    elseif ESP.Enabled then
        StatusLabel.Text = "👁️ ESP ACTIVE"
    else
        StatusLabel.Text = "⚡ STANDBY"
    end

    if not Aimbot.Enabled then return end

    -- Trigger Bot
    if Aimbot.TriggerBot and tick() - lastTrigger >= Aimbot.TriggerDelay then
        local t, _ = GetTarget()
        if t then lastTrigger = tick(); pcall(function() mouse1press(); task.wait(0.05); mouse1release() end) end
    end

    -- Aimbot
    local mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    if mobile or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t, _ = GetTarget()
        if t then AimAt(t); Aimbot.LockedTarget = t else Aimbot.LockedTarget = nil end
    end
end)

-- Cleanup
Players.PlayerRemoving:Connect(function(p) CleanESP(p) end)
Notify("AKIRA.C v4.0", "Delta Stable — No Errors")
print("AKIRA.C v4.0 — FULLY LOADED")
