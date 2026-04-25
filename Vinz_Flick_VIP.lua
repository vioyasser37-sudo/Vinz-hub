local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB VIP | FLICK V3 🎯",
   LoadingTitle = "Groundwork Specialist",
   LoadingSubtitle = "Vioo's Wall-Check Edition",
   ConfigurationSaving = { Enabled = false }
})

-- [[ SETTINGS ]]
getgenv().FlickConfig = {
    Aimbot = false,
    WallCheck = true, -- Fitur Baru
    AimbotPart = "Head",
    ShowFOV = false,
    FOVSize = 100,
    TeamCheck = true,
    NoRecoil = true
}

local lp = game.Players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local mouse = lp:GetMouse()

-- [[ FOV CIRCLE ]]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.5

-- [[ FUNGSI WALL CHECK (RAYCAST) ]]
local function isVisible(part)
    local character = lp.Character
    if not character then return false end
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character, camera}
    
    local origin = camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    local result = game:GetService("Workspace"):Raycast(origin, direction, params)
    
    -- Kalau tidak ada yang menghalangi antara kamera dan musuh, berarti Visible
    if not result or result.Instance:IsDescendantOf(part.Parent) then
        return true
    end
    return false
end

-- [[ CORE AIMBOT ENGINE ]]
local function getClosestPlayer()
    local target = nil
    local shortestDist = getgenv().FlickConfig.FOVSize

    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild(getgenv().FlickConfig.AimbotPart) and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if not getgenv().FlickConfig.TeamCheck or p.Team ~= lp.Team then
                local part = p.Character[getgenv().FlickConfig.AimbotPart]
                local pos, onscreen = camera:WorldToViewportPoint(part.Position)
                
                if onscreen then
                    -- Cek Wall Check
                    if getgenv().FlickConfig.WallCheck and not isVisible(part) then
                        continue -- Lewati musuh kalau di balik tembok
                    end

                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    if dist < shortestDist then
                        target = part
                        shortestDist = dist
                    end
                end
            end
        end
    end
    return target
end

task.spawn(function()
    while task.wait() do
        FOVCircle.Visible = getgenv().FlickConfig.ShowFOV
        FOVCircle.Radius = getgenv().FlickConfig.FOVSize
        FOVCircle.Position = Vector2.new(mouse.X, mouse.Y + 36)

        if getgenv().FlickConfig.Aimbot then
            local target = getClosestPlayer()
            if target then
                camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
            end
        end
        
        -- No Recoil logic
        if getgenv().FlickConfig.NoRecoil and lp.Character then
            pcall(function()
                for _, v in pairs(lp.Character:GetDescendants()) do
                    if v:IsA("NumberValue") and (v.Name:find("Recoil") or v.Name:find("Shake")) then
                        v.Value = 0
                    end
                end
            end)
        end
    end
end)

-- [[ UI TABS ]]
local TabAimbot = Window:CreateTab("Aimbot & Security 🎯")
local TabPlayer = Window:CreateTab("Movement ⚡")

TabAimbot:CreateToggle({
   Name = "Enable Aimbot Lock",
   CurrentValue = false,
   Callback = function(v) getgenv().FlickConfig.Aimbot = v end,
})

TabAimbot:CreateToggle({
   Name = "Wall Check (Anti-Tembok)",
   CurrentValue = true,
   Callback = function(v) getgenv().FlickConfig.WallCheck = v end,
})

TabAimbot:CreateToggle({
   Name = "Show FOV Circle",
   CurrentValue = false,
   Callback = function(v) getgenv().FlickConfig.ShowFOV = v end,
})

TabAimbot:CreateSlider({
   Name = "FOV Size",
   Range = {50, 500},
   Increment = 10,
   CurrentValue = 100,
   Callback = function(v) getgenv().FlickConfig.FOVSize = v end,
})

TabPlayer:CreateSlider({
   Name = "Speed Hack",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) 
       if lp.Character and lp.Character:FindFirstChild("Humanoid") then
           lp.Character.Humanoid.WalkSpeed = v 
       end
   end,
})

Rayfield:Notify({Title = "Wall Check Active", Content = "Aimbot makin pinter, Vioo!", Duration = 5})
