local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB | Premium Edition",
   LoadingTitle = "Jatim Mods Team Presents",
   LoadingSubtitle = "by Vioo",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "VinzHubPremium",
      FileName = "Config"
   },
   KeySystem = true,
   KeySettings = {
      Title = "Vinz Hub | Premium Access",
      Subtitle = "Key: VINZ-HUB-PREM",
      Note = "Key akan otomatis tersimpan!",
      FileName = "VinzKeySave",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"VINZ-HUB-PREM"} 
   }
})

local cfg = { aimHead = false, aimBody = false, espBox = false, espHealth = false, teamCheck = false }
local plrs = game:GetService("Players")
local run = game:GetService("RunService")
local me = plrs.LocalPlayer
local mouse = me:GetMouse()
local cam = workspace.CurrentCamera

-- === FITUR ESP ANTI-BUG ===
local function create_esp(p)
    if p == me then return end
    local function setup()
        local char = p.Character or p.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart", 10)
        local hum = char:WaitForChild("Humanoid", 10)
        if root and hum then
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "VinzESP_Box"
            box.AlwaysOnTop = true
            box.ZIndex = 10
            box.Transparency = 0.5
            box.Parent = root
            local bill = Instance.new("BillboardGui")
            bill.Name = "VinzESP_HP"
            bill.Size = UDim2.new(0, 100, 0, 50)
            bill.AlwaysOnTop = true
            bill.StudsOffset = Vector3.new(0, 3, 0)
            bill.Parent = root
            local hpLabel = Instance.new("TextLabel", bill)
            hpLabel.BackgroundTransparency = 1
            hpLabel.Size = UDim2.new(1, 0, 1, 0)
            hpLabel.Font = Enum.Font.GothamBold
            hpLabel.TextSize = 13
            local conn
            conn = run.RenderStepped:Connect(function()
                if not char.Parent or not hum or hum.Health <= 0 then
                    box.Visible = false
                    bill.Enabled = false
                    if not p.Parent then conn:Disconnect() box:Destroy() bill:Destroy() end
                    return
                end
                local color = (p.Team == me.Team) and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                box.Visible = cfg.espBox
                box.Adornee = char
                box.Size = char:GetExtentsSize()
                box.Color3 = color
                bill.Enabled = cfg.espHealth
                hpLabel.Text = math.floor(hum.Health) .. " HP"
                hpLabel.TextColor3 = (hum.Health > 50) and Color3.new(0,1,0) or Color3.new(1,0,0)
            end)
        end
    end
    setup()
    p.CharacterAdded:Connect(setup)
end

task.spawn(function()
    while task.wait(5) do
        for _, p in ipairs(plrs:GetPlayers()) do
            if p ~= me and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and not p.Character.HumanoidRootPart:FindFirstChild("VinzESP_Box") then
                create_esp(p)
            end
        end
    end
end)

for _, p in ipairs(plrs:GetPlayers()) do create_esp(p) end
plrs.PlayerAdded:Connect(create_esp)

-- === AIMLOCK SYSTEM ===
local function get_closest()
    local target = nil
    local dist = math.huge
    for _, p in ipairs(plrs:GetPlayers()) do
        if p ~= me and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if cfg.teamCheck and p.Team == me.Team then continue end
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = cfg.aimHead and p.Character:FindFirstChild("Head") or p.Character.HumanoidRootPart
                if part then
                    local pos, onScreen = cam:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local mag = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                        if mag < dist then
                            target = p.Character
                            dist = mag
                        end
                    end
                end
            end
        end
    end
    return target
end

run.RenderStepped:Connect(function()
    if cfg.aimHead or cfg.aimBody then
        local target = get_closest()
        if target and target:FindFirstChild("Head") then
            local p = cfg.aimHead and target.Head or target.HumanoidRootPart
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, p.Position), 0.15)
        end
    end
end)

local TabCombat = Window:CreateTab("Combat 🎯", 4483362458)
TabCombat:CreateToggle({ Name = "Aimlock HEAD", CurrentValue = false, Callback = function(v) cfg.aimHead = v if v then cfg.aimBody = false end end })
TabCombat:CreateToggle({ Name = "Aimlock BODY", CurrentValue = false, Callback = function(v) cfg.aimBody = v if v then cfg.aimHead = false end end })
TabCombat:CreateToggle({ Name = "Team Check", CurrentValue = false, Callback = function(v) cfg.teamCheck = v end })

local TabVisual = Window:CreateTab("Visuals 👁️", 4483345998)
TabVisual:CreateToggle({ Name = "ESP Box", CurrentValue = false, Callback = function(v) cfg.espBox = v end })
TabVisual:CreateToggle({ Name = "ESP Health", CurrentValue = false, Callback = function(v) cfg.espHealth = v end })

Rayfield:Notify({ Title = "Vinz Hub Premium", Content = "Loaded Successfully!", Duration = 5 })

