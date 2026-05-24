-- =============================================================================
-- [★] WYNOZ INF V4 - PREMIUM EDITION (TREE-VIEW DROPDOWN INTERFACE)
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

-- 1. KHỞI TẠO BIẾN CẤU HÌNH HỆ THỐNG (V3 CORES + V4 FEATURES)
local HubSettings = {
    AimbotEnabled = false,
    TeamCheck = false,
    TriggerBot = false,
    Smoothness = 0.15,
    
    EspEnabled = false,
    NameEsp = false,
    TracerEnabled = false,
    FOVRadius = 120,
    
    Fly = false,
    Noclip = false,
    WalkSpeedValue = 16,
    
    FixLag30 = false,
    FixLag50 = false,
    FixLag80 = false
}

-- Các dịch vụ Roblox gốc từ v3
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Mouse = LocalPlayer:GetMouse()
local FileName = "Wynoz_v4_Config.json"

-- =============================================================================
-- 2. THIẾT KẾ GIAO DIỆN UI DROPDOWN SIÊU NHỎ GỌN (GUI DESIGN)
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WynozHubV4"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Khung chính siêu nhỏ gọn (Rộng 220px để tiết kiệm diện tích)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 160)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Bo góc cho Khung chính
local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 6)
FrameCorner.Parent = MainFrame

-- Thanh Tiêu đề (Title Bar)
local TitleBar = Instance.new("TextLabel")
TitleBar.Name = "TitleBar"
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

-- Danh sách cuộn chứa các mục Tree-View
local Container = Instance.new("ScrollingFrame")
Container.Name = "Container"
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

-- Cập nhật kích thước cuộn tự động theo số lượng nút hiển thị
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    -- Tự động co giãn nhẹ chiều dọc của MainFrame để menu luôn vuông vắn
    local targetY = math.clamp(UIListLayout.AbsoluteContentSize.Y + 40, 160, 400)
    MainFrame.Size = UDim2.new(0, 220, 0, targetY)
end)

-- =============================================================================
-- 3. HÀM TẠO THÀNH PHẦN GIAO DIỆN (UI CREATOR FUNCTIONS)
-- =============================================================================

-- Hàm tạo Mục Lớn (Category)
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
        if SubFrame.Visible then
            SubFrame.Size = UDim2.new(1, 0, 0, SubLayout.AbsoluteContentSize.Y)
        end
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

-- Hàm tạo Nút Gạt Bật/Tắt (Toggle Switch)
local function CreateToggle(parent, text, configKey, callback)
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
    Button.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
    Button.Text = "OFF"
    Button.TextColor3 = Color3.fromRGB(255, 100, 100)
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 11
    Button.Parent = ToggleFrame
    
    local function UpdateVisual(state)
        HubSettings[configKey] = state
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
    
    Button.MouseButton1Click:Connect(function()
        UpdateVisual(not HubSettings[configKey])
    end)
    
    return {Update = UpdateVisual}
end

-- Hàm tạo Thanh kéo điều chỉnh thông số (Slider)
local function CreateSlider(parent, text, min, max, configKey, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 22)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 10)
    Label.BackgroundTransparency = 1
    Label.Text = " |-- " .. text .. ": " .. tostring(HubSettings[configKey])
    Label.TextColor3 = Color3.fromRGB(150, 150, 150)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 11
    Label.Parent = SliderFrame
    
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(0.9, 0, 0, 4)
    Bar.Position = UDim2.new(0.05, 0, 0.6, 0)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Bar.BorderSizePixel = 0
    Bar.Parent = SliderFrame
    
    local SliderBtn = Instance.new("ImageButton")
    SliderBtn.Size = UDim2.new(0, 8, 0, 8)
    SliderBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    SliderBtn.Position = UDim2.new((HubSettings[configKey] - min) / (max - min), 0, 0.5, 0)
    SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    SliderBtn.Parent = Bar
    
    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        SliderBtn.Position = UDim2.new(pos, 0, 0.5, 0)
        local value = math.floor(min + (max - min) * pos)
        if min == 0 and max == 1 then -- Xử lý số thập phân cho Smoothness
            value = tonumber(string.format("%.2f", min + (max - min) * pos))
        end
        HubSettings[configKey] = value
        Label.Text = " |-- " .. text .. ": " .. tostring(value)
        if callback then callback(value) end
    end
    
    local dragging = false
    SliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider(input)
        end
    end)
end

-- =============================================================================
-- 4. TRIỂN KHAI HOÀN CHỈNH BỐ CỤC DROPDOWN MENU TỪNG MỤC
-- =============================================================================

-- ------------------ [ TAB 1: COMBAT ] ------------------
local CombatSub = CreateCategory("🎯 COMBAT")
local AimToggle = CreateToggle(CombatSub, "Aimbot Core v3", "AimbotEnabled")
local TeamToggle = CreateToggle(CombatSub, "Team Check (Né)", "TeamCheck")
local TriggerToggle = CreateToggle(CombatSub, "Trigger Bot (Auto)", "TriggerBot")
CreateSlider(CombatSub, "Smooth (Độ mượt)", 0, 1, "Smoothness")

-- ------------------ [ TAB 2: VISUAL ] ------------------
local VisualSub = CreateCategory("👁️ VISUAL")
local EspToggle = CreateToggle(VisualSub, "Box/Name ESP v3", "EspEnabled")
local TracerToggle = CreateToggle(VisualSub, "Tracer ESP (Line)", "TracerEnabled")
CreateSlider(VisualSub, "Vòng ngắm FOV", 10, 500, "FOVRadius")

-- ------------------ [ TAB 3: MOVEMENT & FPS SYSTEM ] ------------------
local MoveSub = CreateCategory("⚡ MOVEMENT")
local FlyToggle = CreateToggle(MoveSub, "Fly Engine v3", "Fly")
local NoclipToggle = CreateToggle(MoveSub, "Noclip Core v3", "Noclip")
CreateSlider(MoveSub, "Speed Hack Val", 16, 300, "WalkSpeedValue")

-- Khu vực xử lý Nút gạt Fix Lag Khóa Chéo ON/OFF độc quyền của v4
local Divider = Instance.new("TextLabel")
Divider.Size = UDim2.new(1, 0, 0, 15)
Divider.BackgroundTransparency = 1
Divider.Text = "  [-] FPS BOOSTER & FIX LAG"
Divider.TextColor3 = Color3.fromRGB(0, 255, 200)
Divider.Font = Enum.Font.SourceSansBold
Divider.TextSize = 11
Divider.TextXAlignment = Enum.TextXAlignment.Left
Divider.Parent = MoveSub

local Lag30, Lag50, Lag80 -- Khai báo biến đại diện

-- Hàm thiết lập lại đồ họa ban đầu của game
local function CleanGraphicsEffects()
    Lighting.GlobalShadows = true
end

-- Thuật toán kích hoạt Fix Lag theo cấp độ thực chiến
local function TriggerFixLag(level)
    CleanGraphicsEffects()
    if level == 0 then return end
    
    if level >= 30 then
        if Lighting:FindFirstChild("Bloom") then Lighting.Bloom.Enabled = false end
        if Lighting:FindFirstChild("SunRays") then Lighting.SunRays.Enabled = false end
    end
    if level >= 50 then
        Lighting.GlobalShadows = false
        if Lighting:FindFirstChild("Blur") then Lighting.Blur.Enabled = false end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
                obj.Material = Enum.Material.Plastic
            end
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

-- Gắn sự kiện khóa chéo ON/OFF cho hệ thống nút Fix Lag
Lag30 = CreateToggle(MoveSub, "Fix Lag 30% (Nhẹ)", "FixLag30", function(state)
    if state then
        Lag50.Update(false) Lag80.Update(false)
        TriggerFixLag(30)
    else
        if not HubSettings.FixLag50 and not HubSettings.FixLag80 then TriggerFixLag(0) end
    end
end)

Lag50 = CreateToggle(MoveSub, "Fix Lag 50% (Mạnh)", "FixLag50", function(state)
    if state then
        Lag30.Update(false) Lag80.Update(false)
        TriggerFixLag(50)
    else
        if not HubSettings.FixLag30 and not HubSettings.FixLag80 then TriggerFixLag(0) end
    end
end)

Lag80 = CreateToggle(MoveSub, "Fix Lag 80% (Xóa Hết)", "FixLag80", function(state)
    if state then
        Lag30.Update(false) Lag50.Update(false)
        TriggerFixLag(80)
    else
        if not HubSettings.FixLag30 and not HubSettings.FixLag50 then TriggerFixLag(0) end
    end
end)

-- ------------------ [ TAB 4: CONFIG LOCAL DATA ] ------------------
local ConfigSub = CreateCategory("💾 CONFIG")

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.9, 0, 0, 22)
SaveBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 50)
SaveBtn.Text = "[ LƯU CẤU HÌNH (SAVE) ]"
SaveBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
SaveBtn.Font = Enum.Font.SourceSansBold
SaveBtn.TextSize = 12
SaveBtn.Parent = ConfigSub

local LoadBtn = Instance.new("TextButton")
LoadBtn.Size = UDim2.new(0.9, 0, 0, 22)
LoadBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 50)
LoadBtn.Text = "[ TẢI CẤU HÌNH (LOAD) ]"
LoadBtn.TextColor3 = Color3.fromRGB(200, 100, 255)
LoadBtn.Font = Enum.Font.SourceSansBold
LoadBtn.TextSize = 12
LoadBtn.Parent = ConfigSub

SaveBtn.MouseButton1Click:Connect(function()
    local success, encoded = pcall(function() return HttpService:JSONEncode(HubSettings) end)
    if success and writefile then
        writefile(FileName, encoded)
    end
end)

LoadBtn.MouseButton1Click:Connect(function()
    if isfile and isfile(FileName) then
        local data = readfile(FileName)
        local success, decoded = pcall(function() return HttpService:JSONDecode(data) end)
        if success then
            for k, v in pairs(decoded) do HubSettings[k] = v end
            -- Cập nhật trực quan trạng thái nút bấm
            AimToggle.Update(HubSettings.AimbotEnabled)
            TeamToggle.Update(HubSettings.TeamCheck)
            TriggerToggle.Update(HubSettings.TriggerBot)
            EspToggle.Update(HubSettings.EspEnabled)
            TracerToggle.Update(HubSettings.TracerEnabled)
            FlyToggle.Update(HubSettings.Fly)
            NoclipToggle.Update(HubSettings.Noclip)
        end
    end
end)

-- Phím tắt RightShift để Ẩn/Hiện toàn bộ Menu
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- =============================================================================
-- 5. ENGINE VÒNG LẶP LIÊN TỤC (CORE ENGINE LÕI CỦA V3 NÂNG CẤP LÊN V4)
-- =============================================================================

-- [VÒNG LẶP KHÓA TÂM AIMBOT & TRIGGER BOT V4]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(0, 255, 200)
FOVCircle.Thickness = 1
FOVCircle.Filled = false

local function GetClosestPlayer()
    local Target = nil
    local MaxDistance = HubSettings.FOVRadius
    local MousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            -- TÍNH NĂNG MỚI V4: KIỂM TRA PHÂN PHE (TEAM CHECK)
            if HubSettings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            if player.Character.Humanoid.Health > 0 then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
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

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then HoldingKey = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then HoldingKey = false end
end)

RunService.RenderStepped:Connect(function()
    -- Cập nhật vòng tròn FOV
    FOVCircle.Radius = HubSettings.FOVRadius
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Visible = true

    -- Thực thi Aimbot điều hướng camera mượt mà
    if HubSettings.AimbotEnabled and HoldingKey then
        local targetPlayer = GetClosestPlayer()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
            local targetPos = targetPlayer.Character.Head.Position
            local camPos = Camera.CFrame.Position
            local targetCFrame = CFrame.new(camPos, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, HubSettings.Smoothness)
        end
    end
    
    -- TÍNH NĂNG MỚI V4: TRIGGER BOT PHẢN XẠ SIÊU TỐC
    if HubSettings.TriggerBot and Mouse.Target then
        local targetChar = Mouse.Target.Parent
        local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
        if targetPlayer and targetPlayer ~= LocalPlayer and targetChar:FindFirstChild("Humanoid") and targetChar.Humanoid.Health > 0 then
            if not (HubSettings.TeamCheck and targetPlayer.Team == LocalPlayer.Team) then
                pcall(mouse1click) -- Ép chuột hệ thống nhấn kích hoạt xả đạn
            end
        end
    end
    
    -- Điều khiển vật lý nhân vật (Fly, Speed, Noclip từ v3)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if HubSettings.Noclip then
            for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        -- Đồng bộ hóa tốc độ từ thanh kéo Slider
        LocalPlayer.Character.Humanoid.WalkSpeed = HubSettings.WalkSpeedValue
    end
end)

-- [HỆ THỐNG VẼ LÕI ĐỒ HỌA ESP V3 NÂNG CẤP ĐỔI MÀU TEAM V4]
local function ActiveESP(player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 0, 0)
    Box.Thickness = 1
    Box.Filled = false

    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = Color3.fromRGB(255, 0, 0)
    Tracer.Thickness = 1

    RunService.RenderStepped:Connect(function()
        if HubSettings.EspEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local RootPart = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(RootPart.Position)

            if onScreen then
                -- THAY ĐỔI MÀU KHUNG THÔNG MINH THEO PHE PHÁI
                if HubSettings.TeamCheck and player.Team == LocalPlayer.Team then
                    Box.Color = Color3.fromRGB(0, 255, 100) -- Đồng đội: Xanh lá
                    Tracer.Color = Color3.fromRGB(0, 255, 100)
                else
                    Box.Color = Color3.fromRGB(255, 50, 50)  -- Kẻ địch: Đỏ
                    Tracer.Color = Color3.fromRGB(255, 50, 50)
                end

                -- Thiết lập kích thước khung Box ESP hình học
                Box.Size = Vector2.new(2000 / pos.Z, 2500 / pos.Z)
                Box.Position = Vector2.new(pos.X - Box.Size.X / 2, pos.Y - Box.Size.Y / 2)
                Box.Visible = true

                -- TÍNH NĂNG MỚI V4: VẼ TRACER LINE CHỐNG MÓC LỐP
                if HubSettings.TracerEnabled then
                    Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(pos.X, pos.Y)
                    Tracer.Visible = true
                else
                    Tracer.Visible = false
                end
            else
                Box.Visible = false
                Tracer.Visible = false
            end
        else
            Box.Visible = false
            Tracer.Visible = false
        end
    end)
end

-- Kích hoạt cổng quét ESP tự động cho server
for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then ActiveESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then ActiveESP(p) end end)
