local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB PREMIUM | AUTO HEADSHOT 💀",
   LoadingTitle = "TempekKauJatimMods",
   LoadingSubtitle = "Vioo's 100% Headshot Edition",
   ConfigurationSaving = { Enabled = false }
})

-- [[ SETTINGS ]]
getgenv().CombatConfig = {
    Aimkill = false,
    AutoHeadshot = true, -- Fitur Baru
    HitboxSize = 2,
    InstantReload = true,
    NoRecoil = true,
    Noclip = false,
    Fly = false,
    TeamCheck = true
}

local lp = game.Players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local vim = game:GetService("VirtualInputManager")

-- [[ FUNGSI CARI MUSUH TERDEKAT ]]
local function getClosestPlayer()
    local target = nil
    local dist = math.huge
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if not getgenv().CombatConfig.TeamCheck or p.Team ~= lp.Team then
                local d = (p.Character.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then
                    target = p
                    dist = d
                end
            end
        end
    end
    return target
end

-- [[ CORE ENGINE ]]
task.spawn(function()
    while task.wait() do
        pcall(function()
            local target = getClosestPlayer()

            -- 1. HITBOX 100
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

            -- 2. AUTO HEADSHOT LOGIC (MAGIC BULLET)
            if getgenv().CombatConfig.AutoHeadshot and target then
                -- Membelokkan kamera secara instan ke kepala saat menembak
                camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.Head.Position)
                
                -- Aimkill Execution
                if getgenv().CombatConfig.Aimkill then
                    vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
            end

            -- 3. NOCLIP
            if getgenv().CombatConfig.Noclip then
                for _, part in pairs(lp.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end
end)

-- [[ UI ELEMENTS ]]
local TabBrutal = Window:CreateTab("Ultra Brutal 💀")
local TabPlayer = Window:CreateTab("Movement ✈️")

TabBrutal:CreateToggle({
   Name = "100% AUTO HEADSHOT",
   CurrentValue = true,
   Callback = function(v) getgenv().CombatConfig.AutoHeadshot = v end,
})

TabBrutal:CreateToggle({
   Name = "AUTO AIMKILL (Lepas Tangan)",
   CurrentValue = false,
   Callback = function(v) getgenv().CombatConfig.Aimkill = v end,
})

TabBrutal:CreateSlider({
   Name = "Hitbox Size (MAX 100)",
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
   Name = "Fly Hack",
   CurrentValue = false,
   Callback = function(v)
       getgenv().CombatConfig.Fly = v
       -- (Logic Fly tetap sama seperti sebelumnya)
   end,
})

Rayfield:Notify({Title = "VIOO'S AIMBOT ACTIVATED", Content = "Semua peluru sekarang otomatis ke kepala!", Duration = 5})
