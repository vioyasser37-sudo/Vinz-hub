local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "VINZ HUB V4 | FISHING ISLAND 🎣",
   LoadingTitle = "Jatim Mods Team",
   LoadingSubtitle = "by Vioo",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "VinzFishing",
      FileName = "VinzConfig"
   }
})

local cfg = { fast = false, ultra = false, ws = 16 }
local lp = game.Players.LocalPlayer

-- === AUTO FISHING LOGIC ===
task.spawn(function()
    while task.wait() do
        if cfg.fast or cfg.ultra then
            pcall(function()
                local character = lp.Character
                local rod = character:FindFirstChildOfClass("Tool") or lp.Backpack:FindFirstChildOfClass("Tool")
                
                if rod and rod:FindFirstChild("Click") then
                    -- Lempar
                    rod.Click:FireServer("Cast")
                    
                    -- Jeda Kecepatan
                    if cfg.ultra then
                        task.wait(0.01) -- ULTRA FAST (Gila-gilaan)
                    else
                        task.wait(0.6) -- FAST (Instan & Stabil)
                    end
                    
                    -- Tarik
                    rod.Click:FireServer("Catch")
                end
            end)
        end
    end
end)

-- === TABS ===
local TabFarm = Window:CreateTab("Auto Farm ⚓")

TabFarm:CreateToggle({
   Name = "Fast Fishing (Instant)",
   CurrentValue = false,
   Callback = function(v)
      cfg.fast = v
      if v then cfg.ultra = false end -- Matikan mode satunya biar ga bentrok
   end,
})

TabFarm:CreateToggle({
   Name = "ULTRA FAST FISHING (God Mode)",
   CurrentValue = false,
   Callback = function(v)
      cfg.ultra = v
      if v then cfg.fast = false end
      if v then
         Rayfield:Notify({
            Title = "Warning!",
            Content = "Ultra Mode Aktif! Pastikan Tas Kamu Muat!",
            Duration = 3,
            Image = 4483345998,
         })
      end
   end,
})

local TabMisc = Window:CreateTab("Misc ⚡")

TabMisc:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 300},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Callback = function(v)
      if lp.Character and lp.Character:FindFirstChild("Humanoid") then
         lp.Character.Humanoid.WalkSpeed = v
      end
   end,
})

TabMisc:CreateButton({
   Name = "Anti-AFK",
   Callback = function()
      local vu = game:GetService("VirtualUser")
      lp.Idled:Connect(function()
         vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
         task.wait(1)
         vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
      end)
      Rayfield:Notify({Title = "System", Content = "Anti-AFK Enabled", Duration = 3})
   end,
})

Rayfield:Notify({Title = "Vinz Hub Loaded", Content = "Siap Mancing, Vioo!", Duration = 5})
