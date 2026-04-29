local Venyx = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Venyx-UI-Library/main/source.lua"))()
local UI = Venyx.new("REYZ  | KICK LUCKY BLOCK 💀")

-- [[ THEMES ]]
local Themes = {
    Background = Color3.fromRGB(24, 24, 24),
    Accent = Color3.fromRGB(255, 0, 0),
    LightContrast = Color3.fromRGB(30, 30, 30),
    DarkContrast = Color3.fromRGB(20, 20, 20),  
    TextColor = Color3.fromRGB(255, 255, 255)
}

-- [[ PAGES ]]
local Main = UI:addPage("Main", 5012544693)
local Visual = UI:addPage("Visual", 5012544693)
local Misc = UI:addPage("Misc", 5012544693)

local MainSection = Main:addSection("Automation")
local VisualSection = Visual:addSection("Render Settings")

-- [[ CONFIG ]]
getgenv().KuzeConfig = {
    AutoKick = false,
    AutoRebirth = false,
    AutoWin = false,
    FPSBoost = false
}

-- [[ FEATURES ]]
MainSection:addToggle("Auto Kick Lucky Block", false, function(v)
    getgenv().KuzeConfig.AutoKick = v
    spawn(function()
        while getgenv().KuzeConfig.AutoKick do
            task.wait()
            -- Ganti "KickEvent" dengan nama RemoteEvent asli di game tersebut
            game:GetService("ReplicatedStorage").Events.Kick:FireServer() 
        end
    end)
end)

MainSection:addToggle("Auto Wins (Teleport)", false, function(v)
    getgenv().KuzeConfig.AutoWin = v
    spawn(function()
        while getgenv().KuzeConfig.AutoWin do
            task.wait(0.1)
            local character = game.Players.LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                -- Koordinat garis finish, sesuaikan dengan map
                character.HumanoidRootPart.CFrame = workspace.FinishLine.CFrame 
            end
        end
    end)
end)

VisualSection:addToggle("Smart FPS Boost", false, function(v)
    if v then
        game:GetService("Lighting").GlobalShadows = false
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("Part") or obj:IsA("MeshPart") then
                obj.Material = Enum.Material.SmoothPlastic
            end
        end
        UI:Notify("Optimization", "Realme C65 Mode Active!")
    end
end)

VisualSection:addButton("Clear World Textures", function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        end
    end
end)

-- [[ FOOTER ]]
UI:SelectPage(Main, true)
