
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Эффекты освещения для искажения пространства
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.Contrast = 0.5
colorCorrection.Saturation = 0.5
colorCorrection.TintColor = Color3.fromRGB(200, 0, 255) -- фиолетовый оттенок
colorCorrection.Enabled = false
colorCorrection.Parent = Lighting

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RadialMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

-- Фон для затемнения
local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.new(0, 0, 0)
background.BackgroundTransparency = 1
background.Parent = screenGui

local UICornerBackground = Instance.new("UICorner")
UICornerBackground.CornerRadius = UDim.new(0, 0)
UICornerBackground.Parent = background

-- Круглый контейнер меню
local menuContainer = Instance.new("Frame")
menuContainer.Size = UDim2.new(0, 20, 0, 20) -- стартовый маленький круг
menuContainer.Position = UDim2.new(0.5, -10, 0.5, -10)
menuContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
menuContainer.BackgroundTransparency = 0.2
menuContainer.ClipsDescendants = true
menuContainer.Parent = screenGui

-- Сглаженные углы для круга
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0) -- максимально круглый
UICorner.Parent = menuContainer

-- Внутренний круг для свечения
local glow = Instance.new("ImageLabel")
glow.Size = UDim2.new(1, 20, 1, 20)
glow.Position = UDim2.new(0.5, -10, 0.5, -10)
glow.BackgroundTransparency = 1
glow.Image = "rbxasset://textures/ui/Glow.png"
glow.ImageColor3 = Color3.fromRGB(150, 0, 255)
glow.ImageTransparency = 0.5
glow.Parent = menuContainer

-- Вращающийся элемент (кольцо)
local ring = Instance.new("ImageLabel")
ring.Size = UDim2.new(0.8, 0, 0.8, 0)
ring.Position = UDim2.new(0.5, 0, 0.5, 0)
ring.AnchorPoint = Vector2.new(0.5, 0.5)
ring.BackgroundTransparency = 1
ring.Image = "rbxasset://textures/ui/ShinyRing.png" -- или любая кольцевая текстура, можно создать свою
ring.ImageColor3 = Color3.fromRGB(200, 100, 255)
ring.ImageTransparency = 0.7
ring.Rotation = 0
ring.Parent = menuContainer

-- Текст внутри меню (появится после анимации)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.6, 0, 0.2, 0)
title.Position = UDim2.new(0.5, 0, 0.5, 0)
title.AnchorPoint = Vector2.new(0.5, 0.5)
title.BackgroundTransparency = 1
title.Text = "muqo666"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Visible = false
title.Parent = menuContainer

-- Параметры анимации
local animLength = 2.5
local expandTweenInfo = TweenInfo.new(
	animLength,
	Enum.EasingStyle.Exponential,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

local expandGoal = {
	Size = UDim2.new(0, 400, 0, 400),
	Position = UDim2.new(0.5, -200, 0.5, -200),
	BackgroundTransparency = 0
}

local backgroundTweenInfo = TweenInfo.new(
	animLength,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.Out
)
local backgroundGoal = {
	BackgroundTransparency = 0.7
}

-- Функции анимации
local function animateEffects()
	-- Включаем цветокоррекцию
	colorCorrection.Enabled = true
	
	-- Tween для размытия
	local blurTween = TweenService:Create(blur, TweenInfo.new(animLength, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 8})
	blurTween:Play()
	
	-- Tween для контраста и насыщения
	local contrastGoal = {Contrast = 0.2}
	local saturationGoal = {Saturation = 0.8}
	local tintGoal = {TintColor = Color3.fromRGB(255, 100, 255)}
	local ccTween1 = TweenService:Create(colorCorrection, TweenInfo.new(animLength, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), contrastGoal)
	local ccTween2 = TweenService:Create(colorCorrection, TweenInfo.new(animLength, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), saturationGoal)
	local ccTween3 = TweenService:Create(colorCorrection, TweenInfo.new(animLength, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), tintGoal)
	ccTween1:Play()
	ccTween2:Play()
	ccTween3:Play()
	
	-- Вращение кольца
	local rotation = 0
	local connection
	connection = RunService.Heartbeat:Connect(function(dt)
		if not menuContainer or not menuContainer.Parent then connection:Disconnect() return end
		rotation = rotation + dt * 60 -- 60 градусов в секунду
		ring.Rotation = rotation
	end)
	
	-- Асинхронно добавляем пульсацию размера
	spawn(function()
		wait(0.5)
		local pulseTween1 = TweenService:Create(menuContainer, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Size = UDim2.new(0, 420, 0, 420)})
		pulseTween1:Play()
	end)
end

-- Запуск анимации
local expandTween = TweenService:Create(menuContainer, expandTweenInfo, expandGoal)
local backgroundTween = TweenService:Create(background, backgroundTweenInfo, backgroundGoal)

expandTween:Play()
backgroundTween:Play()
animateEffects()

-- По окончании анимации показываем текст
expandTween.Completed:Connect(function()
	title.Visible = true
	title.TextTransparency = 1
	local fadeIn = TweenService:Create(title, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0})
	fadeIn:Play()
end)

-- При клике вне меню можно скрывать (опционально)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		-- проверка клика вне меню
		local mousePos = UserInputService:GetMouseLocation()
		local absolutePos = menuContainer.AbsolutePosition
		local absoluteSize = menuContainer.AbsoluteSize
		if mousePos.X < absolutePos.X or mousePos.X > absolutePos.X + absoluteSize.X or mousePos.Y < absolutePos.Y or mousePos.Y > absolutePos.Y + absoluteSize.Y then
			-- закрываем меню с обратной анимацией
			local closeTween = TweenService:Create(menuContainer, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
			closeTween:Play()
			closeTween.Completed:Connect(function()
				screenGui:Destroy()
				-- убираем эффекты
				blur:Destroy()
				colorCorrection:Destroy()
			end)
		end
	end
end)

-- Чистка при уничтожении gui (на случай, если игрок уйдет)
player:Destroying:Connect(function()
	if screenGui then screenGui:Destroy() end
	if blur then blur:Destroy() end
	if colorCorrection then colorCorrection:Destroy() end
end)
