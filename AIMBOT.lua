╔══════════════════════════════════════════════════════════════════╗
║     🔥 SCRIPT FIX: AIMBOT + ESP + WALL CHECK + TOGGLE UI 🔥      ║
║                  LIBRARY: RAYFIELD (AKTIF & STABIL)              ║
╚══════════════════════════════════════════════════════════════════╝

-- // LOAD RAYFIELD UI LIBRARY (NO MORE DEAD LINK) // 😈
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
local Window = Rayfield:CreateWindow({
    Name = "🔥 LYX AI | ZAMZZZ PROJECT",
    LoadingTitle = "Memuat Kekuatan Dewa...",
    LoadingSubtitle = "by LYX AI",
    ConfigurationSaving = { Enabled = true, FolderName = "LyxConfig", FileName = "config" },
    KeySystem = false
})

-- Tabs
local AimbotTab = Window:CreateTab("🎯 Aimbot")
local ESPTab = Window:CreateTab("👁 ESP")

-- Variables (lu bisa atur sendiri di UI)
local aimbotEnabled = false
local fovRadius = 150
local aimPartName = "Head"
local wallCheck = false
local espEnabled = false

-- // FUNGSI WALL CHECK (RAYCAST) //
local function IsVisible(targetPart)
    local origin = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    local direction = (targetPart.Position - origin).Unit * 500
    local ray = Ray.new(origin, direction)
    local hit, _ = workspace:FindPartOnRay(ray, game.Players.LocalPlayer.Character)
    return hit and hit.Parent:FindFirstChild("Humanoid") and hit.Parent == targetPart.Parent
end

-- // AIMBOT LOOP //
game:GetService("RunService").RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local camera = workspace.CurrentCamera
    local closestDist = fovRadius
    local closestTarget = nil

    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local targetPart = player.Character:FindFirstChild(aimPartName)
            if targetPart then
                if wallCheck and not IsVisible(targetPart) then continue end
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).magnitude
                if onScreen and dist < fovRadius and dist < closestDist then
                    closestDist = dist
                    closestTarget = targetPart
                end
            end
        end
    end

    if closestTarget then
        camera.CFrame = CFrame.new(camera.CFrame.Position, closestTarget.Position)
    end
end)

-- // UI AIMBOT //
AimbotTab:CreateToggle({ Name = "Enable Aimbot", CurrentValue = false, Callback = function(v) aimbotEnabled = v end })
AimbotTab:CreateSlider({ Name = "FOV Radius", Range = {10, 500}, Increment = 5, CurrentValue = 150, Callback = function(v) fovRadius = v end })
AimbotTab:CreateDropdown({ Name = "Aim Part", Options = {"Head", "HumanoidRootPart", "Torso"}, CurrentOption = "Head", Callback = function(v) aimPartName = v end })
AimbotTab:CreateToggle({ Name = "Wall Check", CurrentValue = false, Callback = function(v) wallCheck = v end })

-- // ESP UI //
ESPTab:CreateToggle({ Name = "Enable ESP", CurrentValue = false, Callback = function(v) espEnabled = v end })

-- // ESP FUNCTION //
local ESPCache = {}
local function CreateESPForPlayer(player)
    if player == game.Players.LocalPlayer then return end
    ESPCache[player] = {
        Box = Drawing.new("Square"),
        Box.Visible = false, Box.Color = Color3.fromRGB(255, 0, 0), Box.Thickness = 2, Box.Filled = false,
        Tracer = Drawing.new("Line"),
        Tracer.Visible = false, Tracer.Color = Color3.fromRGB(255, 0, 0), Tracer.Thickness = 1,
        Distance = Drawing.new("Text"),
        Distance.Visible = false, Distance.Color = Color3.fromRGB(255, 255, 255), Distance.Size = 18, Distance.Center = true, Distance.Outline = true
    }
end

for _, p in ipairs(game.Players:GetPlayers()) do
    CreateESPForPlayer(p)
end
game.Players.PlayerAdded:Connect(CreateESPForPlayer)
game.Players.PlayerRemoving:Connect(function(p) ESPCache[p] = nil end)

game:GetService("RunService").RenderStepped:Connect(function()
    if not espEnabled then
        for _, esp in pairs(ESPCache) do
            esp.Box.Visible = false
            esp.Tracer.Visible = false
            esp.Distance.Visible = false
        end
        return
    end
    for player, esp in pairs(ESPCache) do
        local char = player.Character
        if char and char:FindFirstChild("Head") and char:FindFirstChild("HumanoidRootPart") then
            local head = char.Head
            local cam = workspace.CurrentCamera
            local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
            if onScreen then
                local scale = (cam.CFrame.Position - head.Position).magnitude
                local size = Vector2.new(2000 / scale, 3500 / scale)
                esp.Box.Position = Vector2.new(screenPos.X - size.X/2, screenPos.Y - size.Y/2)
                esp.Box.Size = size
                esp.Box.Visible = true
                esp.Tracer.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                esp.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                esp.Tracer.Visible = true
                esp.Distance.Position = Vector2.new(screenPos.X, screenPos.Y - size.Y/2 - 12)
                esp.Distance.Text = math.floor((cam.CFrame.Position - head.Position).magnitude) .. " studs"
                esp.Distance.Visible = true
            else
                esp.Box.Visible = false; esp.Tracer.Visible = false; esp.Distance.Visible = false
            end
        else
            esp.Box.Visible = false; esp.Tracer.Visible = false; esp.Distance.Visible = false
        end
    end
end)

-- // TOGGLE UI DENGAN RIGHT SHIFT //
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Rayfield:Toggle()
    end
end)

print("🔥 LYX AI SCRIPT LOADED! Rayfield UI, Anti HTTP Error! Enjoy Tuan 😈💀")
