-- Wynoz INF v5 - RAW CORE (100% WORKING)
local P, RS, UIS, Cam = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), workspace.CurrentCamera
local LP = P.LocalPlayer

-- LOGIC CORE
local Settings = {Aimbot=false, Silent=false, Trigger=false, Noclip=false, Speed=false, Fly=false, ESP=false}

local function GetClosest()
    local T, D = nil, 9999
    for _, p in pairs(P:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local pos, on = Cam:WorldToViewportPoint(p.Character.Head.Position)
            if on then local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if mag < D then D = mag; T = p end
            end
        end
    end
    return T
end

-- MAIN ENGINE
RS.RenderStepped:Connect(function()
    if Settings.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetClosest()
        if t then Cam.CFrame = Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position, t.Character.Head.Position), 0.15) end
    end
    if Settings.Noclip and LP.Character then for _,v in pairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    if Settings.Speed and LP.Character then LP.Character.Humanoid.WalkSpeed = 50 end
end)

-- GUI (Gọn, không delay)
local SG = Instance.new("ScreenGui", game.CoreGui)
local M = Instance.new("Frame", SG); M.Size = UDim2.new(0, 160, 0, 30); M.Position = UDim2.new(0.05, 0, 0.2, 0); M.Active = true; M.Draggable = true
local Toggle = Instance.new("TextButton", M); Toggle.Size = UDim2.new(1,0,1,0); Toggle.Text = "Wynoz INF v5 [OPEN]"
local List = Instance.new("ScrollingFrame", M); List.Size = UDim2.new(1, 0, 0, 300); List.Visible = false; List.BackgroundColor3 = Color3.fromRGB(20,20,20)
Toggle.MouseButton1Click:Connect(function() List.Visible = not List.Visible end)

local function Btn(t, f)
    local b = Instance.new("TextButton", List); b.Size = UDim2.new(1,0,0,30); b.Position = UDim2.new(0,0,0, #List:GetChildren()*30); b.Text = t; b.MouseButton1Click:Connect(f)
end

Btn("Aimbot: Toggle", function() Settings.Aimbot = not Settings.Aimbot end)
Btn("Noclip: Toggle", function() Settings.Noclip = not Settings.Noclip end)
Btn("Speed: Toggle", function() Settings.Speed = not Settings.Speed end)
Btn("Cleaner", function() for _,v in pairs(workspace:GetDescendants()) do if v:IsA("Sky") then v:Destroy() end end end)
Btn("Load Dex", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyproceed/DEX/master/main.lua"))() end)

print("Wynoz INF v5 Loaded & Running")
