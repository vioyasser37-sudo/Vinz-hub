local Flux = loadstring(game:HttpGet"https://raw.githubusercontent.com/dawid-scripts/Flux-Lib/main/flux.lua")()

local Window = Flux:Window("VINZ HUB V2", "Blox Fruits Edition", Color3.fromRGB(255, 110, 48), Enum.KeyCode.RightControl)

-- [[ SETTINGS ]]
getgenv().BloxConfig = {
    AutoFarm = false,
    KillAura = false,
    AutoQuest = true,
    AutoFruit = false,
    TweenSpeed = 250,
    Distance = 9
}

local lp = game.Players.LocalPlayer
local ts = game:GetService("TweenService")

-- [[ FUNGSI TWEEN AMAN ]]
local function toPos(targetPos)
    local char = lp.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local distance = (char.HumanoidRootPart.Position - targetPos.p).Magnitude
        local info = TweenInfo.new(distance / getgenv().BloxConfig.TweenSpeed, Enum.EasingStyle.Linear)
        local tween = ts:Create(char.HumanoidRootPart, info, {CFrame = targetPos})
        char.HumanoidRootPart.Velocity = Vector3.new(0,0,0) 
        tween:Play()
        return tween
    end
end

-- [[ TABS ]]
local TabFarm = Window:Tab("Auto Farm", "http://www.roblox.com/asset/?id=6023426915")
local TabFruit = Window:Tab("Fruit Hub", "http://www.roblox.com/asset/?id=6023426915")
local TabSettings = Window:Tab("Settings", "http://www.roblox.com/asset/?id=6023454630")

-- [[ UI ELEMENTS ]]
TabFarm:Toggle("Auto Farm Level", "Auto quest + Tween", function(v)
    getgenv().BloxConfig.AutoFarm = v
end)

TabFarm:Toggle("Kill Aura", "Instan Hit NPC", function(v)
    getgenv().BloxConfig.KillAura = v
end)

TabFruit:Toggle("Auto Get & Store Fruit", "Otomatis ambil dan simpan buah", function(v)
    getgenv().BloxConfig.AutoFruit = v
end)

TabSettings:Slider("Tween Speed", "Atur kecepatan terbang", 100, 500, 250, function(v)
    getgenv().BloxConfig.TweenSpeed = v
end)

-- [[ CORE ENGINE (Logic tetep sama biar ga ribet) ]]
task.spawn(function()
    while task.wait() do
        if getgenv().BloxConfig.AutoFarm then
            pcall(function()
                local lvl = lp.Data.Level.Value
                local hasQuest = lp.PlayerGui.Main:FindFirstChild("Quest") and lp.PlayerGui.Main.Quest.Visible
                
                if not hasQuest and getgenv().BloxConfig.AutoQuest then
                    -- Simple Quest Logic for Sea 1
                    local qName, qID, npcPos
                    if lvl < 10 then qName, qID, npcPos = "BanditQuest1", 1, CFrame.new(1060, 15, 1532)
                    elseif lvl < 15 then qName, qID, npcPos = "JungleQuest", 1, CFrame.new(-1601, 37, 153)
                    end
                    
                    if npcPos then
                        local tw = toPos(npcPos)
                        if tw then tw.Completed:Wait() end
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", qName, qID)
                    end
                end

                for _, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            lp.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().BloxConfig.Distance, 0)
                            if getgenv().BloxConfig.KillAura then
                                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", v.Humanoid)
                            end
                        until not getgenv().BloxConfig.AutoFarm or v.Humanoid.Health <= 0
                    end
                end
            end)
        end
    end
end)

-- [[ AUTO FRUIT ENGINE ]]
task.spawn(function()
    while task.wait(1) do
        if getgenv().BloxConfig.AutoFruit then
            for _, v in pairs(game:GetService("Workspace"):GetChildren()) do
                if v:IsA("Tool") and (v.Name:find("Fruit") or v:FindFirstChild("Fruit")) then
                    local tw = toPos(v.Handle.CFrame)
                    if tw then tw.Completed:Wait() end
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", v:GetAttribute("FruitName"), v)
                end
            end
        end
    end
end)

Flux:Notification("UI Berhasil Diganti!", "Sekarang makin lincah pake Fluxlib, Vioo.")
