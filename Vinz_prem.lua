local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB V6 | JATIM MODS 🚀",
   LoadingTitle = "Premium Project by Vioo",
   LoadingSubtitle = "Universal Combat & Visual",
   ConfigurationSaving = { Enabled = false }
})

-- 1. SETTINGS (Global Variables)
getgenv().VinzSetting = {
    WalkSpeed = 16,
    AimMode = "None",
    WallCheck = false,
    NoRecoil = false,
    FOV = 150,
    ESPBox = false,
    ESPLine = false,
    HitboxSize = 2,
    HitboxTransparency = 0.5
}

local lp = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- 2. TABS
local TabMain = Window:CreateTab("Player 👤")
local TabCombat = Window:CreateTab("Combat 🔫")
local TabVisual = Window:CreateTab("Visuals 👁️")

-- 3. CORE FUNCTIONS
local function isVisible(part)
    if not getgenv().VinzSetting.WallCheck then return true end
    local ray = Camera:ViewportPointToRay(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {lp.Character}
    local result = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, raycastParams)
    return result == nil or result.Instance:IsDescendantOf(part.Parent)
end

local function getClosestPlayer()
    local closestTarget = nil
    local shortestDistance = getgenv().VinzSetting.FOV

    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild(getgenv().VinzSetting.AimMode) then
            local targetPart = p.Character[getgenv().VinzSetting.AimMode]
            local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            
            if onScreen and isVisible(targetPart) then
                local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if distance < shortestDistance then
                    closestTarget = targetPart
                    shortestDistance = distance
                end
            end
        end
    end
    return closestTarget
end

-- 4. UI ELEMENTS
TabMain:CreateSlider({
   Name = "Speed Hack",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) getgenv().VinzSetting.WalkSpeed = v end,
})

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

TabCombat:CreateToggle({
   Name = "Wall Check",
   CurrentValue = false,
   Callback = function(v) getgenv().VinzSetting.WallCheck = v end,
})

TabCombat:CreateSlider({
   Name = "Hitbox Expander (Size)",
   Range = {2, 25},
   Increment = 1,
   CurrentValue = 2,
   Callback = function(v) getgenv().VinzSetting.HitboxSize = v end,
})

TabCombat:CreateToggle({
   Name = "No Recoil",
   CurrentValue = false,
   Callback = function(v) getgenv().VinzSetting.NoRecoil = v end,
})

TabVisual:CreateToggle({
   Name = "ESP Box",
   CurrentValue = false,
   Callback = function(v) getgenv().VinzSetting.ESPBox = v end,
})

-- 5. THE ENGINE (The Fix is Here)
RunService.RenderStepped:Connect(function()
    pcall(function()
        -- WalkSpeed Fix
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.WalkSpeed = getgenv().VinzSetting.WalkSpeed
        end

        -- Aimbot Logic
        if getgenv().VinzSetting.AimMode ~= "None" and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = getClosestPlayer()
            if target then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            end
        end

        -- Hitbox & ESP Fix (Looping All Players)
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                
                -- Hitbox Expander Fix
                if getgenv().VinzSetting.HitboxSize > 2 then
                    hrp.Size = Vector3.new(getgenv().VinzSetting.HitboxSize, getgenv().VinzSetting.HitboxSize, getgenv().VinzSetting.HitboxSize)
                    hrp.Transparency = getgenv().VinzSetting.HitboxTransparency
                    hrp.CanCollide = false
                else
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                end

                -- ESP Box Fix
                if getgenv().VinzSetting.ESPBox then
                    if not hrp:FindFirstChild("VinzVisual") then
                        local box = Instance.new("SelectionBox", hrp)
                        box.Name = "VinzVisual"
                        box.LineThickness = 0.05
                        box.Color3 = Color3.fromRGB(255, 0, 0)
                    end
                    hrp.VinzVisual.Adornee = p.Character
                else
                    if hrp:FindFirstChild("VinzVisual") then
                        hrp.VinzVisual:Destroy()
                    end
                end
            end
        end
    end)
end)

Rayfield:Notify({Title = "Vinz Hub V6", Content = "Fix Terpasang! Enjoy, Vioo!", Duration = 5})
