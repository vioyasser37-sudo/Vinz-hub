local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB PREMIUM | GOD MODE 💀",
   LoadingTitle = "Jatim Mods",
   LoadingSubtitle = "Vioo's Ultimate Brutal Edition",
   ConfigurationSaving = { Enabled = false }
})

-- [[ SETTINGS ]]
getgenv().CombatConfig = {
    Aimkill = false,
    HitboxSize = 2,
    InstantReload = true,
    NoRecoil = true,
    Noclip = false,
    Fly = false,
    FlySpeed = 50,
    TeamCheck = true
}

local lp = game.Players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local vim = game:GetService("VirtualInputManager")

-- [[ TABS ]]
local TabBrutal = Window:CreateTab("Brutal Mods 💀")
local TabPlayer = Window:CreateTab("Movement ✈️")

-- [[ CORE ENGINE ]]
task.spawn(function()
    while task.wait() do
        pcall(function()
            -- 1. HITBOX 100 (SUPER BRUTAL)
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    if getgenv().CombatConfig.HitboxSize > 2 then
                        hrp.Size = Vector3.new(getgenv().CombatConfig.HitboxSize, getgenv().CombatConfig.HitboxSize, getgenv().CombatConfig.HitboxSize)
                        hrp.Transparency = 0.8
                        hrp.CanCollide = false
                    end
                end
            end

            -- 2. AIMKILL & AUTO ATTACK
            if getgenv().CombatConfig.Aimkill then
                local target = nil
                local dist = math.huge
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        if not getgenv().CombatConfig.TeamCheck or p.Team ~= lp.Team then
                            local d = (p.Character.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
                            if d < 1000 and d < dist then
                                target = p
                                dist = d
                            end
                        end
                    end
                end
                if target then
                    camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.Head.Position)
                    vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
            end

            -- 3. NOCLIP LOGIC
            if getgenv().CombatConfig.Noclip then
                for _, part in pairs(lp.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end
end)

-- [[ FLY LOGIC ]]
local function startFly()
    local bg = Instance.new("BodyGyro", lp.Character.HumanoidRootPart)
    local bv = Instance.new("BodyVelocity", lp.Character.HumanoidRootPart)
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = lp.Character.HumanoidRootPart.CFrame
    bv.velocity = Vector3.new(0, 0.1, 0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
    task.spawn(function()
        while getgenv().CombatConfig.Fly do
            task.wait()
            lp.Character.Humanoid.PlatformStand = true
            bv.velocity = camera.CFrame.LookVector * getgenv().CombatConfig.FlySpeed
        end
        bg:Destroy()
        bv:Destroy()
        lp.Character.Humanoid.PlatformStand = false
    end)
end

-- [[ UI ELEMENTS ]]
TabBrutal:CreateToggle({
   Name = "AUTO AIMKILL (Lepas Tangan)",
   CurrentValue = false,
   Callback = function(v) getgenv().CombatConfig.Aimkill = v end,
})

TabBrutal:CreateSlider({
   Name = "Hitbox Expander (MAX 100)",
   Range = {2, 100},
   Increment = 1,
   CurrentValue = 2,
   Callback = function(v) getgenv().CombatConfig.HitboxSize = v end,
})

TabPlayer:CreateToggle({
   Name = "Noclip (Tembus Tembok)",
   CurrentValue = false,
   Callback = function(v) getgenv().CombatConfig.Noclip = v end,
})

TabPlayer:CreateToggle({
   Name = "Fly (Terbang)",
   CurrentValue = false,
   Callback = function(v) 
       getgenv().CombatConfig.Fly = v 
       if v then startFly() end
   end,
})

TabPlayer:CreateSlider({
   Name = "Speed Speed",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) lp.Character.Humanoid.WalkSpeed = v end,
})

Rayfield:Notify({Title = "GOD MODE ACTIVATED", Content = "Hitbox 100 & Noclip Ready, Vioo!", Duration = 5})
