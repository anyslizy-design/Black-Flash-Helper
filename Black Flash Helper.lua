-- Black Flash Helper Script
-- Инжектор Xeno, Roblox

-- Сервисы
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

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
    welcomeLabel.Size = UDim2.new(1, 0, 1, 0)
    welcomeLabel.BackgroundTransparency = 1
    welcomeLabel.Text = "Welcom"
    welcomeLabel.TextColor3 = Color3.new(1, 1, 1)
    welcomeLabel.TextSize = 50
    welcomeLabel.Font = Enum.Font.GothamBold
    welcomeLabel.TextStrokeTransparency = 0.8
    welcomeLabel.TextWrapped = true
    welcomeLabel.TextScaled = true
    welcomeLabel.TextYAlignment = Enum.TextYAlignment.Center
    welcomeLabel.TextXAlignment = Enum.TextXAlignment.Center
    welcomeLabel.Parent = gui

    -- Плавное исчезновение через Tween
    local fadeInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local goal = { TextTransparency = 1 }
    local tween = TweenService:Create(welcomeLabel, fadeInfo, goal)
    tween:Play()

    tween.Completed:Connect(function()
        if welcomeLabel and welcomeLabel.Parent then
            welcomeLabel:Destroy()
        end
    end)
end

showWelcomeMessage()

-- Создаём основное окно (Frame) с увеличенным размером (600x400)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 600, 0, 400)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)  -- центрируем с учётом нового размера
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false     -- изначально скрыто
mainFrame.Parent = gui

-- Скруглённые углы
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- Заголовок окна (также используется для перетаскивания)
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar
-- но углы сверху скруглены, снизу нет — чтобы сочеталось с основным фреймом, можно оставить как есть или сделать отдельно.

-- Текст заголовка
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Black Flash Helper"
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Контейнер для двух колонок
local columnsContainer = Instance.new("Frame")
columnsContainer.Name = "ColumnsContainer"
columnsContainer.Size = UDim2.new(1, 0, 1, -40)  -- ниже заголовка
columnsContainer.Position = UDim2.new(0, 0, 0, 40)
columnsContainer.BackgroundTransparency = 1
columnsContainer.Parent = mainFrame

-- Левая колонка (1/4 ширины)
local leftColumn = Instance.new("Frame")
leftColumn.Name = "LeftColumn"
leftColumn.Size = UDim2.new(0.25, -5, 1, -10)  -- 25% ширины с отступами
leftColumn.Position = UDim2.new(0, 5, 0, 5)
leftColumn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
leftColumn.BorderSizePixel = 0
leftColumn.Parent = columnsContainer

local leftCorner = Instance.new("UICorner")
leftCorner.CornerRadius = UDim.new(0, 6)
leftCorner.Parent = leftColumn

-- Правая колонка (3/4 ширины)
local rightColumn = Instance.new("Frame")
rightColumn.Name = "RightColumn"
rightColumn.Size = UDim2.new(0.75, -10, 1, -10)  -- 75% ширины с отступами
rightColumn.Position = UDim2.new(0.25, 5, 0, 5)
rightColumn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
rightColumn.BorderSizePixel = 0
rightColumn.Parent = columnsContainer

local rightCorner = Instance.new("UICorner")
rightCorner.CornerRadius = UDim.new(0, 6)
rightCorner.Parent = rightColumn

-- Кнопка Combat в левой колонке
local combatButton = Instance.new("TextButton")
combatButton.Name = "CombatButton"
combatButton.Size = UDim2.new(1, -20, 0, 50)
combatButton.Position = UDim2.new(0, 10, 0, 10)
combatButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
combatButton.Text = "⚔️ Combat"
combatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
combatButton.TextSize = 20
combatButton.Font = Enum.Font.GothamBold
combatButton.BorderSizePixel = 0
combatButton.AutoButtonColor = false
combatButton.Parent = leftColumn

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = combatButton

-- Эффект наведения на кнопку
combatButton.MouseEnter:Connect(function()
    combatButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
end)
combatButton.MouseLeave:Connect(function()
    combatButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
end)

-- Функционал кнопки Combat (сюда можно добавить свою логику)
combatButton.MouseButton1Click:Connect(function()
    print("Combat activated!")  -- Замени на свой код
    -- Например, включение/выключение боевого скрипта
end)

-- Перетаскивание окна (за заголовок)
local dragging = false
local dragInput
local dragStart
local startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        dragging = false
    end
end)

-- Обработка нажатия Right Shift для открытия/закрытия
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
    end
end)
