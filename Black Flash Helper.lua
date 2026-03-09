
local player = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local slowMo = false
local hotkey = Enum.KeyCode.LeftShift

local originalWalkSpeed = 16
local originalJumpPower = 50
local slowWalkSpeed = 6
local slowJumpPower = 30
local animSpeed = 0.3

local connection
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local function showText()
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 600, 0, 150)
    label.Position = UDim2.new(0.5, -300, 0.5, -75)
    label.BackgroundTransparency = 1
    label.Text = "slowmo by muqo666"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = screenGui
    label.TextTransparency = 1

    spawn(function()
        for i = 1, 30 do
            label.TextTransparency = 1 - i / 30
            wait(0.02)
        end
        wait(1)
        for i = 1, 30 do
            label.TextTransparency = i / 30
            wait(0.02)
        end
        label:Destroy()
    end)
end

showText()

local function applySlowMo(character)
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then return end

    originalWalkSpeed = humanoid.WalkSpeed
    originalJumpPower = humanoid.JumpPower
    humanoid.WalkSpeed = slowWalkSpeed
    humanoid.JumpPower = slowJumpPower

    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        track:AdjustSpeed(animSpeed)
    end

    if connection then connection:Disconnect() end
    connection = animator.AnimationPlayed:Connect(function(track)
        track:AdjustSpeed(animSpeed)
    end)
end

local function revertSlowMo(character)
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            track:AdjustSpeed(1)
        end
    end
    if connection then
        connection:Disconnect()
        connection = nil
    end
    humanoid.WalkSpeed = originalWalkSpeed
    humanoid.JumpPower = originalJumpPower
end

uis.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == hotkey then
        slowMo = not slowMo
        local char = player.Character
        if slowMo then
            applySlowMo(char)
        else
            revertSlowMo(char)
        end
    end
end)

player.CharacterAdded:Connect(function(char)
    if slowMo then
        char:WaitForChild("Humanoid")
        applySlowMo(char)
    end
end)
