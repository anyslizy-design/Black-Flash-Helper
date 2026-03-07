-- Black Flash Helper Script
-- Инжектор Xeno, Roblox

-- Сервисы
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Проверка на клиент
if not RunService:IsClient() then return end

-- Получаем локального игрока
local player = Players.LocalPlayer
if not player then
    repeat task.wait() until Players.LocalPlayer
    player = Players.LocalPlayer
end

local playerGui = player:WaitForChild("PlayerGui")

-- Удаляем старую версию GUI, если есть
local existingGui = playerGui:FindFirstChild("BlackFlashHelperGui")
if existingGui then
    existingGui:Destroy()
end

-- Создаём главный ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "BlackFlashHelperGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Функция показа приветственного сообщения с плавным исчезновением
local function showWelcomeMessage()
    local welcomeLabel = Instance.new("TextLabel")
    welcomeLabel.Name = "WelcomeLabel"
    welcomeLabel.Size = UDim2.new(1, 0, 1, 0)          -- весь экран
    welcomeLabel.BackgroundTransparency = 1           -- полностью прозрачный фон
    welcomeLabel.Text = "Welcom"
    welcomeLabel.TextColor3 = Color3.new(1, 1, 1)     -- белый
    welcomeLabel.TextSize = 50
    welcomeLabel.Font = Enum.Font.GothamBold
    welcomeLabel.TextStrokeTransparency = 0.8
    welcomeLabel.TextWrapped = true
    welcomeLabel.TextScaled = true                    -- масштабируется
    welcomeLabel.TextYAlignment = Enum.TextYAlignment.Center
    welcomeLabel.TextXAlignment = Enum.TextXAlignment.Center
    welcomeLabel.Parent = gui

    -- Плавное исчезновение через Tween (прозрачность текста)
    local fadeInfo = TweenInfo.new(
        2,                         -- длительность 2 секунды
        Enum.EasingStyle.Linear,   -- линейно
        Enum.EasingDirection.Out,  -- затухание
        0,                         -- задержка
        false,                     -- не повторять
        0                          -- не возвращаться
    )
    local goal = { TextTransparency = 1 }  -- цель: полностью прозрачный текст
    local tween = TweenService:Create(welcomeLabel, fadeInfo, goal)
    tween:Play()

    -- Удалить лейбл после завершения анимации (немного с запасом)
    tween.Completed:Connect(function()
        if welcomeLabel and welcomeLabel.Parent then
            welcomeLabel:Destroy()
        end
    end)
end

-- Запускаем приветствие
showWelcomeMessage()

-- Создаём основное окно (Frame)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)  -- по центру
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false     -- изначально скрыто
mainFrame.Parent = gui

-- Скруглённые углы (8px)
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- Заголовок окна
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Black Flash Helper"
titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- Описание (место под будущие функции)
local descLabel = Instance.new("TextLabel")
descLabel.Name = "Description"
descLabel.Size = UDim2.new(1, 0, 1, -40)
descLabel.Position = UDim2.new(0, 0, 0, 40)
descLabel.BackgroundTransparency = 1
descLabel.Text = "Здесь будут функции скрипта..."
descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
descLabel.TextSize = 16
descLabel.Font = Enum.Font.Gotham
descLabel.TextWrapped = true
descLabel.Parent = mainFrame

-- Обработка нажатия Right Shift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Больше никаких сообщений в консоль!
