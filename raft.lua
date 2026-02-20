-- ======================================
-- 50 DAYS ON A RAFT - BUTTON COLLECT SYSTEM
-- ======================================

-- ===== SERVICES =====
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

-- ===== SETTINGS =====
local SEARCH_RADIUS = 120
local LOOP_DELAY = 0.2

-- ======================================
-- GUI
-- ======================================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "RaftButtonUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,230)
frame.Position = UDim2.new(0,20,0.5,-115)
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

-- ======================================
-- BUTTON CREATOR
-- ======================================
local function createBtn(text, y)
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

local btnA = createBtn("A - Collect Loot", 50)
local btnB = createBtn("B - Collect Barrel", 95)
local btnC = createBtn("C - Collect Structure", 140)
local btnD = createBtn("D - Collect ALL", 185)

-- ======================================
-- COLLECT FUNCTION
-- ======================================
local function collect(filterFunc)
    task.spawn(function()
        for _,p in ipairs(workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") and p.Enabled then
                local part =
                    p.Parent:IsA("BasePart") and p.Parent
                    or p.Parent:FindFirstChildWhichIsA("BasePart")
                    or (p.Parent.Parent and p.Parent.Parent:FindFirstChildWhichIsA("BasePart"))

                if part and hrp then
                    local dist = (part.Position - hrp.Position).Magnitude
                    if dist <= SEARCH_RADIUS and filterFunc(p, part) then
                        pcall(function()
                            hrp.CFrame = part.CFrame + Vector3.new(0,2,0)
                            task.wait(0.15)
                            fireproximityprompt(p, p.HoldDuration)
                            task.wait(LOOP_DELAY)
                        end)
                    end
                end
            end
        end
    end)
end

-- ======================================
-- BUTTON LOGIC
-- ======================================

-- A - Loot kecil
btnA.MouseButton1Click:Connect(function()
    collect(function(prompt)
        return prompt.Name:lower():find("loot")
    end)
end)

-- B - Barrel
btnB.MouseButton1Click:Connect(function()
    collect(function(prompt)
        return prompt.Parent.Name:lower():find("barrel")
    end)
end)

-- C - Bench / Chest / Structure
btnC.MouseButton1Click:Connect(function()
    collect(function(prompt)
        local n = prompt.Parent.Name:lower()
        return n:find("bench") or n:find("chest") or n:find("crate")
    end)
end)

-- D - ALL
btnD.MouseButton1Click:Connect(function()
    collect(function()
        return true
    end)
end)

print("✅ Button Collect System Loaded")
