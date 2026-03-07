--[[
    Xeno Click GUI
    Возможности:
    - Свернуть/развернуть GUI по Right Shift
    - Вкладки: Combat, Funny, Config
    - Combat: кнопка "TP Behind" (телепорт за спину ближайшего игрока)
    - Funny: кнопка "Peredoz" (радужный экран на 60 секунд)
    - Config: сохранение/загрузка конфига, выбор действия на ПКМ
    - Бинд на ПКМ (выполняет выбранное действие)
]]

-- Защита от повторного запуска
if _G.XenoGUI then
    _G.XenoGUI:Destroy()
    _G.XenoGUI = nil
end

-- Сервисы
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Конфиг по умолчанию
local defaultConfig = {
    rightClickBind = "None" -- "None", "TP Behind", "Peredoz"
}

local config = defaultConfig

-- Загрузка конфига из файла
local function loadConfig()
    local success, data = pcall(function()
        return readfile("xeno_gui_config.json")
    end)
    if success and data then
        local decoded = HttpService:JSONDecode(data)
        if type(decoded) == "table" then
            config = decoded
        end
    end
end

-- Сохранение конфига
local function saveConfig()
    local data = HttpService:JSONEncode(config)
    pcall(function()
        writefile("xeno_gui_config.json", data)
    end)
end

-- Загружаем конфиг при старте
loadConfig()

-- Создание GUI
local gui = Instance.new("ScreenGui")
gui.Name = "XenoClickGUI"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

_G.XenoGUI = gui

-- Основное окно (левая треть экрана)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0.3, 0, 1, 0) -- 30% ширины, вся высота
mainFrame.Position = UDim2.new(0, 0, 0, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = false
mainFrame.Parent = gui

-- Делаем окно перетаскиваемым (можно добавить заголовок позже)
local dragBar = Instance.new("Frame")
dragBar.Name = "DragBar"
dragBar.Size = UDim2.new(1, 0, 0, 30)
dragBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dragBar.BorderSizePixel = 0
dragBar.Parent = mainFrame

local dragButton = Instance.new("TextButton")
dragButton.Name = "DragButton"
dragButton.Size = UDim2.new(1, 0, 1, 0)
dragButton.BackgroundTransparency = 1
dragButton.Text = "Xeno GUI  |  Right Shift - свернуть/развернуть"
dragButton.TextColor3 = Color3.fromRGB(255, 255, 255)
dragButton.TextScaled = true
dragButton.Font = Enum.Font.SourceSansBold
dragButton.BorderSizePixel = 0
dragButton.Parent = dragBar

-- Функция перетаскивания
local dragging = false
local dragInput
local dragStart
local startPos

dragButton.MouseButton1Down:Connect(function(input)
    dragging = true
    dragStart = input.Position
    startPos = mainFrame.Position
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Контейнер для содержимого (под dragBar)
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Вкладки (кнопки переключения)
local tabButtonsFrame = Instance.new("Frame")
tabButtonsFrame.Name = "TabButtons"
tabButtonsFrame.Size = UDim2.new(1, 0, 0, 40)
tabButtonsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tabButtonsFrame.BorderSizePixel = 0
tabButtonsFrame.Parent = contentFrame

local combatTabButton = Instance.new("TextButton")
combatTabButton.Name = "CombatTab"
combatTabButton.Size = UDim2.new(0.33, -5, 1, -10)
combatTabButton.Position = UDim2.new(0, 5, 0, 5)
combatTabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
combatTabButton.Text = "Combat"
combatTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
combatTabButton.TextScaled = true
combatTabButton.Font = Enum.Font.SourceSans
combatTabButton.BorderSizePixel = 0
combatTabButton.Parent = tabButtonsFrame

local funnyTabButton = Instance.new("TextButton")
funnyTabButton.Name = "FunnyTab"
funnyTabButton.Size = UDim2.new(0.33, -5, 1, -10)
funnyTabButton.Position = UDim2.new(0.33, 0, 0, 5)
funnyTabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
funnyTabButton.Text = "Funny"
funnyTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
funnyTabButton.TextScaled = true
funnyTabButton.Font = Enum.Font.SourceSans
funnyTabButton.BorderSizePixel = 0
funnyTabButton.Parent = tabButtonsFrame

local configTabButton = Instance.new("TextButton")
configTabButton.Name = "ConfigTab"
configTabButton.Size = UDim2.new(0.33, -5, 1, -10)
configTabButton.Position = UDim2.new(0.66, 0, 0, 5)
configTabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
configTabButton.Text = "Config"
configTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
configTabButton.TextScaled = true
configTabButton.Font = Enum.Font.SourceSans
configTabButton.BorderSizePixel = 0
configTabButton.Parent = tabButtonsFrame

-- Область содержимого вкладок
local tabContent = Instance.new("Frame")
tabContent.Name = "TabContent"
tabContent.Size = UDim2.new(1, 0, 1, -40)
tabContent.Position = UDim2.new(0, 0, 0, 40)
tabContent.BackgroundTransparency = 1
tabContent.Parent = contentFrame

-- Функции для создания элементов вкладок

-- Combat tab
local combatTab = Instance.new("Frame")
combatTab.Name = "Combat"
combatTab.Size = UDim2.new(1, 0, 1, 0)
combatTab.BackgroundTransparency = 1
combatTab.Visible = true
combatTab.Parent = tabContent

local tpBehindButton = Instance.new("TextButton")
tpBehindButton.Name = "TPBehind"
tpBehindButton.Size = UDim2.new(0.8, 0, 0, 40)
tpBehindButton.Position = UDim2.new(0.1, 0, 0.1, 0)
tpBehindButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
tpBehindButton.Text = "TP Behind"
tpBehindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBehindButton.TextScaled = true
tpBehindButton.Font = Enum.Font.SourceSans
tpBehindButton.BorderSizePixel = 0
tpBehindButton.Parent = combatTab

-- Funny tab
local funnyTab = Instance.new("Frame")
funnyTab.Name = "Funny"
funnyTab.Size = UDim2.new(1, 0, 1, 0)
funnyTab.BackgroundTransparency = 1
funnyTab.Visible = false
funnyTab.Parent = tabContent

local peredozButton = Instance.new("TextButton")
peredozButton.Name = "Peredoz"
peredozButton.Size = UDim2.new(0.8, 0, 0, 40)
peredozButton.Position = UDim2.new(0.1, 0, 0.1, 0)
peredozButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
peredozButton.Text = "Peredoz (60s)"
peredozButton.TextColor3 = Color3.fromRGB(255, 255, 255)
peredozButton.TextScaled = true
peredozButton.Font = Enum.Font.SourceSans
peredozButton.BorderSizePixel = 0
peredozButton.Parent = funnyTab

-- Config tab
local configTab = Instance.new("Frame")
configTab.Name = "Config"
configTab.Size = UDim2.new(1, 0, 1, 0)
configTab.BackgroundTransparency = 1
configTab.Visible = false
configTab.Parent = tabContent

-- Выпадающий список для бинда ПКМ
local bindLabel = Instance.new("TextLabel")
bindLabel.Name = "BindLabel"
bindLabel.Size = UDim2.new(0.8, 0, 0, 30)
bindLabel.Position = UDim2.new(0.1, 0, 0.1, 0)
bindLabel.BackgroundTransparency = 1
bindLabel.Text = "ПКМ бинд:"
bindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
bindLabel.TextXAlignment = Enum.TextXAlignment.Left
bindLabel.Font = Enum.Font.SourceSans
bindLabel.TextScaled = true
bindLabel.Parent = configTab

local bindDropdown = Instance.new("TextButton")
bindDropdown.Name = "BindDropdown"
bindDropdown.Size = UDim2.new(0.8, 0, 0, 30)
bindDropdown.Position = UDim2.new(0.1, 0, 0.15, 5)
bindDropdown.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
bindDropdown.Text = config.rightClickBind
bindDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
bindDropdown.TextScaled = true
bindDropdown.Font = Enum.Font.SourceSans
bindDropdown.BorderSizePixel = 0
bindDropdown.Parent = configTab

-- Кнопки сохранения/загрузки
local saveButton = Instance.new("TextButton")
saveButton.Name = "SaveConfig"
saveButton.Size = UDim2.new(0.8, 0, 0, 40)
saveButton.Position = UDim2.new(0.1, 0, 0.3, 10)
saveButton.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
saveButton.Text = "Сохранить конфиг"
saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
saveButton.TextScaled = true
saveButton.Font = Enum.Font.SourceSans
saveButton.BorderSizePixel = 0
saveButton.Parent = configTab

local loadButton = Instance.new("TextButton")
loadButton.Name = "LoadConfig"
loadButton.Size = UDim2.new(0.8, 0, 0, 40)
loadButton.Position = UDim2.new(0.1, 0, 0.45, 20)
loadButton.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
loadButton.Text = "Загрузить конфиг"
loadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
loadButton.TextScaled = true
loadButton.Font = Enum.Font.SourceSans
loadButton.BorderSizePixel = 0
loadButton.Parent = configTab

-- Переключение вкладок
local function setActiveTab(tabName)
    combatTab.Visible = (tabName == "Combat")
    funnyTab.Visible = (tabName == "Funny")
    configTab.Visible = (tabName == "Config")
    
    -- Подсветка кнопок
    combatTabButton.BackgroundColor3 = (tabName == "Combat") and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(70, 70, 70)
    funnyTabButton.BackgroundColor3 = (tabName == "Funny") and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(70, 70, 70)
    configTabButton.BackgroundColor3 = (tabName == "Config") and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(70, 70, 70)
end

combatTabButton.MouseButton1Click:Connect(function() setActiveTab("Combat") end)
funnyTabButton.MouseButton1Click:Connect(function() setActiveTab("Funny") end)
configTabButton.MouseButton1Click:Connect(function() setActiveTab("Config") end)

-- Функционал TP Behind
function tpBehind()
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Находим ближайшего игрока (кроме себя)
    local closestPlayer = nil
    local closestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local targetChar = player.Character
            if targetChar then
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local dist = (rootPart.Position - targetRoot.Position).Magnitude
                    if dist < closestDistance then
                        closestDistance = dist
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    if closestPlayer then
        local targetChar = closestPlayer.Character
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            -- Получаем направление взгляда цели
            local lookVector = targetRoot.CFrame.LookVector
            -- Позиция за спиной (в 5 блоков позади)
            local behindPos = targetRoot.Position - lookVector * 5
            rootPart.CFrame = CFrame.new(behindPos) * CFrame.Angles(0, math.rad(180), 0) -- разворачиваем игрока лицом к цели
        end
    else
        warn("Нет других игроков для телепортации")
    end
end

tpBehindButton.MouseButton1Click:Connect(tpBehind)

-- Функционал Peredoz (радужный экран)
local rainbowEffect = nil
local rainbowConnection = nil

function startRainbow(duration)
    if rainbowEffect then
        rainbowEffect:Destroy()
        if rainbowConnection then
            rainbowConnection:Disconnect()
        end
    end
    
    -- Создаём полноэкранный затемнённый фрейм
    rainbowEffect = Instance.new("Frame")
    rainbowEffect.Name = "RainbowEffect"
    rainbowEffect.Size = UDim2.new(1, 0, 1, 0)
    rainbowEffect.BackgroundTransparency = 0.5
    rainbowEffect.BackgroundColor3 = Color3.new(1, 0, 0)
    rainbowEffect.BorderSizePixel = 0
    rainbowEffect.ZIndex = 10
    rainbowEffect.Parent = gui
    
    -- Анимация смены цвета (HSV)
    local hue = 0
    rainbowConnection = RunService.RenderStepped:Connect(function()
        hue = (hue + 0.005) % 1
        rainbowEffect.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
    end)
    
    -- Удаление через duration секунд
    task.wait(duration)
    if rainbowEffect then
        rainbowEffect:Destroy()
        rainbowEffect = nil
    end
    if rainbowConnection then
        rainbowConnection:Disconnect()
        rainbowConnection = nil
    end
end

peredozButton.MouseButton1Click:Connect(function()
    startRainbow(60)
end)

-- Система выпадающего списка для бинда
local dropdownItems = {"None", "TP Behind", "Peredoz"}
local dropdownVisible = false
local dropdownFrame

function updateBindDropdown()
    bindDropdown.Text = config.rightClickBind
end

bindDropdown.MouseButton1Click:Connect(function()
    if dropdownVisible then
        if dropdownFrame then
            dropdownFrame:Destroy()
            dropdownVisible = false
        end
        return
    end
    
    dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = "Dropdown"
    dropdownFrame.Size = UDim2.new(0.8, 0, 0, #dropdownItems * 30)
    dropdownFrame.Position = UDim2.new(0.1, 0, 0.15 + 0.05, 5 + 30) -- под кнопкой
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Parent = configTab
    dropdownVisible = true
    
    for i, item in ipairs(dropdownItems) do
        local btn = Instance.new("TextButton")
        btn.Name = "Item_"..item
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.Position = UDim2.new(0, 0, 0, (i-1)*30)
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        btn.Text = item
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.SourceSans
        btn.BorderSizePixel = 0
        btn.Parent = dropdownFrame
        
        btn.MouseButton1Click:Connect(function()
            config.rightClickBind = item
            updateBindDropdown()
            dropdownFrame:Destroy()
            dropdownVisible = false
            saveConfig() -- автосохранение при изменении
        end)
    end
end)

-- Сохранение и загрузка конфига
saveButton.MouseButton1Click:Connect(saveConfig)

loadButton.MouseButton1Click:Connect(function()
    loadConfig()
    updateBindDropdown()
end)

-- Обработка ПКМ (бинды)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if config.rightClickBind == "TP Behind" then
            tpBehind()
        elseif config.rightClickBind == "Peredoz" then
            startRainbow(60)
        end
    end
end)

-- Сворачивание/разворачивание по Right Shift
local isMinimized = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        isMinimized = not isMinimized
        mainFrame.Visible = not isMinimized
    end
end)

-- Инициализация
setActiveTab("Combat")
updateBindDropdown()

print("Xeno Click GUI загружен. Нажмите Right Shift, чтобы свернуть/развернуть.")
