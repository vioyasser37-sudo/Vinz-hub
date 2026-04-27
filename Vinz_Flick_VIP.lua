local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SUPER VINX | FLICK VIP 💀",
   LoadingTitle = "SuperVinx Project",
   LoadingSubtitle = "ZeeXSuperVinx",
   ConfigurationSaving = { Enabled = false }
})

-- [[ SETTINGS ]]
getgenv().SuperVinx = {
    Aimbot = false,
    AimbotPart = "Head",
    WallCheck = true,
    ESP = false,
    ESPLine = false,
    NoRecoil = true,
    FPSBoost = false
}

local lp = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = lp:GetMouse()
local RunService = game:GetService("RunService")

-- [[ REFRESH CAMERA ]]
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    camera = workspace.CurrentCamera
end)

-- [[ FUNGSI WALL CHECK ]]
local function isVisible(part)
    if not part then return false end
    local character = lp.Character
    if not character then return false end
    local origin = camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    local ray = RaycastParams.new()
    ray.FilterType = Enum.RaycastFilterType.Exclude
    ray.FilterDescendantsInstances = {character, camera}
    local result = workspace:Raycast(origin, direction, ray)
    return not result or result.Instance:IsDescendantOf(part.Parent)
end

-- [[ ESP TABLE STORAGE ]]
local ESPObjects = {}

local function CreateESP(player)
    local box = Drawing.new("Square")
    local line = Drawing.new("Line")
    
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1
    box.Color = Color3.fromRGB(255, 0, 0)
    
    line.Thickness = 1
    line.Transparency = 1
    line.Color = Color3.fromRGB(255, 255, 255)
    
    ESPObjects[player] = {Box = box, Line = line}
end

-- [[ MAIN LOOP ENGINE ]]
RunService.RenderStepped:Connect(function()
    pcall(function()
        local target = nil
        local dist = math.huge
        
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= lp then
                if not ESPObjects[p] then CreateESP(p) end
                local objects = ESPObjects[p]
                
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local hrp = p.Character.HumanoidRootPart
                    local pos, onscreen = camera:WorldToViewportPoint(hrp.Position)
                    
                    -- 1. ESP LOGIC (DARI VIDEO)
                    if onscreen and getgenv().SuperVinx.ESP then
                        local sizeX, sizeY = 2500 / pos.Z, 4500 / pos.Z
                        
                        objects.Box.Visible = true
                        objects.Box.Size = Vector2.new(sizeX, sizeY)
                        objects.Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                        
                        if getgenv().SuperVinx.ESPLine then
                            objects.Line.Visible = true
                            objects.Line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                            objects.Line.To = Vector2.new(pos.X, pos.Y)
                        else
                            objects.Line.Visible = false
                        end
                    else
                        objects.Box.Visible = false
                        objects.Line.Visible = false
                    end

                    -- 2. AIMBOT LOGIC (ULTRA SNAP)
                    if getgenv().SuperVinx.Aimbot and onscreen then
                        local part = p.Character:FindFirstChild(getgenv().SuperVinx.AimbotPart)
                        if part and (not getgenv().SuperVinx.WallCheck or isVisible(part)) then
                            local mDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                            if mDist < dist then
                                target = part
                                dist = mDist
                            end
                        end
                    end
                else
                    objects.Box.Visible = false
                    objects.Line.Visible = false
                end
            end
        end

        -- EXECUTE LOCK
        if target and getgenv().SuperVinx.Aimbot then
            camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
        end
        
        -- NO RECOIL
        if getgenv().SuperVinx.NoRecoil and lp.Character then
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("NumberValue") and (v.Name:find("Recoil") or v.Name:find("Shake")) then
                    v.Value = 0
                end
            end
        end
    end)
end)

-- [[ UI TABS ]]
local TabCombat = Window:CreateTab("Combat 🔫")
local TabESP = Window:CreateTab("Visuals 👁️")
local TabRender = Window:CreateTab("Optimization ⚡")

TabCombat:CreateToggle({
   Name = "ULTRA AIMBOT",
   CurrentValue = false,
   Callback = function(v) getgenv().SuperVinx.Aimbot = v end,
})

TabCombat:CreateToggle({
   Name = "Wall Check",
   CurrentValue = true,
   Callback = function(v) getgenv().SuperVinx.WallCheck = v end,
})

TabCombat:CreateDropdown({
   Name = "Aimbot Target",
   Options = {"Head", "HumanoidRootPart"},
   CurrentOption = "Head",
   Callback = function(v) getgenv().SuperVinx.AimbotPart = v end,
})

TabESP:CreateToggle({
   Name = "ESP Box (Squares)",
   CurrentValue = false,
   Callback = function(v) getgenv().SuperVinx.ESP = v end,
})

TabESP:CreateToggle({
   Name = "ESP Lines (Tracer)",
   CurrentValue = false,
   Callback = function(v) getgenv().SuperVinx.ESPLine = v end,
})

TabRender:CreateToggle({
   Name = "Universal FPS Boost",
   CurrentValue = false,
   Callback = function(v)
       if v then
           game:GetService("Lighting").GlobalShadows = false
           for _, obj in pairs(game:GetDescendants()) do
               if obj:IsA("Part") or obj:IsA("MeshPart") then
                   obj.Material = Enum.Material.SmoothPlastic
               elseif obj:IsA("ParticleEmitter") then
                   obj.Enabled = false
               end
           end
       end
   end,
})

TabRender:CreateButton({ Name = "Clear RAM", Callback = function() collectgarbage("collect") end })

Rayfield:Notify({Title = "SuperVinx VIP", Content = "Gaskeun Bantai, Vioo!", Duration = 5})
