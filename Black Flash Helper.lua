--[[
    GONDON.SENSE Premium Interface
    Совместимость: Xeno / Любой современный инжектор
    Описание: Обновленный визуальный стиль с приветственным баннером и названием GONDON.SENSE.
]]

local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Поиск события блока
local blockRemote = ReplicatedStorage:FindFirstChild("Block", true) or ReplicatedStorage:FindFirstChild("CombatRes", true)

-- Функция создания приветственного баннера
local function createBigBanner()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "JJS_BigBanner"
    screenGui.Parent = (gethui and gethui()) or CoreGui or Player:WaitForChild("PlayerGui")
    
    local banner = Instance.new("TextLabel")
    banner.Size = UDim2.new(1, 0, 0, 100)
    banner.Position = UDim2.new(0, 0, -0.2, 0) -- Начинаем за пределами экрана
    banner.BackgroundTransparency = 1
    banner.Text = "ГОНДОН"
    banner.TextColor3 = Color3.fromRGB(255, 0, 0)
    banner.TextSize = 80
    banner.Font = Enum.Font.GothamBlack
    banner.TextStrokeTransparency = 0
    banner.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    banner.Parent = screenGui
    
    -- Анимация появления
    TweenService:Create(banner, TweenInfo.new(1, Enum.EasingStyle.Back), {Position = UDim2.new(0, 0, 0.1, 0)}):Play()
    
    -- Исчезновение через 3 секунды
    task.delay(3.5, function()
        local t = TweenService:Create(banner, TweenInfo.new(1, Enum.EasingStyle.Quad), {TextTransparency = 1, TextStrokeTransparency = 1})
        t:Play()
        t.Completed:Wait()
        screenGui:Destroy()
    end)
end

-- Создание премиального Watermark
local function createWatermark()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GONDON_SENSE_V4"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = (gethui and gethui()) or CoreGui or Player:WaitForChild("PlayerGui")
    
    local holder = Instance.new("Frame")
    holder.Name = "Holder"
    holder.Size = UDim2.new(0, 260, 0, 35)
    holder.Position = UDim2.new(0, 20, 0, 20)
    holder.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    holder.BorderSizePixel = 0
    holder.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = holder
    
    local gradientBar = Instance.new("Frame")
    gradientBar.Size = UDim2.new(1, 0, 0, 2)
    gradientBar.Position = UDim2.new(0, 0, 0, 0)
    gradientBar.BorderSizePixel = 0
    gradientBar.Parent = holder
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 4)
    barCorner.Parent = gradientBar
    
    local uigradient = Instance.new("UIGradient")
    uigradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 43, 226))
    })
    uigradient.Parent = gradientBar
    
    task.spawn(function()
        while true do
            local t = tick() * 0.5
            uigradient.Offset = Vector2.new(math.sin(t), 0)
            task.wait()
        end
    end)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(40, 40, 40)
    stroke.Thickness = 1
    stroke.Parent = holder

    local brand = Instance.new("TextLabel")
    brand.Size = UDim2.new(0, 100, 1, 0)
    brand.Position = UDim2.new(0, 10, 0, 1)
    brand.BackgroundTransparency = 1
    brand.Text = "gondon.sense"
    brand.TextColor3 = Color3.fromRGB(255, 255, 255)
    brand.TextSize = 14
    brand.Font = Enum.Font.Ubuntu
    brand.TextXAlignment = Enum.TextXAlignment.Left
    brand.Parent = holder
    
    local sep = Instance.new("TextLabel")
    sep.Size = UDim2.new(0, 10, 1, 0)
    sep.Position = UDim2.new(0, 95, 0, 1)
    sep.BackgroundTransparency = 1
    sep.Text = "|"
    sep.TextColor3 = Color3.fromRGB(60, 60, 60)
    sep.TextSize = 14
    sep.Parent = holder

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -115, 1, 0)
    status.Position = UDim2.new(0, 110, 0, 1)
    status.BackgroundTransparency = 1
    status.Text = "SEX"
    status.TextColor3 = Color3.fromRGB(255, 105, 180)
    status.TextSize = 13
    status.Font = Enum.Font.Code
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = holder
    
    task.delay(2.5, function()
        status.Text = "searching threats..."
        status.TextColor3 = Color3.fromRGB(180, 180, 180)
    end)
    
    return status, stroke
end

-- Инициализация
createBigBanner()
local statusLabel, mainStroke = createWatermark()

-- Настройки
local SETTINGS = {
    BlockDistance = 25,
    Enabled = true,
    BlockKey = Enum.KeyCode.F
}

local isBlocking = false

-- Функция активации блока
local function setBlockState(active)
    local char = Player.Character
    if not char then return end

    char:SetAttribute("Blocking", active)
    
    if active then
        if keypress then keypress(0x46) end
    else
        if keyrelease then keyrelease(0x46) end
    end

    if blockRemote and blockRemote:IsA("RemoteEvent") then
        blockRemote:FireServer(active)
    end
end

-- Проверка атаки
local function isEnemyAttacking(enemyChar)
    if not enemyChar or enemyChar == Player.Character then return false end
    
    local hum = enemyChar:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    
    if animator then
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            local animName = track.Animation.Name:lower()
            if animName:find("attack") or animName:find("punch") or animName:find("swing") or 
               animName:find("slash") or animName:find("execute") or animName:find("ability") or
               animName:find("m1") or animName:find("m2") or animName:find("hit") or 
               animName:find("dash") or animName:find("strong") or animName:find("ultimate") or
               animName:find("combo") or animName:find("skill") then
                return true
            end
        end
    end
    return false
end

-- Основной цикл
RunService.PostSimulation:Connect(function()
    if not SETTINGS.Enabled then 
        statusLabel.Text = "status: disabled"
        statusLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
        return 
    end
    
    local myChar = Player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local shouldBlock = false
    
    for _, otherPlayer in pairs(game:GetService("Players"):GetPlayers()) do
        if otherPlayer ~= Player then
            local enemyChar = otherPlayer.Character
            if enemyChar then
                local enemyRoot = enemyChar:FindFirstChild("HumanoidRootPart")
                local enemyHum = enemyChar:FindFirstChildOfClass("Humanoid")
                
                if enemyRoot and enemyHum and enemyHum.Health > 0 then
                    local dist = (myRoot.Position - enemyRoot.Position).Magnitude
                    if dist <= SETTINGS.BlockDistance then
                        if isEnemyAttacking(enemyChar) then
                            shouldBlock = true
                            break
                        end
                    end
                end
            end
        end
    end
    
    if shouldBlock and not isBlocking then
        isBlocking = true
        statusLabel.Text = "status: blocking"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
        TweenService:Create(mainStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(0, 255, 150)}):Play()
        setBlockState(true)
    elseif not shouldBlock and isBlocking then
        isBlocking = false
        if statusLabel.Text ~= "SEX" then
            statusLabel.Text = "status: active"
            statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        TweenService:Create(mainStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(40, 40, 40)}):Play()
        setBlockState(false)
    end
end)

print("--- GONDON.SENSE V4 Loaded ---")
