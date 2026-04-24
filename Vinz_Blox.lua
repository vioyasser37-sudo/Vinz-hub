local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB | BLOX FRUITS ULTIMATE 🏴‍☠️",
   LoadingTitle = "Jatim ModsAndVinzTeam",
   LoadingSubtitle = "KingMahaRaja's Complete Edition",
   ConfigurationSaving = { Enabled = false }
})

-- [[ SETTINGS ]]
getgenv().BloxConfig = {
    AutoFarm = false,
    KillAura = false,
    BringMob = false,
    AutoQuest = true,
    Distance = 9,
    WeaponMode = "Melee",
    AntiStaff = false
}

local lp = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")

-- [[ TABS ]]
local TabFarm = Window:CreateTab("Auto Farm 🌾")
local TabWeapon = Window:CreateTab("Weapon Mode ⚔️")
local TabWorld = Window:CreateTab("Teleport 🏝️")
local TabSafe = Window:CreateTab("Security 🛡️")

-- [[ FUNGSI AUTO EQUIP ]]
local function equipSelectedWeapon()
    pcall(function()
        local mode = getgenv().BloxConfig.WeaponMode
        for _, v in pairs(lp.Backpack:GetChildren()) do
            if (mode == "Melee" and (v.ToolTip == "Melee" or v.Name == "Combat")) or
               (mode == "Sword" and v.ToolTip == "Sword") or
               (mode == "Fruit" and (v.ToolTip == "Blox Fruit" or v.Name:find("Fruit"))) then
                lp.Character.Humanoid:EquipTool(v)
                break
            end
        end
    end)
end

-- [[ CORE ENGINE: FARM & QUEST ]]
task.spawn(function()
    while task.wait() do
        if getgenv().BloxConfig.AutoFarm then
            pcall(function()
                local lvl = lp.Data.Level.Value
                local hasQuest = lp.PlayerGui.Main:FindFirstChild("Quest") and lp.PlayerGui.Main.Quest.Visible
                
                -- Auto Quest Logic (Sea 1)
                if not hasQuest and getgenv().BloxConfig.AutoQuest then
                    local qName, qID, npcPos
                    if lvl < 10 then qName, qID, npcPos = "BanditQuest1", 1, CFrame.new(1060, 15, 1532)
                    elseif lvl < 15 then qName, qID, npcPos = "JungleQuest", 1, CFrame.new(-1601, 37, 153)
                    elseif lvl < 30 then qName, qID, npcPos = "JungleQuest", 2, CFrame.new(-1601, 37, 153) end
                    
                    if npcPos then
                        lp.Character.HumanoidRootPart.CFrame = npcPos
                        task.wait(0.5)
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", qName, qID)
                    end
                end

                -- Farm & Kill Logic
                for _, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        equipSelectedWeapon()
                        repeat
                            task.wait()
                            lp.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().BloxConfig.Distance, 0)
                            
                            if getgenv().BloxConfig.BringMob then
                                v.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame
                                v.HumanoidRootPart.CanCollide = false
                            end

                            if getgenv().BloxConfig.KillAura then
                                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", v.Humanoid)
                            end
                            vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                            vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        until not getgenv().BloxConfig.AutoFarm or v.Humanoid.Health <= 0
                    end
                end
            end)
        end
    end
end)

-- [[ UI: AUTO FARM ]]
TabFarm:CreateToggle({
   Name = "Auto Farm Level",
   CurrentValue = false,
   Callback = function(v) getgenv().BloxConfig.AutoFarm = v end,
})

TabFarm:CreateToggle({
   Name = "Kill Aura (Instan Hit)",
   CurrentValue = false,
   Callback = function(v) getgenv().BloxConfig.KillAura = v end,
})

TabFarm:CreateToggle({
   Name = "Bring Mob",
   CurrentValue = false,
   Callback = function(v) getgenv().BloxConfig.BringMob = v end,
})

-- [[ UI: WEAPON SELECTION ]]
TabWeapon:CreateDropdown({
   Name = "Select Mastery Mode",
   Options = {"Melee", "Sword", "Fruit"},
   CurrentOption = "Melee",
   Callback = function(v) getgenv().BloxConfig.WeaponMode = v end,
})

-- [[ UI: TELEPORT ]]
TabWorld:CreateDropdown({
   Name = "Teleport To Island",
   Options = {"Starter Island", "Jungle", "Pirate Village", "Desert", "Snow Mountain"},
   CurrentOption = "Starter Island",
   Callback = function(v)
       local locs = {
           ["Starter Island"] = CFrame.new(1054, 16, 1547),
           ["Jungle"] = CFrame.new(-1255, 12, 335),
           ["Pirate Village"] = CFrame.new(-1147, 4, 3828),
           ["Desert"] = CFrame.new(944, 6, 4329),
           ["Snow Mountain"] = CFrame.new(1354, 87, -1324)
       }
       if locs[v] then lp.Character.HumanoidRootPart.CFrame = locs[v] end
   end,
})

-- [[ UI: SECURITY ]]
TabSafe:CreateToggle({
   Name = "Anti-Staff (Auto Kick)",
   CurrentValue = false,
   Callback = function(v) getgenv().BloxConfig.AntiStaff = v end,
})

game.Players.PlayerAdded:Connect(function(p)
    if getgenv().BloxConfig.AntiStaff and p:GetRankInGroup(2830050) >= 10 then
        lp:Kick("Vioo, Admin masuk! Server diputus biar aman.")
    end
end)

Rayfield:Notify({Title = "Vinz Hub ULTIMATE", Content = "Semua fitur sudah kembali, Vioo!", Duration = 5})
