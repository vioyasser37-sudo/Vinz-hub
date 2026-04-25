-- [[ SuperVinxScript - Universal FPS Boost ]]
-- Creator: Vioo
-- Deskripsi: Booster ringan untuk semua game (Anti-Lag & No Visual Kill)

local function BoostFPS()
    local lighting = game:GetService("Lighting")
    
    -- 1. Optimasi Pencahayaan (Shadow mati tapi tetep terang)
    lighting.GlobalShadows = false
    lighting.FogEnd = 9e9
    lighting.Brightness = 1
    
    -- 2. Optimasi Render Objek
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    
    for _, v in pairs(game:GetDescendants()) do
        pcall(function()
            if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                -- Ganti material berat ke Plastic (Paling enteng)
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                -- Tekstur dibuat transparan biar RAM lega
                v.Transparency = 0.5
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                -- Matikan partikel biar gak framedrop pas rame
                v.Enabled = false
            elseif v:IsA("PostEffect") then
                -- Matikan efek blur/bloom yang bikin berat
                v.Enabled = false
            end
        end)
    end
    
    -- 3. Bersihkan Sampah Memori
    collectgarbage("collect")
end

-- Langsung jalankan fungsi
BoostFPS()

-- Notifikasi kecil (opsional, bisa kamu hapus kalau mau silent)
print("SuperVinxScript: FPS Boost Activated!")
