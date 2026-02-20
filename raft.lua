-- =====================================================
-- 50 DAYS ON A RAFT - AUTO COLLECT (REAL FIX)
-- =====================================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ===== CHARACTER =====
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
local DisabledPrompts = {}

-- ===== SETTINGS =====
local SCAN_RADIUS = {25, 50, 80, 120, 160}
local TELEPORT_DELAY = 0.35
local LOOP_DELAY = 1

-- =====================================================
-- GUI
-- =====================================================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "RaftAutoCollectUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,160)
frame.Position = UDim2.new(0,20,0.5,-80)
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

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1,-20,0,45)
toggle.Position = UDim2.new(0,10,0,50)
toggle.Text = "Auto Collect : OFF"
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

local function getPart(prompt)
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

-- 🔥 MATIKAN PROMPT NON-COLLECT
local function disableOtherPrompts()
    DisabledPrompts = {}
    for _,p in ipairs(workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Enabled and p.ActionText ~= "Collect" then
            p.Enabled = false
            table.insert(DisabledPrompts, p)
        end
    end
end

local function restorePrompts()
    for _,p in ipairs(DisabledPrompts) do
        if p then
            p.Enabled = true
        end
    end
    DisabledPrompts = {}
end

-- =====================================================
-- COLLECT LOOP (REAL WORKING)
-- =====================================================
local function collectLoop()
    if Busy or not hrp then return end
    Busy = true
    status.Text = "Status : Collecting"

    disableOtherPrompts()

    for _,radius in ipairs(SCAN_RADIUS) do
        if not AutoCollect then break end

        for _,p in ipairs(workspace:GetDescendants()) do
            if not AutoCollect then break end

            if p:IsA("ProximityPrompt")
            and p.Enabled
            and p.ActionText == "Collect" then

                local part = getPart(p)
                if part then
                    local dist = (part.Position - hrp.Position).Magnitude
                    if dist <= radius then
                        pcall(function()
                            hrp.CFrame = part.CFrame * CFrame.new(0,0,-0.5)
                            task.wait(TELEPORT_DELAY)
                            fireproximityprompt(p, p.HoldDuration)
                            task.wait(0.4)
                        end)
                    end
                end
            end
        end
        task.wait(0.25)
    end

    restorePrompts()
    Busy = false
    status.Text = "Status : Idle"
end

-- =====================================================
-- AUTO LOOP
-- =====================================================
task.spawn(function()
    while task.wait(LOOP_DELAY) do
        if AutoCollect and not Busy then
            collectLoop()
        end
    end
end)

-- =====================================================
-- BUTTON
-- =====================================================
toggle.MouseButton1Click:Connect(function()
    AutoCollect = not AutoCollect
    toggle.Text = AutoCollect and "Auto Collect : ON" or "Auto Collect : OFF"
    status.Text = AutoCollect and "Status : Running" or "Status : Idle"
    Busy = false
end)

print("✅ AUTO COLLECT REAL FIX LOADED")
