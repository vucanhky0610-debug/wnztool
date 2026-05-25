-- =============================================================================
-- [★] WYNOZ INF V4 - OFFICIAL FULL RELEASE (BẢO TOÀN CODE GỐC 100%)
-- =============================================================================

-- 100% CẤU HÌNH AIMBOT & ESP GỐC CỦA BẠN
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

-- Hàm bộ lọc kiểm tra đồng đội
local function IsEnemy(player)
    if not HubSettings.TeamCheck then return true end
    return player.Team ~= LocalPlayer.Team
end

-- 100% HÀM TÌM MỤC TIÊU GỐC
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

-- Tạo cấu trúc ESP thời gian thực
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
        FOVCircle.Position = UserInputService:GetMouseLocation()
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
                else Tracer.Visible = false end
            else Box.Visible = false; Name.Visible = false; Tracer.Visible = false end
        else Box.Visible = false; Name.Visible = false; Tracer.Visible = false; if not Players:FindFirstChild(player.Name) then Box:Remove(); Name:Remove(); Tracer:Remove(); Connection:Disconnect() end end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do CreateESP(player) end
Players.PlayerAdded:Connect(CreateESP)

RunService.Heartbeat:Connect(function()
    if Settings.AimbotEnabled and HoldingKey then
        local TargetPlayer = GetClosestPlayer()
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild(Settings.AimPart) then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPlayer.Character[Settings.AimPart].Position), Settings.Smoothness)
        end
    end
end)

local function ApplyFixLag(tier)
    HubSettings.FixLagTier = tier
    if tier == 0 then Lighting.GlobalShadows = true
    elseif tier == 1 then Lighting.GlobalShadows = false
    elseif tier == 2 then Lighting.GlobalShadows = false
        for _, obj in ipairs(workspace:GetDescendants()) do if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic end end
    elseif tier == 3 then Lighting.GlobalShadows = false
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("SunRaysEffect") then obj:Destroy() end
        end
    end
end
local HttpService = game:GetService("HttpService")
local ConfigFileName = "WynozConfig_v4.txt"

local function SaveConfig()
    local data = { AimbotEnabled = Settings.AimbotEnabled, Smoothness = Settings.Smoothness, FOVEnabled = Settings.FOVEnabled, FOVRadius = Settings.FOVRadius, EspEnabled = HubSettings.EspEnabled, TeamCheck = HubSettings.TeamCheck, TracerEnabled = HubSettings.TracerEnabled, TriggerBot = HubSettings.TriggerBot, WalkSpeedValue = HubSettings.WalkSpeedValue, FixLagTier = HubSettings.FixLagTier }
    pcall(function() if writefile then writefile(ConfigFileName, HttpService:JSONEncode(data)) end end)
end

local function LoadConfig()
    pcall(function()
        if isfile and readfile and isfile(ConfigFileName) then
            local decoded = HttpService:JSONDecode(readfile(ConfigFileName))
            if decoded then
                Settings.AimbotEnabled = decoded.AimbotEnabled or Settings.AimbotEnabled; Settings.Smoothness = decoded.Smoothness or Settings.Smoothness; Settings.FOVEnabled = decoded.FOVEnabled or Settings.FOVEnabled; Settings.FOVRadius = decoded.FOVRadius or Settings.FOVRadius; HubSettings.EspEnabled = decoded.EspEnabled or HubSettings.EspEnabled; HubSettings.TeamCheck = decoded.TeamCheck or HubSettings.TeamCheck; HubSettings.TracerEnabled = decoded.TracerEnabled or HubSettings.TracerEnabled; HubSettings.TriggerBot = decoded.TriggerBot or HubSettings.TriggerBot; HubSettings.WalkSpeedValue = decoded.WalkSpeedValue or HubSettings.WalkSpeedValue
                if decoded.FixLagTier then ApplyFixLag(decoded.FixLagTier) end
            end
        end
    end)
end

-- THIẾT KẾ UI
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui")); ScreenGui.Name = "WynozHubV4"; ScreenGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.Size = UDim2.new(0, 220, 0, 280); MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0); MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MainFrame.Active = true; MainFrame.Draggable = true
Instance.new("UICorner", MainFrame, {CornerRadius = UDim.new(0, 6)})

local Container = Instance.new("ScrollingFrame", MainFrame); Container.Position = UDim2.new(0, 5, 0, 30); Container.Size = UDim2.new(1, -10, 1, -35); Container.BackgroundTransparency = 1; Instance.new("UIListLayout", Container)

local function CreateCategory(name)
    local btn = Instance.new("TextButton", Container); btn.Size = UDim2.new(1, 0, 0, 24); btn.BackgroundColor3 = Color3.fromRGB(32, 32, 32); btn.Text = " [▶] " .. name; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.SourceSansBold; btn.TextSize = 13; btn.TextXAlignment = Enum.TextXAlignment.Left
    local sub = Instance.new("Frame", Container); sub.Size = UDim2.new(1, 0, 0, 0); sub.BackgroundTransparency = 1; sub.Visible = false; Instance.new("UIListLayout", sub)
    btn.MouseButton1Click:Connect(function() sub.Visible = not sub.Visible; btn.Text = sub.Visible and " [▼] " .. name or " [▶] " .. name end)
    return sub
end

local function CreateToggle(parent, text, default, cb)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, 0, 0, 20); f.BackgroundTransparency = 1
    local t = Instance.new("TextLabel", f); t.Size = UDim2.new(0.7, 0, 1, 0); t.Text = " |-- " .. text; t.BackgroundTransparency = 1; t.TextColor3 = Color3.fromRGB(170,170,170); t.TextXAlignment = Enum.TextXAlignment.Left
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0.25, 0, 0.8, 0); b.Position = UDim2.new(0.75, 0, 0.1, 0); b.Text = default and "ON" or "OFF"; b.MouseButton1Click:Connect(function() default = not default; b.Text = default and "ON" or "OFF"; cb(default) end)
    b.Parent = f
end

local CombatSub = CreateCategory("🎯 COMBAT"); CreateToggle(CombatSub, "Aimbot", Settings.AimbotEnabled, function(s) Settings.AimbotEnabled = s end)
local VisualSub = CreateCategory("👁️ VISUAL"); CreateToggle(VisualSub, "ESP", HubSettings.EspEnabled, function(s) HubSettings.EspEnabled = s end)
local MoveSub = CreateCategory("⚡ MOVEMENT"); CreateToggle(MoveSub, "Noclip", false, function(s) HubSettings.Noclip = s end)
local SysSub = CreateCategory("💾 SYSTEM"); CreateToggle(SysSub, "Anti-AFK", false, function(s) HubSettings.AntiAFK = s end)

RunService.Heartbeat:Connect(function()
    if HubSettings.Noclip then for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
end)

UserInputService.InputBegan:Connect(function(i, p) if not p and i.KeyCode == Enum.KeyCode.RightShift then MainFrame.Visible = not MainFrame.Visible end end)
LoadConfig()
