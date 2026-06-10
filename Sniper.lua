-- ====================================================================
-- 🔥 KUZE UNIVERSAL HUB V5 - OMNI SAFE EDITION 🔥
-- ====================================================================
-- Developer : Alya (For Vioo)
-- Status    : 100% Client-Side (Safe)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "KUZE ON HUB 💀",
   LoadingTitle = "Memuat Sistem Kuze...",
   LoadingSubtitle = "Alya is setting things up for Vioo...",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "KuzeOmniV5",
      FileName = "OmniConfig"
   }
})

-- // SERVICES & VARIABLES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local Config = {
    -- Combat
    Aimbot = false, Smoothness = 0.2, AimbotPart = "Head",
    WallCheck = true, TeamCheck = true, FOV = 150, ShowFOV = false,
    -- Visuals
    ESP_Box = false, ESP_Line = false, ESP_Name = false, ESP_Dist = false, ESP_Color = Color3.fromRGB(0, 255, 150),
    -- Player
    WalkSpeed = 16, JumpPower = 50, InfJump = false,
    -- Misc
    AntiAFK = true
}

local ESP_Cache = {}
local FOVCircle = Drawing.new("Circle")
FOVCircle.Filled = false
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

-- // CORE FUNCTIONS
local function IsVisible(target)
    if not Config.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (target.Position - origin).Unit * (target.Position - origin).Magnitude
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local hit = workspace:Raycast(origin, direction, params)
    return hit and hit.Instance:IsDescendantOf(target.Parent)
end

local function GetClosest()
    local target, minDistance = nil, Config.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Config.AimbotPart) then
            if Config.TeamCheck and p.Team == LocalPlayer.Team then continue end
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = p.Character[Config.AimbotPart]
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen and IsVisible(part) then
                    local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if dist < minDistance then
                        minDistance, target = dist, part
                    end
                end
            end
        end
    end
    return target
end

-- ESP SYSTEM
local function CreateESP(p)
    if ESP_Cache[p] then return end
    local Box = Drawing.new("Square")
    Box.Thickness = 1 Box.Filled = false
    local Line = Drawing.new("Line")
    Line.Thickness = 1
    local Text = Drawing.new("Text")
    Text.Size = 14 Text.Center = true Text.Outline = true
    ESP_Cache[p] = {Box = Box, Line = Line, Text = Text}
end

local function RemoveESP(p)
    if ESP_Cache[p] then
        ESP_Cache[p].Box:Remove() ESP_Cache[p].Line:Remove() ESP_Cache[p].Text:Remove()
        ESP_Cache[p] = nil
    end
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- // MAIN LOOPS
RunService.RenderStepped:Connect(function()
    -- FOV Update
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = Config.FOV
    FOVCircle.Visible = Config.ShowFOV

    -- Aimbot Update
    if Config.Aimbot then
        local t = GetClosest()
        if t then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Position), Config.Smoothness)
        end
    end

    -- ESP Update
    for p, obj in pairs(ESP_Cache) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and (not Config.TeamCheck or p.Team ~= LocalPlayer.Team) then
                local hrp = p.Character.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local d = (Camera.CFrame.Position - hrp.Position).Magnitude
                    local sx, sy = math.clamp(2000/d, 10, 150), math.clamp(3000/d, 15, 200)

                    obj.Box.Size = Vector2.new(sx, sy)
                    obj.Box.Position = Vector2.new(pos.X - sx/2, pos.Y - sy/2)
                    obj.Box.Color = Config.ESP_Color
                    obj.Box.Visible = Config.ESP_Box

                    obj.Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    obj.Line.To = Vector2.new(pos.X, pos.Y)
                    obj.Line.Color = Config.ESP_Color
                    obj.Line.Visible = Config.ESP_Line

                    local info = ""
                    if Config.ESP_Name then info = p.Name end
                    if Config.ESP_Dist then info = info .. " [" .. math.floor(d) .. "m]" end
                    obj.Text.Text = info
                    obj.Text.Position = Vector2.new(pos.X, pos.Y - sy/2 - 20)
                    obj.Text.Color = Config.ESP_Color
                    obj.Text.Visible = (Config.ESP_Name or Config.ESP_Dist)
                else
                    obj.Box.Visible, obj.Line.Visible, obj.Text.Visible = false, false, false
                end
            else
                obj.Box.Visible, obj.Line.Visible, obj.Text.Visible = false, false, false
            end
        else
            obj.Box.Visible, obj.Line.Visible, obj.Text.Visible = false, false, false
        end
    end
end)

-- Infinite Jump
game:GetService("UserInputService").JumpRequest:Connect(function()
    if Config.InfJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- // UI TABS

-- 1. COMBAT TAB
local Combat = Window:CreateTab("Combat", 4483362458)
Combat:CreateToggle({Name = "Enable Safe Aimbot", CurrentValue = false, Callback = function(v) Config.Aimbot = v end})
Combat:CreateToggle({Name = "Team Check (Abaikan Teman)", CurrentValue = true, Callback = function(v) Config.TeamCheck = v end})
Combat:CreateToggle({Name = "Wall Check", CurrentValue = true, Callback = function(v) Config.WallCheck = v end})
Combat:CreateSlider({Name = "Aimbot Smoothness", Range = {1, 10}, Increment = 1, CurrentValue = 2, Callback = function(v) Config.Smoothness = v/20 end})
Combat:CreateSection("Target Area (FOV)")
Combat:CreateToggle({Name = "Show FOV Circle", CurrentValue = false, Callback = function(v) Config.ShowFOV = v end})
Combat:CreateSlider({Name = "FOV Radius", Range = {50, 500}, Increment = 10, CurrentValue = 150, Callback = function(v) Config.FOV = v end})

-- 2. VISUAL TAB
local Visual = Window:CreateTab("Visuals", 4483362458)
Visual:CreateToggle({Name = "ESP Box", CurrentValue = false, Callback = function(v) Config.ESP_Box = v end})
Visual:CreateToggle({Name = "ESP Line", CurrentValue = false, Callback = function(v) Config.ESP_Line = v end})
Visual:CreateToggle({Name = "ESP Player Name", CurrentValue = false, Callback = function(v) Config.ESP_Name = v end})
Visual:CreateToggle({Name = "ESP Distance (Meter)", CurrentValue = false, Callback = function(v) Config.ESP_Dist = v end})
Visual:CreateColorPicker({Name = "ESP Global Color", Color = Color3.fromRGB(0, 255, 150), Callback = function(c) Config.ESP_Color = c end})

-- 3. PLAYER TAB
local PlayerTab = Window:CreateTab("Player", 4483362458)
PlayerTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) Config.InfJump = v end})
PlayerTab:CreateSlider({Name = "Set WalkSpeed", Range = {16, 100}, Increment = 1, CurrentValue = 16, Callback = function(v) 
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v end 
end})
PlayerTab:CreateSlider({Name = "Set JumpPower", Range = {50, 200}, Increment = 1, CurrentValue = 50, Callback = function(v) 
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = v end 
end})

-- 4. WORLD & FPS TAB
local WorldTab = Window:CreateTab("World & FPS", 4483362458)
WorldTab:CreateButton({Name = "FPS Booster (Hapus Tekstur)", Callback = function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic v.CastShadow = false end
    end
end})
WorldTab:CreateToggle({Name = "Full Bright (Terang Benderang)", CurrentValue = false, Callback = function(v)
    if v then Lighting.Ambient = Color3.fromRGB(255,255,255) else Lighting.Ambient = Color3.fromRGB(128,128,128) end
end})

-- 5. UTILITY TAB
local UtilityTab = Window:CreateTab("Utility", 4483362458)
UtilityTab:CreateToggle({Name = "Anti-AFK (Aman Ditinggal)", CurrentValue = true, Callback = function(v) Config.AntiAFK = v end})
UtilityTab:CreateButton({Name = "Rejoin Server Ini", Callback = function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end})

Rayfield:Notify({Title = "Script Siap!", Content = "Omni Safe Edition berhasil diload. Selamat main!", Duration = 5})
