local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "VINZ HUB V4 | FISHING ISLAND", HidePremium = false, SaveConfig = true, ConfigFolder = "VinzHubV4"})

local cfg = { fast = false, ultra = false, ws = 16 }
local lp = game.Players.LocalPlayer

-- === AUTO FISHING LOGIC ===
task.spawn(function()
    while task.wait() do
        pcall(function()
            if cfg.fast or cfg.ultra then
                local character = lp.Character
                local rod = character:FindFirstChildOfClass("Tool") or lp.Backpack:FindFirstChildOfClass("Tool")
                
                if rod and rod:FindFirstChild("Click") then
                    -- Lempar Kail
                    rod.Click:FireServer("Cast")
                    
                    -- Jeda Kecepatan
                    if cfg.ultra then
                        task.wait(0.01) -- Sangat Cepat (Ultra)
                    else
                        task.wait(0.5) -- Instan tapi stabil (Fast)
                    end
                    
                    -- Tarik Ikan
                    rod.Click:FireServer("Catch")
                end
            end
        end)
    end
end)

-- === GUI TABS ===
local Tab1 = Window:MakeTab({Name = "Auto Farm 🎣", Icon = "rbxassetid://4483345998", PremiumOnly = false})

Tab1:AddToggle({
    Name = "Fast Fishing (Instant Catch)",
    Default = false,
    Callback = function(v)
        cfg.fast = v
        if v then cfg.ultra = false end -- Biar gak bentrok
    end    
})

Tab1:AddToggle({
    Name = "ULTRA FAST FISHING (God Mode)",
    Default = false,
    Callback = function(v)
        cfg.ultra = v
        if v then cfg.fast = false end -- Biar gak bentrok
        if v then
            OrionLib:MakeNotification({Name = "Warning!", Content = "Ultra Mode Aktif! Pastikan Tas Kamu Luas!", Time = 3})
        end
    end    
})

local Tab2 = Window:MakeTab({Name = "Misc & Movement ⚡", Icon = "rbxassetid://4483345998", PremiumOnly = false})

Tab2:AddSlider({
    Name = "WalkSpeed",
    Min = 16, Max = 300, Default = 16,
    Callback = function(v) 
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.WalkSpeed = v 
        end
    end
})

Tab2:AddButton({
    Name = "Anti-AFK",
    Callback = function()
        local vu = game:GetService("VirtualUser")
        lp.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
        OrionLib:MakeNotification({Name = "System", Content = "Anti-AFK Aktif!", Time = 3})
    end
})

OrionLib:Init()

