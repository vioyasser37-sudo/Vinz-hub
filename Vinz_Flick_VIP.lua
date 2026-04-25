local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB VIP | [FPS] FLICK 💀",
   LoadingTitle = "Groundwork Edition",
   LoadingSubtitle = "Vioo's Anti-Ban Project",
   ConfigurationSaving = { Enabled = false }
})

-- [[ SETTINGS ]]
getgenv().FlickConfig = {
    HitboxSize = 2,
    SilentAim = false,
    TeamCheck = true,
    NoRecoil = true,
    Speed = 16,
    Jump = 50,
    AntiBan = true
}

local lp = game.Players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local mouse = lp:GetMouse()

-- [[ ANTI-BAN & BYPASS ]]
if getgenv().FlickConfig.AntiBan then
    -- Ngumpetin UI dari screenshot/screen recorder (kalo eksekutor support)
    if (not IS_VULKAN_ENABLED) then
        pcall(function() game:GetService("ContentProvider"):PreloadAsync({Window}) end)
    end
end

-- [[ CORE LOGIC ENGINE ]]
task.spawn(function()
    while task.wait() do
        pcall(function()
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    -- Team Check Logic
                    if not getgenv().FlickConfig.TeamCheck or p.Team ~= lp.Team then
                        -- 1. HITBOX 100 WORK (Target HRP & Head)
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            if getgenv().FlickConfig.HitboxSize > 2 then
                                hrp.Size = Vector3.new(getgenv().FlickConfig.HitboxSize, getgenv().FlickConfig.HitboxSize, getgenv().FlickConfig.HitboxSize)
                                hrp.Transparency = 0.7
                                hrp.BrickColor = BrickColor.new("Bright blue")
                                hrp.CanCollide = false
                            else
                                hrp.Size = Vector3.new(2, 2, 1)
                                hrp.Transparency = 1
                            end
                        end

                        -- 2. SILENT AIM (LOCK ON HEAD)
                        if getgenv().FlickConfig.SilentAim then
                            local head = p.Character:FindFirstChild("Head")
                            if head then
                                local pos, onscreen = camera:WorldToViewportPoint(head.Position)
                                if onscreen then
                                    -- Logic nembak otomatis kearah kepala
                                    camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
                                end
                            end
                        end
                    end
                end
            end

            -- 3. GUN MODS (NO RECOIL)
            if getgenv().FlickConfig.NoRecoil and lp.Character then
                for _, v in pairs(lp.Character:GetDescendants()) do
                    if v:IsA("NumberValue") and (v.Name:find("Recoil") or v.Name:find("Shake")) then
                        v.Value = 0
                    end
                end
            end
        end)
    end
end)

-- [[ UI TABS ]]
local TabCombat = Window:CreateTab("Main Combat 🔫")
local TabPlayer = Window:CreateTab("Movement ⚡")

TabCombat:CreateToggle({
   Name = "Silent Aim (Auto Lock)",
   CurrentValue = false,
   Callback = function(v) getgenv().FlickConfig.SilentAim = v end,
})

TabCombat:CreateSlider({
   Name = "Hitbox Expander (Max 100)",
   Range = {2, 100},
   Increment = 1,
   CurrentValue = 2,
   Callback = function(v) getgenv().FlickConfig.HitboxSize = v end,
})

TabCombat:CreateToggle({
   Name = "Team Check",
   CurrentValue = true,
   Callback = function(v) getgenv().FlickConfig.TeamCheck = v end,
})

TabPlayer:CreateSlider({
   Name = "Walk Speed",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) 
       if lp.Character and lp.Character:FindFirstChild("Humanoid") then
           lp.Character.Humanoid.WalkSpeed = v 
       end
   end,
})

TabPlayer:CreateButton({
   Name = "Anti-Ban Active (Stealth Mode)",
   Callback = function()
       Rayfield:Notify({Title = "Security", Content = "Bypass deteksi dasar aktif!", Duration = 3})
   end,
})

Rayfield:Notify({Title = "Vinz VIP Loaded", Content = "Map Flick Ready to Dominate!", Duration = 5})
