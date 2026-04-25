local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB PREMIUM | ULTRA AIMKILL 💀",
   LoadingTitle = "VinzPrime",
   LoadingSubtitle = "by VIP - No Click Edition",
   ConfigurationSaving = { Enabled = false }
})

-- [[ SETTINGS ]]
getgenv().CombatConfig = {
    Aimkill = false,
    HitboxSize = 2,
    InstantReload = true,
    NoRecoil = true,
    TeamCheck = true,
    Speed = 16
}

local lp = game.Players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local vim = game:GetService("VirtualInputManager")

-- [[ TABS ]]
local TabBrutal = Window:CreateTab("Ultra Combat 💀")
local TabPlayer = Window:CreateTab("Movement ⚡")

-- [[ CORE AIMKILL & COMBAT ENGINE ]]
task.spawn(function()
    while task.wait() do
        pcall(function()
            -- 1. AIMKILL LOGIC (AUTO ATTACK)
            if getgenv().CombatConfig.Aimkill then
                local target = nil
                local dist = math.huge
                
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        if not getgenv().CombatConfig.TeamCheck or p.Team ~= lp.Team then
                            local d = (p.Character.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
                            if d < 500 and d < dist then
                                target = p
                                dist = d
                            end
                        end
                    end
                end

                if target and lp.Character:FindFirstChildOfClass("Tool") then
                    -- Lock Kamera ke Kepala
                    camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.Head.Position)
                    
                    -- Spam Attack (Sesuai Request: Tanpa Pencet)
                    local tool = lp.Character:FindFirstChildOfClass("Tool")
                    local remote = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("Fire") or tool:FindFirstChild("Shoot")
                    
                    if remote then
                        remote:FireServer(target.Character.Head.Position, target.Character.Head)
                    end
                    
                    -- Clicker Backup
                    vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
            end

            -- 2. HITBOX & GUN MODS
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    if getgenv().CombatConfig.HitboxSize > 2 then
                        hrp.Size = Vector3.new(getgenv().CombatConfig.HitboxSize, getgenv().CombatConfig.HitboxSize, getgenv().CombatConfig.HitboxSize)
                        hrp.Transparency = 0.7
                    end
                end
            end

            if lp.Character then
                for _, v in pairs(lp.Character:GetDescendants()) do
                    if v:IsA("NumberValue") then
                        if getgenv().CombatConfig.InstantReload and (v.Name:find("Reload") or v.Name:find("Delay")) then v.Value = 0 end
                        if getgenv().CombatConfig.NoRecoil and (v.Name:find("Recoil") or v.Name:find("Shake")) then v.Value = 0 end
                    end
                end
            end
        end)
    end
end)

-- [[ UI ELEMENTS ]]
TabBrutal:CreateToggle({
   Name = "AUTO AIMKILL (LEPAS TANGAN)",
   CurrentValue = false,
   Callback = function(v) getgenv().CombatConfig.Aimkill = v end,
})

TabBrutal:CreateSlider({
   Name = "Hitbox Size (Musuh Gede)",
   Range = {2, 35},
   Increment = 1,
   CurrentValue = 2,
   Callback = function(v) getgenv().CombatConfig.HitboxSize = v end,
})

TabBrutal:CreateToggle({
   Name = "Team Check",
   CurrentValue = true,
   Callback = function(v) getgenv().CombatConfig.TeamCheck = v end,
})

TabPlayer:CreateSlider({
   Name = "Speed Hack",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) lp.Character.Humanoid.WalkSpeed = v end,
})

Rayfield:Notify({Title = "Vioo's Premium Loaded", Content = "Aimkill Ready! Gaskeun!", Duration = 5})
