local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB V2 | Jatim Mods Team",
   LoadingTitle = "Vioo's Special Access",
   LoadingSubtitle = "Premium Updated",
   ConfigurationSaving = { Enabled = true, FolderName = "VinzHubV2", FileName = "Config" },
   KeySystem = true,
   KeySettings = {
      Title = "Vinz Hub | Premium",
      Subtitle = "Key: VINZ-HUB-PREM",
      Note = "Auto-Save Active",
      FileName = "VinzKeySave",
      SaveKey = true,
      Key = {"VINZ-HUB-PREM"} 
   }
})

-- === SETTINGS ===
local cfg = {
    aimHead = false, aimBody = false, 
    espBox = false, espHealth = false, espTracer = false,
    teamCheck = false, wallCheck = false,
    ws = 16, jp = 50, infJump = false,
    fovCircle = false, fovSize = 100,
    noRecoil = false
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
FOV.Radius = cfg.fovSize
FOV.Color = Color3.fromRGB(0, 255, 255)
FOV.Filled = false

run.RenderStepped:Connect(function()
    FOV.Position = Vector2.new(mouse.X, mouse.Y + 36)
    FOV.Visible = cfg.fovCircle
    FOV.Radius = cfg.fovSize
end)

-- === WALL CHECK FIX ===
local function isVisible(part)
    if not cfg.wallCheck then return true end
    local castPoints = {cam.CFrame.Position, part.Position}
    local ignoreList = {me.Character, cam}
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = ignoreList
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ray = workspace:Raycast(cam.CFrame.Position, (part.Position - cam.CFrame.Position).Unit * (part.Position - cam.CFrame.Position).Magnitude, params)
    return not ray
end

-- === IMPROVED ESP & TRACERS ===
local function setup_esp(p)
    if p == me then return end
    local function create()
        local char = p.Character or p.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart", 10)
        local hum = char:WaitForChild("Humanoid", 10)
        
        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Thickness = 1
        tracer.Color = Color3.new(1, 1, 1)

        run.RenderStepped:Connect(function()
            if char and char.Parent and root and hum.Health > 0 then
                local pos, onScreen = cam:WorldToViewportPoint(root.Position)
                local color = (p.Team == me.Team) and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)

                -- Tracer Logic
                if cfg.espTracer and onScreen then
                    tracer.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                    tracer.To = Vector2.new(pos.X, pos.Y)
                    tracer.Color = color
                    tracer.Visible = true
                else
                    tracer.Visible = false
                end
            else
                tracer.Visible = false
                if not p.Parent then tracer:Remove() end
            end
        end)
    end
    create()
    p.CharacterAdded:Connect(create)
end

for _, p in ipairs(plrs:GetPlayers()) do setup_esp(p) end
plrs.PlayerAdded:Connect(setup_esp)

-- === COMBAT TAB ===
local TabCombat = Window:CreateTab("Combat 🎯")
TabCombat:CreateToggle({ Name = "Aimlock HEAD", CurrentValue = false, Callback = function(v) cfg.aimHead = v end })
TabCombat:CreateToggle({ Name = "Wall Check (Anti-Bug)", CurrentValue = false, Callback = function(v) cfg.wallCheck = v end })
TabCombat:CreateToggle({ Name = "Show FOV Circle", CurrentValue = false, Callback = function(v) cfg.fovCircle = v end })
TabCombat:CreateSlider({ Name = "FOV Size", Range = {10, 500}, Increment = 1, Suffix = "px", CurrentValue = 100, Callback = function(v) cfg.fovSize = v end })
TabCombat:CreateToggle({ Name = "No Recoil (Simple)", CurrentValue = false, Callback = function(v) cfg.noRecoil = v end })

-- === VISUAL TAB ===
local TabVisual = Window:CreateTab("Visuals 👁️")
TabVisual:CreateToggle({ Name = "ESP Box", CurrentValue = false, Callback = function(v) cfg.espBox = v end })
TabVisual:CreateToggle({ Name = "ESP Tracers", CurrentValue = false, Callback = function(v) cfg.espTracer = v end })

-- === MOVEMENT TAB ===
local TabMove = Window:CreateTab("Movement ⚡")
TabMove:CreateSlider({ Name = "WalkSpeed", Range = {16, 200}, Increment = 1, Suffix = "spd", CurrentValue = 16, Callback = function(
