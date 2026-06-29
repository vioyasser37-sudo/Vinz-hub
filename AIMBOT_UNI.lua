-- ========================================================= --
-- REZZ AIMBOT ULTRA VIP V12 - RAYFIELD UI EDITION           --
-- FITUR: FULL PACK + RAYFIELD MODERN UI                     --
-- ========================================================= --

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Rezz Ultra VIP V12 | Defusal Hub",
    LoadingTitle = "Rezz Script Loading...",
    LoadingSubtitle = "by Vioo x Lyx AI",
    ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Combat", nil)
local ESPTab = Window:CreateTab("Visuals", nil)

-- CONFIG --
local Config = { Aimbot = false, AimPart = "Head", TeamCheck = true, WallCheck = true, ESP = false }
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- AIMBOT TOGGLE --
Tab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(Value) Config.Aimbot = Value end
})

-- TARGET MODE --
Tab:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "HumanoidRootPart"},
    Callback = function(Option) Config.AimPart = Option end
})

-- TEAM CHECK --
Tab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(Value) Config.TeamCheck = Value end
})

-- WALLCHECK --
Tab:CreateToggle({
    Name = "WallCheck",
    CurrentValue = true,
    Callback = function(Value) Config.WallCheck = Value end
})

-- ESP TOGGLE --
ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(Value) Config.ESP = Value end
})

-- LOGIC --
RunService.RenderStepped:Connect(function()
    if Config.Aimbot then
        local closest, maxDist = nil, 300
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(Config.AimPart) then
                if Config.TeamCheck and plr.Team == LocalPlayer.Team then continue end
                
                local targetPart = plr.Character[Config.AimPart]
                local pos, on = Camera:WorldToScreenPoint(targetPart.Position)
                
                if on then
                    if Config.WallCheck then
                        local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000)
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                        if not hit or not hit:IsDescendantOf(plr.Character) then continue end
                    end
                    
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < maxDist then closest = targetPart; maxDist = dist end
                end
            end
        end
        if closest then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closest.Position), 0.15) end
    end
end)

-- ESP LOGIC --
RunService.RenderStepped:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hl = plr.Character:FindFirstChild("RezzESP")
            if Config.ESP and not hl then 
                local box = Instance.new("Highlight", plr.Character); box.Name = "RezzESP"; box.FillColor = Color3.fromRGB(0, 200, 255) 
            elseif not Config.ESP and hl then hl:Destroy() end
        end
    end
end)
