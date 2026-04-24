-- VINZ HUB LITE V1
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AutoFishBtn = Instance.new("TextButton")
local SpeedBtn = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "VinzHubLite"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
MainFrame.Size = UDim2.new(0, 200, 0, 150)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "VINZ HUB - FISHING"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

-- Tombol Auto Fish
AutoFishBtn.Parent = MainFrame
AutoFishBtn.Position = UDim2.new(0.1, 0, 0.3, 0)
AutoFishBtn.Size = UDim2.new(0.8, 0, 0, 30)
AutoFishBtn.Text = "Auto Fish (Aktifkan)"
AutoFishBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)

-- Tombol Speed
SpeedBtn.Parent = MainFrame
SpeedBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
SpeedBtn.Size = UDim2.new(0.8, 0, 0, 30)
SpeedBtn.Text = "Speed Hack (Fast)"
SpeedBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

-- Fungsi
AutoFishBtn.MouseButton1Click:Connect(function()
    print("Auto Fishing Aktif!")
    -- Logic sederhana: Klik kail otomatis
    task.spawn(function()
        while true do
            task.wait(1)
            local rod = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if rod and rod:FindFirstChild("Click") then
                rod.Click:FireServer("Cast")
                task.wait(2)
                rod.Click:FireServer("Catch")
            end
        end
    end)
end)

SpeedBtn.MouseButton1Click:Connect(function()
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
end)

