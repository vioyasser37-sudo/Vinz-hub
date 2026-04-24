local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB | BLOX FRUITS 🏴‍☠️",
   LoadingTitle = "Jatim Mods Project",
   LoadingSubtitle = "Auto Farm Starter Edition",
   ConfigurationSaving = { Enabled = false }
})

-- [[ SETTINGS ]]
getgenv().AutoFarm = false
getgenv().BringMob = false
getgenv().FastAttack = true -- Kita nyalain terus biar gila

local lp = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")

-- [[ TABS ]]
local TabFarm = Window:CreateTab("Auto Farm 🌾")
local TabSafe = Window:CreateTab("Security 🛡️")

-- [[ FUNGSI AUTO ATTACK ]]
local function autoClick()
    if getgenv().AutoFarm then
        vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end
end

-- [[ CORE FARMING LOGIC ]]
spawn(function()
    while task.wait() do
        if getgenv().AutoFarm then
            pcall(function()
                -- Nyari musuh di sekitar (Contoh: Bandit di Starter Island)
                for _, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            -- 1. Teleport ke musuh (berdiri di belakangnya biar aman)
                            lp.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                            
                            -- 2. Kumpulin musuh kalau fiturnya nyala
                            if getgenv().BringMob then
                                v.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                                v.HumanoidRootPart.CanCollide = false
                            end
                            
                            -- 3. Gebuk!
                            autoClick()
                        until not getgenv().AutoFarm or v.Humanoid.Health <= 0
                    end
                end
            end)
        end
    end
end)

-- [[ UI ELEMENTS ]]
TabFarm:CreateToggle({
   Name = "Start Auto Farm (Bandit)",
   CurrentValue = false,
   Callback = function(v) getgenv().AutoFarm = v end,
})

TabFarm:CreateToggle({
   Name = "Bring Mob (Kumpulin NPC)",
   CurrentValue = false,
   Callback = function(v) getgenv().BringMob = v end,
})

TabSafe:CreateToggle({
   Name = "Anti-Staff (Auto Kick)",
   CurrentValue = false,
   Callback = function(v) 
      getgenv().AntiStaff = v 
   end,
})

-- Logic Anti-Staff
game.Players.PlayerAdded:Connect(function(player)
    if getgenv().AntiStaff then
        -- Cek kalau ada admin/player mencurigakan masuk
        if player:GetRankInGroup(2830050) >= 10 then
            lp:Kick("Admin Detected! Keluar demi keamanan Vioo.")
        end
    end
end)

Rayfield:Notify({Title = "Vinz Hub Blox", Content = "Siap tempur! Pastikan pegang senjata/combat ya!", Duration = 5})
