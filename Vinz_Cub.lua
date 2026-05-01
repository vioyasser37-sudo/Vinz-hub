--[[
██╗ ██████╗ ███████╗███████╗███████╗██╗     ███████╗
██║██╔════╝ ██╔════╝██╔════╝██╔════╝██║     ██╔════╝
██║██║  ███╗█████╗  █████╗  █████╗  ██║     █████╗  
██║██║   ██║██╔══╝  ██╔══╝  ██╔══╝  ██║     ██╔══╝  
██║╚██████╔╝███████╗██║     ███████╗███████╗███████╗
╚═╝ ╚═════╝ ╚══════╝╚═════╝     ╚══════╝╚══════╝╚══════╝
       OBSIDIAN COMBAT - ZENITH UI
       FIXED VERSION FOR RANZMODZ
]]

-- GANTI LIBRARY BIAR PASTI JALAN
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main-loader"))()

local Window = Library:CreateWindow({
    Name = "OBSIDIAN RECKONING",
    Author = "by RanzModz",
    Theme = "Dark",
    Size = UDim2.new(0, 350, 0, 450),
    Resizable = true,
    Transparent = true
})

-- TABS
local CombatTab = Window:AddTab("⚔️ COMBAT")
local PlayerTab = Window:AddTab("📱 PLAYER")

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- CONFIG
local Config = {
    Aimbot = true,
    OneHit = false,
    HitboxSize = 5,
    GodMode = false,
    Speed = 50,
    JumpPower = 100
}

-- === COMBAT TAB ===
CombatTab:AddLabel("COMBAT SYSTEM")

CombatTab:AddToggle("Aimbot", {
    Text = "Aimbot / Lock Target",
    Default = Config.Aimbot,
    Callback = function(v) Config.Aimbot = v end
})

CombatTab:AddToggle("OneHit", {
    Text = "One Hit Kill",
    Default = Config.OneHit,
    Callback = function(v) Config.OneHit = v end
})

CombatTab:AddSlider("Hitbox", {
    Text = "Hitbox Size",
    Min = 1,
    Max = 15,
    Default = Config.HitboxSize,
    Callback = function(v) Config.HitboxSize = v end
})

-- === PLAYER TAB ===
PlayerTab:AddLabel("PLAYER STATS")

PlayerTab:AddSlider("Speed", {
    Text = "Walk Speed",
    Min = 16,
    Max = 500,
    Default = Config.Speed,
    Callback = function(v) Config.Speed = v end
})

PlayerTab:AddSlider("Jump", {
    Text = "Jump Power",
    Min = 50,
    Max = 500,
    Default = Config.JumpPower,
    Callback = function(v) Config.JumpPower = v end
})

PlayerTab:AddToggle("GodMode", {
    Text = "God Mode",
    Default = Config.GodMode,
    Callback = function(v) Config.GodMode = v end
})

-- === MAIN LOOP ===
RunService.RenderStepped:Connect(function()
    local Character = LocalPlayer.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end

    -- APPLY STATS
    Humanoid.WalkSpeed = Config.Speed
    Humanoid.JumpPower = Config.JumpPower

    -- GOD MODE
    if Config.GodMode then
        Humanoid.MaxHealth = math.huge
        Humanoid.Health = math.huge
    end

    -- AIMBOT & HITBOX
    if Config.Aimbot then
        for _, v in pairs(Workspace:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v ~= Character then
                local EnemyHum = v.Humanoid
                local Root = v:FindFirstChild("HumanoidRootPart")
                
                if EnemyHum and Root and EnemyHum.Health > 0 then
                    
                    -- UBAH UKURAN BADAN
                    for _, part in pairs(v:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Size = part.Size * Config.HitboxSize
                        end
                    end

                    -- ONE HIT
                    if Config.OneHit then
                        EnemyHum.MaxHealth = 999999
                        EnemyHum.Health = 0.1
                    end

                    -- LOCK KAMERA
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Root.Position)
                end
            end
        end
    end
end)

-- NOTIF
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "✅ SUCCESS!",
    Text = "Obsidian Combat Activated!",
    Duration = 3
})

print("[OBSIDIAN] SCRIPT LOADED!")
