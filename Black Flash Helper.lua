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

-- Создаём основное окно (Frame) 600x400
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 600, 0, 400)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = gui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- Заголовок окна (для перетаскивания)
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

-- Основной заголовок слева
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(0.7, -10, 1, 0)   -- 70% ширины
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Black Flash Helper"
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Текст автора справа (мелким шрифтом)
local authorLabel = Instance.new("TextLabel")
authorLabel.Name = "Author"
authorLabel.Size = UDim2.new(0.3, -10, 1, 0)   -- 30% ширины
authorLabel.Position = UDim2.new(0.7, 0, 0, 0)
authorLabel.BackgroundTransparency = 1
authorLabel.Text = "by muqo666"
authorLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
authorLabel.TextSize = 14
authorLabel.Font = Enum.Font.Gotham
authorLabel.TextXAlignment = Enum.TextXAlignment.Right
authorLabel.TextYAlignment = Enum.TextYAlignment.Center
authorLabel.Parent = titleBar

-- Контейнер для двух колонок
local columnsContainer = Instance.new("Frame")
columnsContainer.Name = "ColumnsContainer"
columnsContainer.Size = UDim2.new(1, 0, 1, -40)
columnsContainer.Position = UDim2.new(0, 0, 0, 40)
columnsContainer.BackgroundTransparency = 1
columnsContainer.Parent = mainFrame

-- Левая колонка (1/4)
local leftColumn = Instance.new("Frame")
leftColumn.Name = "LeftColumn"
leftColumn.Size = UDim2.new(0.25, -5, 1, -10)
leftColumn.Position = UDim2.new(0, 5, 0, 5)
leftColumn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
leftColumn.BorderSizePixel = 0
leftColumn.Parent = columnsContainer

local leftCorner = Instance.new("UICorner")
leftCorner.CornerRadius = UDim.new(0, 6)
leftCorner.Parent = leftColumn

-- Правая колонка (3/4)
local rightColumn = Instance.new("Frame")
rightColumn.Name = "RightColumn"
rightColumn.Size = UDim2.new(0.75, -10, 1, -10)
rightColumn.Position = UDim2.new(0.25, 5, 0, 5)
rightColumn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
rightColumn.BorderSizePixel = 0
rightColumn.Parent = columnsContainer

local rightCorner = Instance.new("UICorner")
rightCorner.CornerRadius = UDim.new(0, 6)
rightCorner.Parent = rightColumn

-- Кнопки в левой колонке (вкладки)
local combatButton = Instance.new("TextButton")
combatButton.Name = "CombatButton"
combatButton.Size = UDim2.new(1, -20, 0, 50)
combatButton.Position = UDim2.new(0, 10, 0, 10)
combatButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
combatButton.Text = "Combat"
combatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
combatButton.TextSize = 20
combatButton.Font = Enum.Font.GothamBold
combatButton.BorderSizePixel = 0
combatButton.AutoButtonColor = false
combatButton.Parent = leftColumn

local combatButtonCorner = Instance.new("UICorner")
combatButtonCorner.CornerRadius = UDim.new(0, 6)
combatButtonCorner.Parent = combatButton

local playerButton = Instance.new("TextButton")
playerButton.Name = "PlayerButton"
playerButton.Size = UDim2.new(1, -20, 0, 50)
playerButton.Position = UDim2.new(0, 10, 0, 70)
playerButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
playerButton.Text = "Player"
playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
playerButton.TextSize = 20
playerButton.Font = Enum.Font.GothamBold
playerButton.BorderSizePixel = 0
playerButton.AutoButtonColor = false
playerButton.Parent = leftColumn

local playerButtonCorner = Instance.new("UICorner")
playerButtonCorner.CornerRadius = UDim.new(0, 6)
playerButtonCorner.Parent = playerButton

-- Контейнеры для содержимого вкладок
local combatTab = Instance.new("Frame")
combatTab.Name = "CombatTab"
combatTab.Size = UDim2.new(1, -20, 1, -20)
combatTab.Position = UDim2.new(0, 10, 0, 10)
combatTab.BackgroundTransparency = 1
combatTab.Visible = true
combatTab.Parent = rightColumn

local playerTab = Instance.new("Frame")
playerTab.Name = "PlayerTab"
playerTab.Size = UDim2.new(1, -20, 1, -20)
playerTab.Position = UDim2.new(0, 10, 0, 10)
playerTab.BackgroundTransparency = 1
playerTab.Visible = false
playerTab.Parent = rightColumn

-- Кнопки внутри CombatTab
local tpBehindButton = Instance.new("TextButton")
tpBehindButton.Name = "TpBehindButton"
tpBehindButton.Size = UDim2.new(1, 0, 0, 40)
tpBehindButton.Position = UDim2.new(0, 0, 0, 0)
tpBehindButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
tpBehindButton.Text = "TP Behind"
tpBehindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBehindButton.TextSize = 18
tpBehindButton.Font = Enum.Font.Gotham
tpBehindButton.BorderSizePixel = 0
tpBehindButton.Parent = combatTab

local tpBehindCorner = Instance.new("UICorner")
tpBehindCorner.CornerRadius = UDim.new(0, 6)
tpBehindCorner.Parent = tpBehindButton

local lockOnButton = Instance.new("TextButton")
lockOnButton.Name = "LockOnButton"
lockOnButton.Size = UDim2.new(1, 0, 0, 40)
lockOnButton.Position = UDim2.new(0, 0, 0, 50)
lockOnButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
lockOnButton.Text = "Lock On"
lockOnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
lockOnButton.TextSize = 18
lockOnButton.Font = Enum.Font.Gotham
lockOnButton.BorderSizePixel = 0
lockOnButton.Parent = combatTab

local lockOnCorner = Instance.new("UICorner")
lockOnCorner.CornerRadius = UDim.new(0, 6)
lockOnCorner.Parent = lockOnButton

-- Кнопки внутри PlayerTab
local espButton = Instance.new("TextButton")
espButton.Name = "EspButton"
espButton.Size = UDim2.new(1, 0, 0, 40)
espButton.Position = UDim2.new(0, 0, 0, 0)
espButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
espButton.Text = "ESP"
espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espButton.TextSize = 18
espButton.Font = Enum.Font.Gotham
espButton.BorderSizePixel = 0
espButton.Parent = playerTab

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 6)
espCorner.Parent = espButton

local ktLeaveButton = Instance.new("TextButton")
ktLeaveButton.Name = "KtLeaveButton"
ktLeaveButton.Size = UDim2.new(1, 0, 0, 40)
ktLeaveButton.Position = UDim2.new(0, 0, 0, 50)
ktLeaveButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ktLeaveButton.Text = "KTLeave"
ktLeaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ktLeaveButton.TextSize = 18
ktLeaveButton.Font = Enum.Font.Gotham
ktLeaveButton.BorderSizePixel = 0
ktLeaveButton.Parent = playerTab

local ktLeaveCorner = Instance.new("UICorner")
ktLeaveCorner.CornerRadius = UDim.new(0, 6)
ktLeaveCorner.Parent = ktLeaveButton

-- Функция переключения вкладок
local function setActiveTab(tabName)
    if tabName == "Combat" then
        combatTab.Visible = true
        playerTab.Visible = false
        combatButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        playerButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    elseif tabName == "Player" then
        combatTab.Visible = false
        playerTab.Visible = true
        combatButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        playerButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end

setActiveTab("Combat")

-- Клики по вкладкам
combatButton.MouseButton1Click:Connect(function()
    setActiveTab("Combat")
end)

playerButton.MouseButton1Click:Connect(function()
    setActiveTab("Player")
end)

-- Эффекты наведения (опционально)
combatButton.MouseEnter:Connect(function()
    if combatButton.BackgroundColor3 == Color3.fromRGB(70, 70, 70) then
        combatButton.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
    end
end)
combatButton.MouseLeave:Connect(function()
    if combatButton.BackgroundColor3 == Color3.fromRGB(85, 85, 85) then
        combatButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end
end)

playerButton.MouseEnter:Connect(function()
    if playerButton.BackgroundColor3 == Color3.fromRGB(70, 70, 70) then
        playerButton.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
    end
end)
playerButton.MouseLeave:Connect(function()
    if playerButton.BackgroundColor3 == Color3.fromRGB(85, 85, 85) then
        playerButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end
end)

-- Перетаскивание окна
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

-- Открытие/закрытие по Right Shift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Заглушки функционала (замени на свой код)
tpBehindButton.MouseButton1Click:Connect(function()
    print("TP Behind activated")
end)

lockOnButton.MouseButton1Click:Connect(function()
    print("Lock On toggled")
end)

espButton.MouseButton1Click:Connect(function()
    print("ESP toggled")
end)

ktLeaveButton.MouseButton1Click:Connect(function()
    print("KTLeave activated")
end)
