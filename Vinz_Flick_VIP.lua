local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB VIP | ULTRA COMBAT 💀",
   LoadingTitle = "Groundwork Specialist",
   LoadingSubtitle = "Vioo's No-Limit Edition",
   ConfigurationSaving = { Enabled = false }
})

-- [[ SETTINGS ]]
getgenv().FlickConfig = {
    Aimbot = false,
    WallCheck = true,
    AimbotPart = "Head",
    NoRecoil = true,
    Speed = 16
}

local lp = game.Players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local mouse = lp:GetMouse()

-- [[ FUNGSI WALL CHECK ]]
local function isVisible(part)
    local character = lp.Character
    if not character then return false end
    local origin = camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    local ray = RaycastParams.new()
    ray.FilterType = Enum.RaycastFilterType.Exclude
    ray.FilterDescendantsInstances = {character, camera}
    
    local result = game:GetService("Workspace"):Raycast(origin, direction, ray)
    return not result or result.Instance:IsDescendantOf(part.Parent)
end

-- [[ CORE BRUTAL AIMBOT ENGINE (NO TEAM CHECK) ]]
task.spawn(function()
    while task.wait() do
        if getgenv().FlickConfig.Aimbot then
            pcall(function()
                local target = nil
                local dist = math.huge
                
                for _, p in pairs(game.Players:GetPlayers()) do
                    -- Langsung gas semua player kecuali diri sendiri
                    if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        local part = p.Character:FindFirstChild(getgenv().FlickConfig.AimbotPart)
                        if part then
                            -- Wall Check tetap ada biar ga nembak tembok
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

                if target then
                    camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
                end
            end)
        end

        if getgenv().FlickConfig.NoRecoil and lp.Character then
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("NumberValue") and (v.Name:find("Recoil") or v.Name:find("Shake")) then
                    v.Value = 0
                end
            end
        end
    end
end)

-- [[ UI TABS ]]
local TabCombat = Window:CreateTab("Ultra Combat 💀")
local TabPlayer = Window:CreateTab("Movement ⚡")

TabCombat:CreateToggle({
   Name = "ULTRA AIMBOT (Lock-On)",
   CurrentValue = false,
   Callback = function(v) getgenv().FlickConfig.Aimbot = v end,
})

TabCombat:CreateToggle({
   Name = "Wall Check",
   CurrentValue = true,
   Callback = function(v) getgenv().FlickConfig.WallCheck = v end,
})

TabCombat:CreateDropdown({
   Name = "Target Bone",
   Options = {"Head", "HumanoidRootPart"},
   CurrentOption = "Head",
   Callback = function(v) getgenv().FlickConfig.AimbotPart = v end,
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

Rayfield:Notify({Title = "Team Check Removed", Content = "Aimbot sekarang hajar semua orang!", Duration = 5})
