-- Загрузка необходимых сервисов
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Создание уведомления "by muqo666"
local function showNotification()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Muqo666Notification"
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 60)
    frame.Position = UDim2.new(0.5, -150, 0.2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "by muqo666"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = frame

    -- Автоматическое удаление через 3 секунды
    task.delay(3, function()
        screenGui:Destroy()
    end)
end

-- Запуск уведомления
showNotification()

-- Функция получения персонажа игрока
local function getCharacter(player)
    return player.Character
end

-- Функция телепортации позади ближайшего игрока
local function tpBehindNearest()
    local character = getCharacter(LocalPlayer)
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local myPos = root.Position
    local nearestPlayer = nil
    local nearestDistance = math.huge

    -- Поиск ближайшего игрока
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = getCharacter(player)
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - myPos).Magnitude
                    if dist < nearestDistance then
                        nearestDistance = dist
                        nearestPlayer = player
                    end
                end
            end
        end
    end

    -- Телепортация, если цель найдена
    if nearestPlayer then
        local targetChar = getCharacter(nearestPlayer)
        if targetChar then
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local lookVector = targetRoot.CFrame.LookVector
                local behindPos = targetRoot.Position - lookVector * 5
                behindPos = Vector3.new(behindPos.X, targetRoot.Position.Y, behindPos.Z)
                root.CFrame = CFrame.new(behindPos)
                
                -- Маленькое уведомление о цели (опционально)
                print("Телепортировался к " .. nearestPlayer.Name)
            end
        end
    else
        print("Рядом нет других игроков")
    end
end

-- Ожидание ввода клавиши E
local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end  -- Игнорировать, если ввод уже обработан игрой (например, чат)
    if input.KeyCode == Enum.KeyCode.E then
        tpBehindNearest()
    end
end

UserInputService.InputBegan:Connect(onInputBegan)

-- Небольшое подтверждение в консоль
print("Скрипт загружен. Нажмите E, чтобы телепортироваться за спину ближайшего игрока.")
