local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

local Window = Rayfield:CreateWindow({
   Name = "OBSIDIAN RECKONING",
   LoadingTitle = "LOADING...",
   LoadingSubtitle = "by RanzModz",
   ConfigurationSaving = {Enabled = true, FolderName = nil, FileName = "Obsidian"},
   Discord = {Enabled = false, Invite = "noinvitelink", RememberJoins = true},
   KeySystem = false
})

local CombatTab = Window:CreateTab("⚔️ COMBAT", nil)
local PlayerTab = Window:CreateTab("📱 PLAYER", nil)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Config = {
    Aimbot = true,
    OneHit = false,
    HitboxSize = 5,
    GodMode = false,
    Speed = 50,
    JumpPower = 100
}

CombatTab:CreateSection("COMBAT SYSTEM")

CombatTab:CreateToggle({
   Name = "Aimbot / Lock Target",
   CurrentValue = Config.Aimbot,
   Flag = "AimbotToggle",
   Callback = function(Value) Config.Aimbot = Value end
})

CombatTab:CreateToggle({
   Name = "One Hit Kill",
   CurrentValue = Config.OneHit,
   Flag = "OneHitToggle",
   Callback = function(Value) Config.OneHit = Value end
})

CombatTab:CreateSlider({
   Name = "Hitbox Size",
   Range = {1, 15},
   Increment = 0.5,
   CurrentValue = Config.HitboxSize,
   Flag = "HitboxSlider",
   Callback = function(Value) Config.HitboxSize = Value end
})

PlayerTab:CreateSection("PLAYER STATS")

PlayerTab:CreateSlider({
   Name = "Walk Speed",
   Range = {16, 500},
   Increment = 5,
   CurrentValue = Config.Speed,
   Flag = "SpeedSlider",
   Callback = function(Value) Config.Speed = Value end
})

PlayerTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 500},
   Increment = 10,
   CurrentValue = Config.JumpPower,
   Flag = "JumpSlider",
   Callback = function(Value) Config.JumpPower = Value end
})

PlayerTab:CreateToggle({
   Name = "God Mode",
   CurrentValue = Config.GodMode,
   Flag = "GodModeToggle",
   Callback = function(Value) Config.GodMode = Value end
})

RunService.RenderStepped:Connect(function()
    local Character = LocalPlayer.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end

    Humanoid.WalkSpeed = Config.Speed
    Humanoid.JumpPower = Config.JumpPower

    if Config.GodMode then
        Humanoid.MaxHealth = math.huge
        Humanoid.Health = math.huge
    end

    if Config.Aimbot then
        for _, v in pairs(Workspace:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v ~= Character then
                local EnemyHum = v.Humanoid
                local Root = v:FindFirstChild("HumanoidRootPart")
                
                if EnemyHum and Root and EnemyHum.Health > 0 then
                    
                    for _, part in pairs(v:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Size = part.Size * Config.HitboxSize
                        end
                    end

                    if Config.OneHit then
                        EnemyHum.MaxHealth = 999999
                        EnemyHum.Health = 0.1
                    end

                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Root.Position)
                end
            end
        end
    end
end)

Rayfield:Notify({
   Title = "✅ SUCCESS!",
   Content = "Obsidian Combat Activated!",
   Duration = 4,
   Image = "rbxassetid://4408781165"
})
