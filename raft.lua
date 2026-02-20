-- =================================================
-- 50 DAYS ON A RAFT - COMBAT & SURVIVAL SCRIPT
-- =================================================

-----------------------
-- BASIC SETUP
-----------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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
-- SETTINGS (EDITABLE)
-----------------------
local KILL_RADIUS = 15        -- jarak auto kill (studs)
local KILL_INTERVAL = 0.2     -- kecepatan cek musuh
local ENABLE_ANTIDAMAGE = true

-----------------------
-- STATE
-----------------------
local AutoKill = false
local SpeedValue = 16 -- default Roblox

-----------------------
-- UI
-----------------------
local gui = Instance.new("ScreenGui")
gui.Name = "RaftCombatUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

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

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,260,0,210)
frame.Position = UDim2.new(0,80,0.5,-105)
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

-- Auto Kill Button
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

-- Speed Label
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1,-20,0,25)
speedLabel.Position = UDim2.new(0,10,0,95)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: 16"
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 13
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.Parent = frame

-- Speed Slider (0-100)
local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1,-20,0,12)
sliderBg.Position = UDim2.new(0,10,0,125)
sliderBg.BackgroundColor3 = Color3.fromRGB(60,60,60)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = frame
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0,6)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0,0,1,0)
sliderFill.BackgroundColor3 = Color3.fromRGB(120,180,255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0,6)

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

-- Slider drag
local dragging = false
sliderBg.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
end)
sliderBg.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
RunService.RenderStepped:Connect(function()
    if dragging then
        local mouse = game:GetService("UserInputService"):GetMouseLocation().X
        local pos = math.clamp((mouse - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(pos,0,1,0)
        SpeedValue = math.floor(pos * 100)
        speedLabel.Text = "Speed: "..SpeedValue
        hum.WalkSpeed = SpeedValue
    end
end)

-----------------------
-- ANTI DAMAGE (REALISTIC)
-----------------------
if ENABLE_ANTIDAMAGE then
    hum.HealthChanged:Connect(function(hp)
        if hp < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end)
end

-----------------------
-- AUTO KILL (NEARBY)
-----------------------
task.spawn(function()
    while task.wait(KILL_INTERVAL) do
        if AutoKill and hrp then
            for _,npc in pairs(workspace:GetDescendants()) do
                local nh = npc:FindFirstChildOfClass("Humanoid")
                local nhrp = npc:FindFirstChild("HumanoidRootPart")
                if nh and nhrp and npc ~= char and nh.Health > 0 then
                    local dist = (nhrp.Position - hrp.Position).Magnitude
                    if dist <= KILL_RADIUS then
                        -- attempt client-side damage
                        pcall(function()
                            nh.Health = 0
                        end)
                    end
                end
            end
        end
    end
end)

pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Loaded",
        Text = "⚔️ Auto Kill | ❤️ Anti-Damage | ⚡ Speed",
        Duration = 5
    })
end)

print("✅ Combat & Survival script loaded")
