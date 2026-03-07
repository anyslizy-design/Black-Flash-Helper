-- Загружаем сервисы
local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")

-- Уничтожаем предыдущее GUI, если оно есть
local oldGui = player:FindFirstChild("PlayerGui"):FindFirstChild("BlackFlashHelper")
if oldGui then oldGui:Destroy() end

-- Создаём основной ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlackFlashHelper"
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false
screenGui.Enabled = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Основной фрейм (окно)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 700, 0, 500)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Заголовок окна
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.5, 0, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Black Flash Helper"
titleText.TextColor3 = Color3.fromRGB(220, 220, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 18
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local creditText = Instance.new("TextLabel")
creditText.Size = UDim2.new(0.5, -10, 1, 0)
creditText.Position = UDim2.new(0.5, 0, 0, 0)
creditText.BackgroundTransparency = 1
creditText.Text = "by muqo666"
creditText.TextColor3 = Color3.fromRGB(150, 150, 180)
creditText.Font = Enum.Font.GothamLight
creditText.TextSize = 14
creditText.TextXAlignment = Enum.TextXAlignment.Right
creditText.Parent = titleBar

-- Левая панель (вкладки)
local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0.2, 0, 1, -30)
leftPanel.Position = UDim2.new(0, 0, 0, 30)
leftPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
leftPanel.BorderSizePixel = 0
leftPanel.Parent = mainFrame

-- Правая панель (содержимое)
local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(0.8, 0, 1, -30)
rightPanel.Position = UDim2.new(0.2, 0, 0, 30)
rightPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
rightPanel.BorderSizePixel = 0
rightPanel.Parent = mainFrame

-- Контейнер для кнопок вкладок с вертикальным расположением
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -10, 1, -10)
tabContainer.Position = UDim2.new(0, 5, 0, 5)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = leftPanel

local tabLayout = Instance.new("UIListLayout")
tabLayout.Parent = tabContainer
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 5)

-- Контейнер для содержимого правой панели (будет заполняться динамически)
local contentContainer = Instance.new("ScrollingFrame")
contentContainer.Size = UDim2.new(1, -20, 1, -20)
contentContainer.Position = UDim2.new(0, 10, 0, 10)
contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0
contentContainer.ScrollBarThickness = 6
contentContainer.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120)
contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
contentContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentContainer.Parent = rightPanel

-- Функция очистки правой панели
local function clearRightPanel()
    for _, child in pairs(contentContainer:GetChildren()) do
        child:Destroy()
    end
    contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
end

-- === Система биндов (активация через колесико мыши) ===
local keyToFunction = {}      -- Клавиша (Enum.KeyCode) -> функция
local listeningForBind = false -- Режим ожидания назначения
local currentBindingFunc = nil -- Функция, для которой назначаем бинд
local bindPromptLabel = nil    -- Временная подсказка
local currentTabButton = nil   -- Текущая активная вкладка

-- Функция отмены режима ожидания
local function cancelBindListening()
    listeningForBind = false
    currentBindingFunc = nil
    if bindPromptLabel then
        bindPromptLabel:Destroy()
        bindPromptLabel = nil
    end
end

-- Показать подсказку в правой панели
local function showBindPrompt(text)
    if bindPromptLabel then bindPromptLabel:Destroy() end
    bindPromptLabel = Instance.new("TextLabel")
    bindPromptLabel.Size = UDim2.new(1, -20, 0, 40)
    bindPromptLabel.Position = UDim2.new(0, 10, 0, 10)
    bindPromptLabel.BackgroundTransparency = 1
    bindPromptLabel.Text = text
    bindPromptLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    bindPromptLabel.Font = Enum.Font.GothamBold
    bindPromptLabel.TextSize = 18
    bindPromptLabel.TextWrapped = true
    bindPromptLabel.Parent = contentContainer
end

-- Функция создания кнопки вкладки
local function createTabButton(name, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Text = name
    button.BackgroundColor3 = color or Color3.fromRGB(45, 45, 60)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 16
    button.BorderSizePixel = 0
    button.Parent = tabContainer

    -- При клике запоминаем текущую вкладку
    button.MouseButton1Click:Connect(function()
        currentTabButton = button
    end)

    return button
end

-- Функция создания кнопки действия (с поддержкой биндов через колесико)
local function createActionButton(parent, text, func)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 45)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 16
    button.BorderSizePixel = 0
    button.Parent = parent

    -- Закруглённые углы (опционально)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    local baseText = text

    -- Функция обновления текста с учётом бинда
    local function updateButtonText()
        local key = nil
        for k, f in pairs(keyToFunction) do
            if f == func then
                key = k
                break
            end
        end
        if key then
            local keyName = tostring(key):gsub("Enum.KeyCode.", "")
            button.Text = baseText .. "  [" .. keyName .. "]"
        else
            button.Text = baseText
        end
    end

    updateButtonText()

    -- Клик ЛКМ – выполнить функцию
    button.MouseButton1Click:Connect(func)

    -- Клик колесиком – начать назначение бинда
    button.MouseButton3Click:Connect(function()
        if listeningForBind then
            cancelBindListening()
        end
        listeningForBind = true
        currentBindingFunc = func
        showBindPrompt("Нажмите любую клавишу для '" .. baseText .. "' (Esc - отмена)")
    end)

    -- Сохраняем функцию обновления в кнопку, чтобы можно было вызвать позже (необязательно)
    button.UpdateBindText = updateButtonText

    return button
end

-- Функция создания заглушки
local function createPlaceholder(parent)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 50)
    label.Text = "Скоро тут будет что-то интересное:)"
    label.TextColor3 = Color3.fromRGB(180, 180, 200)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamItalic
    label.TextSize = 18
    label.Parent = parent
    return label
end

-- Создаём кнопки вкладок (цвета подобраны под стиль Celestial)
local combatBtn = createTabButton("Combat", Color3.fromRGB(70, 50, 80))
local miscBtn   = createTabButton("Misc", Color3.fromRGB(50, 70, 80))
local funnyBtn  = createTabButton("Funny", Color3.fromRGB(80, 70, 50))
local configBtn = createTabButton("Config", Color3.fromRGB(60, 60, 90))

-- Устанавливаем начальную активную вкладку
currentTabButton = combatBtn

-- === Реализация функций ===

-- TP Behind
local function tpBehind()
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        warn("Персонаж не найден")
        return
    end

    local closestPlayer = nil
    local closestDistance = math.huge
    local myPos = character.HumanoidRootPart.Position

    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= localPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
            if dist < closestDistance then
                closestDistance = dist
                closestPlayer = plr
            end
        end
    end

    if closestPlayer then
        local targetChar = closestPlayer.Character
        local targetRoot = targetChar.HumanoidRootPart
        local lookVector = targetRoot.CFrame.LookVector
        local behindPos = targetRoot.Position - lookVector * 5
        character.HumanoidRootPart.CFrame = CFrame.new(behindPos) * CFrame.Angles(0, targetRoot.Orientation.Y * math.pi/180, 0)
        print("TP Behind to " .. closestPlayer.Name)
    else
        warn("Нет других игроков")
    end
end

-- Воспроизведение песни
local function playEggManSong()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://137702431366019"
    sound.Volume = 0.5
    sound.Looped = true
    sound.Parent = player.PlayerGui
    sound:Play()
    task.wait(60)
    sound:Stop()
    sound:Destroy()
end

-- Peredoz
local peredozActive = false
local rainbowFrame = nil

local function peredoz()
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Sit = true
            task.wait(0.5)
            humanoid.Sit = false
        end
    end

    if peredozActive then return end
    peredozActive = true

    coroutine.wrap(playEggManSong)()

    rainbowFrame = Instance.new("Frame")
    rainbowFrame.Size = UDim2.new(1, 0, 1, 0)
    rainbowFrame.Position = UDim2.new(0, 0, 0, 0)
    rainbowFrame.BackgroundColor3 = Color3.new(1, 0, 0)
    rainbowFrame.BackgroundTransparency = 0.3
    rainbowFrame.BorderSizePixel = 0
    rainbowFrame.ZIndex = 10
    rainbowFrame.Parent = player:WaitForChild("PlayerGui")

    local hue = 0
    local startTime = tick()
    local duration = 60
    local connection

    connection = runService.RenderStepped:Connect(function()
        if not rainbowFrame or not rainbowFrame.Parent then
            connection:Disconnect()
            return
        end
        local elapsed = tick() - startTime
        if elapsed >= duration then
            rainbowFrame:Destroy()
            rainbowFrame = nil
            peredozActive = false
            connection:Disconnect()
            return
        end
        hue = hue + 0.01
        if hue > 1 then hue = 0 end
        rainbowFrame.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
    end)
end

-- === Обработка вкладок ===
combatBtn.MouseButton1Click:Connect(function()
    clearRightPanel()
    cancelBindListening()

    local layout = Instance.new("UIListLayout")
    layout.Parent = contentContainer
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)

    createActionButton(contentContainer, "TP Behind", tpBehind)
end)

miscBtn.MouseButton1Click:Connect(function()
    clearRightPanel()
    cancelBindListening()
    createPlaceholder(contentContainer)
end)

funnyBtn.MouseButton1Click:Connect(function()
    clearRightPanel()
    cancelBindListening()

    local layout = Instance.new("UIListLayout")
    layout.Parent = contentContainer
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)

    createActionButton(contentContainer, "Peredoz", peredoz)
end)

configBtn.MouseButton1Click:Connect(function()
    clearRightPanel()
    cancelBindListening()
    createPlaceholder(contentContainer)
end)

-- Автоматически открываем вкладку Combat при запуске
combatBtn.MouseButton1Click:Fire()

-- === Глобальная обработка клавиш ===
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- Режим ожидания бинда
    if listeningForBind then
        if input.KeyCode == Enum.KeyCode.Escape then
            cancelBindListening()
            return
        end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode
            if key ~= Enum.KeyCode.Unknown then
                -- Удаляем старую привязку этой клавиши
                if keyToFunction[key] then
                    keyToFunction[key] = nil
                end
                -- Удаляем старую привязку этой функции (если была)
                for k, f in pairs(keyToFunction) do
                    if f == currentBindingFunc then
                        keyToFunction[k] = nil
                        break
                    end
                end
                -- Назначаем новую
                keyToFunction[key] = currentBindingFunc
                cancelBindListening()

                -- Перезагружаем текущую вкладку, чтобы обновить текст кнопок
                if currentTabButton then
                    currentTabButton.MouseButton1Click:Fire()
                end
            end
        end
        return
    end

    -- Обычные бинды
    if keyToFunction[input.KeyCode] then
        keyToFunction[input.KeyCode]()
    end

    -- Открытие/закрытие по P
    if input.KeyCode == Enum.KeyCode.P then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

print("Black Flash Helper загружен! Нажмите P, чтобы скрыть/показать. Используйте КОЛЕСИКО МЫШИ на кнопке для назначения бинда.")
