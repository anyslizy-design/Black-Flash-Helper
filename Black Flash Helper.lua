
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "CoolMenu"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Затемнение фона
local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.new(0, 0, 0)
background.BackgroundTransparency = 1
background.Parent = gui

-- Контейнер меню
local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 50, 0, 50)
menu.Position = UDim2.new(0.5, -25, 0.5, -25)
menu.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
menu.BackgroundTransparency = 0.2
menu.Parent = gui

-- Скругление (круг)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = menu

-- Внутреннее свечение (стандартная текстура)
local glow = Instance.new("ImageLabel")
glow.Size = UDim2.new(1, 20, 1, 20)
glow.Position = UDim2.new(0.5, -10, 0.5, -10)
glow.BackgroundTransparency = 1
glow.Image = "rbxasset://textures/ui/Glow.png"
glow.ImageColor3 = Color3.fromRGB(200, 0, 255)
glow.ImageTransparency = 0.6
glow.Parent = menu

-- Вращающееся кольцо (стандартная текстура)
local ring = Instance.new("ImageLabel")
ring.Size = UDim2.new(0.8, 0, 0.8, 0)
ring.Position = UDim2.new(0.5, 0, 0.5, 0)
ring.AnchorPoint = Vector2.new(0.5, 0.5)
ring.BackgroundTransparency = 1
ring.Image = "rbxasset://textures/ui/ShinyRing.png"
ring.ImageColor3 = Color3.fromRGB(255, 100, 255)
ring.ImageTransparency = 0.5
ring.Parent = menu

-- Маленькие звездочки вокруг (стандартная текстура)
local stars = {}
for i = 1, 6 do
	local star = Instance.new("ImageLabel")
	star.Size = UDim2.new(0, 15, 0, 15)
	star.AnchorPoint = Vector2.new(0.5, 0.5)
	local angle = (i / 6) * math.pi * 2
	star.Position = UDim2.new(0.5 + math.cos(angle) * 0.5, 0, 0.5 + math.sin(angle) * 0.5, 0)
	star.BackgroundTransparency = 1
	star.Image = "rbxasset://textures/ui/Gooey/Star.png"
	star.ImageColor3 = Color3.fromRGB(255, 200, 0)
	star.ImageTransparency = 0.3
	star.Parent = menu
	stars[i] = star
end

-- Текст
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(0.7, 0, 0.3, 0)
textLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
textLabel.BackgroundTransparency = 1
textLabel.Text = "muqo666"
textLabel.TextColor3 = Color3.new(1, 1, 1)
textLabel.TextScaled = true
textLabel.Font = Enum.Font.GothamBold
textLabel.Visible = false
textLabel.Parent = menu

-- Анимация появления
local expand = TweenService:Create(
	menu,
	TweenInfo.new(2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	{Size = UDim2.new(0, 350, 0, 350), Position = UDim2.new(0.5, -175, 0.5, -175), BackgroundTransparency = 0}
)
local fadeBg = TweenService:Create(
	background,
	TweenInfo.new(2),
	{BackgroundTransparency = 0.6}
)
expand:Play()
fadeBg:Play()

-- Вращение кольца
local rot = 0
local rotationConnection
rotationConnection = RunService.Heartbeat:Connect(function(dt)
	if not menu.Parent then rotationConnection:Disconnect() return end
	rot = rot + dt * 60
	ring.Rotation = rot
end)

-- Пульсация звезд
for _, star in ipairs(stars) do
	TweenService:Create(star, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Size = UDim2.new(0, 20, 0, 20)}):Play()
end

-- Показываем текст после анимации
expand.Completed:Connect(function()
	textLabel.Visible = true
	TweenService:Create(textLabel, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
end)

-- Закрытие по клику вне меню
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local mousePos = UserInputService:GetMouseLocation()
		local absPos = menu.AbsolutePosition
		local absSize = menu.AbsoluteSize
		if mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X or mousePos.Y < absPos.Y or mousePos.Y > absPos.Y + absSize.Y then
			local close = TweenService:Create(menu, TweenInfo.new(0.5), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
			close:Play()
			close.Completed:Connect(function() gui:Destroy() end)
		end
	end
end)
