-- Aimbot (только горизонталь) с хоткеем E
-- При запуске приветствие "welcome to BFH" на 5 сек с затуханием
-- При нажатии E: плавный поворот к ближайшему игроку, вертикаль не меняется

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Настройки
local ROTATION_DURATION = 0.2  -- длительность поворота (сек)

-- Приветствие
local function showWelcome()
    local gui = Instance.new("ScreenGui")
    gui.Name = "BFHWelcome"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(0, 500, 0, 100)
    text.Position = UDim2.new(0.5, -250, 0.5, -50)
    text.BackgroundTransparency = 1
    text.Text = "welcome to BFH"
    text.TextColor3 = Color3.new(1, 1, 1)
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.TextTransparency = 1
    text.Parent = gui

    -- Появление
    local fadeIn = TweenService:Create(text, TweenInfo.new(1), {TextTransparency = 0})
    fadeIn:Play()
    fadeIn.Completed:Wait()

    task.wait(3)

    -- Затухание
    local fadeOut = TweenService:Create(text, TweenInfo.new(1), {TextTransparency = 1})
    fadeOut:Play()
    fadeOut.Completed:Wait()

    gui:Destroy()
end
showWelcome()

-- Уведомление о готовности
StarterGui:SetCore("SendNotification", {
    Title = "Aimbot",
    Text = "Нажми E для наведения на ближайшего игрока",
    Duration = 5
})

-- Поиск ближайшего игрока
local function getNearestPlayer()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local myPos = myRoot.Position

    local nearest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local dist = (char.HumanoidRootPart.Position - myPos).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = plr
                end
            end
        end
    end
    return nearest
end

-- Поворот персонажа и камеры к цели (только горизонталь)
local function aimAt(targetPlayer)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local targetChar = targetPlayer.Character
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    -- Направление от игрока к цели
    local direction = (targetRoot.Position - root.Position).unit
    -- Сохраняем текущий вертикальный угол камеры
    local currentLook = camera.CFrame.LookVector
    -- Новое направление: горизонтальная составляющая direction + вертикальная текущего взгляда
    -- Получаем горизонтальный вектор цели
    local horizontalDir = (direction * Vector3.new(1, 0, 1)).unit
    -- Строим новый LookVector: горизонтальный от цели и вертикальный от текущего взгляда
    local newLook = (horizontalDir * Vector3.new(1, 0, 1) + Vector3.new(0, currentLook.Y, 0)).unit

    -- Позиция, куда смотрим: от текущей позиции корня по направлению newLook
    local lookAtPos = root.Position + newLook * 10

    -- Поворачиваем персонажа
    local targetCF = CFrame.lookAt(root.Position, lookAtPos)
    local tween = TweenService:Create(root, TweenInfo.new(ROTATION_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = targetCF})
    tween:Play()

    -- Поворачиваем камеру
    local camTween = TweenService:Create(camera, TweenInfo.new(ROTATION_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = CFrame.lookAt(camera.CFrame.Position, lookAtPos)})
    camTween:Play()
end

-- Обработка нажатия E
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        local target = getNearestPlayer()
        if target then
            aimAt(target)
            StarterGui:SetCore("SendNotification", {
                Title = "Aimbot",
                Text = "Наведено на " .. target.Name,
                Duration = 1.5
            })
        else
            StarterGui:SetCore("SendNotification", {
                Title = "Ошибка",
                Text = "Нет игроков рядом",
                Duration = 1.5
            })
        end
    end
end)

print("Aimbot (горизонталь) загружен. Нажми E для наведения.")
