local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "VINZ HUB V3 | JATIM MODS", HidePremium = false, SaveConfig = true, ConfigFolder = "VinzHub"})

-- Variabel
local cfg = {ws = 16, jp = 50, aim = false, esp = false}

-- Tab Combat
local Tab1 = Window:MakeTab({Name = "Combat 🎯", Icon = "rbxassetid://4483345998", PremiumOnly = false})
Tab1:AddToggle({Name = "Aimlock (Hold Right Click)", Default = false, Callback = function(v) cfg.aim = v end})

-- Tab Visual
local Tab2 = Window:MakeTab({Name = "Visuals 👁️", Icon = "rbxassetid://4483345998", PremiumOnly = false})
Tab2:AddToggle({Name = "ESP Box", Default = false, Callback = function(v) cfg.esp = v end})

-- Tab Movement
local Tab3 = Window:MakeTab({Name = "Movement ⚡", Icon = "rbxassetid://4483345998", PremiumOnly = false})
Tab3:AddSlider({Name = "Speed", Min = 16, Max = 300, Default = 16, Color = Color3.fromRGB(255,255,255), Increment = 1, ValueName = "Speed", Callback = function(v) cfg.ws = v end})
Tab3:AddSlider({Name = "Jump", Min = 50, Max = 500, Default = 50, Color = Color3.fromRGB(255,255,255), Increment = 1, ValueName = "Power", Callback = function(v) cfg.jp = v end})

-- Loop Fitur
game:GetService("RunService").RenderStepped:Connect(function()
    pcall(function()
        local me = game.Players.LocalPlayer
        if me.Character and me.Character:FindFirstChild("Humanoid") then
            me.Character.Humanoid.WalkSpeed = cfg.ws
            me.Character.Humanoid.JumpPower = cfg.jp
        end
        
        -- ESP Sederhana
        if cfg.esp then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= me and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if not p.Character.HumanoidRootPart:FindFirstChild("VinzHighlight") then
                        local hl = Instance.new("Highlight", p.Character.HumanoidRootPart)
                        hl.Name = "VinzHighlight"
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0
                    end
                end
            end
        else
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.HumanoidRootPart:FindFirstChild("VinzHighlight") then
                    p.Character.HumanoidRootPart.VinzHighlight:Destroy()
                end
            end
        end
    end)
end)

OrionLib:Init()

