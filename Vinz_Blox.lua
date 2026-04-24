local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB | BLOX FRUITS PERFECT 🏴‍☠️",
   LoadingTitle = "Jatim Mods Project",
   LoadingSubtitle = "Brutal Kill Aura Edition",
   ConfigurationSaving = { Enabled = false }
})

-- [[ SETTINGS ]]
getgenv().BloxConfig = {
    AutoFarm = false,
    KillAura = false,
    BringMob = false,
    AutoQuest = true,
    Distance = 10
}

local lp = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")

-- [[ TABS ]]
local TabFarm = Window:CreateTab("Auto Farm 🌾")
local TabCombat = Window:CreateTab("Combat ⚔️")
local TabMisc = Window:CreateTab("Misc 🛡️")

-- [[ FUNGSI AMBIL QUEST OTOMATIS (REMOTE METHOD) ]]
local function checkAndGetQuest()
    local myLvl = lp.Data.Level.Value
    local hasQuest = lp.PlayerGui.Main:FindFirstChild("Quest") and lp.PlayerGui.Main.Quest.Visible
    
    if not hasQuest and getgenv().BloxConfig.AutoQuest then
        local remote = game:GetService("ReplicatedStorage").Remotes.CommF_
        if myLvl < 10 then
            remote:InvokeServer("StartQuest", "BanditQuest1", 1)
        elseif myLvl < 15 then
            remote:InvokeServer("StartQuest", "JungleQuest", 1) -- Monkey
        elseif myLvl < 30 then
            remote:InvokeServer("StartQuest", "JungleQuest", 2) -- Gorilla
        end
        -- Note: Nanti kita bisa tambah terus list levelnya di sini
    end
end

-- [[ CORE ENGINE: AUTO FARM & KILL AURA ]]
task.spawn(function()
    while task.wait() do
        pcall(function()
            if getgenv().BloxConfig.AutoFarm then
                checkAndGetQuest()
                
                for _, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            -- Teleport ke atas musuh
                            lp.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().BloxConfig.Distance, 0)
                            
                            -- Bring Mob
                            if getgenv().BloxConfig.BringMob then
                                v.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame * CFrame.new(0, -getgenv().BloxConfig.Distance, 0)
                                v.HumanoidRootPart.CanCollide = false
                            end
                            
                            -- Click Attack
                            vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                            vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        until not getgenv().BloxConfig.AutoFarm or v.Humanoid.Health <= 0
                    end
                end
            end
            
            -- KILL AURA LOGIC (Terpisah biar makin brutal)
            if getgenv().BloxConfig.KillAura then
                for _, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                    if v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude < 50 then
                        -- Memberi damage tanpa perlu animasi
                        local args = { [1] = v.Humanoid }
                        game:GetService("ReplicatedStorage").Remotes.Validator:FireServer(unpack(args))
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", v.Humanoid)
                    end
                end
            end
        end)
    end
end)

-- [[ UI ELEMENTS ]]
TabFarm:CreateToggle({
   Name = "Auto Farm Level",
   CurrentValue = false,
   Callback = function(v) getgenv().BloxConfig.AutoFarm = v end,
})

TabFarm:CreateToggle({
   Name = "Auto Quest (Smart)",
   CurrentValue = true,
   Callback = function(v) getgenv().BloxConfig.AutoQuest = v end,
})

TabFarm:CreateToggle({
   Name = "Bring Mob",
   CurrentValue = false,
   Callback = function(v) getgenv().BloxConfig.BringMob = v end,
})

TabCombat:CreateToggle({
   Name = "Kill Aura (Instan Kill)",
   CurrentValue = false,
   Callback = function(v) getgenv().BloxConfig.KillAura = v end,
})

TabMisc:CreateButton({
   Name = "Server Hop",
   Callback = function()
       -- Logic pindah server sepi
   end,
})

Rayfield:Notify({Title = "Vinz Hub PERFECT", Content = "Kill Aura & Auto Quest Siap!", Duration = 5})
