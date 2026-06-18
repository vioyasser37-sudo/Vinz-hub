-- [[ SHADOWREAPER UNIVERSAL HUB v2.0 - RAYFIELD EDITION ]] --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "⚡ SHADOWREAPER v2.0 | UNIVERSAL HUB ⚡",
   LoadingTitle = "Mengaktifkan Protokol Kematian...",
   LoadingSubtitle = "by Javas/Vio",
   ConfigurationSaving = {
      Enabled = false
   }
})

-- [[ VARIABLE SYSTEM ]] --
local Camera = workspace.CurrentCamera
local LocalPlayer = game.Players.LocalPlayer

-- Aimbot Vars
local Aimbot_Enabled = false
local AimPart = "Head"
local Aim_FOV = 150
local FOV_Circle = Drawing.new("Circle")

-- ESP Vars
local ESP_Enabled = false
local ESP_Boxes = {}
local ESP_Lines = {}
local ESP_Health = {}

-- Hitbox Vars
local Hitbox_Enabled = false
local Hitbox_Size = 2

-- Configure FOV Circle
FOV_Circle.Thickness = 1
FOV_Circle.Color = Color3.fromRGB(255, 0, 0)
FOV_Circle.Radius = Aim_FOV
FOV_Circle.Filled = false
FOV_Circle.Visible = false

-- [[ UTILITY FUNCTIONS ]] --
local function GetClosestPlayer()
    local ClosestTarget = nil
    local MaxDistance = Aim_FOV

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(player.Character[AimPart].Position)
            if OnScreen then
                local MousePos = Vector2.new(game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y)
                local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
                if Distance < MaxDistance then
                    ClosestTarget = player
                    MaxDistance = Distance
                end
            end
        end
    end
    return ClosestTarget
end

-- [[ AIMBOT LOOP ]] --
game:GetService("RunService").RenderStepped:Connect(function()
    FOV_Circle.Position = Vector2.new(game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y)
    FOV_Circle.Radius = Aim_FOV
    FOV_Circle.Visible = Aimbot_Enabled
    
    if Aimbot_Enabled then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild(AimPart) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character[AimPart].Position)
        end
    end
end)

-- [[ HITBOX EXPANDER LOOP ]] --
task.spawn(function()
    while task.wait(1) do
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if root and hum and hum.Health > 0 then
                    if Hitbox_Enabled then
                        root.Size = Vector3.new(Hitbox_Size, Hitbox_Size, Hitbox_Size)
                        root.Transparency = 0.6
                        root.Color = Color3.fromRGB(255, 0, 0)
                        root.Material = Enum.Material.Neon
                        root.CanCollide = false
                    else
                        root.Size = Vector3.new(2, 2, 1)
                        root.Transparency = 1
                    end
                end
            end
        end
    end
end)

-- [[ ESP VISUALIZATIONS ]] --
game:GetService("RunService").RenderStepped:Connect(function()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local box = ESP_Boxes[player] or Drawing.new("Square")
            local line = ESP_Lines[player] or Drawing.new("Line")
            local health = ESP_Health[player] or Drawing.new("Line")
            
            ESP_Boxes[player] = box
            ESP_Lines[player] = line
            ESP_Health[player] = health
            
            if ESP_Enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                local root = player.Character.HumanoidRootPart
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    -- Box ESP
                    box.Size = Vector2.new(1000 / pos.Z, 1500 / pos.Z)
                    box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                    box.Color = Color3.fromRGB(255, 0, 0)
                    box.Thickness = 1500 / (pos.Z * 500)
                    box.Visible = true
                    
                    -- Line ESP (Snaplines)
                    line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    line.To = Vector2.new(pos.X, pos.Y)
                    line.Color = Color3.fromRGB(255, 255, 255)
                    line.Thickness = 1
                    line.Visible = true
                    
                    -- Health Bar
                    health.From = Vector2.new(box.Position.X - 5, box.Position.Y + box.Size.Y)
                    health.To = Vector2.new(box.Position.X - 5, box.Position.Y + box.Size.Y - (box.Size.Y * (hum.Health / hum.MaxHealth)))
                    health.Color = Color3.fromRGB(0, 255, 0)
                    health.Thickness = 2
                    health.Visible = true
                    continue
                end
            end
            box.Visible = false
            line.Visible = false
            health.Visible = false
        end
    end
end)

-- [[ CREATING TABS IN RAYFIELD ]] --
local CombatTab = Window:CreateTab("Combat & Hitbox", 4483345998)
local VisualsTab = Window:CreateTab("Visuals (ESP)", 4483345998)

-- Combat Elements
CombatTab:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = false,
   Callback = function(Value) Aimbot_Enabled = Value end,
})

CombatTab:CreateDropdown({
   Name = "Aim Target Part",
   Options = {"Head", "HumanoidRootPart"},
   CurrentOption = {"Head"},
   MultipleOptions = false,
   Callback = function(Option) AimPart = Option[1] == "HumanoidRootPart" and "HumanoidRootPart" or "Head" end,
})

CombatTab:CreateSlider({
   Name = "Aimbot FOV",
   Min = 50,
   Max = 500,
   CurrentValue = 150,
   Increment = 10,
   Callback = function(Value) Aim_FOV = Value end,
})

CombatTab:CreateToggle({
   Name = "Enable Hitbox Expander",
   CurrentValue = false,
   Callback = function(Value) Hitbox_Enabled = Value end,
})

CombatTab:CreateSlider({
   Name = "Hitbox Size (Radius)",
   Min = 2,
   Max = 30,
   CurrentValue = 2,
   Increment = 1,
   Callback = function(Value) Hitbox_Size = Value end,
})

-- Visual Elements
VisualsTab:CreateToggle({
   Name = "Enable ESP Master",
   CurrentValue = false,
   Callback = function(Value) ESP_Enabled = Value end,
})

Rayfield:Notify({Title = "SHADOWREAPER LOADED", Content = "Semua modul tempur siap, Javas.", Duration = 4})
