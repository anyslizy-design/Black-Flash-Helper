-- Авто Black Flash (Legit) с aimbot-захватом
-- Приветствие 5 сек, E — захват цели, A/D+Q — рывок + двойное 3

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- Переменные
local currentTarget = nil
local dashDistance = 5          -- дистанция за спиной
local dashDuration = 0.3         -- длительность рывка
local camera = workspace.CurrentCamera

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

-- Поворот камеры и персонажа в сторону цели (aimbot)
local function aimAt(targetPlayer)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not root or not humanoid then return end

    local targetChar = targetPlayer.Character
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    -- Направление от игрока к цели
    local direction = (targetRoot.Position - root.Position).unit
    local lookAtPos = root.Position + direction

    -- Плавный поворот персонажа
    local targetCF = CFrame.lookAt(root.Position, lookAtPos)
    local tween = TweenService:Create(root, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = targetCF})
    tween:Play()

    -- Поворот камеры (опционально)
    camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetRoot.Position)
end

-- Плавный рывок за спину цели
local function dashBehind(targetPlayer)
    local char = LocalPlayer.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    local targetChar = targetPlayer.Character
    if not targetChar then return false end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end

    -- Позиция за спиной
    local behindPos = targetRoot.Position - targetRoot.CFrame.LookVector * dashDistance
    local targetCF = CFrame.new(behindPos, targetRoot.Position) -- смотрим на цель

    local tween = TweenService:Create(root, TweenInfo.new(dashDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = targetCF})
    tween:Play()
    tween.Completed:Wait()
    return true
end

-- Двойное нажатие 3 с точным интервалом 360 мс
local function doDoubleThree()
    local start = tick()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Three, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Three, false, game)

    -- Ждём ровно 360 мс от начала первого нажатия
    local elapsed = tick() - start
    local remaining = 0.360 - elapsed
    if remaining > 0 then
        task.wait(remaining)
    end

    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Three, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Three, false, game)
end

-- Обработка нажатий
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    -- E: захват цели и aimbot
    if input.KeyCode == Enum.KeyCode.E then
        local target = getNearestPlayer()
        if target then
            currentTarget = target
            aimAt(target)  -- поворачиваемся к цели
            StarterGui:SetCore("SendNotification", {
                Title = "Aimbot",
                Text = "Цель: " .. target.Name,
                Duration = 2
            })
        else
            StarterGui:SetCore("SendNotification", {
                Title = "Ошибка",
                Text = "Нет игроков рядом",
                Duration = 2
            })
        end
    end

    -- Q + зажатие A или D
    if input.KeyCode == Enum.KeyCode.Q and currentTarget then
        local aDown = UserInputService:IsKeyDown(Enum.KeyCode.A)
        local dDown = UserInputService:IsKeyDown(Enum.KeyCode.D)
        if aDown or dDown then
            local success = dashBehind(currentTarget)
            if success then
                task.wait(0.1)
                doDoubleThree()
            else
                StarterGui:SetCore("SendNotification", {
                    Title = "Ошибка",
                    Text = "Рывок не удался",
                    Duration = 2
                })
            end
        end
    end
end)

print("BFH скрипт загружен. Нажми E для захвата цели.")
