-- Создаём основной GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ExpensiveGUI"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 600, 0, 500)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true   -- чтобы можно было перетаскивать
mainFrame.Parent = screenGui

-- Скругление углов (опционально)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "EXPENSIVE"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Панель вкладок (просто текст, без функционала)
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(1, 0, 0, 30)
tabsFrame.Position = UDim2.new(0, 0, 0, 40)
tabsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tabsFrame.BorderSizePixel = 0
tabsFrame.Parent = mainFrame

-- Список вкладок
local tabs = {"Combat", "Movement", "Player", "Render", "Misc", "Theme", "Configurations"}
local tabButtons = {}
local tabX = 5
for i, tabName in ipairs(tabs) do
	local tab = Instance.new("TextButton")
	tab.Size = UDim2.new(0, 80, 0, 20)
	tab.Position = UDim2.new(0, tabX, 0, 5)
	tab.Text = tabName
	tab.TextColor3 = Color3.fromRGB(200, 200, 200)
	tab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	tab.BorderSizePixel = 0
	tab.AutoButtonColor = false   -- без реакции на нажатие
	tab.Parent = tabsFrame
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 4)
	btnCorner.Parent = tab
	
	tabX = tabX + 85
end

-- Основная область с функциями
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -90)
contentFrame.Position = UDim2.new(0, 10, 0, 80)
contentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = contentFrame

-- Внутренний отступ
local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingTop = UDim.new(0, 10)
padding.Parent = contentFrame

-- Создаём элементы, как на скриншоте
local yPos = 0

-- Функция для создания заголовка секции
local function createSection(title)
	local section = Instance.new("TextLabel")
	section.Size = UDim2.new(1, 0, 0, 25)
	section.Position = UDim2.new(0, 0, 0, yPos)
	section.BackgroundTransparency = 1
	section.Text = title
	section.TextColor3 = Color3.fromRGB(180, 180, 180)
	section.TextXAlignment = Enum.TextXAlignment.Left
	section.Font = Enum.Font.GothamSemibold
	section.TextSize = 16
	section.Parent = contentFrame
	yPos = yPos + 30
end

-- Функция для создания элемента с переключателем и ползунком/текстом
local function createItem(name, hasToggle, toggleState, hasSlider, sliderText, extra)
	local itemFrame = Instance.new("Frame")
	itemFrame.Size = UDim2.new(1, 0, 0, 35)
	itemFrame.Position = UDim2.new(0, 0, 0, yPos)
	itemFrame.BackgroundTransparency = 1
	itemFrame.Parent = contentFrame
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0, 120, 1, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextSize = 14
	nameLabel.Parent = itemFrame
	
	local xOffset = 130
	
	if hasToggle then
		local toggleFrame = Instance.new("Frame")
		toggleFrame.Size = UDim2.new(0, 50, 0, 20)
		toggleFrame.Position = UDim2.new(0, xOffset, 0.5, -10)
		toggleFrame.BackgroundColor3 = toggleState and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
		toggleFrame.BorderSizePixel = 0
		toggleFrame.Parent = itemFrame
		
		local toggleCorner = Instance.new("UICorner")
		toggleCorner.CornerRadius = UDim.new(1, 0)
		toggleCorner.Parent = toggleFrame
		
		local toggleText = Instance.new("TextLabel")
		toggleText.Size = UDim2.new(1, 0, 1, 0)
		toggleText.BackgroundTransparency = 1
		toggleText.Text = toggleState and "Включен" or "Выключен"
		toggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
		toggleText.TextSize = 12
		toggleText.Parent = toggleFrame
		
		xOffset = xOffset + 60
	end
	
	if hasSlider then
		local sliderLabel = Instance.new("TextLabel")
		sliderLabel.Size = UDim2.new(0, 80, 1, 0)
		sliderLabel.Position = UDim2.new(0, xOffset, 0, 0)
		sliderLabel.BackgroundTransparency = 1
		sliderLabel.Text = sliderText
		sliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
		sliderLabel.Font = Enum.Font.Gotham
		sliderLabel.TextSize = 12
		sliderLabel.Parent = itemFrame
		
		xOffset = xOffset + 90
	end
	
	if extra then
		local extraLabel = Instance.new("TextLabel")
		extraLabel.Size = UDim2.new(0, 100, 1, 0)
		extraLabel.Position = UDim2.new(0, xOffset, 0, 0)
		extraLabel.BackgroundTransparency = 1
		extraLabel.Text = extra
		extraLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		extraLabel.TextXAlignment = Enum.TextXAlignment.Left
		extraLabel.Font = Enum.Font.Gotham
		extraLabel.TextSize = 12
		extraLabel.Parent = itemFrame
	end
	
	yPos = yPos + 40
end

-- Заполняем контент в соответствии со скриншотом
createSection("Combat")

createItem("AutoAlarms", true, true, true, "Задержка: 100.0")
createItem("AutoSweep", true, false, false, nil)  -- просто включено/выключено? на скрине нет доп. параметров

createItem("AntiBlast", true, true, true, "Предел щит", "Скачать на: Генны   MOUSE100 Кнопка")

createItem("AutoExploit", true, true, true, "Здоровье: 16.0")
createItem("AutoGetem", true, false, false, nil)

createItem("AutoFusion", true, true, true, "Низкий")

createItem("AutoRiot", true, true, true, "Здоровье: 3.5", "Мод Обычный")

-- Добавим три дополнительные кнопки AutoRiot, как на скрине
local riotFrame = Instance.new("Frame")
riotFrame.Size = UDim2.new(1, 0, 0, 30)
riotFrame.Position = UDim2.new(0, 0, 0, yPos)
riotFrame.BackgroundTransparency = 1
riotFrame.Parent = contentFrame

for i = 1, 3 do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 80, 0, 25)
	btn.Position = UDim2.new(0, (i-1)*85, 0, 0)
	btn.Text = "AutoRiot"
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Parent = riotFrame
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 4)
	btnCorner.Parent = btn
end

yPos = yPos + 40

-- На случай если контент выходит за границы, установим размер Canvas для возможного ScrollingFrame, но мы не добавляли скролл.
-- Для простоты оставим так. Если нужно, можно обернуть contentFrame в ScrollingFrame.

print("GUI загружен (без функций)")
