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

-- === ULTRA FAST LOGIC (MODE BRUTAL) ===
task.spawn(function()
    while true do
        task.wait() -- Minimal delay biar ga crash
        if cfg.ultra then
            pcall(function()
                local character = lp.Character
                local rod = character:FindFirstChildOfClass("Tool") or lp.Backpack:FindFirstChildOfClass("Tool")
                
                if rod and rod:FindFirstChild("Click") then
                    -- Kirim sinyal lempar dan tarik secara bersamaan tanpa jeda
                    rod.Click:FireServer("Cast")
                    rod.Click:FireServer("Catch")
                end
            end)
        elseif cfg.fast then
            pcall(function()
                local character = lp.Character
                local rod = character:FindFirstChildOfClass("Tool") or lp.Backpack:FindFirstChildOfClass("Tool")
                
                if rod and rod:FindFirstChild("Click") then
                    rod.Click:FireServer("Cast")
                    task.wait(0.5) -- Jeda setengah detik biar agak natural
                    rod.Click:FireServer("Catch")
                end
            end)
        end
    end
end)

-- === TABS ===
local TabFarm = Window:CreateTab("Auto Farm ⚓")

TabFarm:CreateToggle({
   Name = "Fast Fishing (Stabil)",
   CurrentValue = false,
   Callback = function(v)
      cfg.fast = v
      if v then cfg.ultra = false end
   end,
})

TabFarm:CreateToggle({
   Name = "ULTRA FAST FISHING (Kayak Video)",
   CurrentValue = false,
   Callback = function(v)
      cfg.ultra = v
      if v then cfg.fast = false end
      if v then
         Rayfield:Notify({
            Title = "MODE BRUTAL!",
            Content = "Hati-hati, Tas bakal penuh dalam sekejap!",
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
      Rayfield:Notify({Title = "System", Content = "Anti-AFK Aktif", Duration = 3})
   end,
})

Rayfield:Notify({Title = "Vinz Hub Loaded", Content = "Mode Brutal Ready!", Duration = 5})
