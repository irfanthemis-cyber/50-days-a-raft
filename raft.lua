-- =====================================================
-- 50 DAYS ON A RAFT - FINAL BUTTON COLLECT SCRIPT
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
local MAX_RADIUS = 150
local STEP_RADIUS = {25, 50, 80, 120, 150}
local ACTION_DELAY = 0.25

-- =====================================================
-- GUI
-- =====================================================
local gui = Instance.new("ScreenGui")
gui.Name = "RaftFinalUI"
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

local btnA = makeBtn("A - Collect (Collect)", 50)
local btnB = makeBtn("B - Open (Bench / Chest)", 95)
local btnC = makeBtn("C - Use / Interact", 140)
local btnD = makeBtn("D - Collect ALL", 185)

-- =====================================================
-- CORE FUNCTIONS (GAME-ACCURATE)
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

local function interactByAction(actionFilter)
    task.spawn(function()
        if not hrp then return end

        for _,radius in ipairs(STEP_RADIUS) do
            for _,p in ipairs(workspace:GetDescendants()) do
                if p:IsA("ProximityPrompt") and p.Enabled then
                    if actionFilter(p) then
                        local part = getBasePart(p)
                        if part then
                            local dist = (part.Position - hrp.Position).Magnitude
                            if dist <= radius then
                                pcall(function()
                                    -- TELEPORT SANGAT DEKAT (WAJIB DI GAME INI)
                                    hrp.CFrame = part.CFrame * CFrame.new(0,0,-1)
                                    task.wait(0.15)
                                    fireproximityprompt(p, p.HoldDuration)
                                    task.wait(ACTION_DELAY)
                                end)
                            end
                        end
                    end
                end
            end
            task.wait(0.2)
        end
    end)
end

-- =====================================================
-- BUTTON LOGIC (SESUAI GAME ASLI)
-- =====================================================

-- A - Collect (barrel, floating loot, crate)
btnA.MouseButton1Click:Connect(function()
    interactByAction(function(p)
        return p.ActionText == "Collect"
    end)
end)

-- B - Open (crafting bench, chest, storage)
btnB.MouseButton1Click:Connect(function()
    interactByAction(function(p)
        return p.ActionText == "Open"
    end)
end)

-- C - Use / Interact (campfire, furnace, purifier)
btnC.MouseButton1Click:Connect(function()
    interactByAction(function(p)
        return p.ActionText ~= "Collect" and p.ActionText ~= "Open"
    end)
end)

-- D - ALL
btnD.MouseButton1Click:Connect(function()
    interactByAction(function()
        return true
    end)
end)

print("✅ 50 Days on a Raft - FINAL SCRIPT LOADED")
