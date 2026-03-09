
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Эффекты освещения (искажение пространства)
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.Contrast = 0.5
colorCorrection.Saturation = 0.5
colorCorrection.TintColor = Color3.fromRGB(200, 0, 255)
colorCorrection.Enabled = false
colorCorrection.Parent = Lighting

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RadialMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Затемнение фона
local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.new(0, 0, 0)
background.BackgroundTransparency = 1
background.Parent = screenGui

-- Основной круглый контейнер
local menuContainer = Instance.new("Frame")
menuContainer.Size = UDim2.new(0, 20, 0, 20)
menuContainer.Position = UDim2.new(0.5, -10, 0.5, -10)
menuContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
menuContainer.BackgroundTransparency = 0.2
menuContainer.ClipsDescendants = true
menuContainer.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = menuContainer

-- Внутренний круг (для красоты)
local innerCircle = Instance.new("Frame")
innerCircle.Size = UDim2.new(0.8, 0, 0.8, 0)
innerCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
innerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
innerCircle.BackgroundColor3 = Color3.fromRGB(140, 0, 255)
innerCircle.BackgroundTransparency = 0.4
local innerCorner = Instance.new("UICorner")
innerCorner.CornerRadius = UDim.new(1, 0)
innerCorner.Parent = innerCircle
innerCircle.Parent = menuContainer

-- Вращающиеся частицы по кругу
local orbitContainer = Instance.new("Frame")
orbitContainer.Size = UDim2.new(1, 0, 1, 0)
orbitContainer.BackgroundTransparency = 1
orbitContainer.Parent = menuContainer

local particles = {}
for i = 1, 8 do
	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 8, 0, 8)
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	local angle = (i / 8) * math.pi * 2
	dot.Position = UDim2.new(0.5 + math.cos(angle) * 0.4, 0, 0.5 + math.sin(angle) * 0.4, 0)
	dot.BackgroundColor3 = Color3.fromRGB(200, 100, 255)
	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = dot
	dot.Parent = orbitContainer
	particles[i] = dot
end

-- Текст в центре
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

-- Анимация расширения
local expandTween = TweenService:Create(
	menuContainer,
	TweenInfo.new(2.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
	{Size = UDim2.new(0, 400, 0, 400), Position = UDim2.new(0.5, -200, 0.5, -200), BackgroundTransparency = 0}
)

local backgroundTween = TweenService:Create(
	background,
	TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
	{BackgroundTransparency = 0.7}
)

-- Включение эффектов и вращение
expandTween:Play()
backgroundTween:Play()

-- Активируем искажения
colorCorrection.Enabled = true
TweenService:Create(blur, TweenInfo.new(2.5), {Size = 10}):Play()
TweenService:Create(colorCorrection, TweenInfo.new(2.5), {Contrast = 0.2, Saturation = 0.7, TintColor = Color3.fromRGB(255, 100, 255)}):Play()

-- Вращение частиц
local angleOffset = 0
local rotateConnection
rotateConnection = RunService.Heartbeat:Connect(function(dt)
	if not menuContainer.Parent then rotateConnection:Disconnect() return end
	angleOffset = angleOffset + dt * 1.5
	for i, dot in ipairs(particles) do
		local angle = (i / 8) * math.pi * 2 + angleOffset
		dot.Position = UDim2.new(0.5 + math.cos(angle) * 0.4, 0, 0.5 + math.sin(angle) * 0.4, 0)
	end
end)

-- Показываем текст после анимации
expandTween.Completed:Connect(function()
	title.Visible = true
	TweenService:Create(title, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
end)

-- Закрытие по клику вне меню
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local mousePos = UserInputService:GetMouseLocation()
		local absPos = menuContainer.AbsolutePosition
		local absSize = menuContainer.AbsoluteSize
		if mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X or mousePos.Y < absPos.Y or mousePos.Y > absPos.Y + absSize.Y then
			-- Закрываем меню
			local closeTween = TweenService:Create(menuContainer, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
			closeTween:Play()
			closeTween.Completed:Connect(function()
				screenGui:Destroy()
				blur:Destroy()
				colorCorrection:Destroy()
			end)
		end
	end
end)

-- Очистка при выгрузке
player:Destroying:Connect(function()
	if screenGui then screenGui:Destroy() end
	if blur then blur:Destroy() end
	if colorCorrection then colorCorrection:Destroy() end
end)
