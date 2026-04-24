local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB | BLOX FRUITS V3 🏴‍☠️",
   LoadingTitle = "Jatim Mods Project",
   LoadingSubtitle = "Fix Security & Smooth Farm",
   ConfigurationSaving = { Enabled = false }
})

-- [[ SETTINGS ]]
getgenv().Config = {
    AutoFarm = false,
    BringMob = false,
    Distance = 8
}

local lp = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

-- [[ TABS ]]
local TabFarm = Window:CreateTab("Main Farm 🌾")
local TabMisc = Window:CreateTab("Misc 🛡️")

-- [[ FUNGSI TWEEN (BIAR GAK KENA KICK) ]]
local function toPos(pos)
    local char = lp.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local distance = (char.HumanoidRootPart.Position - pos.p).Magnitude
        local info = TweenInfo.new(distance / 300, Enum.EasingStyle.Linear) -- Speed 300
        local tween = TweenService:Create(char.HumanoidRootPart, info, {CFrame = pos})
        tween:Play()
        return tween
    end
end

-- [[ DATA QUEST & NPC ]]
local questData = {
    {Level = 0, Enemy = "Bandit", QuestNPC = "Bandit Quest Giver", QuestName = "BanditQuest1", QuestID = 1, PosNPC = CFrame.new(1060, 15, 1532)},
    {Level = 10, Enemy = "Monkey", QuestNPC = "Adventurer", QuestName = "JungleQuest", QuestID = 1, PosNPC = CFrame.new(-1601, 37, 153)},
    {Level = 15, Enemy = "Gorilla", QuestNPC = "Adventurer", QuestName = "JungleQuest", QuestID = 2, PosNPC = CFrame.new(-1601, 37, 153)}
}

local function getCurrentQuest()
    local myLvl = lp.Data.Level.Value
    local best = questData[1]
    for _, q in pairs(questData) do
        if myLvl >= q.Level then best = q end
    end
    return best
end

-- [[ CORE FARMING ENGINE ]]
task.spawn(function()
    while task.wait() do
        if getgenv().Config.AutoFarm then
            pcall(function()
                local q = getCurrentQuest()
                
                -- 1. CEK APAKAH SUDAH PUNYA QUEST
                local hasQuest = lp.PlayerGui.Main:FindFirstChild("Quest") and lp.PlayerGui.Main.Quest.Visible
                
                if not hasQuest then
                    -- Pergi ke NPC Quest
                    toPos(q.PosNPC)
                    task.wait(1)
                    -- Dialog ambil quest (Simulasi klik)
                    fireclickdetector(game:GetService("Workspace").NPCs[q.QuestNPC].ClickDetector)
                    -- Pilih Quest (Ini butuh penyesuaian tergantung game, contoh simulasi klik)
                    task.wait(0.5)
                else
                    -- 2. CARI MUSUH
                    local enemyFound = false
                    for _, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                        if v.Name == q.Enemy and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            enemyFound = true
                            lp.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().Config.Distance, 0)
                            
                            -- Bring Mob
                            if getgenv().Config.BringMob then
                                v.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame * CFrame.new(0, -getgenv().Config.Distance, 0)
                                v.HumanoidRootPart.CanCollide = false
                            end
                            
                            -- Serang
                            vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                            vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        end
                    end
                    
                    -- Jika musuh tidak ada di Workspace, ke area spawn-nya
                    if not enemyFound then
                        toPos(q.PosNPC * CFrame.new(0, 50, 50)) -- Ke area sekitar NPC
                    end
                end
            end)
        end
    end
end)

-- [[ UI ELEMENTS ]]
TabFarm:CreateToggle({
   Name = "Auto Farm (Quest Based)",
   CurrentValue = false,
   Callback = function(v) getgenv().Config.AutoFarm = v end,
})

TabFarm:CreateToggle({
   Name = "Bring Mob",
   CurrentValue = false,
   Callback = function(v) getgenv().Config.BringMob = v end,
})

TabMisc:CreateButton({
   Name = "Rejoin Game (Fix Lag/Kick)",
   Callback = function()
       game:GetService("TeleportService"):Teleport(game.PlaceId, lp)
   end,
})

Rayfield:Notify({Title = "Vinz Hub Fix", Content = "Script sudah diperbarui! Gaskeun Vioo!", Duration = 5})
