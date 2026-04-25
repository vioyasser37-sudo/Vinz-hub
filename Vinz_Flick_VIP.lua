local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB VIP | BUG FIXED 💀",
   LoadingTitle = "TempekkTeam",
   LoadingSubtitle = "Vioo's No-Bug Edition",
   ConfigurationSaving = { Enabled = false }
})

-- [[ SETTINGS ]]
getgenv().FlickConfig = {
    Aimbot = false,
    WallCheck = true,
    AimbotPart = "Head",
    ESP = false,
    NoRecoil = true,
    Speed = 16
}

local lp = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = lp:GetMouse()
local RunService = game:GetService("RunService")

-- [[ AUTO-REFRESH CAMERA ]]
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    camera = workspace.CurrentCamera
end)

-- [[ FUNGSI WALL CHECK ]]
local function isVisible(part)
    if not part then return false end
    local character = lp.Character
    if not character then return false end
    
    local origin = camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    local ray = RaycastParams.new()
    ray.FilterType = Enum.RaycastFilterType.Exclude
    ray.FilterDescendantsInstances = {character, camera, workspace:FindFirstChild("Ignore")}
    
    local result = workspace:Raycast(origin, direction, ray)
    return not result or result.Instance:IsDescendantOf(part.Parent)
end

-- [[ CORE ENGINE - RENDER STEPPED (FASTEST) ]]
RunService.RenderStepped:Connect(function()
    pcall(function()
        local target = nil
        local dist = math.huge
        
        -- 1. LOOP PLAYER & ESP
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= lp and p.Character then
                -- ESP CHAMS
                local highlight = p.Character:FindFirstChild("VinzESP")
                if getgenv().FlickConfig.ESP and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "VinzESP"
                        highlight.Parent = p.Character
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.FillTransparency = 0.5
                    end
                else
                    if highlight then highlight:Destroy() end
                end

                -- AIMBOT TARGETING
                if getgenv().FlickConfig.Aimbot and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local part = p.Character:FindFirstChild(getgenv().FlickConfig.AimbotPart)
                    if part then
                        if getgenv().FlickConfig.WallCheck and not isVisible(part) then
                            continue
                        end
                        
                        local pos, onscreen = camera:WorldToViewportPoint(part.Position)
                        if onscreen then
                            local mDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                            if mDist < dist then
                                target = part
                                dist = mDist
                            end
                        end
                    end
                end
            end
        end

        -- 2. EXECUTE AIMBOT (NO DELAY)
        if target and getgenv().FlickConfig.Aimbot then
            camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
        end
        
        -- 3. NO RECOIL (REALTIME)
        if getgenv().FlickConfig.NoRecoil and lp.Character then
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("NumberValue") and (v.Name:find("Recoil") or v.Name:find("Shake")) then
                    v.Value = 0
                end
            end
        end
    end)
end)

-- [[ UI TABS ]]
local TabCombat = Window:CreateTab("Ultra Combat 💀")
local TabPlayer = Window:CreateTab("Movement ⚡")

TabCombat:CreateToggle({
   Name = "ULTRA AIMBOT",
   CurrentValue = false,
   Callback = function(v) getgenv().FlickConfig.Aimbot = v end,
})

TabCombat:CreateToggle({
   Name = "Wall Check",
   CurrentValue = true,
   Callback = function(v) getgenv().FlickConfig.WallCheck = v end,
})

TabCombat:CreateToggle({
   Name = "ESP Musuh (Chams)",
   CurrentValue = false,
   Callback = function(v) getgenv().FlickConfig.ESP = v end,
})

TabCombat:CreateDropdown({
   Name = "Target Bone",
   Options = {"Head", "HumanoidRootPart"},
   CurrentOption = "Head",
   Callback = function(v) 
       getgenv().FlickConfig.AimbotPart = v 
       Rayfield:Notify({Title = "Mode Changed", Content = "Target sekarang: " .. v, Duration = 2})
   end,
})

TabPlayer:CreateSlider({
   Name = "Walk Speed",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) 
       if lp.Character and lp.Character:FindFirstChild("Humanoid") then
           lp.Character.Humanoid.WalkSpeed = v 
       end
   end,
})

Rayfield:Notify({Title = "FIXED TOTAL!", Content = "Ganti mode sekarang lancar jaya, Vioo!", Duration = 5})
