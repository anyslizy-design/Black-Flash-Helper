--[[
    Auto Black Flash для Jujutsu Shenanigans (Velocity)
    Активация: клавиша E
    Описание:
        - Находит ближайшего игрока.
        - Определяет направление его взгляда.
        - Рассчитывает точку за его спиной.
        - Мгновенно поворачивает камеру в сторону этой точки.
        - Выполняет деш (Q) для захода за спину.
        - Делает двойное нажатие 3 (Black Flash) с интервалом 360 мс.
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera

local localPlayer = Players.LocalPlayer

-- Поиск ближайшего противника в радиусе 30 юнитов
local function getNearestEnemy(maxDistance)
    local character = localPlayer.Character
    if not character then return nil end
    local myRoot = character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local nearest = nil
    local nearestDist = maxDistance or 30

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local dist = (myRoot.Position - targetRoot.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = player
                end
            end
        end
    end
    return nearest
end

-- Получение направления взгляда цели (LookVector корневой части)
local function getTargetLookDirection(targetChar)
    local root = targetChar:FindFirstChild("HumanoidRootPart")
    return root and root.CFrame.LookVector
end

-- Основная функция выполнения black flash с заходом в спину
local function performBlackFlash(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetChar = targetPlayer.Character
    local myChar = localPlayer.Character
    if not myChar then return end

    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot then return end

    -- Направление взгляда цели
    local targetLook = getTargetLookDirection(targetChar)
    if not targetLook then return end

    -- Точка за спиной цели (на расстоянии 8 юнитов, можно изменить)
    local behindPos = targetRoot.Position - targetLook * 8

    -- Направление от текущего игрока к точке за спиной
    local dirToBehind = (behindPos - myRoot.Position).Unit

    -- Мгновенный поворот камеры в это направление
    local newCamCF = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + dirToBehind * 10)
    Camera.CFrame = newCamCF
    wait(0.1) -- небольшая пауза для применения поворота

    -- Нажатие Q (деш)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)

    -- Ожидание завершения рывка (подберите под свои ощущения)
    wait(0.4)

    -- Двойное нажатие 3 с интервалом 360 мс
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Three, false, game)
    wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Three, false, game)
    wait(0.36)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Three, false, game)
    wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Three, false, game)
end

-- Обработчик нажатия клавиши E
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        local target = getNearestEnemy(30)
        if target then
            performBlackFlash(target)
        else
            print("Нет врагов поблизости")
        end
    end
end)

print("Скрипт Auto Black Flash загружен. Нажмите E для активации.")
