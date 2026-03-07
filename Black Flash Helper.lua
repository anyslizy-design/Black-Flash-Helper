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

local miscButton = Instance.new("TextButton")
miscButton.Name = "MiscButton"
miscButton.Size = UDim2.new(1, -20, 0, 50)
miscButton.Position = UDim2.new(0, 10, 0, 70)
miscButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
miscButton.Text = "Misc"
miscButton.TextColor3 = Color3.fromRGB(255, 255, 255)
miscButton.TextSize = 20
miscButton.Font = Enum.Font.GothamBold
miscButton.BorderSizePixel = 0
miscButton.AutoButtonColor = false
miscButton.Parent = leftColumn

local miscButtonCorner = Instance.new("UICorner")
miscButtonCorner.CornerRadius = UDim.new(0, 6)
miscButtonCorner.Parent = miscButton

-- Аниме-девушка в левой колонке (ImageLabel)
local animeImage = Instance.new("ImageLabel")
animeImage.Name = "AnimeGirl"
animeImage.Size = UDim2.new(1, -20, 0, 120)
animeImage.Position = UDim2.new(0, 10, 1, -130)
animeImage.BackgroundTransparency = 1
animeImage.Image = "rbxassetid://6023426918"
animeImage.ScaleType = Enum.ScaleType.Fit
animeImage.Parent = leftColumn

-- Контейнеры для содержимого вкладок
local combatTab = Instance.new("Frame")
combatTab.Name = "CombatTab"
combatTab.Size = UDim2.new(1, -20, 1, -20)
combatTab.Position = UDim2.new(0, 10, 0, 10)
combatTab.BackgroundTransparency = 1
combatTab.Visible = true
combatTab.Parent = rightColumn

local miscTab = Instance.new("Frame")
miscTab.Name = "MiscTab"
miscTab.Size = UDim2.new(1, -20, 1, -20)
miscTab.Position = UDim2.new(0, 10, 0, 10)
miscTab.BackgroundTransparency = 1
miscTab.Visible = false
miscTab.Parent = rightColumn

-- Функция для обновления текста кнопки с биндом
local function updateButtonText(button, baseText, bindKey)
    if bindKey and bindKey ~= Enum.KeyCode.Unknown then
        local keyName = string.gsub(tostring(bindKey), "Enum.KeyCode.", "")
        button.Text = baseText .. " [" .. keyName .. "]"
    else
        button.Text = baseText
    end
end

-- Система биндов
local bindings = {}
local bindingMode = false
local currentBindingButton = nil

-- Обработка глобального ввода для биндов
local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end

    if bindingMode and currentBindingButton then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode
            if key ~= Enum.KeyCode.Unknown then
                bindings[currentBindingButton] = key
                local baseText = currentBindingButton.BaseText
                updateButtonText(currentBindingButton, baseText, key)
                bindingMode = false
                currentBindingButton = nil
            end
        end
        return
    end

    for button, key in pairs(bindings) do
        if input.KeyCode == key then
            button:Click()
            break
        end
    end
end

UserInputService.InputBegan:Connect(onInputBegan)

-- Функция создания кнопки функции с поддержкой биндов
local function createFunctionButton(parent, name, baseText, posY, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Position = UDim2.new(0, 0, 0, posY)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.Text = baseText
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 18
    button.Font = Enum.Font.Gotham
    button.BorderSizePixel = 0
    button.Parent = parent

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button

    button.BaseText = baseText

    button.MouseButton1Click:Connect(callback)

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            input:Consume()
            bindingMode = true
            currentBindingButton = button
            button.Text = "Press any key..."
            task.delay(5, function()
                if bindingMode and currentBindingButton == button then
                    bindingMode = false
                    currentBindingButton = nil
                    updateButtonText(button, button.BaseText, bindings[button])
                end
            end)
        end
    end)

    return button
end

-- Кнопки внутри CombatTab
local tpBehindButton = createFunctionButton(combatTab, "TpBehindButton", "TP Behind", 0, function()
    print("TP Behind activated")
    -- сюда твой код
end)

local aimbotButton = createFunctionButton(combatTab, "AimbotButton", "Aimbot", 50, function()
    print("Aimbot toggled")
    -- сюда твой код
end)

-- Кнопки внутри MiscTab
local espButton = createFunctionButton(miscTab, "EspButton", "ESP", 0, function()
    print("ESP toggled")
    -- сюда твой код
end)

local ktLeaveButton = createFunctionButton(miscTab, "KtLeaveButton", "KTLeave", 50, function()
    print("KTLeave activated")
    -- сюда твой код
end)

-- Функция переключения вкладок
local function setActiveTab(tabName)
    if tabName == "Combat" then
        combatTab.Visible = true
        miscTab.Visible = false
        combatButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        miscButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    elseif tabName == "Misc" then
        combatTab.Visible = false
        miscTab.Visible = true
        combatButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        miscButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end

setActiveTab("Combat")

-- Клики по вкладкам
combatButton.MouseButton1Click:Connect(function()
    setActiveTab("Combat")
end)

miscButton.MouseButton1Click:Connect(function()
    setActiveTab("Misc")
end)

-- Эффекты наведения на вкладки
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

miscButton.MouseEnter:Connect(function()
    if miscButton.BackgroundColor3 == Color3.fromRGB(70, 70, 70) then
        miscButton.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
    end
end)
miscButton.MouseLeave:Connect(function()
    if miscButton.BackgroundColor3 == Color3.fromRGB(85, 85, 85) then
        miscButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
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

-- Открытие/закрытие по Right Shift (исправлено: убрана проверка gameProcessed)
UserInputService.InputBegan:Connect(function(input, _)
    if input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
    end
end)
