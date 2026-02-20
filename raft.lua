-- ======================================
-- 50 DAYS ON A RAFT - AUTO COLLECT FINAL FIX
-- ======================================

-- ===== SERVICES =====
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ===== CHARACTER SAFE =====
local char, hrp
local function bindChar()
    char = player.Character or player.CharacterAdded:Wait()
    hrp = char:WaitForChild("HumanoidRootPart")

    -- reset state saat respawn / masuk game
    Busy = false
    if AutoCollect then
        task.wait(1)
        StartCFrame = hrp.CFrame
    end
end

player.CharacterAdded:Connect(bindChar)
bindChar()

-- ===== STATE =====
AutoCollect = false
StartCFrame = nil
Busy = false

-- ===== SETTINGS (BOLEH EDIT) =====
local SEARCH_RADIUS = 60
local LOOP_DELAY = 0.5

-- ======================================
-- GUI
-- ======================================
local gui = Instance.new("ScreenGui")
gui.Name = "RaftAutoUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0,55,0,55)
toggleBtn.Position = UDim2.new(0,10,0.5,-27)
toggleBtn.Text = "⚓"
toggleBtn.TextSize = 26
toggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.BorderSizePixel = 0
toggleBtn.Active = true
toggleBtn.Draggable = true

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,240,0,150)
frame.Position = UDim2.new(0,80,0.5,-75)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Visible = false
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
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

toggleBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

autoBtn.MouseButton1Click:Connect(function()
    AutoCollect = not AutoCollect
    autoBtn.Text = AutoCollect and "Auto Collect : ON" or "Auto Collect : OFF"

    if AutoCollect and hrp then
        StartCFrame = hrp.CFrame
        Busy = false
    else
        Busy = false
    end
end)

-- ======================================
-- FIND NEAREST PROMPT (FIXED)
-- ======================================
local function getNearestPrompt()
    if not hrp then return end

    local bestPrompt, bestPart
    local shortest = SEARCH_RADIUS

    for _,p in ipairs(workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Enabled then
            local c = p.Parent
            local part =
                (c:IsA("BasePart") and c)
                or c:FindFirstChildWhichIsA("BasePart")
                or (c.Parent and c.Parent:FindFirstChildWhichIsA("BasePart"))

            if part then
                local dist = (part.Position - hrp.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    bestPrompt = p
                    bestPart = part
                end
            end
        end
    end

    return bestPrompt, bestPart
end

-- ======================================
-- MAIN LOOP (ANTI STUCK)
-- ======================================
task.spawn(function()
    while task.wait(LOOP_DELAY) do
        if not AutoCollect or Busy or not hrp or not StartCFrame then
            continue
        end

        local prompt, part = getNearestPrompt()
        if prompt and part then
            Busy = true

            pcall(function()
                -- teleport ke item
                hrp.CFrame = part.CFrame + Vector3.new(0,2,0)
                task.wait(0.2)

                -- hold prompt
                fireproximityprompt(prompt, prompt.HoldDuration)

                task.wait(0.25)

                -- balik ke posisi awal
                if hrp then
                    hrp.CFrame = StartCFrame
                end
            end)

            Busy = false
        end
    end
end)

print("✅ Auto Collect FINAL FIX loaded")
