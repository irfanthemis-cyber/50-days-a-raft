-- =====================================================
-- 50 DAYS ON A RAFT - COLLECT ONLY (VIDEO FIX)
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

-- ===== SETTINGS =====
local STEP_RADIUS = {20, 40, 70, 100, 150}
local TELEPORT_DELAY = 0.35   -- mobile safe
local ACTION_DELAY = 0.4

-- =====================================================
-- GUI
-- =====================================================
local gui = Instance.new("ScreenGui")
gui.Name = "RaftCollectUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

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

local btnA = makeBtn("A - Collect Loot", 50)
local btnB = makeBtn("B - Disabled", 95)
local btnC = makeBtn("C - Disabled", 140)
local btnD = makeBtn("D - Collect ALL", 185)

-- =====================================================
-- CORE FUNCTIONS (SESUI VIDEO)
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

-- ===== COLLECT ONLY (TIDAK OPEN BENCH) =====
local function collectOnly()
    task.spawn(function()
        if not hrp then return end

        for _,radius in ipairs(STEP_RADIUS) do
            for _,p in ipairs(workspace:GetDescendants()) do
                if p:IsA("ProximityPrompt")
                and p.Enabled
                and p.ActionText == "Collect" then

                    local part = getBasePart(p)
                    if part then
                        local dist = (part.Position - hrp.Position).Magnitude
                        if dist <= radius then
                            pcall(function()
                                -- teleport nempel ke item
                                hrp.CFrame = part.CFrame * CFrame.new(0,0,-0.5)
                                task.wait(TELEPORT_DELAY)

                                fireproximityprompt(p, p.HoldDuration)
                                task.wait(ACTION_DELAY)
                            end)
                        end
                    end
                end
            end
            task.wait(0.3)
        end
    end)
end

-- =====================================================
-- BUTTON LOGIC
-- =====================================================

-- A - COLLECT SAJA
btnA.MouseButton1Click:Connect(function()
    collectOnly()
end)

-- B & C DIMATIKAN (BIAR TIDAK GANGGU)
btnB.AutoButtonColor = false
btnC.AutoButtonColor = false

-- D - SAMA SEPERTI A (COLLECT ALL YANG VALID)
btnD.MouseButton1Click:Connect(function()
    collectOnly()
end)

print("✅ 50 Days on a Raft - COLLECT ONLY SCRIPT LOADED")
