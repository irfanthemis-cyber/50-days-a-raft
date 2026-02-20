-- =====================================================
-- AUTO COLLECT WOOD (WATER PICKUP FIX)
-- 50 DAYS ON A RAFT
-- =====================================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local char, hrp
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
local SEARCH_RADIUS = 160
local TOUCH_TIME = 0.15
local LOOP_DELAY = 1.2

-- =====================================================
-- GUI
-- =====================================================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "AutoWoodWaterUI"
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
title.Text = "Auto Collect Wood (Water)"
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

local function isWood(part)
    local n = part.Name:lower()
    return n:find("wood") or n:find("plank") or n:find("log")
end

local function collectWoodWater()
    if Busy or not hrp then return end
    Busy = true
    status.Text = "Status : Collecting Wood"

    local root = hrp

    for _,obj in ipairs(workspace:GetDescendants()) do
        if not AutoWood then break end

        if obj:IsA("BasePart") and isWood(obj) then
            local dist = (obj.Position - root.Position).Magnitude
            if dist <= SEARCH_RADIUS then
                pcall(function()
                    -- teleport dekat wood
                    root.CFrame = obj.CFrame * CFrame.new(0,0,-0.3)
                    task.wait(0.1)

                    -- 🔥 SIMULASI SENTUHAN (INI KUNCI)
                    firetouchinterest(root, obj, 0)
                    task.wait(TOUCH_TIME)
                    firetouchinterest(root, obj, 1)

                    task.wait(0.25)
                end)
            end
        end
    end

    Busy = false
    status.Text = "Status : Idle"
end

-- =====================================================
-- LOOP
-- =====================================================
task.spawn(function()
    while task.wait(LOOP_DELAY) do
        if AutoWood then
            collectWoodWater()
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

print("✅ Auto Collect Wood (Water) FIXED LOADED")
