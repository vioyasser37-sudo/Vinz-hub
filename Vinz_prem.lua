local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB PREMIUM | ULTRA BRUTALY💀",
   LoadingTitle = "VinzTeam",
   LoadingSubtitle = "Vioo's God Mode - No Mercy",
   ConfigurationSaving = { Enabled = false }
})

-- [[ SETTINGS ]]
getgenv().CombatConfig = {
    Aimbot = false,
    TriggerBot = false,
    HitboxSize = 2,
    InstantReload = false,
    NoRecoil = false,
    Fly = false,
    Speed = 100,
    Jump = 50
}

local lp = game.Players.LocalPlayer
local mouse = lp:GetMouse()
local camera = game:GetService("Workspace").CurrentCamera

-- [[ TABS ]]
local TabBrutal = Window:CreateTab("Ultra Brutal 💀")
local TabPlayer = Window:CreateTab("Player & Fly ✈️")
local TabWeapon = Window:CreateTab("Gun Mods 🔫")

-- [[ CORE BRUTAL LOGIC ]]
task.spawn(function()
    while task.wait() do
        pcall(function()
            -- 1. HITBOX EXPANDER (MAX BRUTAL)
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    if getgenv().CombatConfig.HitboxSize > 2 then
                        hrp.Size = Vector3.new(getgenv().CombatConfig.HitboxSize, getgenv().CombatConfig.HitboxSize, getgenv().CombatConfig.HitboxSize)
                        hrp.Transparency = 0.8
                        hrp.CanCollide = false -- Musuh gak bisa nabrak kamu, tapi kamu bisa tembus mereka
                    end
                end
            end

            -- 2. SILENT AIMBOT + TRIGGER BOT
            if getgenv().CombatConfig.Aimbot then
                local target = nil
                local dist = math.huge
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= lp and p.Character and p.Character:FindFirstChild("Head") then
                        local pos, onscreen = camera:WorldToViewportPoint(p.Character.Head.Position)
                        if onscreen then
                            local mDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                            if mDist < dist then
                                target = p.Character.Head
                                dist = mDist
                            end
                        end
                    end
                end
                if target then
                    camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
                    -- Trigger Bot (Otomatis Klik pas Lock)
                    if getgenv().CombatConfig.TriggerBot then
                        mouse1click()
                    end
                end
            end

            -- 3. GUN MODS (INSTANT)
            if lp.Character then
                for _, v in pairs(lp.Character:GetDescendants()) do
                    if v:IsA("NumberValue") or v:IsA("IntValue") then
                        if getgenv().CombatConfig.InstantReload and (v.Name:find("Reload") or v.Name:find("Delay")) then
                            v.Value = 0
                        end
                        if getgenv().CombatConfig.NoRecoil and (v.Name:find("Recoil") or v.Name:find("Shake")) then
                            v.Value = 0
                        end
                    end
                end
            end
        end)
    end
end)

-- [[ UI ELEMENTS ]]
TabBrutal:CreateToggle({
   Name = "Lock-On Aimbot",
   CurrentValue = false,
   Callback = function(v) getgenv().CombatConfig.Aimbot = v end,
})

TabBrutal:CreateToggle({
   Name = "Auto-Shoot (TriggerBot)",
   CurrentValue = false,
   Callback = function(v) getgenv().CombatConfig.TriggerBot = v end,
})

TabBrutal:CreateSlider({
   Name = "Hitbox Expander (35 = GOD)",
   Range = {2, 35},
   Increment = 1,
   CurrentValue = 2,
   Callback = function(v) getgenv().CombatConfig.HitboxSize = v end,
})

TabWeapon:CreateToggle({
   Name = "Instant Reload ⚡",
   CurrentValue = false,
   Callback = function(v) getgenv().CombatConfig.InstantReload = v end,
})

TabWeapon:CreateToggle({
   Name = "No Recoil (Laser)",
   CurrentValue = false,
   Callback = function(v) getgenv().CombatConfig.NoRecoil = v end,
})

TabPlayer:CreateToggle({
   Name = "Noclip (Tembus Tembok)",
   CurrentValue = false,
   Callback = function(v)
       task.spawn(function()
           while v do
               task.wait()
               for _, part in pairs(lp.Character:GetDescendants()) do
                   if part:IsA("BasePart") then part.CanCollide = false end
               end
               if not getgenv().CombatConfig.Noclip then break end
           end
       end)
       getgenv().CombatConfig.Noclip = v
   end,
})

TabPlayer:CreateSlider({
   Name = "Speed Speed",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) lp.Character.Humanoid.WalkSpeed = v end,
})

Rayfield:Notify({Title = "ULTRA BRUTAL ACTIVATED", Content = "Hati-hati Vioo, jangan sampe kena report massal!", Duration = 5})
