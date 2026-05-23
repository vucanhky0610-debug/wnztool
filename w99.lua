-- WYNOZ INF ADVANCED HUB V3 (SOLARA V3 COMPATIBLE - CLEAN EDITION)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Khởi tạo biến lưu trữ cấu hình ngầm
local Settings = {
    Fly = false, FlySpeed = 100,
    SpeedHack = false, WalkSpeedValue = 100,
    Noclip = false, Esp = false,
    Aimbot = false, AimPart = "Head", Smoothness = 0.15, FOVRadius = 120,
    Invisibility = false
}

-- 1. THIẾT KẾ GIAO DIỆN HỆ THỐNG (GUI WINDOW)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WynozINF_V3_Clean"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.5, -175, 0.3, -100)
MainFrame.Size = UDim2.new(0, 350, 0, 320) -- Đã thu gọn kích thước khung cho gọn gàng
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
Title.Text = "★ Wynoz INF v3 - Clean Advanced Tool ★"
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

-- Đặt các nút chức năng cốt lõi chia làm 2 cột song song gọn gàng
CreateToggle("Fly (Bay tự do)", UDim2.new(0.06, 0, 0.16, 0), function(v) Settings.Fly = v end)
CreateToggle("Speed (Chạy bộ)", UDim2.new(0.52, 0, 0.16, 0), function(v) Settings.SpeedHack = v end)
CreateToggle("Noclip (Xuyên tường)", UDim2.new(0.06, 0, 0.28, 0), function(v) Settings.Noclip = v end)
CreateToggle("Name ESP (Định vị)", UDim2.new(0.52, 0, 0.28, 0), function(v) Settings.Esp = v end)
CreateToggle("Aimbot (Khóa tâm)", UDim2.new(0.06, 0, 0.40, 0), function(v) Settings.Aimbot = v end)
CreateToggle("Invis (Tàng hình)", UDim2.new(0.52, 0, 0.40, 0), function(v) Settings.Invisibility = v end)

-- CHỨC NĂNG TELEPORT TỚI NGƯỜI CHƠI (TELEPORT INPUT BOX)
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

-- Ô NHẬP TỐC ĐỘ CHUNG (SPEED VALUE INPUT)
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

-- Thanh chú thích đóng mở dưới cùng
local Tip = Instance.new("TextLabel")
Tip.Parent = MainFrame
Tip.BackgroundTransparency = 1
Tip.Position = UDim2.new(0, 0, 0.85, 0)
Tip.Size = UDim2.new(1, 0, 0, 25)
Tip.Font = Enum.Font.SourceSansItalic
Tip.Text = "[RightShift] để Ẩn/Hiện Menu panel"
Tip.TextColor3 = Color3.fromRGB(150, 150, 150)
Tip.TextSize = 12

-- 2. HỆ THỐNG XỬ LÝ LOGIC CÁC TÍNH NĂNG NGẦM (CORE ENGINE)
local BodyVelocity, BodyGyro = nil, nil
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Filled = false
FOVCircle.Visible = false

-- Hàm quét tìm kẻ địch cho mục Aimbot chuột phải
local function GetClosestPlayerForAim()
    local Target = nil
    local MaxDistance = Settings.FOVRadius
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Settings.AimPart) and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                local ScreenPos, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character[Settings.AimPart].Position)
                if OnScreen then
                    local MousePos = UserInputService:GetMouseLocation()
                    local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
                    if Distance < MaxDistance then MaxDistance = Distance Target = player end
                end
            end
        end
    end
    return Target
end

local HoldingRightClick = false
UserInputService.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 then HoldingRightClick = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 then HoldingRightClick = false end end)

-- VÒNG LẶP RENDERSTEPPED XỬ LÝ ĐỒNG BỘ LIÊN TỤC (TỐI ƯU FPS)
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    -- Xử lý Aimbot & FOV (Vòng ngắm chuyển sang Đỏ mặc định)
    FOVCircle.Visible = Settings.Aimbot
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Color = Color3.fromRGB(255, 0, 0)
    
    if Settings.Aimbot and HoldingRightClick then
        local target = GetClosestPlayerForAim()
        if target and target.Character and target.Character:FindFirstChild(Settings.AimPart) then
            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character[Settings.AimPart].Position), Settings.Smoothness)
        end
    end

    -- Xử lý Fly
    if root and Settings.Fly then
        if not BodyVelocity or not BodyVelocity.Parent then BodyVelocity = Instance.new("BodyVelocity", root) BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge) end
        if not BodyGyro or not BodyGyro.Parent then BodyGyro = Instance.new("BodyGyro", root) BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge) end
        BodyGyro.CFrame = workspace.CurrentCamera.CFrame
        local dir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + workspace.CurrentCamera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - workspace.CurrentCamera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - workspace.CurrentCamera.CFrame.LookVector:Cross(Vector3.new(0,1,0)) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + workspace.CurrentCamera.CFrame.LookVector:Cross(Vector3.new(0,1,0)) end
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

    -- Xử lý Invisibility (Tàng hình Client)
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

-- XỬ LÝ VẼ BOX NAME ESP ĐỊNH VỊ XUYÊN TƯỜNG (MÀU XANH LÁ)
local DrawingObjects = {}
local function ApplyEsp(player)
    if player == LocalPlayer then return end
    local text = Drawing.new("Text")
    text.Visible = false
    text.Color = Color3.fromRGB(0, 255, 0)
    text.Size = 14
    text.Center = true
    text.Outline = true
    DrawingObjects[player] = text
    
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if Settings.Esp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                text.Position = Vector2.new(pos.X, pos.Y - 30)
                text.Text = string.format("%s [%dm]", player.Name, math.floor(pos.Z))
                text.Visible = true
            else text.Visible = false end
        else
            text.Visible = false
            if not Players:FindFirstChild(player.Name) then text:Remove() DrawingObjects[player] = nil conn:Disconnect() end
        end
    end)
end
for _, p in ipairs(Players:GetPlayers()) do ApplyEsp(p) end
Players.PlayerAdded:Connect(ApplyEsp)

-- Bấm RightShift để ẩn/hiện bảng điều khiển
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then MainFrame.Visible = not MainFrame.Visible end
end)
