local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "VINZ HUB | FISHING ISLAND 🎣", HidePremium = false, SaveConfig = true, ConfigFolder = "VinzFishing"})

local cfg = { autofish = false, fastMode = false }
local lp = game.Players.LocalPlayer

-- === AUTO FISHING LOGIC ===
task.spawn(function()
    while task.wait(0.1) do
        if cfg.autofish then
            pcall(function()
                local character = lp.Character
                local rod = character:FindFirstChildOfClass("Tool") or lp.Backpack:FindFirstChildOfClass("Tool")
                
                if rod and rod:FindFirstChild("Click") then
                    -- Lempar Kail jika belum
                    rod.Click:FireServer("Cast")
                    
                    if cfg.fastMode then
                        task.wait(0.2) -- Mode Cepat
                    else
                        task.wait(1) -- Mode Normal
                    end
                    
                    -- Tarik Ikan (Instantly)
                    rod.Click:FireServer("Catch")
                end
            end)
        end
    end
end)

-- === GUI TABS ===
local Tab = Window:MakeTab({Name = "Main Farm ⚓", Icon = "rbxassetid://4483345998", PremiumOnly = false})

Tab:AddToggle({
    Name = "Auto Fishing (ON/OFF)",
    Default = false,
    Callback = function(v)
        cfg.autofish = v
        if v then
            OrionLib:MakeNotification({Name = "Vinz Hub", Content = "Auto Fishing Aktif!", Time = 3})
        end
    end    
})

Tab:AddToggle({
    Name = "Fast Mode (⚡)",
    Default = false,
    Callback = function(v)
        cfg.fastMode = v
    end    
})

local TabMisc = Window:MakeTab({Name = "Misc ⚡", Icon = "rbxassetid://4483345998", PremiumOnly = false})

TabMisc:AddSlider({
    Name = "WalkSpeed",
    Min = 16, Max = 250, Default = 16,
    Callback = function(v) lp.Character.Humanoid.WalkSpeed = v end
})

TabMisc:AddButton({
    Name = "Anti-AFK",
    Callback = function()
        local vu = game:GetService("VirtualUser")
        lp.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end)
        OrionLib:MakeNotification({Name = "Vinz Hub", Content = "Anti-AFK Aktif!", Time = 3})
    end
})

OrionLib:Init()
