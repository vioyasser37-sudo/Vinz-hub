local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB V6 PREMIUM 🚀",
   LoadingTitle = "Jatim Mods Project",
   LoadingSubtitle = "BRUTAL & INSTANT EDITION",
   ConfigurationSaving = { Enabled = false }
})

-- 1. SETTINGS
getgenv().VinzSetting = {
    WalkSpeed = 16,
    AimMode = "None",
    WallCheck = false,
    NoRecoil = false,
    InstantReload = false, -- FITUR BARU
    FOV = 150,
    ESPBox = false,
    HitboxSize = 2,
    HitboxTransparency = 0.6
}

local lp = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- 2. TABS
local TabMain = Window:CreateTab("Player 👤")
local TabCombat = Window:CreateTab("Combat 🔫")
local TabVisual = Window:CreateTab("Visuals 👁️")

-- 3. FIX AIMBOT & WALL CHECK ENGINE
local function getClosestToCurser()
    local target = nil
    local dist = getgenv().VinzSetting.FOV
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local partName = getgenv().VinzSetting.AimMode
            if partName == "None" then continue end
            local targetPart = p.Character:FindFirstChild(partName == "Head" and "Head" or "HumanoidRootPart")
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mouseDist < dist then
                        local passWall = true
                        if getgenv().VinzSetting.WallCheck then
                            local params = RaycastParams.new()
                            params.FilterType = Enum.RaycastFilterType.Exclude
                            params.FilterDescendantsInstances = {lp.Character, p.Character}
                            local result = workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, params)
                            if result then passWall = false end
                        end
                        if passWall then target = targetPart; dist = mouseDist end
                    end
                end
            end
        end
    end
    return target
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
   Options = {"None", "Head", "HumanoidRootPart"},
   CurrentOption = "None",
   Callback = function(v) getgenv().VinzSetting.AimMode = v end,
})

TabCombat:CreateSlider({
   Name = "Hitbox Expander (BRUTAL)",
   Range = {2, 30},
   Increment = 1,
   CurrentValue = 2,
   Callback = function(v) getgenv().VinzSetting.HitboxSize = v end,
})

TabCombat:CreateToggle({
   Name = "Wall Check",
   CurrentValue = false,
   Callback = function(v) getgenv().VinzSetting.WallCheck = v end,
})

TabCombat:CreateToggle({
   Name = "No Recoil",
   CurrentValue = false,
   Callback = function(v) getgenv().VinzSetting.NoRecoil = v end,
})

TabCombat:CreateToggle({
   Name = "Instant Reload ⚡",
   CurrentValue = false,
   Callback = function(v) getgenv().VinzSetting.InstantReload = v end,
})

TabVisual:CreateToggle({
   Name = "ESP Box",
   CurrentValue = false,
   Callback = function(v) getgenv().VinzSetting.ESPBox = v end,
})

-- 5. THE ENGINE
RunService.RenderStepped:Connect(function()
    pcall(function()
        -- Speed
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.WalkSpeed = getgenv().VinzSetting.WalkSpeed
        end

        -- Aimbot Fix
        if getgenv().VinzSetting.AimMode ~= "None" then
            if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                local target = getClosestToCurser()
                if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
            end
        end

        -- Instant Reload & No Recoil Logic
        if lp.Character then
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("FloatValue") then
                    if getgenv().VinzSetting.NoRecoil and (v.Name == "Recoil" or v.Name == "Shake") then
                        v.Value = 0
                    end
                    if getgenv().VinzSetting.InstantReload and (v.Name == "ReloadTime" or v.Name == "Reload") then
                        v.Value = 0
                    end
                end
            end
        end

        -- Hitbox & ESP
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                if getgenv().VinzSetting.HitboxSize > 2 then
                    hrp.Size = Vector3.new(getgenv().VinzSetting.HitboxSize, getgenv().VinzSetting.HitboxSize, getgenv().VinzSetting.HitboxSize)
                    hrp.Transparency = getgenv().VinzSetting.HitboxTransparency
                    hrp.CanCollide = false
                else
                    hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1
                end
                if getgenv().VinzSetting.ESPBox then
                    if not hrp:FindFirstChild("VinzVisual") then
                        local box = Instance.new("SelectionBox", hrp)
                        box.Name = "VinzVisual"; box.LineThickness = 0.05; box.Color3 = Color3.fromRGB(255, 0, 0)
                    end
                    hrp.VinzVisual.Adornee = p.Character
                else
                    if hrp:FindFirstChild("VinzVisual") then hrp.VinzVisual:Destroy() end
                end
            end
        end
    end)
end)

Rayfield:Notify({Title = "Vinz Hub BRUTAL", Content = "Instant Reload & Fix Wall Check Aktif!", Duration = 5})
