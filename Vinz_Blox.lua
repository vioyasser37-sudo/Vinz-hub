local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB | BLOX FRUITS TWEEN 🏴‍☠️",
   LoadingTitle = "Jatim Mods Project",
   LoadingSubtitle = "Vioo's Safe & Brutal Edition",
   ConfigurationSaving = { Enabled = false }
})

-- [[ SETTINGS ]]
getgenv().BloxConfig = {
    AutoFarm = false,
    KillAura = false,
    BringMob = false,
    AutoQuest = true,
    Distance = 10,
    WeaponMode = "Melee",
    AntiStaff = false,
    TweenSpeed = 300
}

local lp = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")
local ts = game:GetService("TweenService")

-- [[ TABS ]]
local TabFarm = Window:CreateTab("Auto Farm 🌾")
local TabWeapon = Window:CreateTab("Weapon Mode ⚔️")
local TabWorld = Window:CreateTab("Teleport 🏝️")
local TabSafe = Window:CreateTab("Security 🛡️")

-- [[ FUNGSI TWEEN (TERBANG MULUS) ]]
local function toPos(targetPos)
    local char = lp.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local distance = (char.HumanoidRootPart.Position - targetPos.p).Magnitude
        local info = TweenInfo.new(distance / getgenv().BloxConfig.TweenSpeed, Enum.EasingStyle.Linear)
        local tween = ts:Create(char.HumanoidRootPart, info, {CFrame = targetPos})
        tween:Play()
        return tween
    end
end

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

-- [[ CORE ENGINE ]]
task.spawn(function()
    while task.wait() do
        if getgenv().BloxConfig.AutoFarm then
            pcall(function()
                local lvl = lp.Data.Level.Value
                local hasQuest = lp.PlayerGui.Main:FindFirstChild("Quest") and lp.PlayerGui.Main.Quest.Visible
                
                -- 1. SMART AUTO QUEST (TWEEN KE NPC)
                if not hasQuest and getgenv().BloxConfig.AutoQuest then
                    local qName, qID, npcPos
                    if lvl < 10 then qName, qID, npcPos = "BanditQuest1", 1, CFrame.new(1060, 15, 1532)
                    elseif lvl < 15 then qName, qID, npcPos = "JungleQuest", 1, CFrame.new(-1601, 37, 153)
                    elseif lvl < 30 then qName, qID, npcPos = "JungleQuest", 2, CFrame.new(-1601, 37, 153) end
                    
                    if npcPos then
                        local tw = toPos(npcPos)
                        if tw then tw.Completed:Wait() end
                        task.wait(0.5)
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", qName, qID)
                    end
                end

                -- 2. FARM & KILL AURA FIX
                for _, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        equipSelectedWeapon()
                        repeat
                            task.wait()
                            -- Gerak mulus ke musuh
                            lp.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().BloxConfig.Distance, 0)
                            
                            if getgenv().BloxConfig.BringMob then
                                v.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame
                                v.HumanoidRootPart.CanCollide = false
                            end

                            -- KILL AURA FIX (Attack Remote + Validator)
                            if getgenv().BloxConfig.KillAura then
                                local args = {[1] = v.Humanoid}
                                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", args)
                                -- Clicker manual buat backup
                                vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                                vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                            end
                        until not getgenv().BloxConfig.AutoFarm or v.Humanoid.Health <= 0
                    end
                end
            end)
        end
    end
end)

-- [[ UI TOGGLES ]]
TabFarm:CreateToggle({
   Name = "Auto Farm Level (Tween)",
   CurrentValue = false,
   Callback = function(v) getgenv().BloxConfig.AutoFarm = v end,
})

TabFarm:CreateToggle({
   Name = "Kill Aura (Fixed Damage)",
   CurrentValue = false,
   Callback = function(v) getgenv().BloxConfig.KillAura = v end,
})

TabFarm:CreateToggle({
   Name = "Bring Mob",
   CurrentValue = false,
   Callback = function(v) getgenv().BloxConfig.BringMob = v end,
})

TabWeapon:CreateDropdown({
   Name = "Select Mastery Mode",
   Options = {"Melee", "Sword", "Fruit"},
   CurrentOption = "Melee",
   Callback = function(v) getgenv().BloxConfig.WeaponMode = v end,
})

TabWorld:CreateDropdown({
   Name = "Teleport To Island (Tween)",
   Options = {"Starter Island", "Jungle", "Pirate Village", "Desert"},
   CurrentOption = "Starter Island",
   Callback = function(v)
       local locs = {
           ["Starter Island"] = CFrame.new(1054, 16, 1547),
           ["Jungle"] = CFrame.new(-1255, 12, 335),
           ["Pirate Village"] = CFrame.new(-1147, 4, 3828),
           ["Desert"] = CFrame.new(944, 6, 4329)
       }
       if locs[v] then toPos(locs[v]) end
   end,
})

TabSafe:CreateToggle({
   Name = "Anti-Staff",
   CurrentValue = false,
   Callback = function(v) getgenv().BloxConfig.AntiStaff = v end,
})

-- Logic Anti-Staff
game.Players.PlayerAdded:Connect(function(p)
    if getgenv().BloxConfig.AntiStaff and p:GetRankInGroup(2830050) >= 10 then
        lp:Kick("Admin Masuk! Sesi diputus.")
    end
end)

Rayfield:Notify({Title = "Vinz Hub TWEEN", Content = "Fix Kill Aura & Smooth Travel Ready!", Duration = 5})
