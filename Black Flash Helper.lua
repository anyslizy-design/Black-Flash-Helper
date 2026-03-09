
--[[
    ██████╗ ██╗      █████╗  ██████╗██╗  ██╗    ██╗  ██╗ ██████╗ ██╗     ███████╗
    ██╔══██╗██║     ██╔══██╗██╔════╝██║  ██║    ██║  ██║██╔═══██╗██║     ██╔════╝
    ██████╔╝██║     ███████║██║     ███████║    ███████║██║   ██║██║     █████╗  
    ██╔══██╗██║     ██╔══██║██║     ██╔══██║    ██╔══██║██║   ██║██║     ██╔══╝  
    ██████╔╝███████╗██║  ██║╚██████╗██║  ██║    ██║  ██║╚██████╔╝███████╗███████╗
    ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝
    
    Эффект "Чёрная дыра" — максимально плавно, без звуков, только графика.
    Искажение пространства, вращение, расширение из сингулярности.
]]

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlackHoleGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Эффект искажения (размытие)
local Blur = Instance.new("BlurEffect")
Blur.Name = "BlackHoleBlur"
Blur.Size = 0
Blur.Enabled = true
Blur.Parent = Camera

-- Основной круг — абсолютно чёрный
local BlackHole = Instance.new("ImageLabel")
BlackHole.Name = "BlackHole"
BlackHole.Size = UDim2.new(0, 8, 0, 4)         -- изначально сплющен, как горизонт событий
BlackHole.Position = UDim2.new(0.5, -4, 0.5, -2)
BlackHole.BackgroundTransparency = 1
BlackHole.Image = "rbxassetid://3570695787"    -- радиальный градиент (можно заменить на сплошной круг)
BlackHole.ImageColor3 = Color3.new(0, 0, 0)    -- чисто чёрный
BlackHole.ImageTransparency = 0.2
BlackHole.Rotation = 0
BlackHole.ZIndex = 10
BlackHole.Parent = ScreenGui

-- Свечение аккреционного диска (тонкое белое кольцо)
local Glow = Instance.new("ImageLabel")
Glow.Name = "AccretionGlow"
Glow.Size = BlackHole.Size
Glow.Position = BlackHole.Position
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://3570695787"
Glow.ImageColor3 = Color3.new(1, 1, 1)
Glow.ImageTransparency = 0.9
Glow.Rotation = 0
Glow.ZIndex = 9
Glow.Parent = ScreenGui

-- Параметры анимации (длительность 4 секунды)
local AnimDuration = 4.0
local FinalSize = 650
local MaxBlur = 35

-- ФАЗА 1: Быстрое искажение (0.6 сек) — чёрная дыра вытягивается, вращается, размытие нарастает
local Phase1Dur = 0.6
local Phase1Info = TweenInfo.new(
    Phase1Dur,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out,
    0,
    false,
    0
)

local Phase1Hole = TweenService:Create(BlackHole, Phase1Info, {
    Size = UDim2.new(0, 300, 0, 80),        -- сильно вытянута по горизонтали
    Position = UDim2.new(0.5, -150, 0.5, -40),
    Rotation = 180,
    ImageTransparency = 0.1
})

local Phase1Glow = TweenService:Create(Glow, Phase1Info, {
    Size = UDim2.new(0, 330, 0, 100),
    Position = UDim2.new(0.5, -165, 0.5, -50),
    Rotation = -120,
    ImageTransparency = 0.7
})

local Phase1Blur = TweenService:Create(Blur, Phase1Info, {
    Size = 20
})

-- ФАЗА 2: Расширение и округление (оставшееся время) — дыра превращается в идеальный круг, вращение замедляется
local Phase2Info = TweenInfo.new(
    AnimDuration - Phase1Dur,
    Enum.EasingStyle.Exponential,
    Enum.EasingDirection.Out,
    0,
    false,
    0
)

local Phase2Hole = TweenService:Create(BlackHole, Phase2Info, {
    Size = UDim2.new(0, FinalSize, 0, FinalSize),
    Position = UDim2.new(0.5, -FinalSize/2, 0.5, -FinalSize/2),
    Rotation = 720,                          -- продолжает вращение (суммарно ~900° за всю анимацию)
    ImageTransparency = 0.05
})

local Phase2Glow = TweenService:Create(Glow, Phase2Info, {
    Size = UDim2.new(0, FinalSize * 1.12, 0, FinalSize * 1.12),
    Position = UDim2.new(0.5, -FinalSize * 0.56, 0.5, -FinalSize * 0.56),
    Rotation = -540,
    ImageTransparency = 0.5
})

local Phase2Blur = TweenService:Create(Blur, Phase2Info, {
    Size = MaxBlur
})

-- Последовательный запуск
Phase1Hole.Completed:Connect(function()
    Phase2Hole:Play()
    Phase2Glow:Play()
    Phase2Blur:Play()
end)

-- Старт
Phase1Hole:Play()
Phase1Glow:Play()
Phase1Blur:Play()

-- Постоянное микро-вращение после завершения (для атмосферы)
local SpinConnection
SpinConnection = RunService.Heartbeat:Connect(function(dt)
    if Phase2Hole.PlaybackState == Enum.PlaybackState.Completed then
        BlackHole.Rotation = BlackHole.Rotation + dt * 5
        Glow.Rotation = Glow.Rotation - dt * 8
    end
end)

-- Чистка при нажатии Delete (скрыть эффект)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Delete then
        SpinConnection:Disconnect()
        Blur:Destroy()
        ScreenGui:Destroy()
    end
end)

print("Чёрная дыра активирована. Нажми Delete, чтобы закрыть. Звуков нет.")
