local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB V2 | JATIM MODS TEAM",
   LoadingTitle = "Vioo's Premium Script",
   LoadingSubtitle = "by Jatim Mods Team",
   KeySystem = true,
   KeySettings = {
      Title = "Vinz Hub | Premium Access",
      Subtitle = "Key: VINZ-HUB-PREM",
      SaveKey = true,
      Key = {"VINZ-HUB-PREM"} 
   }
})

local cfg = { ws = 16, jp = 50, infJump = false, fovCircle = false, fovSize = 100, espTracer = false }
local plrs = game:GetService("Players")
local me = plrs.LocalPlayer

-- === MOVEMENT TAB ===
local TabMove = Window:CreateTab("Movement ⚡")
TabMove:CreateSlider({ Name = "WalkSpeed", Range = {16, 200}, Increment = 1, CurrentValue = 16, Callback = function(v) cfg.ws = v end })
TabMove:CreateSlider({ Name = "JumpPower", Range = {50, 500}, Increment = 1, CurrentValue = 50, Callback = function(v) cfg.jp = v end })
TabMove:CreateToggle({ Name = "Infinite Jump", CurrentValue = false, Callback = function(v) cfg.infJump = v end })

-- === VISUAL TAB ===
local TabVisual = Window:CreateTab("Visuals 👁️")
TabVisual:CreateToggle({ Name = "Show FOV Circle", CurrentValue = false, Callback = function(v) cfg.fovCircle = v end })
TabVisual:CreateSlider({ Name = "FOV Size", Range = {10, 500}, Increment = 1, CurrentValue = 100, Callback = function(v) cfg.fovSize = v end })
TabVisual:CreateToggle({ Name = "ESP Tracers", CurrentValue = false, Callback = function(v) cfg.espTracer = v end })

-- === LOOPS ===
game:GetService("RunService").RenderStepped:Connect(function()
    if me.Character and me.Character:FindFirstChild("Humanoid") then
        me.Character.Humanoid.WalkSpeed = cfg.ws
        me.Character.Humanoid.JumpPower = cfg.jp
    end
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if cfg.infJump and me.Character and me.Character:FindFirstChild("Humanoid") then
        me.Character.Humanoid:ChangeState("Jumping")
    end
end)

Rayfield:Notify({ Title = "Vinz Hub V2", Content = "Siap tempur, Vioo!", Duration = 5 })
