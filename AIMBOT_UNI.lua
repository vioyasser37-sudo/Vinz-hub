-- [[ SHADOWREAPER UNIVERSAL HUB v3.0 - RAYFIELD EDITION ]] --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "⚡ SHADOWREAPER v3.0 | NO MERCY ⚡",
   LoadingTitle = "Menginisialisasi Kematian...",
   LoadingSubtitle = "by Javas",
   ConfigurationSaving = { Enabled = false }
})

-- [[ VARIABLE SYSTEM ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Aimbot Vars
local Aimbot_Enabled = false
local WallCheck_Enabled = false
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
local Hitbox_Size = 5

-- Configure FOV Circle (Locked in Center)
FOV_Circle.Thickness = 1.5
FOV_Circle.Color = Color3.fromRGB(255, 0, 0)
FOV_Circle.Radius = Aim_FOV
FOV_Circle.Filled = false
FOV_Circle.Visible = false

-- [[ WALL CHECK FUNCTION ]] --
local function IsVisible(targetPart)
    if not WallCheck_Enabled then return true end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local rayResult = workspace:Raycast(origin, direction, rayParams)
    
    if rayResult and rayResult.Instance then
        if rayResult.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        else
            return false
        end
    end
    return true
end

-- [[ TARGETING SYSTEM ]] --
local function GetClosestPlayer()
    local ClosestTarget = nil
    local MaxDistance = Aim_FOV
    local ViewportCenter = Camera.ViewportSize / 2

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local targetPart = player.Character[AimPart]
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if OnScreen then
                    local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - ViewportCenter).Magnitude
                    if Distance < MaxDistance then
                        if IsVisible(targetPart) then
                            ClosestTarget = player
                            MaxDistance = Distance
                        end
                    end
                end
            end
        end
    end
    return ClosestTarget
end

-- [[ AIMBOT & FOV LOOP ]] --
RunService.RenderStepped:Connect(function()
    local ViewportCenter = Camera.ViewportSize / 2
    FOV_Circle.Position = ViewportCenter
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
    while task.wait(0.5) do
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                
                if root and hum and hum.Health > 0 then
                    if Hitbox_Enabled then
                        root.Size = Vector3.new(Hitbox_Size, Hitbox_Size, Hitbox_Size)
                        root.Transparency = 0.5
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
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not ESP_Boxes[player] then ESP_Boxes[player] = Drawing.new("Square") end
            if not ESP_Lines[player] then ESP_Lines[player] = Drawing.new("Line") end
            if not ESP_Health[player] then ESP_Health[player] = Drawing.new("Line") end
            
            local box = ESP_Boxes[player]
            local line = ESP_Lines[player]
            local health = ESP_Health[player]
            
            if ESP_Enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local root = player.Character.HumanoidRootPart
                    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    
                    if onScreen then
                        box.Size = Vector2.new(1000 / pos.Z, 1500 / pos.Z)
                        box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                        box.Color = Color3.fromRGB(255, 0, 0)
                        box.Thickness = 1.5
                        box.Filled = false
                        box.Visible = true
                        
                        line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        line.To = Vector2.new(pos.X, pos.Y + (box.Size.Y / 2))
                        line.Color = Color3.fromRGB(200, 0, 0)
                        line.Thickness = 1
                        line.Visible = true
                        
                        health.From = Vector2.new(box.Position.X - 6, box.Position.Y + box.Size.Y)
                        health.To = Vector2.new(box.Position.X - 6, box.Position.Y + box.Size.Y - (box.Size.Y * (hum.Health / hum.MaxHealth)))
                        health.Color = Color3.fromRGB(0, 255, 0)
                        health.Thickness = 2
                        health.Visible = true
                        continue
                    end
                end
            end
            box.Visible = false
            line.Visible = false
            health.Visible = false
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESP_Boxes[player] then ESP_Boxes[player]:Remove(); ESP_Boxes[player] = nil end
    if ESP_Lines[player] then ESP_Lines[player]:Remove(); ESP_Lines[player] = nil end
    if ESP_Health[player] then ESP_Health[player]:Remove(); ESP_Health[player] = nil end
end)

-- [[ UI TABS & MENU CREATION ]] --
local CombatTab = Window:CreateTab("🔫 Aimbot", 4483345998)
local VisualTab = Window:CreateTab("👁️ ESP & Hitbox", 4483345998)

-- Aimbot Menu
CombatTab:CreateSection("Aimbot Settings")
CombatTab:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = false,
   Callback = function(Value) Aimbot_Enabled = Value end,
})
CombatTab:CreateToggle({
   Name = "Enable Wall Check",
   CurrentValue = false,
   Callback = function(Value) WallCheck_Enabled = Value end,
})
CombatTab:CreateDropdown({
   Name = "Aim Part",
   Options = {"Head", "HumanoidRootPart"},
   CurrentOption = {"Head"},
   MultipleOptions = false,
   Callback = function(Option) AimPart = Option[1] end,
})
CombatTab:CreateSlider({
   Name = "Aimbot FOV Size",
   Min = 10, Max = 800, CurrentValue = 150, Increment = 10,
   Callback = function(Value) Aim_FOV = Value end,
})

-- Visual & Hitbox Menu
VisualTab:CreateSection("ESP Settings")
VisualTab:CreateToggle({
   Name = "Enable All ESP (Box, Line, Health)",
   CurrentValue = false,
   Callback = function(Value) ESP_Enabled = Value end,
})

VisualTab:CreateSection("Hitbox Settings")
VisualTab:CreateToggle({
   Name = "Enable Hitbox Expander",
   CurrentValue = false,
   Callback = function(Value) Hitbox_Enabled = Value end,
})
VisualTab:CreateSlider({
   Name = "Hitbox Size",
   Min = 2, Max = 50, CurrentValue = 5, Increment = 1,
   Callback = function(Value) Hitbox_Size = Value end,
})

Rayfield:Notify({Title = "SHADOWREAPER V3.0", Content = "Kode disempurnakan. Hancurkan mereka.", Duration = 3})
