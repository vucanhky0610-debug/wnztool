-- =============================================================================
-- [★] WYNOZ INF V4 - PREMIUM EDITION (RESTORED USER'S ORIGINAL CORE)
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

-- 1. ĐỒNG BỘ CẤU HÌNH GỐC CỦA BẠN (TRẢ LẠI GIÁ TRỊ MẶC ĐỊNH BẬT)
local Settings = {
    AimbotEnabled = true, -- Mặc định bật theo code gốc của bạn
    AimKey = Enum.UserInputType.MouseButton2, -- Giữ Chuột Phải để Aim
    AimPart = "Head", -- Bộ phận khóa tâm
    Smoothness = 0.15, -- Độ mượt gốc
    
    FOVEnabled = true,
    FOVRadius = 120, 
    FOVColor = Color3.fromRGB(0, 255, 255)
}

-- Biến phụ cho các tính năng khác của GUI v4
local HubSettings = {
    EspEnabled = true,
    TeamCheck = false,
    TriggerBot = false,
    Fly = false,
    Noclip = false,
    WalkSpeedValue = 16,
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
-- 2. ĐỒ HỌA VÒNG TRÒN FOV GỐC CỦA BẠN
-- =============================================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Settings.FOVEnabled
FOVCircle.Color = Settings.FOVColor
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Filled = false

-- Hàm tìm mục tiêu gần tâm ngắm nhất (GIỮ NGUYÊN 100% CODE CỦA BẠN)
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

-- Xử lý bắt giữ chuột phải (CODE GỐC CỦA BẠN - KHÔNG DELAY)
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
-- 3. THIẾT KẾ GIAO DIỆN UI DROPDOWN TREE-VIEW
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WynozHubV4"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 160)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 6)
FrameCorner.Parent = MainFrame

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 25)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.Text = " ★ WYNOZ INF V4 Premium"
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
Container.Position = UDim2.new(0, 5, 0, 30)
Container.Size = UDim2.new(1, -10, 1, -35)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ScrollBarThickness = 2
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 3)

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    local targetY = math.clamp(UIListLayout.AbsoluteContentSize.Y + 40, 160, 400)
    MainFrame.Size = UDim2.new(0, 220, 0, targetY)
end)

local function CreateCategory(name)
    local CategoryBtn = Instance.new("TextButton")
    CategoryBtn.Size = UDim2.new(1, 0, 0, 25)
    CategoryBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    CategoryBtn.Text = " [▶] " .. name
    CategoryBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CategoryBtn.Font = Enum.Font.SourceSansBold
    CategoryBtn.TextSize = 14
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
    SubLayout.Padding = UDim.new(0, 2)
    
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

local function CreateToggle(parent, text, defaultState, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 20)
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
    Button.Size = UDim2.new(0.28, 0, 0.9, 0)
    Button.Position = UDim2.new(0.72, 0, 0.05, 0)
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 11
    Button.Parent = ToggleFrame
    
    local state = defaultState
    local function UpdateVisual(s)
        state = s
        if state then
            Button.BackgroundColor3 = Color3.fromRGB(20, 50, 20)
            Button.Text = "ON"
            Button.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            Button.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
            Button.Text = "OFF"
            Button.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        if callback then callback(state) end
    end
    Button.MouseButton1Click:Connect(function() UpdateVisual(not state) end)
    UpdateVisual(state)
    return {Update = UpdateVisual}
end

-- =============================================================================
-- 4. BỐ CỤC DROPDOWN MENU (KẾT NỐI ĐIỀU KHIỂN)
-- =============================================================================

-- TAB 1: COMBAT
local CombatSub = CreateCategory("🎯 COMBAT")
CreateToggle(CombatSub, "Aimbot Core v3", Settings.AimbotEnabled, function(state) Settings.AimbotEnabled = state end)
CreateToggle(CombatSub, "Khóa vào Body (Root)", false, function(state) Settings.AimPart = state and "HumanoidRootPart" or "Head" end)
CreateToggle(CombatSub, "Trigger Bot (Auto)", false, function(state) HubSettings.TriggerBot = state end)

-- TAB 2: VISUAL
local VisualSub = CreateCategory("👁️ VISUAL")
CreateToggle(VisualSub, "Box/Name ESP v3", HubSettings.EspEnabled, function(state) HubSettings.EspEnabled = state end)
CreateToggle(VisualSub, "Vòng tròn FOV", Settings.FOVEnabled, function(state) Settings.FOVEnabled = state end)

-- TAB 3: MOVEMENT
local MoveSub = CreateCategory("⚡ MOVEMENT")
CreateToggle(MoveSub, "Noclip Core v3", false, function(state) HubSettings.Noclip = state end)

-- FPS Booster & Fix Lag giữ nguyên cấu trúc nhẹ
local Divider = Instance.new("TextLabel")
Divider.Size = UDim2.new(1, 0, 0, 15); Divider.BackgroundTransparency = 1; Divider.Text = "  [-] FPS BOOSTER & FIX LAG"; Divider.TextColor3 = Color3.fromRGB(0, 255, 200); Divider.Font = Enum.Font.SourceSansBold; Divider.TextSize = 11; Divider.TextXAlignment = Enum.TextXAlignment.Left; Divider.Parent = MoveSub

local function ApplyFixLag(level)
    Lighting.GlobalShadows = true
    if level == 80 then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
                obj.Material = Enum.Material.SmoothPlastic
            elseif (obj:IsA("Decal") or obj:IsA("Texture")) and not obj:IsDescendantOf(LocalPlayer.Character) then
                pcall(function() obj.Transparency = 1 end)
            end
        end
    end
end
CreateToggle(MoveSub, "Fix Lag Max 80%", false, function(state) ApplyFixLag(state and 80 or 0) end)

-- Phím RightShift ẩn hiện GUI nhanh
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then MainFrame.Visible = not MainFrame.Visible end
end)

-- =============================================================================
-- 5. HỆ THỐNG ESP GỐC CỦA BẠN (GIỮ NGUYÊN TOÀN BỘ LOGIC TOÁN HỌC)
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

    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        -- Cập nhật vòng tròn FOV luôn đi theo chuột (Tách riêng biệt)
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Settings.FOVRadius
        FOVCircle.Visible = Settings.FOVEnabled

        -- Vẽ ESP dựa theo biến của GUI bật/tắt công thức toán học của bạn
        if HubSettings.EspEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
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

-- Kích hoạt cổng tạo ESP cho Server
for _, player in ipairs(Players:GetPlayers()) do CreateESP(player) end
Players.PlayerAdded:Connect(CreateESP)

-- =============================================================================
-- 6. VÒNG LẶP CHẠY AIMBOT GỐC CỦA BẠN (KHÔNG CHỈNH SỬA, KHÔNG DELAY)
-- =============================================================================
RunService.RenderStepped:Connect(function()
    -- Xử lý Aimbot chuyển động Camera chuẩn của bạn
    if Settings.AimbotEnabled and HoldingKey then
        local TargetPlayer = GetClosestPlayer()
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild(Settings.AimPart) then
            -- Giữ nguyên thuật toán gốc bắt dính mục tiêu lập tức của bạn
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPlayer.Character[Settings.AimPart].Position), Settings.Smoothness)
        end
    end

    -- Kèm theo xử lý phụ Noclip/Triggerbot nếu người chơi bật từ GUI
    if HubSettings.TriggerBot and Mouse.Target then
        local tChar = Mouse.Target.Parent
        local tPlayer = Players:GetPlayerFromCharacter(tChar)
        if tPlayer and tPlayer ~= LocalPlayer and tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health > 0 then
            pcall(mouse1click)
        end
    end

    if LocalPlayer.Character and HubSettings.Noclip then
        for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)
