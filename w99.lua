-- =============================================================================
-- [★] WYNOZ INF V4 - FULL PREMIUM EDITION (RESTORED ALL FUNCTIONS)
-- =============================================================================

-- 0. HỆ THỐNG AN TOÀN CHỐNG SẬP GAME (ENVIRONMENT CHECK)
if not Drawing then
    local FakeDrawing = {}
    FakeDrawing.new = function()
        local fakeObj = {}
        setmetatable(fakeObj, {
            __newindex = function() end,
            __index = function(t, k)
                if k == "Remove" or k == "Disconnect" then return function() end end
                return nil
            end
        })
        return fakeObj
    end
    getgenv().Drawing = FakeDrawing
end

-- 1. GIỮ NGUYÊN BẢNG CẤU HÌNH GỐC CỦA BẠN (KẾT NỐI TRỰC TIẾP VỚI UI)
local Settings = {
    AimbotEnabled = true,
    AimKey = Enum.UserInputType.MouseButton2, -- Giữ Chuột Phải để Aim
    AimPart = "Head", -- Bộ phận khóa tâm ("Head" hoặc "HumanoidRootPart")
    Smoothness = 0.15, -- Độ mượt
    
    FOVEnabled = true,
    FOVRadius = 120, -- Bán kính vòng tròn tâm ngắm
    FOVColor = Color3.fromRGB(0, 255, 255) -- Màu xanh neon cho vòng FOV
}

-- Bảng cấu hình các tính năng v4 của riêng bạn
local HubSettings = {
    EspEnabled = true,
    TeamCheck = false,
    TracerEnabled = false,
    TriggerBot = false,
    
    Fly = false,
    Noclip = false,
    WalkSpeedValue = 16,
    FlySpeedValue = 50,
    
    FixLag30 = false,
    FixLag50 = false,
    FixLag80 = false
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Mouse = LocalPlayer:GetMouse()
local FileName = "Wynoz_v4_Config.json"

local HoldingKey = false

-- =============================================================================
-- 2. VẼ VÒNG TRÒN FOV GỐC CỦA BẠN
-- =============================================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Settings.FOVEnabled
FOVCircle.Color = Settings.FOVColor
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Filled = false

-- Hàm tìm mục tiêu gần tâm ngắm nhất (GIỮ NGUYÊN CHUẨN 100% CODE CỦA BẠN)
local function GetClosestPlayer()
    local Target = nil
    local MaxDistance = Settings.FOVRadius

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Settings.AimPart) and player.Character:FindFirstChild("Humanoid") then
            -- Tích hợp Team Check nếu người dùng bật trên UI
            if HubSettings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
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

-- Xử lý bật/tắt khi giữ phím Aim (Gốc của bạn)
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

-- =============================================================================
-- 3. KHỞI TẠO UI DROPDOWN TREE-VIEW ĐẦY ĐỦ PHÂN HỆ
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WynozHubV4"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 230, 0, 350)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 6)
FrameCorner.Parent = MainFrame

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 28)
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
TitleBar.Text = "  ★ WYNOZ INF V4 PREMIUM"
TitleBar.TextColor3 = Color3.fromRGB(0, 255, 200)
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Font = Enum.Font.SourceSansBold
TitleBar.TextSize = 14
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 6)
TitleCorner.Parent = TitleBar

local Container = Instance.new("ScrollingFrame")
Container.Position = UDim2.new(0, 5, 0, 32)
Container.Size = UDim2.new(1, -10, 1, -38)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ScrollBarThickness = 3
Container.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end)

-- Hàm tạo Category (Tab đóng/mở)
local function CreateCategory(name)
    local CategoryBtn = Instance.new("TextButton")
    CategoryBtn.Size = UDim2.new(1, 0, 0, 26)
    CategoryBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    CategoryBtn.Text = " [▶] " .. name
    CategoryBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CategoryBtn.Font = Enum.Font.SourceSansBold
    CategoryBtn.TextSize = 13
    CategoryBtn.TextXAlignment = Enum.TextXAlignment.Left
    CategoryBtn.BorderSizePixel = 0
    CategoryBtn.Parent = Container
    
    local SubFrame = Instance.new("Frame")
    SubFrame.Size = UDim2.new(1, 0, 0, 0)
    SubFrame.BackgroundTransparency = 1
    SubFrame.BorderSizePixel = 0
    SubFrame.Visible = false
    SubFrame.Parent = Container
    
    local SubLayout = Instance.new("UIListLayout")
    SubLayout.Parent = SubFrame
    SubLayout.Padding = UDim.new(0, 3)
    
    SubLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if SubFrame.Visible then SubFrame.Size = UDim2.new(1, 0, 0, SubLayout.AbsoluteContentSize.Y) end
    end)
    
    CategoryBtn.MouseButton1Click:Connect(function()
        SubFrame.Visible = not SubFrame.Visible
        if SubFrame.Visible then
            CategoryBtn.Text = " [▼] " .. name
            CategoryBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
            SubFrame.Size = UDim2.new(1, 0, 0, SubLayout.AbsoluteContentSize.Y)
        else
            CategoryBtn.Text = " [▶] " .. name
            CategoryBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            SubFrame.Size = UDim2.new(1, 0, 0, 0)
        end
    end)
    return SubFrame
end

-- Hàm tạo nút Bật/Tắt (Toggle)
local function CreateToggle(parent, text, defaultState, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 22)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = parent
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = " |-- " .. text
    TextLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.TextSize = 13
    TextLabel.Parent = ToggleFrame
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.26, 0, 0.85, 0)
    Button.Position = UDim2.new(0.74, 0, 0.07, 0)
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 11
    Button.Parent = ToggleFrame
    
    local state = defaultState
    local function UpdateVisual(s)
        state = s
        if state then
            Button.BackgroundColor3 = Color3.fromRGB(20, 55, 20)
            Button.Text = "ON"
            Button.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            Button.BackgroundColor3 = Color3.fromRGB(55, 20, 20)
            Button.Text = "OFF"
            Button.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        if callback then callback(state) end
    end
    Button.MouseButton1Click:Connect(function() UpdateVisual(not state) end)
    UpdateVisual(state)
    return {Update = UpdateVisual}
end

-- Hàm tạo thanh trượt tùy biến thông số (Slider)
local function CreateSlider(parent, text, min, max, defaultVal, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 26)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 12)
    Label.BackgroundTransparency = 1
    Label.Text = " |-- " .. text .. ": " .. tostring(defaultVal)
    Label.TextColor3 = Color3.fromRGB(150, 150, 150)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 12
    Label.Parent = SliderFrame
    
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(0.9, 0, 0, 4)
    Bar.Position = UDim2.new(0.05, 0, 0.65, 0)
    Bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Bar.BorderSizePixel = 0
    Bar.Parent = SliderFrame
    
    local SliderBtn = Instance.new("ImageButton")
    SliderBtn.Size = UDim2.new(0, 8, 0, 8)
    SliderBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    SliderBtn.Position = UDim2.new((defaultVal - min) / (max - min), 0, 0.5, 0)
    SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    SliderBtn.Parent = Bar
    
    local currentVal = defaultVal
    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        SliderBtn.Position = UDim2.new(pos, 0, 0.5, 0)
        local value = min + (max - min) * pos
        if max <= 1 then value = tonumber(string.format("%.2f", value)) else value = math.floor(value) end
        currentVal = value
        Label.Text = " |-- " .. text .. ": " .. tostring(value)
        if callback then callback(currentVal) end
    end
    
    local dragging = false
    SliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider(input) end end)
end

-- =============================================================================
-- 4. LIÊN KẾT ĐẦY ĐỦ CÁC NÚT BẤM VÀO HỆ THỐNG BIẾN (KHÔNG BỎ SÓT)
-- =============================================================================

-- TAB 1: COMBAT
local CombatSub = CreateCategory("🎯 COMBAT")
CreateToggle(CombatSub, "Aimbot Enabled", Settings.AimbotEnabled, function(state) Settings.AimbotEnabled = state end)
CreateToggle(CombatSub, "Aim khóa Body (Root)", false, function(state) Settings.AimPart = state and "HumanoidRootPart" or "Head" end)
CreateToggle(CombatSub, "Team Check (Né bạn)", HubSettings.TeamCheck, function(state) HubSettings.TeamCheck = state end)
CreateToggle(CombatSub, "Trigger Bot (Auto)", HubSettings.TriggerBot, function(state) HubSettings.TriggerBot = state end)
CreateSlider(CombatSub, "Smoothness (Độ mượt)", 0.01, 1, Settings.Smoothness, function(val) Settings.Smoothness = val end)

-- TAB 2: VISUAL (KHÔI PHỤC ĐẦY ĐỦ TUỲ BIẾN FOV VÀ TRACER)
local VisualSub = CreateCategory("👁️ VISUAL")
CreateToggle(VisualSub, "Box/Name ESP", HubSettings.EspEnabled, function(state) HubSettings.EspEnabled = state end)
CreateToggle(VisualSub, "Tracer ESP (Đường kẻ)", HubSettings.TracerEnabled, function(state) HubSettings.TracerEnabled = state end)
CreateToggle(VisualSub, "FOV Circle Enabled", Settings.FOVEnabled, function(state) Settings.FOVEnabled = state end)
CreateSlider(VisualSub, "Bán kính FOV Radius", 10, 500, Settings.FOVRadius, function(val) Settings.FOVRadius = val end)

-- TAB 3: MOVEMENT (KHÔI PHỤC FLY, NOCLIP VÀ SPEED HACK)
local MoveSub = CreateCategory("⚡ MOVEMENT")
CreateToggle(MoveSub, "Fly Engine v3", HubSettings.Fly, function(state) HubSettings.Fly = state end)
CreateToggle(MoveSub, "Noclip Core v3", HubSettings.Noclip, function(state) HubSettings.Noclip = state end)
CreateSlider(MoveSub, "Speed Hack Value", 16, 300, HubSettings.WalkSpeedValue, function(val) HubSettings.WalkSpeedValue = val end)
CreateSlider(MoveSub, "Fly Speed Value", 10, 300, HubSettings.FlySpeedValue, function(val) HubSettings.FlySpeedValue = val end)

-- PHÂN HỆ FIX LAG ĐỘC LẬP BAN ĐẦU
local Divider = Instance.new("TextLabel")
Divider.Size = UDim2.new(1, 0, 0, 15); Divider.BackgroundTransparency = 1; Divider.Text = "  [-] FPS BOOSTER & FIX LAG"; Divider.TextColor3 = Color3.fromRGB(0, 255, 200); Divider.Font = Enum.Font.SourceSansBold; Divider.TextSize = 11; Divider.TextXAlignment = Enum.TextXAlignment.Left; Divider.Parent = MoveSub

local Lag30, Lag50, Lag80
local function ApplyFixLag(level)
    Lighting.GlobalShadows = true
    if level == 0 then return end
    if level >= 30 then
        if Lighting:FindFirstChild("Bloom") then Lighting.Bloom.Enabled = false end
        if Lighting:FindFirstChild("SunRays") then Lighting.SunRays.Enabled = false end
    end
    if level >= 50 then
        Lighting.GlobalShadows = false
        if Lighting:FindFirstChild("Blur") then Lighting.Blur.Enabled = false end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then obj.Material = Enum.Material.Plastic end
        end
    end
    if level == 80 then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
                obj.Material = Enum.Material.SmoothPlastic
            elseif (obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ParticleEmitter")) and not obj:IsDescendantOf(LocalPlayer.Character) then
                pcall(function() obj.Transparency = 1 end)
                pcall(function() obj.Enabled = false end)
            end
        end
    end
end

Lag30 = CreateToggle(MoveSub, "Fix Lag 30% (Nhẹ)", HubSettings.FixLag30, function(state)
    HubSettings.FixLag30 = state
    if state then Lag50.Update(false); Lag80.Update(false); ApplyFixLag(30) else if not HubSettings.FixLag50 and not HubSettings.FixLag80 then ApplyFixLag(0) end end
end)
Lag50 = CreateToggle(MoveSub, "Fix Lag 50% (Mạnh)", HubSettings.FixLag50, function(state)
    HubSettings.FixLag50 = state
    if state then Lag30.Update(false); Lag80.Update(false); ApplyFixLag(50) else if not HubSettings.FixLag30 and not HubSettings.FixLag80 then ApplyFixLag(0) end end
end)
Lag80 = CreateToggle(MoveSub, "Fix Lag 80% (Xóa Hết)", HubSettings.FixLag80, function(state)
    HubSettings.FixLag80 = state
    if state then Lag30.Update(false); Lag50.Update(false); ApplyFixLag(80) else if not HubSettings.FixLag30 and not HubSettings.FixLag50 then ApplyFixLag(0) end end
end)

-- TAB 4: CONFIG DATA SYSTEM
local ConfigSub = CreateCategory("💾 CONFIG DATA")
local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.9, 0, 0, 22); SaveBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 50); SaveBtn.Text = "[ LƯU CẤU HÌNH (SAVE) ]"; SaveBtn.TextColor3 = Color3.fromRGB(100, 200, 255); SaveBtn.Font = Enum.Font.SourceSansBold; SaveBtn.TextSize = 12; SaveBtn.Parent = ConfigSub
local LoadBtn = Instance.new("TextButton")
LoadBtn.Size = UDim2.new(0.9, 0, 0, 22); LoadBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 50); LoadBtn.Text = "[ TẢI CẤU HÌNH (LOAD) ]"; LoadBtn.TextColor3 = Color3.fromRGB(200, 100, 255); LoadBtn.Font = Enum.Font.SourceSansBold; LoadBtn.TextSize = 12; LoadBtn.Parent = ConfigSub

SaveBtn.MouseButton1Click:Connect(function()
    local t1 = {Settings = Settings, HubSettings = HubSettings}
    local success, encoded = pcall(function() return HttpService:JSONEncode(t1) end)
    if success and writefile then writefile(FileName, encoded) end
end)
LoadBtn.MouseButton1Click:Connect(function()
    if isfile and isfile(FileName) then
        local data = readfile(FileName)
        local success, decoded = pcall(function() return HttpService:JSONDecode(data) end)
        if success and decoded.Settings and decoded.HubSettings then
            for k,v in pairs(decoded.Settings) do Settings[k] = v end
            for k,v in pairs(decoded.HubSettings) do HubSettings[k] = v end
        end
    end
end)

-- Phím RightShift đóng/mở nhanh UI
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then MainFrame.Visible = not MainFrame.Visible end
end)

-- =============================================================================
-- 5. TẠO CẤU TRÚC ESP GỐC CỦA BẠN (KHÔNG SỬA ĐỔI TOÁN HỌC / THÊM TÍNH NĂNG TEAM CHẤT LƯỢNG V4)
-- =============================================================================
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
    
    -- Khôi phục Tracer Line của v4 mà bạn cần
    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = Color3.fromRGB(255, 0, 0)
    Tracer.Thickness = 1

    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        -- Cập nhật vòng tròn FOV luôn đi theo chuột (Giữ nguyên của bạn)
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Settings.FOVRadius
        FOVCircle.Visible = Settings.FOVEnabled

        -- Vẽ ESP (Giữ nguyên thuật toán logic toán học của bạn)
        if HubSettings.EspEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local HumRoot = player.Character.HumanoidRootPart
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(HumRoot.Position)

            if OnScreen then
                -- Tính năng v4 phân tách màu Team: Bạn bè màu xanh lá, Địch màu đỏ
                if player.Team == LocalPlayer.Team then
                    Box.Color = Color3.fromRGB(0, 255, 100)
                    Tracer.Color = Color3.fromRGB(0, 255, 100)
                else
                    Box.Color = Color3.fromRGB(255, 0, 0)
                    Tracer.Color = Color3.fromRGB(255, 0, 0)
                end

                -- Công thức tính tỷ lệ khoảng cách của bạn
                local Scale = 1 / (ScreenPos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5))) * 1000
                local Width, Height = 4 * Scale, 5 * Scale

                Box.Size = Vector2.new(Width, Height)
                Box.Position = Vector2.new(ScreenPos.X - Width / 2, ScreenPos.Y - Height / 2)
                Box.Visible = true

                Name.Position = Vector2.new(ScreenPos.X, ScreenPos.Y - (Height / 2) - 18)
                Name.Visible = true
                
                -- Khôi phục hiển thị đường kẻ Tracer định vị của v4
                if HubSettings.TracerEnabled then
                    Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(ScreenPos.X, ScreenPos.Y)
                    Tracer.Visible = true
                else
                    Tracer.Visible = false
                end
            else
                Box.Visible = false
                Name.Visible = false
                Tracer.Visible = false
            end
        else
            Box.Visible = false
            Name.Visible = false
            Tracer.Visible = false
            if not Players:FindFirstChild(player.Name) then
                Box:Remove()
                Name:Remove()
                Tracer:Remove()
                Connection:Disconnect()
            end
        end
    end)
end

-- Kích hoạt cho mọi người chơi (Gốc của bạn)
for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end
Players.PlayerAdded:Connect(CreateESP)

-- =============================================================================
-- 6. VÒNG LẶP HỆ THỐNG XỬ LÝ AIMBOT GỐC & VẬT LÝ DI CHUYỂN BIỆT LẬP
-- =============================================================================
local FlyBody = nil
RunService.RenderStepped:Connect(function()
    -- Xử lý Aimbot chuyển động Camera (GIỮ NGUYÊN BẢN GỐC CỦA BẠN - CLICK CHUỘT PHẢI ĂN NGAY KHÔNG TRỄ)
    if Settings.AimbotEnabled and HoldingKey then
        local TargetPlayer = GetClosestPlayer()
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild(Settings.AimPart) then
            local TargetPos = Camera:WorldToViewportPoint(TargetPlayer.Character[Settings.AimPart].Position)
            local MousePos = UserInputService:GetMouseLocation()
            
            -- Di chuyển Camera mượt mà đến vị trí địch theo đúng công thức của bạn
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPlayer.Character[Settings.AimPart].Position), Settings.Smoothness)
        end
    end

    -- Khôi phục xử lý Trigger Bot tự động click chuột
    if HubSettings.TriggerBot and Mouse.Target then
        local tChar = Mouse.Target.Parent
        local tPlayer = Players:GetPlayerFromCharacter(tChar)
        if tPlayer and tPlayer ~= LocalPlayer and tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health > 0 then
            if not (HubSettings.TeamCheck and tPlayer.Team == LocalPlayer.Team) then
                pcall(mouse1click)
            end
        end
    end

    -- Khôi phục toàn diện phân hệ vật lý di chuyển (WalkSpeed, Noclip, Fly) độc lập
    local Character = LocalPlayer.Character
    if Character and Character:FindFirstChild("Humanoid") and Character:FindFirstChild("HumanoidRootPart") then
        local Hum = Character.Humanoid
        local Root = Character.HumanoidRootPart
        
        -- Xử lý WalkSpeed Hack mượt mà
        Hum.WalkSpeed = HubSettings.WalkSpeedValue
        
        -- Xử lý Noclip Xuyên Tường v4 ban đầu
        if HubSettings.Noclip then
            for _, part in ipairs(Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        
        -- Khôi phục cơ chế Bay (Fly Engine v3) mượt mà bằng phím di chuyển không kẹt vật lý
        if HubSettings.MoveFly or HubSettings.Fly then
            if not FlyBody then
                FlyBody = Instance.new("BodyVelocity")
                FlyBody.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                FlyBody.Velocity = Vector3.new(0, 0.1, 0)
                FlyBody.Parent = Root
            end
            
            local FlyDirection = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then FlyDirection = FlyDirection + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then FlyDirection = FlyDirection - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then FlyDirection = FlyDirection - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then FlyDirection = FlyDirection + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then FlyDirection = FlyDirection + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then FlyDirection = FlyDirection - Vector3.new(0, 1, 0) end
            
            FlyBody.Velocity = FlyDirection.Unit * HubSettings.FlySpeedValue
            if FlyDirection == Vector3.new(0,0,0) then FlyBody.Velocity = Vector3.new(0, 0.05, 0) end
        else
            if FlyBody then FlyBody:Destroy(); FlyBody = nil end
        end
    else
        if FlyBody then FlyBody:Destroy(); FlyBody = nil end
    end
end)
