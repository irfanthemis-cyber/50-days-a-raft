-- =====================================================
-- 50 DAYS ON A RAFT - AUTO COLLECT LOOP (SAFE VERSION)
-- =====================================================

-- ===== SERVICES =====
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ===== CHARACTER SAFE =====
local char, hrp
local function bindChar()
    char = player.Character or player.CharacterAdded:Wait()
    hrp = char:WaitForChild("HumanoidRootPart")
end
bindChar()
player.CharacterAdded:Connect(bindChar)

-- ===== STATE =====
local AutoCollect = false
local Busy = false

-- ===== SETTINGS =====
local STEP_RADIUS = {20, 40, 70, 100, 150}
local TELEPORT_DELAY = 0.35   -- mobile safe
local ACTION_DELAY = 0.4
local LOOP_DELAY = 1.0

-- =====================================================
-- GUI
-- =====================================================
local gui = Instance.new("ScreenGui")
gui.Name = "RaftAutoCollectUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,170)
frame.Position = UDim2.new(0,20,0.5,-85)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "50 Days on a Raft"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)

local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(1,-20,0,45)
autoBtn.Position = UDim2.new(0,10,0,55)
autoBtn.Text = "Auto Collect : OFF"
autoBtn.Font = Enum.Font.Gotham
autoBtn.TextSize = 14
autoBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
autoBtn.TextColor3 = Color3.new(1,1,1)
autoBtn.BorderSizePixel = 0
Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0,8)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,-20,0,30)
status.Position = UDim2.new(0,10,0,110)
status.BackgroundTransparency = 1
status.Text = "Status : Idle"
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.TextColor3 = Color3.fromRGB(200,200,200)

-- =====================================================
-- CORE FUNCTIONS
-- =====================================================

local function getBasePart(prompt)
    if prompt.Parent:IsA("BasePart") then
        return prompt.Parent
    end
    if prompt.Parent:IsA("Model") then
        return prompt.Parent:FindFirstChildWhichIsA("BasePart")
    end
    if prompt.Parent.Parent and prompt.Parent.Parent:IsA("Model") then
        return prompt.Parent.Parent:FindFirstChildWhichIsA("BasePart")
    end
end

local function collectNearby()
    if Busy or not hrp then return end
    Busy = true
    status.Text = "Status : Collecting..."

    for _,radius in ipairs(STEP_RADIUS) do
        if not AutoCollect then break end

        for _,p in ipairs(workspace:GetDescendants()) do
            if not AutoCollect then break end

            if p:IsA("ProximityPrompt")
            and p.Enabled
            and p.ActionText == "Collect" then

                local part = getBasePart(p)
                if part then
                    local dist = (part.Position - hrp.Position).Magnitude
                    if dist <= radius then
                        pcall(function()
                            hrp.CFrame = part.CFrame * CFrame.new(0,0,-0.5)
                            task.wait(TELEPORT_DELAY)

                            fireproximityprompt(p, p.HoldDuration)
                            task.wait(ACTION_DELAY)
                        end)
                    end
                end
            end
        end
        task.wait(0.25)
    end

    Busy = false
    status.Text = "Status : Idle"
end

-- =====================================================
-- MAIN AUTO LOOP
-- =====================================================
task.spawn(function()
    while task.wait(LOOP_DELAY) do
        if AutoCollect and not Busy then
            collectNearby()
        end
    end
end)

-- =====================================================
-- BUTTON
-- =====================================================
autoBtn.MouseButton1Click:Connect(function()
    AutoCollect = not AutoCollect
    autoBtn.Text = AutoCollect and "Auto Collect : ON" or "Auto Collect : OFF"
    status.Text = AutoCollect and "Status : Running..." or "Status : Idle"
    Busy = false
end)

print("✅ 50 Days on a Raft - AUTO COLLECT LOOP LOADED")
