-- ======================================
-- SPEED (0-100) + FLY SCRIPT
-- ======================================

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
local FlyOn = false
local CurrentSpeed = 16

-- ======================================
-- GUI
-- ======================================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "SpeedFlyUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,240)
frame.Position = UDim2.new(0,20,0.5,-120)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "Speed & Fly"
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
local flyBtn   = makeBtn("Fly : OFF", 90)

-- ======================================
-- SPEED SLIDER (0-100)
-- ======================================
local sliderFrame = Instance.new("Frame", frame)
sliderFrame.Size = UDim2.new(1,-20,0,50)
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
fill.Size = UDim2.new(0.16,0,1,0) -- default 16%
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

-- ===== SLIDER INPUT =====
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

bar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        updateSpeed(input.Position.X)
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        updateSpeed(input.Position.X)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ======================================
-- FLY LOGIC
-- ======================================
local bodyGyro, bodyVel, flyConn
local FLY_SPEED = 60

local function startFly()
    FlyOn = true
    flyBtn.Text = "Fly : ON"

    bodyGyro = Instance.new("BodyGyro", hrp)
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)

    bodyVel = Instance.new("BodyVelocity", hrp)
    bodyVel.MaxForce = Vector3.new(9e9,9e9,9e9)

    flyConn = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        bodyGyro.CFrame = cam.CFrame

        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += cam.CFrame.UpVector end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= cam.CFrame.UpVector end

        bodyVel.Velocity = move * FLY_SPEED
    end)
end

local function stopFly()
    FlyOn = false
    flyBtn.Text = "Fly : OFF"
    if flyConn then flyConn:Disconnect() end
    if bodyGyro then bodyGyro:Destroy() end
    if bodyVel then bodyVel:Destroy() end
end

flyBtn.MouseButton1Click:Connect(function()
    if FlyOn then
        stopFly()
    else
        startFly()
    end
end)

print("✅ Speed (0–100) + Fly Loaded")

-- =====================================================
-- AUTO COLLECT WOOD - 50 DAYS ON A RAFT
-- =====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char, hrp

-- ===== CHARACTER SAFE =====
local function bindChar()
    char = player.Character or player.CharacterAdded:Wait()
    hrp = char:WaitForChild("HumanoidRootPart")
end
bindChar()
player.CharacterAdded:Connect(bindChar)

-- ===== STATE =====
local AutoWood = false
local Busy = false

-- ===== SETTINGS =====
local SEARCH_RADIUS = 120
local TOUCH_DELAY = 0.3
local LOOP_DELAY = 1.2

-- =====================================================
-- GUI
-- =====================================================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "AutoWoodUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,150)
frame.Position = UDim2.new(0,20,0.5,-75)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "Auto Collect Wood"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1,-20,0,45)
toggle.Position = UDim2.new(0,10,0,50)
toggle.Text = "Auto Wood : OFF"
toggle.Font = Enum.Font.Gotham
toggle.TextSize = 14
toggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BorderSizePixel = 0
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,8)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,-20,0,25)
status.Position = UDim2.new(0,10,0,105)
status.BackgroundTransparency = 1
status.Text = "Status : Idle"
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.TextColor3 = Color3.fromRGB(200,200,200)

-- =====================================================
-- CORE LOGIC
-- =====================================================

local function isWood(obj)
    local name = obj.Name:lower()
    return name:find("wood")
        or name:find("plank")
        or name:find("log")
end

local function collectWood()
    if Busy or not hrp then return end
    Busy = true
    status.Text = "Status : Collecting Wood"

    local startCF = hrp.CFrame

    for _,obj in ipairs(workspace:GetDescendants()) do
        if not AutoWood then break end

        if obj:IsA("BasePart") and isWood(obj) then
            local dist = (obj.Position - hrp.Position).Magnitude
            if dist <= SEARCH_RADIUS then
                pcall(function()
                    -- teleport nempel (touch pickup)
                    hrp.CFrame = obj.CFrame * CFrame.new(0, 0, -0.5)
                    task.wait(TOUCH_DELAY)
                end)
            end
        end
    end

    -- balik ke posisi awal
    if hrp then
        hrp.CFrame = startCF
    end

    Busy = false
    status.Text = "Status : Idle"
end

-- =====================================================
-- AUTO LOOP
-- =====================================================
task.spawn(function()
    while task.wait(LOOP_DELAY) do
        if AutoWood then
            collectWood()
        end
    end
end)

-- =====================================================
-- BUTTON
-- =====================================================
toggle.MouseButton1Click:Connect(function()
    AutoWood = not AutoWood
    toggle.Text = AutoWood and "Auto Wood : ON" or "Auto Wood : OFF"
    status.Text = AutoWood and "Status : Running" or "Status : Idle"
    Busy = false
end)

print("✅ Auto Collect Wood Loaded")
