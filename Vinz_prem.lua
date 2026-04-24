local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB PREMIUM | COMBAT 🔫",
   LoadingTitle = "Jatim Mods Project",
   LoadingSubtitle = "by kingMahaRajaVio - Mobile Optimization",
   ConfigurationSaving = { Enabled = false }
})

-- [[ SETTINGS ]]
getgenv().CombatConfig = {
    Aimbot = false,
    HitboxSize = 2,
    InstantReload = false,
    NoRecoil = false,
    ESP = false,
    WalkSpeed = 16
}

local lp = game.Players.LocalPlayer
local mouse = lp:GetMouse()
local camera = game:GetService("Workspace").CurrentCamera

-- [[ TABS ]]
local TabMain = Window:CreateTab("Main Hacks 🛡️")
local TabPlayer = Window:CreateTab("Player 👤")
local TabMisc = Window:CreateTab("Misc ⚙️")

-- [[ CORE COMBAT LOGIC ]]
task.spawn(function()
    while task.wait() do
        pcall(function()
            -- 1. HITBOX EXPANDER (BRUTAL)
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    if getgenv().CombatConfig.HitboxSize > 2 then
                        hrp.Size = Vector3.new(getgenv().CombatConfig.HitboxSize, getgenv().CombatConfig.HitboxSize, getgenv().CombatConfig.HitboxSize)
                        hrp.Transparency = 0.7
                        hrp.CanCollide = false
                    else
                        hrp.Size = Vector3.new(2, 2, 1)
                        hrp.Transparency = 1
                    end
                end
            end

            -- 2. INSTANT RELOAD & NO RECOIL
            if lp.Character then
                for _, v in pairs(lp.Character:GetDescendants()) do
                    if v:IsA("NumberValue") or v:IsA("IntValue") then
                        if getgenv().CombatConfig.InstantReload then
                            if v.Name == "ReloadTime" or v.Name == "Reload" then v.Value = 0 end
                        end
                        if getgenv().CombatConfig.NoRecoil then
                            if v.Name == "Recoil" or v.Name == "Shake" then v.Value = 0 end
                        end
                    end
                end
            end

            -- 3. SIMPLE AIMBOT (LOCK ON MOUSE)
            if getgenv().CombatConfig.Aimbot then
                local closest = nil
                local dist = math.huge
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local pos, onscreen = camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                        if onscreen then
                            local mDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                            if mDist < dist then
                                closest = p.Character.HumanoidRootPart
                                dist = mDist
                            end
                        end
                    end
                end
                if closest then
                    camera.CFrame = CFrame.new(camera.CFrame.Position, closest.Position)
                end
            end
        end)
    end
end)

-- [[ UI ELEMENTS ]]
TabMain:CreateToggle({
   Name = "Silent Aimbot (Auto Lock)",
   CurrentValue = false,
   Callback = function(v) getgenv().CombatConfig.Aimbot = v end,
})

TabMain:CreateSlider({
   Name = "Hitbox Size (Musuh Gede)",
   Range = {2, 35},
   Increment = 1,
   CurrentValue = 2,
   Callback = function(v) getgenv().CombatConfig.HitboxSize = v end,
})

TabMain:CreateToggle({
   Name = "Instant Reload ⚡",
   CurrentValue = false,
   Callback = function(v) getgenv().CombatConfig.InstantReload = v end,
})

TabMain:CreateToggle({
   Name = "No Recoil (Lurus Terus)",
   CurrentValue = false,
   Callback = function(v) getgenv().CombatConfig.NoRecoil = v end,
})

TabPlayer:CreateSlider({
   Name = "Speed Hack",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) lp.Character.Humanoid.WalkSpeed = v end,
})

Rayfield:Notify({Title = "Vinz Premium Load", Content = "Siap ngerasain brutalnya, Vioo?", Duration = 5})
