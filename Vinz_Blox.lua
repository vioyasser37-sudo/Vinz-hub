local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB | BLOX FRUITS 🏴‍☠️",
   LoadingTitle = "Jatim Mods Project",
   LoadingSubtitle = "Special Blox Fruits Edition",
   ConfigurationSaving = { Enabled = false }
})

-- [[ SETTINGS ]]
getgenv().BloxConfig = {
    AutoFarm = false,
    BringMob = false,
    Distance = 10,
    AutoQuest = true,
    FruitNotifier = false,
    AntiStaff = false
}

local lp = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")

-- [[ TABS ]]
local TabFarm = Window:CreateTab("Auto Farm 🌾")
local TabWorld = Window:CreateTab("Teleport 🏝️")
local TabSafe = Window:CreateTab("Security 🛡️")

-- [[ FUNGSI AUTO CLICK ]]
local function autoClick()
    vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

-- [[ CORE FARMING ENGINE ]]
task.spawn(function()
    while task.wait() do
        if getgenv().BloxConfig.AutoFarm then
            pcall(function()
                -- Cek Quest
                local hasQuest = lp.PlayerGui.Main:FindFirstChild("Quest") and lp.PlayerGui.Main.Quest.Visible
                
                if not hasQuest and getgenv().BloxConfig.AutoQuest then
                    -- LANGSUNG AMBIL QUEST VIA REMOTE (Gak perlu bengong di depan NPC)
                    local lvl = lp.Data.Level.Value
                    if lvl < 10 then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
                    elseif lvl >= 10 and lvl < 15 then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "JungleQuest", 1)
                    end
                    task.wait(0.5)
                end

                -- HAJAR MUSUH
                for _, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            -- Posisi di atas musuh biar aman
                            lp.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().BloxConfig.Distance, 0)
                            
                            -- Bring Mob
                            if getgenv().BloxConfig.BringMob then
                                v.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame * CFrame.new(0, -getgenv().BloxConfig.Distance, 0)
                                v.HumanoidRootPart.CanCollide = false
                            end
                            
                            autoClick()
                        until not getgenv().BloxConfig.AutoFarm or v.Humanoid.Health <= 0
                    end
                end
            end)
        end
    end
end)

-- [[ UI ELEMENTS ]]
TabFarm:CreateToggle({
   Name = "Auto Farm Level",
   CurrentValue = false,
   Callback = function(v) getgenv().BloxConfig.AutoFarm = v end,
})

TabFarm:CreateToggle({
   Name = "Bring Mob",
   CurrentValue = false,
   Callback = function(v) getgenv().BloxConfig.BringMob = v end,
})

TabWorld:CreateDropdown({
   Name = "Teleport Island",
   Options = {"Starter Island", "Jungle", "Pirate Village", "Desert"},
   CurrentOption = "Starter Island",
   Callback = function(v)
       local locs = {
           ["Starter Island"] = CFrame.new(1054, 16, 1547),
           ["Jungle"] = CFrame.new(-1255, 12, 335),
           ["Pirate Village"] = CFrame.new(-1147, 4, 3828)
       }
       if locs[v] then lp.Character.HumanoidRootPart.CFrame = locs[v] end
   end,
})

TabSafe:CreateToggle({
   Name = "Anti-Staff",
   CurrentValue = false,
   Callback = function(v) getgenv().BloxConfig.AntiStaff = v end,
})

-- Logic Anti-Staff
game.Players.PlayerAdded:Connect(function(player)
    if getgenv().BloxConfig.AntiStaff then
        if player:GetRankInGroup(2830050) >= 10 then
            lp:Kick("Vioo, ada Admin masuk! Server di-cut.")
        end
    end
end)

Rayfield:Notify({Title = "Vinz Hub Blox", Content = "Script Ready & Separated!", Duration = 5})
