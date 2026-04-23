local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB V3 | ULTIMATE",
   LoadingTitle = "Jatim Mods Team - Vioo",
   LoadingSubtitle = "Fixing All Bugs...",
   KeySystem = true,
   KeySettings = {
      Title = "Vinz Hub | Premium Access",
      Subtitle = "Key: VINZ-HUB-PREM",
      SaveKey = true,
      Key = {"VINZ-HUB-PREM"} 
   }
})

-- === SETTINGS STORAGE ===
local cfg = {
    aimHead = false, aimBody = false, wallCheck = false,
    espBox = false, espHealth = false, espTracer = false,
    ws = 16, jp = 50, infJump = false,
    noRecoil = false, fovCircle = false, fovSize = 100
}

local plrs = game:GetService("Players")
local run = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local me = plrs.LocalPlayer
local mouse = me:GetMouse()
local cam = workspace.CurrentCamera

-- === FOV CIRCLE ===
local FOV = Drawing.new("Circle")
FOV.Visible = false
FOV.Thickness = 1.5
FOV.Color = Color3.fromRGB(0, 255, 255)

run.RenderStepped:Connect(function()
    FOV.Position = Vector2.new(mouse.X, mouse.Y + 36)
    FOV.Visible = cfg.fovCircle
    FOV.Radius = cfg.fovSize
end)

-- === WALL CHECK FUNCTION ===
local function isVisible(part)
    if not cfg.wallCheck then return true end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {me.Character, cam}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(cam.CFrame.Position, (part.Position - cam.CFrame.Position).Unit * (part.Position - cam.CFrame.Position).Magnitude, params)
    return not result
end

-- === AIMLOCK SYSTEM ===
local function get_closest()
    local target = nil
    local dist = cfg.fovCircle and cfg.fovSize or math.huge
    for _, p in ipairs(plrs:GetPlayers()) do
        if p ~= me and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = cfg.aimHead and p.Character:FindFirstChild("Head") or p.Character.HumanoidRootPart
                if part and isVisible(part) then
                    local pos, onScreen = cam:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local mag = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                        if mag < dist then
                            target = part
                            dist = mag
                        end
                    end
                end
            end
        end
    end
    return target
end

-- === ESP SYSTEM ===
local function setup_esp(p)
    if p == me then return end
    local function create()
        local char = p.Character or p.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart", 10)
        local hum = char:WaitForChild("Humanoid", 10)
        
        -- Drawing Objects
        local box = Drawing.new("Square")
        box.Thickness = 1
        box.Filled = false
        local hp = Drawing.new("Text")
        hp.Size = 13
        hp.Center = true
        hp.Outline = true

        run.RenderStepped:Connect(function()
            if char and char.Parent and root and hum.Health > 0 then
                local pos, onScreen = cam:WorldToViewportPoint(root.Position)
                if onScreen then
                    local color = (p.Team == me.Team) and Color3.new(0,1,0) or Color3.new(1,0,0)
                    -- Box
                    box.Visible = cfg.espBox
                    box.Size = Vector2.new(2000/pos.Z, 3000/pos.Z)
                    box.Position = Vector2.new(pos.X - box.Size.X/2, pos.Y - box.Size.Y/2)
                    box.Color = color
                    -- Health
                    hp.Visible = cfg.espHealth
                    hp.Position = Vector2.new(pos.X, pos.Y - (box.Size.Y/2) - 15)
                    hp.Text = math.floor(hum.Health) .. " HP"
                    hp.Color = Color3.new(1,1,1)
                else
                    box.Visible = false
                    hp.Visible = false
                end
            else
                box.Visible = false
                hp.Visible = false
                if not p.Parent then box:Remove() hp:Remove() end
            end
        end)
    end
    create()
    p.CharacterAdded:Connect(create)
end

for _, p in ipairs(plrs:GetPlayers()) do setup_esp(p) end
plrs.PlayerAdded:Connect(setup_esp)

-- === GUI TABS ===
local TabCombat = Window:CreateTab("Combat 🎯")
TabCombat:CreateToggle({ Name = "Aimlock HEAD", CurrentValue = false, Callback = function(v) cfg.aimHead = v end })
TabCombat:CreateToggle({ Name = "Wall Check", CurrentValue = false, Callback = function(v) cfg.wallCheck = v end })
TabCombat:CreateToggle({ Name = "No Recoil", CurrentValue = false, Callback = function(v) cfg.noRecoil = v end })
TabCombat:CreateToggle({ Name = "Show FOV Circle", CurrentValue = false, Callback = function(v) cfg.fovCircle = v end })
TabCombat:CreateSlider({ Name = "FOV Size", Range = {10, 600}, Increment = 1, CurrentValue = 100, Callback = function(v) cfg.fovSize = v end })

local TabVisual = Window:CreateTab("Visuals 👁️")
TabVisual:CreateToggle({ Name = "ESP Box", CurrentValue = false, Callback = function(v) cfg.espBox = v end })
TabVisual:CreateToggle({ Name = "ESP Health", CurrentValue = false, Callback = function(
