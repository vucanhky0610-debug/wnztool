-- ==========================================
-- 1. CẤU HÌNH GỐC CỦA HUB VÀ LỆNH ĐIỀU KHIỂN
-- ==========================================
local HubSettings = {
    Fly = false, FlySpeed = 100,
    SpeedHack = false, WalkSpeedValue = 100,
    Noclip = false, 
    Invisibility = false
}

-- CẤU HÌNH AIMBOT & ESP (GIỮ NGUYÊN GỐC CỦA BẠN)
local Settings = {
    AimbotEnabled = false,
    AimKey = Enum.UserInputType.MouseButton2, -- Giữ Chuột Phải để Aim
    AimPart = "Head", -- Bộ phận khóa tâm ("Head" hoặc "HumanoidRootPart")
    Smoothness = 0.15, -- Độ mượt
    
    FOVEnabled = true,
    FOVRadius = 120, -- Bán kính vòng tròn tâm ngắm
    FOVColor = Color3.fromRGB(0, 255, 255), -- Màu xanh neon cho vòng FOV
    EspEnabled = false
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local HoldingKey = false

-- ==========================================
-- 2. ĐOẠN LOGIC AIMBOT & ESP (GIỮ NGUYÊN 100% THEO YÊU CẦU)
-- ==========================================

-- Vẽ Vòng tròn FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Settings.FOVEnabled
FOVCircle.Color = Settings.FOVColor
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Filled = false

-- Hàm tìm mục tiêu gần tâm ngắm nhất và nằm trong vòng FOV
local function GetClosestPlayer()
    local Target = nil
    local MaxDistance = Settings.FOVRadius

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Settings.AimPart) and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(player.Character[Settings.AimPart].Position)
                if OnScreen then
                    local MousePos = UserInputService:GetMouseLocation()
                    local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
                    
                    if Distance < MaxDistance then
                        MaxDistance = Distance
                        Target = player
                    end
                end
            end
        end
    end
    return Target
end

-- Xử lý bật/tắt khi giữ phím Aim
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Settings.AimKey then
        HoldingKey = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Settings.AimKey then
        HoldingKey = false
    end
end)

-- Tạo cấu trúc ESP cho từng người chơi
local function CreateESP(player)
    if player == LocalPlayer then return end

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 0, 0)
    Box.Thickness = 1.5
    Box.Filled = false

    local Name = Drawing.new("Text")
    Name.Visible = false
    Name.Text = player.Name
    Name.Color = Color3.fromRGB(255, 255, 255)
    Name.Size = 15
    Name.Center = true
    Name.Outline = true

    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        -- Cập nhật vòng tròn FOV luôn đi theo chuột
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Settings.FOVRadius
        FOVCircle.Visible = Settings.AimbotEnabled and Settings.FOVEnabled

        -- Xử lý Aimbot chuyển động Camera
        if Settings.AimbotEnabled and HoldingKey then
            local TargetPlayer = GetClosestPlayer()
            if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild(Settings.AimPart) then
                local TargetPos = Camera:WorldToViewportPoint(TargetPlayer.Character[Settings.AimPart].Position)
                local MousePos = UserInputService:GetMouseLocation()
                
                -- Di chuyển Camera mượt mà đến vị trí địch
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPlayer.Character[Settings.AimPart].Position), Settings.Smoothness)
            end
        end

        -- Vẽ ESP
        if Settings.EspEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local HumRoot = player.Character.HumanoidRootPart
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(HumRoot.Position)

            if OnScreen then
                local Scale = 1 / (ScreenPos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5))) * 1000
                local Width, Height = 4 * Scale, 5 * Scale

                Box.Size = Vector2.new(Width, Height)
                Box.Position = Vector2.new(ScreenPos.X - Width / 2, ScreenPos.Y - Height / 2)
                Box.Visible = true

                Name.Position = Vector2.new(ScreenPos.X, ScreenPos.Y - (Height / 2) - 18)
                Name.Visible = true
            else
                Box.Visible = false
                Name.Visible = false
            end
        else
            Box.Visible = false
            Name.Visible = false
            if not Players:FindFirstChild(player.Name) then
                Box:Remove()
                Name:Remove()
                Connection:Disconnect()
            end
        end
    end)
end

-- Kích hoạt cho mọi người chơi
for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end
Players.PlayerAdded:Connect(CreateESP)

-- HÀM FIX LAG TỐI ƯU FPS
local function OptimizeGameForFPS()
    -- Tối ưu hóa cài đặt ánh sáng hệ thống (Lighting)
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") then
            effect.Enabled = false
        end
    end

    -- Quét toàn bộ map để xóa bớt vật thể nặng
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(Players.LocalPlayer.Character) then
            obj.CastShadow = false
            -- Đơn giản hóa chất liệu bề mặt vật thể để giảm tải cho VGA
            if obj.Material ~= Enum.Material.SmoothPlastic and obj.Material ~= Enum.Material.Plastic then
                obj.Material = Enum.Material.SmoothPlastic
            end
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Sparkles") or obj:IsA("Smoke") or obj:IsA("Fire") then
            obj.Enabled = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1 -- Ẩn bớt các hình dán phức tạp trên tường
