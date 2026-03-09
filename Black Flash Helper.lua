--[[
    ███████╗███╗   ██╗███████╗ ██████╗     ██╗   ██╗ █████╗ ██╗    ██╗
    ██╔════╝████╗  ██║██╔════╝██╔═══██╗    ██║   ██║██╔══██╗██║    ██║
    █████╗  ██╔██╗ ██║█████╗  ██║   ██║    ██║   ██║███████║██║ █╗ ██║
    ██╔══╝  ██║╚██╗██║██╔══╝  ██║   ██║    ╚██╗ ██╔╝██╔══██║██║███╗██║
    ███████╗██║ ╚████║██║     ╚██████╔╝     ╚████╔╝ ██║  ██║╚███╔███╔╝
    ╚══════╝╚═╝  ╚═══╝╚═╝      ╚═════╝       ╚═══╝  ╚═╝  ╚═╝ ╚══╝╚══╝ 
    
    Оптимизированный скрипт с эффектом "WOW" для Xeno
    Плавное появление круга с искажением и вращением.
]]

-- Проверка окружения (для совместимости с Xeno)
if not game:GetService("Players").LocalPlayer then
    return warn("Скрипт должен выполняться в клиентском контексте (LocalScript).")
end

-- Кэширование сервисов
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Создаём ScreenGui (будет поверх всего)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WOWEffectGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Добавляем эффект размытия (искажение пространства)
local Blur = Instance.new("BlurEffect")
Blur.Name = "MenuBlur"
Blur.Size = 0
Blur.Enabled = true
Blur.Parent = Camera

-- Основной круг (будем использовать ImageLabel для красивого градиента)
local Circle = Instance.new("ImageLabel")
Circle.Name = "MainCircle"
Circle.Size = UDim2.new(0, 10, 0, 10) -- начнём с малого
Circle.Position = UDim2.new(0.5, -5, 0.5, -5) -- центр экрана
Circle.BackgroundTransparency = 1
Circle.Image = "rbxassetid://3570695787" -- круг с мягким градиентом (можно заменить)
Circle.ImageColor3 = Color3.fromRGB(0, 170, 255)
Circle.ImageTransparency = 0.3
Circle.Rotation = 0
Circle.ZIndex = 10
Circle.Parent = ScreenGui

-- Добавим второй круг для дополнительного эффекта вращения
local InnerCircle = Instance.new("ImageLabel")
InnerCircle.Name = "InnerCircle"
InnerCircle.Size = UDim2.new(0, 10, 0, 10)
InnerCircle.Position = UDim2.new(0.5, -5, 0.5, -5)
InnerCircle.BackgroundTransparency = 1
InnerCircle.Image = "rbxassetid://3570695787" -- можно другое изображение
InnerCircle.ImageColor3 = Color3.fromRGB(255, 255, 255)
InnerCircle.ImageTransparency = 0.6
InnerCircle.Rotation = 0
InnerCircle.ZIndex = 11
InnerCircle.Parent = ScreenGui

-- Параметры анимации
local AnimationTime = 1.2 -- секунды
local FinalSize = 600 -- конечный размер круга (ширина/высота)
local StartBlur = 0
local EndBlur = 20 -- максимальное размытие

-- Создаём твины (анимации)
local TweenInfo = TweenInfo.new(
    AnimationTime,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out,
    0,
    false,
    0
)

-- Анимация для основного круга
local CircleTween = TweenService:Create(Circle, TweenInfo, {
    Size = UDim2.new(0, FinalSize, 0, FinalSize),
    Position = UDim2.new(0.5, -FinalSize/2, 0.5, -FinalSize/2),
    ImageTransparency = 0.1,
    Rotation = 360 -- полный оборот
})

-- Анимация для внутреннего круга (вращается в другую сторону)
local InnerTween = TweenService:Create(InnerCircle, TweenInfo, {
    Size = UDim2.new(0, FinalSize * 0.8, 0, FinalSize * 0.8),
    Position = UDim2.new(0.5, -FinalSize * 0.4, 0.5, -FinalSize * 0.4),
    ImageTransparency = 0.3,
    Rotation = -360 -- обратное вращение
})

-- Анимация для размытия
local BlurTween = TweenService:Create(Blur, TweenInfo, {
    Size = EndBlur
})

-- Запускаем анимации одновременно
CircleTween:Play()
InnerTween:Play()
BlurTween:Play()

-- Дополнительный эффект: вращение с помощью RunService для более плавного бесконечного вращения после завершения твина?
-- Но твин уже включает вращение, после окончания остановится. Можно сделать бесконечное вращение.
-- Чтобы после анимации круг продолжал медленно вращаться, создадим отдельный поток.

local RunConnection
RunConnection = RunService.Heartbeat:Connect(function(dt)
    -- Постоянное вращение после завершения твина (очень медленное)
    if CircleTween.PlaybackState == Enum.PlaybackState.Completed then
        Circle.Rotation = Circle.Rotation + dt * 10 -- 10 градусов в секунду
        InnerCircle.Rotation = InnerCircle.Rotation - dt * 15 -- обратное вращение
    end
end)

-- Чистка при выгрузке скрипта (если пользователь захочет отключить)
local function Cleanup()
    RunConnection:Disconnect()
    Blur:Destroy()
    ScreenGui:Destroy()
end

-- Добавляем возможность закрыть GUI по нажатию клавиши (например, Delete)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Delete then
        Cleanup()
    end
end)

-- Информируем пользователя (опционально)
print("WOW эффект активирован! Нажмите Delete для закрытия.")
