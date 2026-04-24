local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB | BLOX FRUITS V2 🏴‍☠️",
   LoadingTitle = "Jatim Mods Project",
   LoadingSubtitle = "by Vioo - Leveling Edition",
   ConfigurationSaving = { Enabled = false }
})

-- [[ SETTINGS ]]
getgenv().Config = {
    AutoFarm = false,
    BringMob = false,
    AntiStaff = false,
    AutoEquip = true,
    Distance = 8
}

local lp = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")

-- [[ TABS ]]
local TabFarm = Window:CreateTab("Auto Leveling 🌾")
local TabTeleport = Window:CreateTab("World Travel 🏝️")
local TabMisc = Window:CreateTab("Misc & Safe 🛡️")

-- [[ FUNGSI AUTO CLICK & EQUIP ]]
local function autoClick()
    vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

local function equipWeapon()
    if getgenv().Config.AutoEquip then
        for _, v in pairs(lp.Backpack:GetChildren()) do
            if v:IsA("Tool") then
                lp.Character.Humanoid:EquipTool(v)
            end
        end
    end
end

-- [[ LOGIC AUTO QUEST (SEA 1 BASIS) ]]
local function getQuest()
    local lvl = lp.Data.Level.Value
    if lvl < 10 then return "Bandit", "BanditQuest1", 1
    elseif lvl < 15 then return "Monkey", "JungleQuest", 1
    elseif lvl < 30 then return "Gorilla", "JungleQuest", 2
    -- Tambahkan logic quest lainnya di sini sesuai progress kamu
    else return "Bandit", "BanditQuest1", 1 end
end

-- [[ CORE FARMING ENGINE ]]
task.spawn(function()
    while task.wait() do
        if getgenv().Config.AutoFarm then
            pcall(function()
                local target, questName, questId = getQuest()
                
                -- Cek apakah sudah punya quest
                if not lp.PlayerGui.Main:FindFirstChild("Quest") or lp.PlayerGui.Main.Quest.Visible == false then
                    -- Teleport ke NPC Quest (Contoh Starter Island)
                    -- Sesuai lokasi NPC masing-masing quest
                end

                equipWeapon()
                
                for _, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                    if v.Name == target and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            lp.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().Config.Distance, 0)
                            
                            if getgenv().Config.BringMob then
                                v.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame * CFrame.new(0, -getgenv().Config.Distance, 0)
                                v.HumanoidRootPart.CanCollide = false
                            end
                            
                            autoClick()
                        until not getgenv().Config.AutoFarm or v.Humanoid.Health <= 0
                    end
                end
            end)
        end
    end
end)

-- [[ UI ELEMENTS ]]
TabFarm:CreateToggle({
   Name = "Auto Farm Level (Auto Quest)",
   CurrentValue = false,
   Callback = function(v) getgenv().Config.AutoFarm = v end,
})

TabFarm:CreateToggle({
   Name = "Bring Mob (Fast Farm)",
   CurrentValue = false,
   Callback = function(v) getgenv().Config.BringMob = v end,
})

TabTeleport:CreateDropdown({
   Name = "Teleport To Island",
   Options = {"Starter Island", "Jungle", "Pirate Village", "Desert", "Snow Mountain"},
   CurrentOption = "Starter Island",
   Callback = function(v)
       local locations = {
           ["Starter Island"] = CFrame.new(1054, 16, 1547),
           ["Jungle"] = CFrame.new(-1255, 12, 335),
           ["Pirate Village"] = CFrame.new(-1147, 4, 3828),
           ["Desert"] = CFrame.new(944, 6, 4329),
           ["Snow Mountain"] = CFrame.new(1354, 87, -1324)
       }
       if locations[v] then
           lp.Character.HumanoidRootPart.CFrame = locations[v]
       end
   end,
})

TabMisc:CreateToggle({
   Name = "Anti-AFK",
   CurrentValue = true,
   Callback = function(v)
       -- Logic Anti-AFK
       local vu = game:GetService("VirtualUser")
       lp.Idled:Connect(function()
           if v then vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame) task.wait(1) vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame) end
       end)
   end,
})

TabMisc:CreateButton({
   Name = "Server Hop (Cari Server Sepi)",
   Callback = function()
       local x = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
       for _,v in pairs(x.data) do
           if v.playing < v.maxPlayers then
               game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v.id)
           end
       end
   end,
})

Rayfield:Notify({Title = "Vinz Hub Fixed", Content = "Bug Teleport Fix & Auto-Quest Ready!", Duration = 5})
