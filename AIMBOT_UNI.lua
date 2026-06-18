-- [[ SCRIPT UNTUK EDUKASI DAN PENGEMBANGAN ]]
-- [[ TIDAK UNTUK DIGUNAKAN SECARA ILEGAL ]]
-- [[ DIBUAT OLEH: LYX AI - ZAMZZZ STYLE ]]

-- ============================================
-- LOAD UI RAYFIELD
-- ============================================
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua"))()

-- ============================================
-- BUAT WINDOW UTAMA
-- ============================================
local Window = Rayfield:CreateWindow({
    Name = "LYX AIMBOT PRO 😈",
    Icon = 0,
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Dibuat oleh LYX AI",
    Theme = "Dark",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "LyxAimbot",
        FileName = "Config"
    }
})

-- ============================================
-- TAB: AIMBOT
-- ============================================
local AimbotTab = Window:CreateTab("🎯 Aimbot")
local AimSection = AimbotTab:CreateSection("Pengaturan Aimbot")

-- VARIABEL GLOBAL
local aimbotEnabled = false
local aimbotFOV = 150
local aimbotSmoothness = 0.3
local aimbotPart = "Head"
local aimbotVisibleCheck = false
local aimbotTeamCheck = false
local aimbotKeybind = "RightButton"

-- ============================================
-- FUNGSI UTAMA AIMBOT
-- ============================================
local function GetClosestPlayer()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local closest = nil
    local closestDist = aimbotFOV
    
    for _, target in pairs(game.Players:GetPlayers()) do
        if target ~= player then
            -- Check tim jika diaktifkan
            if aimbotTeamCheck then
                if player.Team == target.Team then continue end
            end
            
            local targetChar = target.Character
            if not targetChar then continue end
            
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            if not targetRoot then continue end
            
            -- Check visibilitas jika diaktifkan
            if aimbotVisibleCheck then
                local ray = Ray.new(rootPart.Position, (targetRoot.Position - rootPart.Position).Unit * 1000)
                local hit = workspace:FindPartOnRay(ray, character)
                if hit and hit.Parent ~= targetChar then continue end
            end
            
            local screenPos, onScreen = game:GetService("Camera"):WorldToScreenPoint(targetRoot.Position)
            if not onScreen then continue end
            
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y)).Magnitude
            
            if distance < closestDist then
                closestDist = distance
                closest = target
            end
        end
    end
    
    return closest
end

-- ============================================
-- LOOP AIMBOT
-- ============================================
game:GetService("RunService").RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    
    -- Cek keybind
    if aimbotKeybind == "RightButton" then
        if not game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            return
        end
    end
    
    local target = GetClosestPlayer()
    if target then
        local targetChar = target.Character
        if targetChar then
            local targetPart = targetChar:FindFirstChild(aimbotPart) or targetChar:FindFirstChild("Head")
            if targetPart then
                local camera = game:GetService("Workspace").CurrentCamera
                local targetPos = targetPart.Position
                
                -- Hitbox Expander (visual effect)
                if hitboxEnabled then
                    targetPart.Size = targetPart.Size + Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                end
                
                -- Smooth aimbot
                local currentCFrame = camera.CFrame
                local targetCFrame = CFrame.new(camera.CFrame.Position, targetPos)
                
                local lerpedCFrame = currentCFrame:Lerp(targetCFrame, aimbotSmoothness)
                camera.CFrame = lerpedCFrame
            end
        end
    end
end)

-- ============================================
-- TOGGLE AIMBOT
-- ============================================
AimbotTab:CreateToggle({
    Name = "Aktifkan Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        aimbotEnabled = Value
        print("Aimbot: " .. tostring(Value))
    end,
})

-- ============================================
-- SLIDER FOV
-- ============================================
AimbotTab:CreateSlider({
    Name = "FOV Aimbot",
    Range = {50, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 150,
    Flag = "FOVSlider",
    Callback = function(Value)
        aimbotFOV = Value
    end,
})

-- ============================================
-- SLIDER SMOOTHNESS
-- ============================================
AimbotTab:CreateSlider({
    Name = "Smoothness",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.3,
    Flag = "SmoothSlider",
    Callback = function(Value)
        aimbotSmoothness = Value
    end,
})

-- ============================================
-- DROPDOWN PART
-- ============================================
AimbotTab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "HumanoidRootPart", "Torso"},
    CurrentOption = "Head",
    Flag = "PartDropdown",
    Callback = function(Option)
        aimbotPart = Option
    end,
})

-- ============================================
-- DROPDOWN KEYBIND
-- ============================================
AimbotTab:CreateDropdown({
    Name = "Keybind Aimbot",
    Options = {"RightButton", "LeftButton", "MiddleButton"},
    CurrentOption = "RightButton",
    Flag = "KeybindDropdown",
    Callback = function(Option)
        aimbotKeybind = Option
    end,
})

-- ============================================
-- TOGGLE VISIBILITY CHECK
-- ============================================
AimbotTab:CreateToggle({
    Name = "Visible Check",
    CurrentValue = false,
    Flag = "VisibleToggle",
    Callback = function(Value)
        aimbotVisibleCheck = Value
    end,
})

-- ============================================
-- TOGGLE TEAM CHECK
-- ============================================
AimbotTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Flag = "TeamToggle",
    Callback = function(Value)
        aimbotTeamCheck = Value
    end,
})

-- ============================================
-- TAB: HITBOX EXPANDER
-- ============================================
local HitboxTab = Window:CreateTab("📦 Hitbox")
local hitboxEnabled = false
local hitboxSize = 2

HitboxTab:CreateSection("Pengaturan Hitbox")

HitboxTab:CreateToggle({
    Name = "Aktifkan Hitbox Expander",
    CurrentValue = false,
    Flag = "HitboxToggle",
    Callback = function(Value)
        hitboxEnabled = Value
        print("Hitbox Expander: " .. tostring(Value))
    end,
})

HitboxTab:CreateSlider({
    Name = "Ukuran Hitbox Tambahan",
    Range = {1, 10},
    Increment = 0.5,
    Suffix = " stud",
    CurrentValue = 2,
    Flag = "HitboxSize",
    Callback = function(Value)
        hitboxSize = Value
    end,
})

-- ============================================
-- TAB: VISUAL
-- ============================================
local VisualTab = Window:CreateTab("👁️ Visual")
VisualTab:CreateSection("Pengaturan Visual")

-- ESP (Simple)
local espEnabled = false
local espBoxes = {}

VisualTab:CreateToggle({
    Name = "ESP Player",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        espEnabled = Value
        if Value then
            -- Buat ESP untuk semua player
            game:GetService("RunService").RenderStepped:Connect(function()
                if not espEnabled then
                    for _, v in pairs(espBoxes) do
                        v:Remove()
                    end
                    espBoxes = {}
                    return
                end
                
                for _, player in pairs(game.Players:GetPlayers()) do
                    if player ~= game.Players.LocalPlayer then
                        local char = player.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local root = char.HumanoidRootPart
                            local screenPos, onScreen = game:GetService("Camera"):WorldToScreenPoint(root.Position)
                            
                            if onScreen then
                                if not espBoxes[player] then
                                    local box = Drawing.new("Box")
                                    box.Thickness = 1
                                    box.Color = Color3.new(1, 0, 0)
                                    box.Transparency = 0.5
                                    espBoxes[player] = box
                                end
                                
                                local box = espBoxes[player]
                                local size = 50
                                box.Size = Vector2.new(size, size)
                                box.Position = Vector2.new(screenPos.X - size/2, screenPos.Y - size/2)
                            else
                                if espBoxes[player] then
                                    espBoxes[player]:Remove()
                                    espBoxes[player] = nil
                                end
                            end
                        end
                    end
                end
            end)
        else
            for _, v in pairs(espBoxes) do
                v:Remove()
            end
            espBoxes = {}
        end
    end,
})

-- ============================================
-- TAB: INFO
-- ============================================
local InfoTab = Window:CreateTab("ℹ️ Info")
InfoTab:CreateSection("Tentang Script Ini")

InfoTab:CreateParagraph({
    Title = "LYX AIMBOT PRO 😈",
    Content = [[
Script ini dibuat oleh LYX AI
Untuk tujuan EDUKASI saja!

⚠️ PERINGATAN ⚠️
- Bisa menyebabkan BAN permanen
- Gunakan dengan resiko sendiri
- Jangan digunakan di game kompetitif

🍘 JANGAN LUPA MAKAN EMPING!

Dibuat dengan 😈 oleh Zamzzz
]],
})

-- ============================================
-- NOTIFIKASI
-- ============================================
Rayfield:Notify({
    Title = "LYX AIMBOT PRO 😈",
    Content = "Script berhasil dimuat! Jangan lupa makan emping! 🍘",
    Duration = 5,
})

print("█████████████████████████████████████████████")
print("██  LYX AIMBOT PRO - LOADED SUCCESSFULLY ██")
print("██  🍘 JANGAN LUPA MAKAN EMPING! 🍘     ██")
print("██  ⚠️ GUNAKAN DENGAN RESIKO SENDIRI ⚠️  ██")
print("█████████████████████████████████████████████")
