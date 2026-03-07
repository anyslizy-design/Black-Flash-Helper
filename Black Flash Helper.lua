-- Загружаем библиотеку для упрощения работы с GUI (опционально, но часто используется)
-- local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
-- Но в данном примере сделаем всё вручную.

-- Уничтожаем предыдущее GUI, если оно существует
local player = game.Players.LocalPlayer
local gui = player:FindFirstChild("PlayerGui"):FindFirstChild("XenoGUI")
if gui then gui:Destroy() end

-- Создаём основной ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "XenoGUI"
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false -- Чтобы GUI не исчезало при респавне

-- Основной фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 600, 0, 400) -- Размер окна
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200) -- По центру
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Делаем окно перетаскиваемым (можно тащить за любую часть)
mainFrame.Parent = screenGui

-- Заголовок для красоты и указания, что окно можно тащить
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, 0, 1, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Xeno GUI"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.SourceSansBold
titleText.TextSize = 18
titleText.Parent = titleBar

-- Левая панель (1/3 ширины)
local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(1/3, 0, 1, -30) -- Вычитаем высоту заголовка
leftPanel.Position = UDim2.new(0, 0, 0, 30)
leftPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
leftPanel.BorderSizePixel = 0
leftPanel.Parent = mainFrame

-- Правая панель (2/3 ширины)
local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(2/3, 0, 1, -30)
rightPanel.Position = UDim2.new(1/3, 0, 0, 30)
rightPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
rightPanel.BorderSizePixel = 0
rightPanel.Parent = mainFrame

-- Вертикальное расположение кнопок в левой панели
local layout = Instance.new("UIListLayout")
layout.Parent = leftPanel
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

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

-- Функция для создания кнопки в левой панели
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

-- Функция для создания кнопки действия внутри правой панели
local function createActionButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 40)
    button.Position = UDim2.new(0, 5, 0, 0)
    button.Text = text
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 18
    button.BorderSizePixel = 0
    button.Parent = parent
    button.MouseButton1Click:Connect(callback)
    return button
end

-- Создаём кнопки-разделители
local combatBtn = createTabButton("Combat", Color3.fromRGB(80, 40, 40))
local miscBtn   = createTabButton("Misc", Color3.fromRGB(40, 80, 40))
local funnyBtn  = createTabButton("Funny", Color3.fromRGB(80, 80, 40))
local configBtn = createTabButton("Config", Color3.fromRGB(40, 40, 80))

-- === Реализация функций ===

-- Функция TP Behind (телепорт за спину ближайшего игрока)
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

    -- Ищем ближайшего игрока (кроме себя)
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
        -- Направление взгляда цели
        local lookVector = targetRoot.CFrame.LookVector
        -- Позиция немного сзади цели (за спиной)
        local behindPos = targetRoot.Position - lookVector * 5 -- 5 студий позади
        -- Телепортируем игрока
        character.HumanoidRootPart.CFrame = CFrame.new(behindPos) * CFrame.Angles(0, targetRoot.Orientation.Y * math.pi/180, 0)
        -- Небольшое уведомление
        print("TP Behind to " .. closestPlayer.Name)
    else
        warn("Нет других игроков")
    end
end

-- Функция Trip (имитация падения)
local function trip()
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        -- Принудительно переводим в состояние падения
        humanoid.Sit = true -- Вариант: заставить сидеть (fall имитирует сидение)
        wait(0.5)
        humanoid.Sit = false
        -- Другой вариант: применить силу
        -- character.HumanoidRootPart.Velocity = character.HumanoidRootPart.CFrame.LookVector * -50 + Vector3.new(0,20,0)
        print("Trip! (упал)")
    end
end

-- === Обработка нажатий на вкладки ===
combatBtn.MouseButton1Click:Connect(function()
    clearRightPanel()
    -- Создаём вертикальный список для кнопок
    local layout = Instance.new("UIListLayout")
    layout.Parent = contentContainer
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)

    -- Кнопка TP Behind
    createActionButton(contentContainer, "TP Behind", tpBehind)
end)

miscBtn.MouseButton1Click:Connect(function()
    clearRightPanel()
    -- Можно добавить что-то позже, пока просто текст
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.Text = "Здесь будут функции Misc"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.TextSize = 18
    label.Parent = contentContainer
end)

funnyBtn.MouseButton1Click:Connect(function()
    clearRightPanel()
    local layout = Instance.new("UIListLayout")
    layout.Parent = contentContainer
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)

    -- Кнопка Trip
    createActionButton(contentContainer, "Trip", trip)
end)

configBtn.MouseButton1Click:Connect(function()
    clearRightPanel()
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.Text = "Настройки пока не реализованы"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.TextSize = 18
    label.Parent = contentContainer
end)

-- Активируем вкладку Combat по умолчанию (опционально)
combatBtn.MouseButton1Click:Wait() -- Можно вызвать вручную
combatBtn.MouseButton1Click:Fire()

-- Уведомление о загрузке
print("Xeno GUI загружен!")
