-- =============================================================================
-- [★] WYNOZ INF V4 - OFFICIAL FULL STABLE VERSION (100% FIXED & OPTIMIZED)
-- =============================================================================

-- 100% GIỮ NGUYÊN BẢN CẤU HÌNH AIMBOT & ESP GỐC CỦA BẠN
local Settings = {
    AimbotEnabled = true,
    AimKey = Enum.UserInputType.MouseButton2, -- Giữ Chuột Phải để Aim
    AimPart = "Head", -- Bộ phận khóa tâm ("Head" hoặc "HumanoidRootPart")
    Smoothness = 0.15, -- Độ mượt gốc
    
    FOVEnabled = true,
    FOVRadius = 120, -- Bán kính vòng tròn tâm ngắm gốc
    FOVColor = Color3.fromRGB(0, 255, 255) -- Màu xanh neon gốc
}

-- Các cấu hình tính năng bổ sung của bản v4
local HubSettings = {
    EspEnabled = true,
    TeamCheck = false,
    TracerEnabled = false,
    TriggerBot = false,
    WalkSpeedValue = 16,
    Noclip = false,
    Fly = false,
    FlySpeedValue = 50,
    FixLagTier = 0 -- 0: Tắt, 1: 30%, 2: 50%, 3: 80%
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Mouse = LocalPlayer:GetMouse()

local HoldingKey = false

-- Vẽ Vòng tròn FOV gốc
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Settings.FOVEnabled
FOVCircle.Color = Settings.FOVColor
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Filled = false

-- Hàm bộ lọc kiểm tra đồng đội (Hỗ trợ cho ESP và Aimbot gốc)
local function IsEnemy(player)
    if not HubSettings.TeamCheck then return true end
    return player.Team ~= LocalPlayer.Team
end

-- 100% TUYỆT ĐỐI GIỮ NGUYÊN HÀM TÌM MỤC TIÊU GỐC CỦA BẠN
-- (Đã thêm quét an toàn cả Head và RootPart để tránh lỗi nil value khi nhân vật mới load)
local function GetClosestPlayer()
    local Target = nil
    local MaxDistance = Settings.FOVRadius

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("HumanoidRootPart") then
            if player.Character.Humanoid.Health > 0 then
                local TargetPart = player.Character:FindFirstChild(Settings.AimPart)
                if TargetPart then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
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
    end
    return Target
end

-- Xử lý nút bấm giữ phím Aim gốc
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Settings.AimKey then HoldingKey = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Settings.AimKey then HoldingKey = false end
end)

-- Tạo cấu trúc ESP thời gian thực (Giữ nguyên thuật toán Scale/Vẽ gốc của bạn + Thêm đường kẻ Tracer)
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

    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = Color3.fromRGB(0, 255, 255)
    Tracer.Thickness = 1

    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        -- Cập nhật vòng tròn FOV luôn đi theo chuột (Đúng code gốc)
        FOVCircle.Position = UserInputService:GetMouseLocation()

        -- Vẽ kết cấu đồ thị ESP bám đuổi trung thực thời gian thực
        if HubSettings.EspEnabled and IsEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
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

                if HubSettings.TracerEnabled then
                    Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(ScreenPos.X, ScreenPos.Y)
                    Tracer.Visible = true
                else
                    Tracer.Visible = false
                end
            else
                Box.Visible = false; Name.Visible = false; Tracer.Visible = false
            end
        else
            Box.Visible = false; Name.Visible = false; Tracer.Visible = false
            if not Players:FindFirstChild(player.Name) then
                Box:Remove(); Name:Remove(); Tracer:Remove()
                Connection:Disconnect()
            end
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do CreateESP(player) end
Players.PlayerAdded:Connect(CreateESP)

-- TÁCH LUỒNG AIMBOT ĐỘC LẬP TRÊN HEARTBEAT (Triệt tiêu toàn bộ delay lên chuột, giữ nguyên 100% Lerp CFrame gốc)
RunService.Heartbeat:Connect(function()
    if Settings.AimbotEnabled and HoldingKey then
        local TargetPlayer = GetClosestPlayer()
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild(Settings.AimPart) then
            -- Áp dụng chuẩn xác 100% lệnh dịch chuyển Camera gốc của bạn
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPlayer.Character[Settings.AimPart].Position), Settings.Smoothness)
        end
    end
end)

-- =============================================================================
-- HỆ THỐNG PHÂN CẤP TỐI ƯU FPS BOOSTER ĐỘC LẬP (Đã gỡ bỏ hoàn toàn luồng gây nghẽn)
-- =============================================================================
local function ApplyFixLag(tier)
    HubSettings.FixLagTier = tier
    if tier == 0 then
        Lighting.GlobalShadows = true
    elseif tier == 1 then
        Lighting.GlobalShadows = false -- Mức 30%: Chỉ tắt bóng đổ toàn cục
    elseif tier == 2 then
        Lighting.GlobalShadows = false -- Mức 50%: Tắt bóng + Ép SmoothPlastic một lần cho toàn map
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic end
        end
    elseif tier == 3 then
        Lighting.GlobalShadows = false -- Mức 80%: Khử sạch vật liệu địa hình + Xóa bỏ triệt để mọi thực thể hạt/khói/lửa nặng máy
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("SunRaysEffect") then
                obj:Destroy()
            end
        end
    end
end

-- =============================================================================
-- HỆ THỐNG LƯU / TẢI CONFIG FILE .TXT CHUẨN V4
-- =============================================================================
local HttpService = game:GetService("HttpService")
local ConfigFileName = "WynozConfig_v4.txt"

local function SaveConfig()
    local data = {
        AimbotEnabled = Settings.AimbotEnabled, Smoothness = Settings.Smoothness,
        FOVEnabled = Settings.FOVEnabled, FOVRadius = Settings.FOVRadius,
        EspEnabled = HubSettings.EspEnabled, TeamCheck = HubSettings.TeamCheck,
        TracerEnabled = HubSettings.TracerEnabled, TriggerBot = HubSettings.TriggerBot,
        WalkSpeedValue = HubSettings.WalkSpeedValue, FixLagTier = HubSettings.FixLagTier
    }
    pcall(function() if writefile then writefile(ConfigFileName, HttpService:JSONEncode(data)) end end)
end

local function LoadConfig()
    pcall(function()
        if isfile and readfile and isfile(ConfigFileName) then
            local decoded = HttpService:JSONDecode(readfile(ConfigFileName))
            if decoded then
                Settings.AimbotEnabled = decoded.AimbotEnabled ~= nil and decoded.AimbotEnabled or Settings.AimbotEnabled
                Settings.Smoothness = decoded.Smoothness or Settings.Smoothness
                Settings.FOVEnabled = decoded.FOVEnabled ~= nil and decoded.FOVEnabled or Settings.FOVEnabled
                Settings.FOVRadius = decoded.FOVRadius or Settings.FOVRadius
                HubSettings.EspEnabled = decoded.EspEnabled ~= nil and decoded.EspEnabled or HubSettings.EspEnabled
                HubSettings.TeamCheck = decoded.TeamCheck ~= nil and decoded.TeamCheck or HubSettings.TeamCheck
                HubSettings.TracerEnabled = decoded.TracerEnabled ~= nil and decoded.TracerEnabled or HubSettings.TracerEnabled
                HubSettings.TriggerBot = decoded.TriggerBot ~= nil and decoded.TriggerBot or HubSettings.TriggerBot
                HubSettings.WalkSpeedValue = decoded.WalkSpeedValue or HubSettings.WalkSpeedValue
                if decoded.FixLagTier then ApplyFixLag(decoded.FixLagTier) end
            end
        end
    end)
end

-- =============================================================================
-- THIẾT KẾ GIAO DIỆN UI TREE-VIEW GỌN GÀNG (220 x 280) - XOÁ BỎ MẢNG ĐEN THỪA
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WynozHubV4"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 280) -- Định kích thước chuẩn để ôm sát, loại bỏ mảng đen
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true; MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 6); FrameCorner.Parent = MainFrame

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 26)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.Text = "  ★ WYNOZ INF V4"
TitleBar.TextColor3 = Color3.fromRGB(0, 255, 200)
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Font = Enum.Font.SourceSansBold; TitleBar.TextSize = 13
TitleBar.BorderSizePixel = 0; TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 6); TitleCorner.Parent = TitleBar

-- BẢNG THÔNG BÁO FPS REAL-TIME TRÊN THANH TIÊU ĐỀ MENU
local FpsLabel = Instance.new("TextLabel")
FpsLabel.Size = UDim2.new(0, 60, 1, 0)
FpsLabel.Position = UDim2.new(1, -65, 0, 0)
FpsLabel.BackgroundTransparency = 1
FpsLabel.Text = "[FPS: --]"
FpsLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
FpsLabel.Font = Enum.Font.SourceSansBold; FpsLabel.TextSize = 12
FpsLabel.TextXAlignment = Enum.TextXAlignment.Right
FpsLabel.Parent = TitleBar

-- Cơ chế đếm FPS độc lập thời gian thực
local FrameCount = 0
local LastTime = os.clock()
RunService.RenderStepped:Connect(function()
    FrameCount = FrameCount + 1
    local CurrentTime = os.clock()
    if CurrentTime - LastTime >= 1 then
        local Fps = math.floor(FrameCount / (CurrentTime - LastTime))
        FpsLabel.Text = "[FPS: " .. tostring(Fps) .. "]"
        if Fps >= 50 then FpsLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        elseif Fps >= 30 then FpsLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        else FpsLabel.TextColor3 = Color3.fromRGB(255, 50, 50) end
        FrameCount = 0
        LastTime = CurrentTime
    end
end)

local Container = Instance.new("ScrollingFrame")
Container.Position = UDim2.new(0, 5, 0, 30); Container.Size = UDim2.new(1, -10, 1, -35)
Container.BackgroundTransparency = 1; Container.BorderSizePixel = 0
Container.ScrollBarThickness = 3; Container.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Container; UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder; UIListLayout.Padding = UDim.new(0, 3)

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 5)
end)

local function CreateCategory(name)
    local CategoryBtn = Instance.new("TextButton")
    CategoryBtn.Size = UDim2.new(1, 0, 0, 24); CategoryBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    CategoryBtn.Text = " [▶] " .. name; CategoryBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CategoryBtn.Font = Enum.Font.SourceSansBold; CategoryBtn.TextSize = 13
    CategoryBtn.TextXAlignment = Enum.TextXAlignment.Left; CategoryBtn.BorderSizePixel = 0; CategoryBtn.Parent = Container
    
    local SubFrame = Instance.new("Frame")
    SubFrame.Size = UDim2.new(1, 0, 0, 0); SubFrame.BackgroundTransparency = 1; SubFrame.BorderSizePixel = 0
    SubFrame.Visible = false; SubFrame.Parent = Container
    
    local SubLayout = Instance.new("UIListLayout")
    SubLayout.Parent = SubFrame; SubLayout.Padding = UDim.new(0, 2)
    
    SubLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if SubFrame.Visible then SubFrame.Size = UDim2.new(1, 0, 0, SubLayout.AbsoluteContentSize.Y) end
    end)
    
    CategoryBtn.MouseButton1Click:Connect(function()
        SubFrame.Visible = not SubFrame.Visible
        if SubFrame.Visible then
            CategoryBtn.Text = " [▼] " .. name; CategoryBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
            SubFrame.Size = UDim2.new(1, 0, 0, SubLayout.AbsoluteContentSize.Y)
        else
            CategoryBtn.Text = " [▶] " .. name; CategoryBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            SubFrame.Size = UDim2.new(1, 0, 0, 0)
        end
    end)
    return SubFrame
end

local function CreateToggle(parent, text, defaultState, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 20); ToggleFrame.BackgroundTransparency = 1; ToggleFrame.Parent = parent
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(0.7, 0, 1, 0); TextLabel.BackgroundTransparency = 1; TextLabel.Text = " |-- " .. text
    TextLabel.TextColor3 = Color3.fromRGB(170, 170, 170); TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Font = Enum.Font.SourceSans; TextLabel.TextSize = 12; TextLabel.Parent = ToggleFrame
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.25, 0, 0.85, 0); Button.Position = UDim2.new(0.75, 0, 0.07, 0)
    Button.Font = Enum.Font.SourceSansBold; Button.TextSize = 11; Button.Parent = ToggleFrame
    
    local state = defaultState
    local function UpdateVisual(s)
        state = s
        if state then
            Button.BackgroundColor3 = Color3.fromRGB(20, 55, 20); Button.Text = "ON"; Button.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            Button.BackgroundColor3 = Color3.fromRGB(55, 20, 20); Button.Text = "OFF"; Button.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        if callback then callback(state) end
    end
    Button.MouseButton1Click:Connect(function() UpdateVisual(not state) end)
    UpdateVisual(state)
end

local function CreateSlider(parent, text, min, max, defaultVal, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 24); SliderFrame.BackgroundTransparency = 1; SliderFrame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 12); Label.BackgroundTransparency = 1; Label.Text = " |-- " .. text .. ": " .. tostring(defaultVal)
    Label.TextColor3 = Color3.fromRGB(140, 140, 140); Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.SourceSans; Label.TextSize = 11; Label.Parent = SliderFrame
    
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(0.9, 0, 0, 3); Bar.Position = UDim2.new(0.05, 0, 0.65, 0)
    Bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Bar.BorderSizePixel = 0; Bar.Parent = SliderFrame
    
    local SliderBtn = Instance.new("ImageButton")
    SliderBtn.Size = UDim2.new(0, 6, 0, 6); SliderBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    SliderBtn.Position = UDim2.new((defaultVal - min) / (max - min), 0, 0.5, 0)
    SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 200); SliderBtn.Parent = Bar
    
    local dragging = false
    SliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            SliderBtn.Position = UDim2.new(pos, 0, 0.5, 0)
            local value = min + (max - min) * pos
            if max <= 1 then value = tonumber(string.format("%.2f", value)) else value = math.floor(value) end
            Label.Text = " |-- " .. text .. ": " .. tostring(value)
            if callback then callback(value) end
        end
    end)
end

-- ĐỒNG BỘ CÁC TÍNH NĂNG VÀO HỆ THỐNG MENU TREE-VIEW
local CombatSub = CreateCategory("🎯 COMBAT")
CreateToggle(CombatSub, "Aimbot Core System", Settings.AimbotEnabled, function(state) Settings.AimbotEnabled = state end)
CreateToggle(CombatSub, "Aim Lock Body (Root)", false, function(state) Settings.AimPart = state and "HumanoidRootPart" or "Head" end)
CreateToggle(CombatSub, "Trigger Bot (Auto)", HubSettings.TriggerBot, function(state) HubSettings.TriggerBot = state end)
CreateSlider(CombatSub, "Smoothness Speed", 0.01, 1, Settings.Smoothness, function(val) Settings.Smoothness = val end)

local VisualSub = CreateCategory("👁️ VISUAL ESP")
CreateToggle(VisualSub, "Box/Name ESP", HubSettings.EspEnabled, function(state) HubSettings.EspEnabled = state end)
CreateToggle(VisualSub, "Team Check Filter", HubSettings.TeamCheck, function(state) HubSettings.TeamCheck = state end)
CreateToggle(VisualSub, "Tracer Lane (Lines)", HubSettings.TracerEnabled, function(state) HubSettings.TracerEnabled = state end)
CreateToggle(VisualSub, "FOV Circle Visibility", Settings.FOVEnabled, function(state) Settings.FOVEnabled = state end)
CreateSlider(VisualSub, "FOV Radius Limit", 10, 500, Settings.FOVRadius, function(val) Settings.FOVRadius = val end)

local MoveSub = CreateCategory("⚡ MOVEMENT")
CreateToggle(MoveSub, "Fly Engine v3", HubSettings.Fly, function(state) HubSettings.Fly = state end)
CreateToggle(MoveSub, "Noclip Core v3", HubSettings.Noclip, function(state) HubSettings.Noclip = state end)
CreateSlider(MoveSub, "Speed Value Hack", 16, 250, HubSettings.WalkSpeedValue, function(val) HubSettings.WalkSpeedValue = val end)

local BoostSub = CreateCategory("🖥️ FPS BOOSTER")
CreateToggle(BoostSub, "Fix Lag Boost 30%", false, function(state) ApplyFixLag(state and 1 or 0) end)
CreateToggle(BoostSub, "Fix Lag Boost 50%", false, function(state) ApplyFixLag(state and 2 or 0) end)
CreateToggle(BoostSub, "Fix Lag Boost 80%", false, function(state) ApplyFixLag(state and 3 or 0) end)

local SysSub = CreateCategory("💾 SYSTEM CONFIG")
local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(1, 0, 0, 22); SaveBtn.BackgroundColor3 = Color3.fromRGB(25, 45, 25); SaveBtn.Text = "SAVE CONFIG"; SaveBtn.TextColor3 = Color3.fromRGB(100, 255, 100); SaveBtn.Font = Enum.Font.SourceSansBold; SaveBtn.Parent = SysSub
SaveBtn.MouseButton1Click:Connect(function() SaveConfig() SaveBtn.Text = "SAVED SUCCESFULLY!" task.wait(1) SaveBtn.Text = "SAVE CONFIG" end)

local LoadBtn = Instance.new("TextButton")
LoadBtn.Size = UDim2.new(1, 0, 0, 22); LoadBtn.BackgroundColor3 = Color3.fromRGB(45, 25, 25); LoadBtn.Text = "LOAD CONFIG"; LoadBtn.TextColor3 = Color3.fromRGB(255, 100, 100); LoadBtn.Font = Enum.Font.SourceSansBold; LoadBtn.Parent = SysSub
LoadBtn.MouseButton1Click:Connect(function() LoadConfig() LoadBtn.Text = "LOADED SUCCESSFULLY!" task.wait(1) LoadBtn.Text = "LOAD CONFIG" end)

LoadConfig()

-- Nhấn phím RightShift ẩn/hiện nhanh UI
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then MainFrame.Visible = not MainFrame.Visible end
end)

-- VÒNG LẶP PHỤ TRỢ (Movement & Sửa lỗi quét sâu TriggerBot & FIX LỖI NIL VALUE FLY)
local FlyBody = nil
local LastClick = 0

RunService.Heartbeat:Connect(function()
    FOVCircle.Visible = Settings.FOVEnabled
    FOVCircle.Radius = Settings.FOVRadius

    local Character = LocalPlayer.Character
    if Character and Character:FindFirstChild("Humanoid") and Character:FindFirstChild("HumanoidRootPart") then
        Character.Humanoid.WalkSpeed = HubSettings.WalkSpeedValue
        
        if HubSettings.Noclip then
            for _, part in ipairs(Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        
        -- SỬA LỖI NIL VALUE KHI FLY ĐỨNG YÊN
        if HubSettings.Fly then
            if not FlyBody then
                FlyBody = Instance.new("BodyVelocity")
                FlyBody.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                FlyBody.Parent = Character.HumanoidRootPart
            end
            local Dir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then Dir = Dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then Dir = Dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then Dir = Dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then Dir = Dir + Camera.CFrame.RightVector end
            
            -- Biện pháp triệt tiêu lỗi nil value / NAN khi Vector bằng 0
            if Dir.Magnitude > 0 then
                FlyBody.Velocity = Dir.Unit * HubSettings.FlySpeedValue
            else
                FlyBody.Velocity = Vector3.new(0, 0.05, 0) -- Giữ nguyên vị trí lơ lửng an toàn khi không bấm nút
            end
        else
            if FlyBody then FlyBody:Destroy(); FlyBody = nil end
        end
    end
    
    -- SỬA LỖI TRIGGERBOT (Quét đệ quy tìm Model gốc của thực thể địch)
    if HubSettings.TriggerBot and Mouse.Target and (tick() - LastClick > 0.1) then
        local CurrentObj = Mouse.Target
        local TargetChar = nil
        
        while CurrentObj and CurrentObj ~= workspace do
            if CurrentObj:IsA("Model") and CurrentObj:FindFirstChildOfClass("Humanoid") then
                TargetChar = CurrentObj
                break
            end
            CurrentObj = CurrentObj.Parent
        end
        
        if TargetChar and TargetChar:FindFirstChild("Humanoid") and TargetChar.Humanoid.Health > 0 then
            local tPlayer = Players:GetPlayerFromCharacter(TargetChar)
            if tPlayer and tPlayer ~= LocalPlayer and IsEnemy(tPlayer) then
                LastClick = tick()
                if mouse1click then pcall(mouse1click) end
            end
        end
    end
end)
