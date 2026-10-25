-- ==========================================
-- PROJECT: CLOVER RPG - HYBRID AUTO SYSTEM
-- Target: Xeno Executor / In-Game Lua (Fixed)
-- ==========================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Hapus GUI lama jika script dieksekusi ulang
if CoreGui:FindFirstChild("CloverRPGGUI") then
    CoreGui.CloverRPGGUI:Destroy()
end

-- Buat ScreenGui Utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CloverRPGGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Frame Utama
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 400)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(11, 14, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 240, 255)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundTransparency = 1
TitleBar.Text = "  CLOVER RPG - AUTO FARM & QUEST HUB"
TitleBar.TextColor3 = Color3.fromRGB(0, 240, 255)
TitleBar.TextSize = 14
TitleBar.Font = Enum.Font.Code
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Parent = MainFrame

local HeaderDivider = Instance.new("Frame")
HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
HeaderDivider.Position = UDim2.new(0, 0, 0, 45)
HeaderDivider.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
HeaderDivider.BorderSizePixel = 0
HeaderDivider.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 45)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.Code
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Size = UDim2.new(1, -20, 1, -60)
ContentContainer.Position = UDim2.new(0, 10, 0, 55)
ContentContainer.BackgroundTransparency = 1
ContentContainer.CanvasSize = UDim2.new(0, 0, 1.8, 0)
ContentContainer.ScrollBarThickness = 4
ContentContainer.Parent = MainFrame

local function CreateButton(name, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(20, 26, 38)
    btn.TextColor3 = Color3.fromRGB(200, 220, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.Code
    btn.Text = "  > " .. name
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = ContentContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

local autoFarmActive = false
local autoQuestActive = false

-- 1. Fitur Auto Farm (Diperbaiki kodenya)
CreateButton("Toggle Auto Farm (Target Nearest Enemy)", 10, function()
    autoFarmActive = not autoFarmActive
    print("[CloverRPG] Auto Farm Status: " .. tostring(autoFarmActive))
    
    task.spawn(function()
        while autoFarmActive do
            task.wait(0.5)
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    local nearestEnemy, shortestDist = nil, math.huge
                    
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                            if obj.Parent ~= char and obj ~= char then
                                local dist = (hrp.Position - obj.HumanoidRootPart.Position).Magnitude
                                if dist < shortestDist then
                                    shortestDist = dist
                                    nearestEnemy = obj.HumanoidRootPart
                                end
                            end
                        end
                    end
                    
                    if nearestEnemy then
                        hrp.CFrame = nearestEnemy.CFrame * CFrame.new(0, 0, 3)
                    end
                end
            end)
        end
    end)
end)

-- 2. Fitur Auto Quest
CreateButton("Toggle Auto Quest (Accept/Complete)", 60, function()
    autoQuestActive = not autoQuestActive
    print("[CloverRPG] Auto Quest Status: " .. tostring(autoQuestActive))
    
    task.spawn(function()
        while autoQuestActive do
            task.wait(2)
            pcall(function()
                for _, npc in ipairs(workspace:GetDescendants()) do
                    if npc:FindFirstChild("Humanoid") then
                        local nameLower = string.lower(npc.Name)
                        if string.find(nameLower, "quest") or string.find(nameLower, "npc") then
                            local char = LocalPlayer.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                char.HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
                                for _, prompt in ipairs(npc:GetDescendants()) do
                                    if prompt:IsA("ProximityPrompt") then
                                        fireproximityprompt(prompt)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

-- 3. Fitur Speed Hack
local speedActive = false
CreateButton("Toggle Movement Speed Boost (50)", 110, function()
    speedActive = not speedActive
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speedActive and 50 or 16
    end
end)

-- 4. Infinite Jump
local infJumpConnection
CreateButton("Toggle Infinite Jump", 160, function()
    local UserInputService = game:GetService("UserInputService")
    if not infJumpConnection then
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        print("[CloverRPG] Infinite Jump Enabled")
    else
        infJumpConnection:Disconnect()
        infJumpConnection = nil
        print("[CloverRPG] Infinite Jump Disabled")
    end
end)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 1, -30)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Clover RPG Script Loaded Successfully"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Code
StatusLabel.Parent = MainFrame

print("Clover RPG Automation Script Loaded!")