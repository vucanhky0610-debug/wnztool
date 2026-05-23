-- WYNOZ INF ADVANCED HUB V3 (SOLARA V3 COMPATIBLE)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- 1. CẤU HÌNH BAN ĐẦU (KẾT HỢP HUB VÀ ĐOẠN CODE CỦA BẠN)
local Settings = {
    Fly = false, FlySpeed = 100,
    SpeedHack = false, WalkSpeedValue = 100,
    Noclip = false, 
    
    -- Giữ nguyên cấu hình Aimbot & ESP gốc của bạn
    Esp = false, -- Đồng bộ bật/tắt qua giao diện GUI
    AimbotEnabled = false, -- Đồng bộ bật/tắt qua giao diện GUI
    AimKey = Enum.UserInputType.MouseButton2, -- Giữ Chuột Phải để Aim
    AimPart = "Head", -- Bộ phận khóa tâm ("Head" hoặc "HumanoidRootPart")
    Smoothness = 0.15, -- Độ mượt gốc của bạn
    FOVEnabled = true,
    FOVRadius = 120, -- Bán kính vòng tròn tâm ngắm của bạn
    FOVColor = Color3.fromRGB(0, 255, 255), -- Màu xanh neon của bạn
    
    Invisibility = false
}

-- 2. THIẾT KẾ GIAO DIỆN HỆ THỐNG (GUI WINDOW)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WynozINF_V3_Integrated"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.5, -175, 0.3, -100)
MainFrame.Size = UDim2.new(0, 350, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true

-- Thanh Topbar tiêu đề
local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TopBar.Size = UDim2.new(1, 0, 0, 35)

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Font = Enum.Font.Code
Title.Text = "★ Wynoz INF v3 - Integrated Edition ★"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14

-- Hàm tạo các nút bật/tắt (Toggle Button) nhanh
local function CreateToggle(text, position, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.BorderColor3 = Color3.fromRGB(60, 60, 60)
    btn.Position = position
    btn.Size = UDim2.new(0.42, 0, 0, 32)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 50, 50)
    btn.TextSize = 13
    
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.Text = text .. (active and ": ON" or ": OFF")
        btn.TextColor3 = active and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        btn.BackgroundColor3 = active and Color3.fromRGB(25, 45, 25) or Color3.fromRGB(35, 35, 35)
        callback(active)
    end)
end

-- Liên kết các nút bấm GUI trực tiếp vào cấu hình biến ngầm
CreateToggle("Fly (Bay tự do)", UDim2.new(0.06, 0, 0.16, 0), function(v) Settings.Fly = v end)
CreateToggle("Speed (Chạy bộ)", UDim2.new(0.52, 0, 0.16, 0), function(v) Settings.SpeedHack = v end)
CreateToggle("Noclip (Xuyên tường)", UDim2.new(0.06, 0, 0.28, 0), function(v) Settings.Noclip = v end)
CreateToggle("Name ESP (Định vị)", UDim2.new(0.52, 0, 0.28, 0), function(v) Settings.Esp = v end)
CreateToggle("Aimbot (Khóa tâm)", UDim2.new(0.06, 0, 0.40, 0), function(v) Settings.AimbotEnabled = v end)
CreateToggle("Invis (Tàng hình)", UDim2.new(0.52, 0, 0.40, 0), function(v) Settings.Invisibility = v end)

-- CHỨC NĂNG TELEPORT TỚI NGƯỜI CHƠI
local TeleInput = Instance.new("TextBox")
TeleInput.Parent = MainFrame
TeleInput.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
TeleInput.BorderColor3 = Color3.fromRGB(70, 70, 70)
TeleInput.Position = UDim2.new(0.06, 0, 0.55, 0)
TeleInput.Size = UDim2.new(0.88, 0, 0, 30)
TeleInput.Font = Enum.Font.SourceSans
TeleInput.Text = "Nhập tên người chơi muốn Teleport tới..."
TeleInput.TextColor3 = Color3.fromRGB(180, 180, 180)
TeleInput.TextSize = 13
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

-- Ô NHẬP TỐC ĐỘ CHUNG
local SpeedInput = Instance.new("TextBox")
SpeedInput.Parent = MainFrame
SpeedInput.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
SpeedInput.BorderColor3 = Color3.fromRGB(70, 70, 70)
SpeedInput.Position = UDim2.new(0.06, 0, 0.68, 0)
SpeedInput.Size = UDim2.new(0.88, 0, 0, 30)
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.Text = "Nhập con số Tốc độ (Mặc định: 100)"
SpeedInput.TextColor3 = Color3.fromRGB(180, 180, 180)
SpeedInput.TextSize = 13
SpeedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local num = tonumber(SpeedInput.Text)
        if num then
            Settings.FlySpeed = num
            Settings.WalkSpeedValue = num
        end
    end
end)

local Tip = Instance.new("TextLabel")
Tip.Parent = MainFrame
Tip.BackgroundTransparency = 1
Tip.Position = UDim2.new(0, 0, 0.85, 0)
Tip.Size = UDim2.new(1, 0, 0, 25)
Tip.Font = Enum.Font.SourceSansItalic
Tip.Text = "[RightShift] để Ẩn/Hiện Menu panel"
Tip.TextColor3 = Color3.fromRGB(150, 150, 150)
Tip.TextSize = 12

-- 3. KHỞI TẠO VÒNG TRÒN FOV GỐC CỦA BẠN
local Camera = game:GetService("Workspace").CurrentCamera
local HoldingKey = false

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Settings.FOVEnabled
FOVCircle.Color = Settings.FOVColor
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Filled = false

-- Hàm tìm mục tiêu gần tâm ngắm nhất của bạn
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

-- Lắng nghe giữ chuột phải ngắm bắn
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Settings.AimKey then HoldingKey = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Settings.AimKey then HoldingKey = false end
end)

-- 4. VÒNG LẶP CORE ENGINE XỬ LÝ LIÊN TỤC (RENDERSTEPPED)
local BodyVelocity, BodyGyro = nil, nil

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    -- Đồng bộ hiển thị vòng tròn FOV theo trạng thái nút bấm GUI
    FOVCircle.Visible = Settings.AimbotEnabled and Settings.FOVEnabled
    FOVCircle.Position = UserInputService:GetMouseLocation()

    -- Thực thi Aimbot của bạn khi nút GUI đang ON và có giữ chuột phải
    if Settings.AimbotEnabled and HoldingKey then
        local TargetPlayer = GetClosestPlayer()
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild(Settings.AimPart) then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPlayer.Character[Settings.AimPart].Position), Settings.Smoothness)
        end
    end

    -- Xử lý Fly
    if root and Settings.Fly then
        if not BodyVelocity or not BodyVelocity.Parent then BodyVelocity = Instance.new("BodyVelocity", root) BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge) end
        if not BodyGyro or not BodyGyro.Parent then BodyGyro = Instance.new("BodyGyro", root) BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge) end
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

    -- Xử lý WalkSpeed
    if hum then
        hum.WalkSpeed = (Settings.SpeedHack and not Settings.Fly) and Settings.WalkSpeedValue or 16
    end

    -- Xử lý Noclip
    if Settings.Noclip and char then
        for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
    end

    -- Xử lý Invisibility
    if char and Settings.Invisibility then
        for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then p.Transparency = 1 end end
    else
        if char and not Settings.Invisibility and char:FindFirstChild("Head") and char.Head.Transparency == 1 then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end
                if p:IsA("Decal") then p.Transparency = 0 end
            end
        end
    end
end)

-- 5. HỆ THỐNG VẼ BOX VÀ NAME ESP GỐC CỦA BẠN (LIÊN KẾT NÚT GUI)
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 0, 0) -- Giữ màu đỏ gốc của bạn
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
        -- Chỉ vẽ khi nút Name ESP trên GUI đang bật (ON)
        if Settings.Esp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
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

-- Kích hoạt ESP cho toàn bộ server
for _, player in ipairs(Players:GetPlayers()) do CreateESP(player) end
Players.PlayerAdded:Connect(CreateESP)

-- Phím Ẩn/Hiện Panel GUI nhanh
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then MainFrame.Visible = not MainFrame.Visible end
end)
