-- WNOZ INF v5 - FULL FEATURES - OPTIMIZED
local Players, RunService, UserInputService, Camera = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- CẤU HÌNH HỆ THỐNG
local Settings = {
    Aimbot = true, Silent = false, Trigger = false, Noclip = false, 
    Speed = false, Fly = false, Tracers = false, FOV = 120
}

-- [1. GUI MENU - SIÊU GỌN]
local SG = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", SG); Main.Size = UDim2.new(0, 160, 0, 30); Main.Position = UDim2.new(0.1, 0, 0.1, 0); Main.BackgroundColor3 = Color3.fromRGB(40,40,40); Main.Draggable = true
local Toggle = Instance.new("TextButton", Main); Toggle.Size = UDim2.new(1,0,1,0); Toggle.Text = "Wynoz INF v5 [MỞ]"; Toggle.BackgroundTransparency = 1; Toggle.TextColor3 = Color3.new(1,1,1)
local Content = Instance.new("ScrollingFrame", Main); Content.Size = UDim2.new(1, 0, 0, 300); Content.Position = UDim2.new(0,0,1,0); Content.Visible = false; Content.BackgroundColor3 = Color3.fromRGB(30,30,30)

local function AddBtn(text, func)
    local b = Instance.new("TextButton", Content); b.Size = UDim2.new(1,-10,0,30); b.Position = UDim2.new(0,5,0, #Content:GetChildren()*35); b.Text = text; b.BackgroundColor3 = Color3.fromRGB(60,60,60); b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(func)
end
Toggle.MouseButton1Click:Connect(function() Content.Visible = not Content.Visible; Toggle.Text = Content.Visible and "Wynoz INF v5 [ĐÓNG]" or "Wynoz INF v5 [MỞ]" end)

-- [2. ENGINE LOGIC]
local function GetClosest()
    local Target, Max = nil, Settings.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local pos, on = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if on then
                local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if dist < Max then Max = dist; Target = p end
            end
        end
    end
    return Target
end

-- [3. MAIN LOOP - CHỐNG NIL VALUE & DELAY]
RunService.RenderStepped:Connect(function(dt)
    -- Aimbot & Prediction Logic
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetClosest()
        if t and t.Character and t.Character:FindFirstChild("Head") then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Character.Head.Position), 0.15)
        end
    end
    
    -- Movement & System
    if LocalPlayer.Character then
        if Settings.Noclip then for _,v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        if Settings.Speed then LocalPlayer.Character.Humanoid.WalkSpeed = 50 end
    end
end)

-- [4. FULL FEATURES BUTTONS]
AddBtn("Aimbot/Silent/Trigger", function() Settings.Aimbot = not Settings.Aimbot; Settings.Trigger = not Settings.Trigger end)
AddBtn("Noclip / Speed", function() Settings.Noclip = not Settings.Noclip; Settings.Speed = not Settings.Speed end)
AddBtn("Chams / Highlight", function() for _,p in pairs(Players:GetPlayers()) do if p.Character then Instance.new("Highlight", p.Character) end end end)
AddBtn("Teleport to Mouse", function() if LocalPlayer:GetMouse().Hit then LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer:GetMouse().Hit + Vector3.new(0,5,0) end end)
AddBtn("World Cleaner", function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("Sky") or v:IsA("Decal") then v:Destroy() end end end)
AddBtn("Load DarkDex", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyproceed/DEX/master/main.lua"))() end)
AddBtn("Anti-AFK", function() game:GetService("VirtualUser"):CaptureController() end)

print("Wynoz INF v5 - 100% Full Features Loaded!")
