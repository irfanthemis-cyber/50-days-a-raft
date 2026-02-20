-- =====================================================
-- SPEED (0-100) + GOD MODE
-- =====================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char, hum, hrp

-- ===== CHARACTER SAFE =====
local function bindChar()
    char = player.Character or player.CharacterAdded:Wait()
    hum = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end
bindChar()
player.CharacterAdded:Connect(bindChar)

-- ===== STATE =====
local SpeedOn = false
local GodMode = false
local CurrentSpeed = 16
local MaxHealth = 100

-- =====================================================
-- GUI
-- =====================================================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "SpeedGodUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,270,0,260)
frame.Position = UDim2.new(0,20,0.5,-130)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "Speed & God Mode"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)

-- ======================================
-- BUTTON CREATOR
-- ======================================
local function makeBtn(text, y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1,-20,0,40)
    b.Position = UDim2.new(0,10,0,y)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    return b
end

local speedBtn = makeBtn("Speed : OFF", 45)
local godBtn   = makeBtn("God Mode : OFF", 90)

-- ======================================
-- SPEED SLIDER (0-100)
-- ======================================
local sliderFrame = Instance.new("Frame", frame)
sliderFrame.Size = UDim2.new(1,-20,0,60)
sliderFrame.Position = UDim2.new(0,10,0,140)
sliderFrame.BackgroundTransparency = 1

local speedLabel = Instance.new("TextLabel", sliderFrame)
speedLabel.Size = UDim2.new(1,0,0,20)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed : 16"
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14
speedLabel.TextColor3 = Color3.new(1,1,1)

local bar = Instance.new("Frame", sliderFrame)
bar.Size = UDim2.new(1,0,0,8)
bar.Position = UDim2.new(0,0,0,30)
bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
bar.BorderSizePixel = 0
Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

local fill = Instance.new("Frame", bar)
fill.Size = UDim2.new(0.16,0,1,0)
fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
fill.BorderSizePixel = 0
Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

-- ======================================
-- SPEED LOGIC
-- ======================================
speedBtn.MouseButton1Click:Connect(function()
    SpeedOn = not SpeedOn
    speedBtn.Text = SpeedOn and "Speed : ON" or "Speed : OFF"
    hum.WalkSpeed = SpeedOn and CurrentSpeed or 16
end)

local dragging = false
local function updateSpeed(x)
    local scale = math.clamp(
        (x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
        0, 1
    )
    CurrentSpeed = math.floor(scale * 100)
    fill.Size = UDim2.new(scale,0,1,0)
    speedLabel.Text = "Speed : "..CurrentSpeed
    if SpeedOn then
        hum.WalkSpeed = CurrentSpeed
    end
end

bar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        updateSpeed(i.Position.X)
    end
end)

UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch) then
        updateSpeed(i.Position.X)
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ======================================
-- GOD MODE LOGIC (ANTI DAMAGE)
-- ======================================
godBtn.MouseButton1Click:Connect(function()
    GodMode = not GodMode
    godBtn.Text = GodMode and "God Mode : ON" or "God Mode : OFF"

    if GodMode then
        MaxHealth = hum.MaxHealth
        hum.Health = MaxHealth
    end
end)

hum.HealthChanged:Connect(function(h)
    if GodMode and h < hum.MaxHealth then
        hum.Health = hum.MaxHealth
    end
end)

-- Anti instant kill
RunService.Stepped:Connect(function()
    if GodMode and hum then
        hum.Health = hum.MaxHealth
    end
end)

print("✅ Speed 0–100 + God Mode Loaded")
