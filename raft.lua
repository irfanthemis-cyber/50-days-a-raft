-- =================================================
-- 50 DAYS ON A RAFT - COMBAT & SURVIVAL (FINAL FIX)
-- =================================================

-----------------------
-- SERVICES
-----------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-----------------------
-- PLAYER SETUP
-----------------------
local player = Players.LocalPlayer
local char, hrp, hum

local function bindChar()
    char = player.Character or player.CharacterAdded:Wait()
    hrp = char:WaitForChild("HumanoidRootPart")
    hum = char:WaitForChild("Humanoid")
end
bindChar()
player.CharacterAdded:Connect(bindChar)

-----------------------
-- SETTINGS
-----------------------
local KILL_RADIUS = 15        -- jarak auto kill
local KILL_DELAY = 0.2
local ENABLE_ANTIDAMAGE = true

-----------------------
-- STATE
-----------------------
local AutoKill = false

-----------------------
-- UI ROOT
-----------------------
local gui = Instance.new("ScreenGui")
gui.Name = "RaftCombatFinal"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-----------------------
-- TOGGLE BUTTON
-----------------------
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0,55,0,55)
toggleBtn.Position = UDim2.new(0,10,0.5,-27)
toggleBtn.Text = "⚔️"
toggleBtn.TextSize = 22
toggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.BorderSizePixel = 0
toggleBtn.Active = true
toggleBtn.Draggable = true
toggleBtn.Parent = gui

-----------------------
-- MAIN FRAME
-----------------------
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,260,0,220)
frame.Position = UDim2.new(0,80,0.5,-110)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Visible = false
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "Combat & Survival"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)
title.Parent = frame

-----------------------
-- AUTO KILL BUTTON
-----------------------
local killBtn = Instance.new("TextButton")
killBtn.Size = UDim2.new(1,-20,0,40)
killBtn.Position = UDim2.new(0,10,0,45)
killBtn.Text = "Auto Kill : OFF"
killBtn.Font = Enum.Font.Gotham
killBtn.TextSize = 14
killBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
killBtn.TextColor3 = Color3.new(1,1,1)
killBtn.BorderSizePixel = 0
killBtn.Parent = frame
Instance.new("UICorner", killBtn).CornerRadius = UDim.new(0,8)

-----------------------
-- SPEED LABEL
-----------------------
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1,-20,0,22)
speedLabel.Position = UDim2.new(0,10,0,95)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: 16"
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 13
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.Parent = frame

-----------------------
-- SPEED SLIDER
-----------------------
local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1,-20,0,14)
sliderBg.Position = UDim2.new(0,10,0,125)
sliderBg.BackgroundColor3 = Color3.fromRGB(60,60,60)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = frame
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0,7)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.16,0,1,0)
sliderFill.BackgroundColor3 = Color3.fromRGB(120,180,255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0,7)

-----------------------
-- UI LOGIC
-----------------------
toggleBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

killBtn.MouseButton1Click:Connect(function()
    AutoKill = not AutoKill
    killBtn.Text = AutoKill and "Auto Kill : ON" or "Auto Kill : OFF"
end)

-----------------------
-- SPEED SLIDER LOGIC (FIXED)
-----------------------
local dragging = false

local function updateSpeed(inputX)
    local pos = math.clamp(
        (inputX - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X,
        0, 1
    )
    local speed = math.floor(pos * 100)
    sliderFill.Size = UDim2.new(pos,0,1,0)
    speedLabel.Text = "Speed: "..speed
    hum.WalkSpeed = speed
end

sliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        updateSpeed(input.Position.X)
    end
end)

sliderBg.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        updateSpeed(input.Position.X)
    end
end)

-----------------------
-- ANTI DAMAGE
-----------------------
if ENABLE_ANTIDAMAGE then
    hum.HealthChanged:Connect(function(hp)
        if hp < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end)
end

-----------------------
-- AUTO KILL LOOP
-----------------------
task.spawn(function()
    while task.wait(KILL_DELAY) do
        if AutoKill and hrp then
            for _,npc in pairs(workspace:GetDescendants()) do
                local nh = npc:FindFirstChildOfClass("Humanoid")
                local nhrp = npc:FindFirstChild("HumanoidRootPart")
                if nh and nhrp and npc ~= char and nh.Health > 0 then
                    if (nhrp.Position - hrp.Position).Magnitude <= KILL_RADIUS then
                        pcall(function()
                            nh.Health = 0
                        end)
                    end
                end
            end
        end
    end
end)

-----------------------
-- NOTIFICATION
-----------------------
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Loaded",
        Text = "⚔️ Auto Kill | ❤️ Anti Damage | ⚡ Speed 0-100",
        Duration = 5
    })
end)

print("✅ FINAL COMBAT SCRIPT LOADED")
