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

-- Основной фрейм (окно)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 600, 0, 400)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Заголовок окна
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

-- Название слева
local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.5, 0, 1, 0)
titleText.Position = UDim2.new(0, 5, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Black Flash Helper"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.SourceSansBold
titleText.TextSize = 18
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Подпись справа (мелким шрифтом)
local creditText = Instance.new("TextLabel")
creditText.Size = UDim2.new(0.5, -5, 1, 0)
creditText.Position = UDim2.new(0.5, 0, 0, 0)
creditText.BackgroundTransparency = 1
creditText.Text = "by muqo666"
creditText.TextColor3 = Color3.fromRGB(180, 180, 180)
creditText.Font = Enum.Font.SourceSansLight
creditText.TextSize = 14
creditText.TextXAlignment = Enum.TextXAlignment.Right
creditText.Parent = titleBar

-- Левая панель (кнопки-вкладки)
local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(1/3, 0, 1, -30)
leftPanel.Position = UDim2.new(0, 0, 0, 30)
leftPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
leftPanel.BorderSizePixel = 0
leftPanel.Parent = mainFrame

-- Правая панель (содержимое вкладок)
local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(2/3, 0, 1, -30)
rightPanel.Position = UDim2.new(1/3, 0, 0, 30)
rightPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
rightPanel.BorderSizePixel = 0
rightPanel.Parent = mainFrame

-- Вертикальное расположение кнопок на левой панели
local layoutLeft = Instance.new("UIListLayout")
layoutLeft.Parent = leftPanel
layoutLeft.SortOrder = Enum.SortOrder.LayoutOrder
layoutLeft.Padding = UDim.new(0, 5)

-- Контейнер для содержимого правой панели
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -10, 1, -10)
contentContainer.Position = UDim2.new(0, 5, 0, 5)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = rightPanel

-- Функция очистки правой панели
local function clearRightPanel()
    for _, child in pairs(contentContainer:GetChildren()) do
        child:Destroy()
    end
end

-- Функция создания кнопки-вкладки
local function createTabButton(name, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 40)
    button.Position = UDim2.new(0, 5, 0, 0)
    button.Text = name
    button.BackgroundColor3 = color or Color3.fromRGB(60, 60, 60)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 20
    button.BorderSizePixel = 0
    button.Parent = leftPanel
    return button
end

-- === Система биндов ===
local keyToFunction = {}      -- Клавиша (Enum.KeyCode) -> функция
local listeningForBind = false -- Режим ожидания назначения
var currentBindingFunc = nil   -- Функция, для которой назначаем бинд
local bindPromptLabel = nil    -- Временная подсказка

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
    bindPromptLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    bindPromptLabel.Font = Enum.Font.SourceSansBold
    bindPromptLabel.TextSize = 20
    bindPromptLabel.TextWrapped = true
    bindPromptLabel.Parent = contentContainer
end

-- Обновление текста кнопки с учётом бинда
local function updateButtonText(button, func, baseText)
    local key = nil
    for k, f in pairs(keyToFunction) do
        if f == func then
            key = k
            break
        end
    end
    if key then
        -- Преобразуем Enum.KeyCode в читаемое имя (например, "O" вместо "KeyCode.O")
        local keyName = tostring(key):gsub("Enum.KeyCode.", "")
        button.Text = baseText .. " [" .. keyName .. "]"
    else
        button.Text = baseText
    end
end

-- Функция создания кнопки действия (теперь с поддержкой биндов)
local function createActionButton(parent, text, func)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 40)
    button.Position = UDim2.new(0, 5, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 18
    button.BorderSizePixel = 0
    button.Parent = parent

    -- Устанавливаем начальный текст с учётом возможного бинда
    local baseText = text
    updateButtonText(button, func, baseText)

    -- Клик ЛКМ – выполнить функцию
    button.MouseButton1Click:Connect(func)

    -- Клик ПКМ – начать назначение бинда
    button.MouseButton2Click:Connect(function()
        if listeningForBind then
            -- Если уже слушаем, предложим отменить или переназначить
            cancelBindListening()
        end
        listeningForBind = true
        currentBindingFunc = func
        showBindPrompt("Нажмите любую клавишу для привязки к '" .. baseText .. "' (Esc - отмена)")
    end)

    -- При уничтожении кнопки не удаляем бинд (он сохраняется для функции)
    return button
end

-- Функция создания заглушки "Скоро тут будет что-то интересное:)"
local function createPlaceholder(parent)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.Text = "Скоро тут будет что-то интересное:)"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSansItalic
    label.TextSize = 18
    label.Parent = parent
    label.Position = UDim2.new(0, 0, 0.5, -15)
    return label
end

-- Создаём кнопки-вкладки
local combatBtn = createTabButton("Combat", Color3.fromRGB(80, 40, 40))
local miscBtn   = createTabButton("Misc", Color3.fromRGB(40, 80, 40))
local funnyBtn  = createTabButton("Funny", Color3.fromRGB(80, 80, 40))
local configBtn = createTabButton("Config", Color3.fromRGB(40, 40, 80))

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

-- Peredoz (радужный экран + падение)
local peredozActive = false
local rainbowFrame = nil

local function peredoz()
    -- Эффект падения (как в старом Trip)
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Sit = true
            wait(0.5)
            humanoid.Sit = false
        end
    end

    -- Радужный экран (если ещё не активен)
    if peredozActive then return end
    peredozActive = true

    -- Создаём полупрозрачный полноэкранный фрейм
    rainbowFrame = Instance.new("Frame")
    rainbowFrame.Size = UDim2.new(1, 0, 1, 0)
    rainbowFrame.Position = UDim2.new(0, 0, 0, 0)
    rainbowFrame.BackgroundColor3 = Color3.new(1, 0, 0)
    rainbowFrame.BackgroundTransparency = 0.3
    rainbowFrame.BorderSizePixel = 0
    rainbowFrame.ZIndex = 10
    rainbowFrame.Parent = player:WaitForChild("PlayerGui")

    -- Анимация смены цвета
    local hue = 0
    local connection
    connection = runService.RenderStepped:Connect(function()
        if not rainbowFrame or not rainbowFrame.Parent then
            connection:Disconnect()
            return
        end
        hue = hue + 0.01
        if hue > 1 then hue = 0 end
        rainbowFrame.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
    end)

    -- Через 3 секунды убираем
    task.wait(3)
    if rainbowFrame then
        rainbowFrame:Destroy()
        rainbowFrame = nil
    end
    peredozActive = false
end

-- === Обработка вкладок ===
combatBtn.MouseButton1Click:Connect(function()
    clearRightPanel()
    cancelBindListening() -- сбрасываем режим ожидания при смене вкладки
    local layout = Instance.new("UIListLayout")
    layout.Parent = contentContainer
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)

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
    layout.Padding = UDim.new(0, 5)

    createActionButton(contentContainer, "Peredoz", peredoz)
end)

configBtn.MouseButton1Click:Connect(function()
    clearRightPanel()
    cancelBindListening()
    createPlaceholder(contentContainer)
end)

-- Автоматически открываем вкладку Combat при запуске
combatBtn.MouseButton1Click:Fire()

-- === Глобальная обработка клавиш (бинды + открытие/закрытие) ===
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- Обработка режима ожидания бинда
    if listeningForBind then
        if input.KeyCode == Enum.KeyCode.Escape then
            cancelBindListening()
            return
        end
        -- Проверяем, что это клавиша клавиатуры (не мышь, не геймпад)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode
            if key ~= Enum.KeyCode.Unknown then
                -- Удаляем предыдущую привязку этой клавиши (если была)
                if keyToFunction[key] then
                    keyToFunction[key] = nil
                end
                -- Удаляем предыдущую привязку этой функции (если была на другой клавише)
                for k, f in pairs(keyToFunction) do
                    if f == currentBindingFunc then
                        keyToFunction[k] = nil
                        break
                    end
                end
                -- Назначаем новую
                keyToFunction[key] = currentBindingFunc
                cancelBindListening()
                -- Обновляем текст кнопок во всех вкладках (проще всего перезагрузить текущую вкладку)
                -- Но можно просто обновить все существующие кнопки в контейнере
                for _, child in pairs(contentContainer:GetChildren()) do
                    if child:IsA("TextButton") and child.MouseButton1Click then
                        -- Определяем, какая функция у этой кнопки? Сложно, поэтому просто перезагрузим вкладку
                        -- Самый простой способ: эмулировать клик по текущей вкладке
                        local activeTab = nil
                        if combatBtn.BackgroundColor3 == Color3.fromRGB(100, 60, 60) then -- приблизительно
                            activeTab = combatBtn
                        elseif miscBtn.BackgroundColor3 == Color3.fromRGB(60, 100, 60) then
                            activeTab = miscBtn
                        elseif funnyBtn.BackgroundColor3 == Color3.fromRGB(100, 100, 60) then
                            activeTab = funnyBtn
                        elseif configBtn.BackgroundColor3 == Color3.fromRGB(60, 60, 100) then
                            activeTab = configBtn
                        end
                        if activeTab then
                            activeTab.MouseButton1Click:Fire()
                        end
                    end
                end
            end
        end
        return
    end

    -- Обычная обработка биндов
    if keyToFunction[input.KeyCode] then
        keyToFunction[input.KeyCode]()
    end

    -- Открытие/закрытие по P
    if input.KeyCode == Enum.KeyCode.P then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

print("Black Flash Helper загружен! Нажмите P, чтобы скрыть/показать. Используйте ПКМ по кнопке для назначения бинда.")
