
local player = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local aimEnabled = false
local smoothness = 0.9

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local function showWord(word, duration)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 600, 0, 150)
    label.Position = UDim2.new(0.5, -300, 0.5, -75)
    label.BackgroundTransparency = 1
    label.Text = word
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = screenGui
    label.TextTransparency = 1

    local fadeTime = duration / 3
    for i = 1, 30 do
        label.TextTransparency = 1 - i / 30
        wait(fadeTime / 30)
    end
    label.TextTransparency = 0
    wait(fadeTime)
    for i = 1, 30 do
        label.TextTransparency = i / 30
        wait(fadeTime / 30)
    end
    label:Destroy()
end

spawn(function()
    showWord("legit", 5)
    showWord("by", 5)
    showWord("muqo666", 5)
    screenGui:Destroy()
end)

local function getClosestPlayer()
    local closest, shortest = nil, math.huge
    for _, other in ipairs(game:GetService("Players"):GetPlayers()) do
        if other ~= player and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
            local root = other.Character.HumanoidRootPart
            local dist = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortest then
                shortest = dist
                closest = other
            end
        end
    end
    return closest
end

uis.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E then
        aimEnabled = not aimEnabled
    end
end)

runService.Heartbeat:Connect(function()
    if aimEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            local desired = CFrame.lookAt(camera.CFrame.Position, targetPos)
            camera.CFrame = camera.CFrame:Lerp(desired, smoothness)
        end
    end
end)
