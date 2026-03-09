
local player = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local lighting = game:GetService("Lighting")
local camera = workspace.CurrentCamera

local tripActive = false
local hotkey = Enum.KeyCode.L

local blur
local colorCorrection
local heartConnection
local originalFOV = camera.FieldOfView
local noise = 0

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local function createEffects()
    blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = lighting

    colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Contrast = 0.2
    colorCorrection.Saturation = 0.1
    colorCorrection.TintColor = Color3.fromRGB(255, 0, 255)
    colorCorrection.Parent = lighting
end

local function removeEffects()
    if blur then blur:Destroy() blur = nil end
    if colorCorrection then colorCorrection:Destroy() colorCorrection = nil end
end

local function startTrip()
    createEffects()
    originalFOV = camera.FieldOfView
    noise = 0

    -- Плавное нарастание эффектов
    spawn(function()
        for i = 1, 30 do
            if not tripActive then break end
            if blur then blur.Size = i / 3 end
            if colorCorrection then
                colorCorrection.Contrast = 0.1 + i/100
                colorCorrection.Saturation = 0.2 - i/150
            end
            wait(0.03)
        end
    end)

    -- Цикл искажений камеры
    heartConnection = runService.Heartbeat:Connect(function()
        if not tripActive then return end
        noise = noise + 0.1
        local rotX = math.sin(noise * 5) * 0.02
        local rotY = math.cos(noise * 4) * 0.02
        local rotZ = math.sin(noise * 3) * 0.01
        camera.CFrame = camera.CFrame * CFrame.Angles(rotX, rotY, rotZ)
        camera.FieldOfView = originalFOV + math.sin(noise * 2) * 5
    end)
end

local function stopTrip()
    if heartConnection then
        heartConnection:Disconnect()
        heartConnection = nil
    end
    removeEffects()
    -- Плавное возвращение
    spawn(function()
        local startFOV = camera.FieldOfView
        for i = 1, 30 do
            camera.FieldOfView = startFOV - (startFOV - originalFOV) * i/30
            camera.CFrame = workspace.CurrentCamera.CFrame -- сброс дрожи
            wait(0.03)
        end
        camera.FieldOfView = originalFOV
    end)
end

uis.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == hotkey then
        tripActive = not tripActive
        if tripActive then
            startTrip()
        else
            stopTrip()
        end
    end
end)

-- Маленькое подтверждение при запуске
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 400, 0, 100)
label.Position = UDim2.new(0.5, -200, 0.5, -50)
label.BackgroundTransparency = 1
label.Text = "bad trip by muqo666"
label.TextColor3 = Color3.new(1, 0, 1)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.Parent = screenGui
label.TextTransparency = 1

spawn(function()
    for i = 1, 30 do
        label.TextTransparency = 1 - i / 30
        wait(0.02)
    end
    wait(1.5)
    for i = 1, 30 do
        label.TextTransparency = i / 30
        wait(0.02)
    end
    label:Destroy()
end)
