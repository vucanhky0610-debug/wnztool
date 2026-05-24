-- ==========================================
-- 1. CẤU HÌNH HỆ THỐNG ĐỒNG BỘ
-- ==========================================
local Settings = {
    Fly = false, FlySpeed = 100,
    SpeedHack = false, WalkSpeedValue = 100,
    Noclip = false, 
    Invisibility = false,
    
    -- Tích hợp cấu hình Aimbot & ESP tối ưu
    AimbotEnabled = false, 
    AimKey = Enum.UserInputType.MouseButton2, -- Giữ Chuột Phải để Aim
    AimPart = "Head", -- "Head" hoặc "HumanoidRootPart"
    Smoothness = 0.15, -- Độ mượt tính toán camera
    
    FOVEnabled = true,
    FOVRadius = 120, -- Bán kính vòng ngắm mặc định
    FOVColor = Color3.fromRGB(0, 255, 255), -- Màu xanh neon
    
    Esp = false -- Trạng thái bật/tắt khung định vị
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local HoldingKey = false

-- Khởi tạo đối tượng hình học cho vòng tròn FOV ngắm bắn
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Color = Settings.FOVColor
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Filled = false

-- ==========================================
-- 2. HÀM TÌM MỤC TIÊU (TỐI ƯU HÓA QUÉT MẢNG)
-- ==========================================
local function GetClosestPlayer()
    local Target = nil
    local MaxDistance = Settings.FOVRadius
    local MousePos = UserInputService:GetMouseLocation()
    local allPlayers = Players:GetPlayers()

    -- Sử dụng vòng lặp số thay vì pairs để giảm tải CPU
    for i = 1, #allPlayers do
        local player = allPlayers[i]
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local part = char:FindFirstChild(Settings.AimPart)
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            if part and hum and hum.Health > 0 then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(part.Position)
                if OnScreen then
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

-- Lắng nghe trạng thái chuột phải ngắm bắn
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

-- ==========================================
-- 3. THIẾT KẾ THỐNG NHẤT GIAO DIỆN (GUI PANEL)
-- ==========================================
if CoreGui:FindFirstChild("WynozINF_V3_Integrated") then
    CoreGui.WynozINF_V3_Integrated:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WynozINF_V3_Integrated"
ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.5, -175, 0.25, -100)
MainFrame.Size = UDim2.new(0, 350, 0, 360) -- Mở rộng khung để vừa cấu hình FOV mới
MainFrame.Active = true
MainFrame.Draggable = true

-- Khung bo góc cho mượt mà
local MainUIModifier = Instance.new("UICorner")
MainUIModifier.CornerRadius = UDim.new(0, 6)
MainUIModifier.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TopBar.Size = UDim2.new(1, 0, 0, 35)

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(0, 6)
BarCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Font = Enum.Font.Code
Title.Text = "★ Wynoz INF v3 - Integrated Edition ★"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13

-- Hàm thiết lập nút chức năng đổi màu
local function CreateToggle(text, position, default, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.Position = position
    btn.Size = UDim2.new(0.42, 0, 0, 32)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    
    local active = default
    local function UpdateVisual()
        btn.Text = text .. (active and ": ON" or ": OFF")
        btn.TextColor3 = active and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        btn.BackgroundColor3 = active and Color3.fromRGB(25, 45, 25) or Color3.fromRGB(35, 35, 35)
    end
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    UpdateVisual()
    
    btn.MouseButton1Click:Connect(function()
        active = not active
        UpdateVisual()
        callback(active)
    end)
end

-- Định vị lại các nút trên giao diện tổng thể
CreateToggle("Fly (Bay tự do)", UDim2.new(0.06, 0, 0.14, 0), Settings.Fly, function(v) Settings.Fly = v end)
CreateToggle("Speed (Chạy bộ)", UDim2.new(0.52, 0, 0.14, 0), Settings.SpeedHack, function(v) Settings.SpeedHack = v end)
CreateToggle("Noclip (Xuyên tường)", UDim2.new(0.06, 0, 0.25, 0), Settings.Noclip, function(v) Settings.Noclip = v end)
CreateToggle("Name ESP (Định vị)", UDim2.new(0.52, 0, 0.25, 0), Settings.Esp, function(v) Settings.Esp = v end)
CreateToggle("Aimbot (Khóa tâm)", UDim2.new(0.06, 0, 0.36, 0), Settings.AimbotEnabled, function(v) Settings.AimbotEnabled = v end)
CreateToggle("Invis (Tàng hình)", UDim2.new(0.52, 0, 0.36, 0), Settings.Invisibility, function(v) Settings.Invisibility = v end)

-- CHỨC NĂNG TELEPORT TỚI NGƯỜI CHƠI
local TeleInput = Instance.new("TextBox")
TeleInput.Parent = MainFrame
TeleInput.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
TeleInput.Position = UDim2.new(0.06, 0, 0.49, 0)
TeleInput.Size = UDim2.new(0.88, 0, 0, 30)
TeleInput.Font = Enum.Font.SourceSans
TeleInput.Text = "Nhập tên người chơi muốn Teleport tới..."
TeleInput.TextColor3 = Color3.fromRGB(180, 180, 180)
TeleInput.TextSize = 13

local TeleCorner = Instance.new("UICorner")
TeleCorner.CornerRadius = UDim.new(0, 4)
TeleCorner.Parent = TeleInput

TeleInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local targetName = string.lower(TeleInput.Text)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and string.find(string.lower(p.Name), targetName) then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    break
                end
            end
        end
        TeleInput.Text = "Nhập tên người chơi muốn Teleport tới..."
    end
end)

-- Ô NHẬP TỐC ĐỘ CHUNG (SPEED VALUE)
local SpeedInput = Instance.new("TextBox")
SpeedInput.Parent = MainFrame
SpeedInput.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
SpeedInput.Position = UDim2.new(0.06, 0, 0.60, 0)
SpeedInput.Size = UDim2.new(0.88, 0, 0, 30)
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.Text = "Nhập con số Tốc độ (Mặc định: 100)"
SpeedInput.TextColor3 = Color3.fromRGB(180, 180, 180)
SpeedInput.TextSize = 13

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 4)
SpeedCorner.Parent = SpeedInput

SpeedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local num = tonumber(SpeedInput.Text)
        if num then
            Settings.FlySpeed = num
            Settings.WalkSpeedValue = num
        end
    end
end)

-- Ô NHẬP KÍCH THƯỚC BÁN KÍNH VÒNG FOV
local FOVInput = Instance.new("TextBox")
FOVInput.Parent = MainFrame
FOVInput.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
FOVInput.Position = UDim2.new(0.06, 0, 0.71, 0)
FOVInput.Size = UDim2.new(0.88, 0, 0, 30)
FOVInput.Font = Enum.Font.SourceSans
FOVInput.Text = "Cài đặt kích thước vòng FOV: " .. tostring(Settings.FOVRadius)
FOVInput.TextColor3 = Color3.fromRGB(180, 180, 180)
FOVInput.TextSize = 13

local FOVInputCorner = Instance.new("UICorner")
FOVInputCorner.CornerRadius = UDim.new(0, 4)
FOVInputCorner.Parent = FOVInput

FOVInput.FocusLost:Connect(function(enterPressed)
    local num = tonumber(string.match(FOVInput.Text, "%d+"))
    if num then
        Settings.FOVRadius = num
        FOVInput.Text = "Cài đặt kích thước vòng FOV: " .. tostring(num)
    else
        FOVInput.Text = "Cài đặt kích thước vòng FOV: " .. tostring(Settings.FOVRadius)
    end
end)

local Tip = Instance.new("TextLabel")
Tip.Parent = MainFrame
Tip.BackgroundTransparency = 1
Tip.Position = UDim2.new(0, 0, 0.88, 0)
Tip.Size = UDim2.new(1, 0, 0, 25)
Tip.Font = Enum.Font.SourceSansItalic
Tip.Text = "[RightShift] để Ẩn/Hiện Menu panel"
Tip.TextColor3 = Color3.fromRGB(150, 150, 150)
Tip.TextSize = 12

-- ==========================================
-- 4. VÒNG LẶP ENGINE LIÊN TỤC (RENDERSTEPPED)
-- ==========================================
local BodyVelocity, BodyGyro = nil, nil

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    -- Đồng bộ và cập nhật vị trí/kích thước vòng tròn FOV theo Hub
    FOVCircle.Visible = Settings.AimbotEnabled and Settings.FOVEnabled
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Settings.FOVRadius

    -- Thực thi Aimbot xử lý mượt mà (Lerp) mới
    if Settings.AimbotEnabled and HoldingKey then
        local TargetPlayer = GetClosestPlayer()
        if TargetPlayer and TargetPlayer.Character then
            local part = TargetPlayer.Character:FindFirstChild(Settings.AimPart)
            if part then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), Settings.Smoothness)
            end
        end
    end

    -- Cơ chế xử lý Fly bay tự do
    if root and Settings.Fly then
        if not BodyVelocity or not BodyVelocity.Parent then 
            BodyVelocity = Instance.new("BodyVelocity", root) 
            BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge) 
        end
        if not BodyGyro or not BodyGyro.Parent then 
            BodyGyro = Instance.new("BodyGyro", root) 
            BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge) 
        end
        BodyGyro.CFrame = Camera.CFrame
        local dir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.LookVector:Cross(Vector3.new(0,1,0)) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.LookVector:Cross(Vector3.new(0,1,0)) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
        BodyVelocity.Velocity = dir * Settings.FlySpeed
    else
        if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
        if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
    end

    -- Cơ chế chỉnh sửa tốc độ WalkSpeed công khai
    if hum then
        hum.WalkSpeed = (Settings.SpeedHack and not Settings.Fly) and Settings.WalkSpeedValue or 16
    end

    -- Cơ chế xử lý Noclip xuyên tường cấu trúc phẳng
    if Settings.Noclip and char then
        for _, part in ipairs(char:GetDescendants()) do 
            if part:IsA("BasePart") then part.CanCollide = false end 
        end
    end

    -- Cơ chế xử lý Tàng hình (Invisibility) hình ảnh bản thân
    if char and Settings.Invisibility then
        for _, p in ipairs(char:GetDescendants()) do 
            if p:IsA("BasePart") or p:IsA("Decal") then p.Transparency = 1 end 
        end
    else
        if char and not Settings.Invisibility and char:FindFirstChild("Head") and char.Head.Transparency == 1 then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end
                if p:IsA("Decal") then p.Transparency = 0 end
            end
        end
    end
end)

-- ==========================================
-- 5. HỆ THỐNG VẼ BOX VÀ NAME ESP TÍCH HỢP
-- ==========================================
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
    Name.Size = 14
    Name.Center = true
    Name.Outline = true

    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        -- Chỉ thực hiện dựng khung hình khi tùy chọn nút bấm ESP đang được bật (ON)
        if Settings.Esp and player.Character then
            local char = player.Character
            local HumRoot = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            if HumRoot and hum and hum.Health > 0 then
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
            end
        else
            Box.Visible = false
            Name.Visible = false
        end

        -- Hủy kết nối dọn sạch bộ nhớ bản vẽ khi người chơi rời phòng
        if not Players:FindFirstChild(player.Name) then
            Box:Remove()
            Name:Remove()
            Connection:Disconnect()
        end
    end)
end

-- Kích hoạt cấu trúc ESP đồng loạt trên máy chủ
for _, player in ipairs(Players:GetPlayers()) do 
    CreateESP(player) 
end
Players.PlayerAdded:Connect(CreateESP)

-- Lắng nghe phím ẩn/hiện nhanh bảng điều khiển UI
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then 
        MainFrame.Visible = not MainFrame.Visible 
    end
end)
