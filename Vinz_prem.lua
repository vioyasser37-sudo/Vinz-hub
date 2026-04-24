local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB V6 | JATIM MODS 🚀",
   LoadingTitle = "Master Project by Vioo",
   LoadingSubtitle = "Universal Combat & Visual",
   ConfigurationSaving = { Enabled = false }
})

-- 1. SETTINGS
getgenv().VinzSetting = {
    WalkSpeed = 16,
    AimMode = "None",
    WallCheck = false,
    NoRecoil = false,
    FOV = 150,
    -- Visual & Hitbox
    ESPBox = false,
    ESPLine = false,
    HitboxSize = 2, -- Ukuran default (2 = normal)
    HitboxTransparency = 0.5
}

local lp = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")

-- 2. TABS
local TabMain = Window:CreateTab("Player 👤")
local TabCombat = Window:CreateTab("Combat 🔫")
local TabVisual = Window:CreateTab("Visuals 👁️")

-- 3. UI ELEMENTS
TabCombat:CreateDropdown({
   Name = "Aimlock Target",
   Options = {"None", "Head (Danger)", "HumanoidRootPart (Safe)"},
   CurrentOption = "None",
   Callback = function(v)
      if v == "Head (Danger)" then getgenv().VinzSetting.AimMode = "Head"
      elseif v == "HumanoidRootPart (Safe)" then getgenv().VinzSetting.AimMode = "HumanoidRootPart"
      else getgenv().VinzSetting.AimMode = "None" end
   end,
})

TabCombat:CreateSlider({
   Name = "Hitbox Expander (Size)",
   Range = {2, 20},
   Increment = 1,
   CurrentValue = 2,
   Callback = function(v) getgenv().VinzSetting.HitboxSize = v end,
})

TabVisual:CreateToggle({
   Name = "ESP Box",
   CurrentValue = false,
   Callback = function(v) getgenv().VinzSetting.ESPBox = v end,
})

TabVisual:CreateToggle({
   Name = "ESP Line",
   CurrentValue = false,
   Callback = function(v) getgenv().VinzSetting.ESPLine = v end,
})

-- 4. ENGINE LOOP (Hitbox, ESP, & Combat)


                -- LOGIC ESP BOX & LINE (Highlight)
                if not hrp:FindFirstChild("VinzVisual") and (getgenv().VinzSetting.ESPBox or getgenv().VinzSetting.ESPLine) then
                    local box = Instance.new("SelectionBox", hrp)
                    box.Name = "VinzVisual"
                    box.Adornee = (getgenv().VinzSetting.ESPBox and p.Character or nil)
                    box.LineThickness = 0.05
                    box.Color3 = Color3.fromRGB(255, 0, 0)
                elseif hrp:FindFirstChild("VinzVisual") then
                    hrp.VinzVisual.Adornee = (getgenv().VinzSetting.ESPBox and ptask.spawn(function()
    game:GetService("RunService").RenderStepped:Connect(function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                
                -- LOGIC HITBOX EXPANDER (Mempengaruhi Tembakan)
                if getgenv().VinzSetting.HitboxSize > 2 then
                    hrp.Size = Vector3.new(getgenv().VinzSetting.HitboxSize, getgenv().VinzSetting.HitboxSize, getgenv().VinzSetting.HitboxSize)
                    hrp.Transparency = getgenv().VinzSetting.HitboxTransparency
                    hrp.CanCollide = false -- Biar ga nabrak pas lari
                else
                    hrp.Size = Vector3.new(2, 2, 1) -- Ukuran asli Roblox
                    hrp.Transparency = 1
                        end.Character or nil)
                    if not getgenv().VinzSetting.ESPBox and not getgenv().VinzSetting.ESPLine then
                        hrp.VinzVisual:Destroy()
                    end
                end
            end
        end
        
        -- Speed & Aimbot Logic
        pcall(function()
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                lp.Character.Humanoid.WalkSpeed = getgenv().VinzSetting.WalkSpeed
            end
            if getgenv().VinzSetting.AimMode ~= "None" and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                -- Aimbot logic here (sama seperti sebelumnya)
            end
        end)
    end)
end)

Rayfield:Notify({Title = "Vinz Hub V6", Content = "ESP & Hitbox Ready!", Duration = 5})
