--[[
    JJS.SENSE Premium Interface
    Совместимость: Xeno / Любой современный инжектор
    Описание: Обновленный визуальный стиль "Modern Dark". Добавлена пасхалка при загрузке.
]]

local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Поиск события блока
local blockRemote = ReplicatedStorage:FindFirstChild("Block", true) or ReplicatedStorage:FindFirstChild("CombatRes", true)

-- Создание премиального Watermark
local function createWatermark()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "JJS_SENSE_V4"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = (gethui and gethui()) or CoreGui or Player:WaitForChild("PlayerGui")
    
    -- Контейнер с тенью
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
    
    -- Анимированная градиентная полоска
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
        ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)), -- Фиолетовый
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)), -- Циан
        ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 43, 226))
    })
    uigradient.Parent = gradientBar
    
    -- Анимация градиента
    task.spawn(function()
        while true do
            local t = tick() * 0.5
            uigradient.Offset = Vector2.new(math.sin(t), 0)
            task.wait()
        end
    end)

    -- Обводка
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(40, 40, 40)
    stroke.Thickness = 1
    stroke.Parent = holder

    -- Текст (Бренд)
    local brand = Instance.new("TextLabel")
    brand.Size = UDim2.new(0, 80, 1, 0)
    brand.Position = UDim2.new(0, 10, 0, 1)
    brand.BackgroundTransparency = 1
    brand.Text = "jjs.sense"
    brand.TextColor3 = Color3.fromRGB(255, 255, 255)
    brand.TextSize = 14
    brand.Font = Enum.Font.Ubuntu
    brand.TextXAlignment = Enum.TextXAlignment.Left
    brand.Parent = holder
    
    -- Разделитель
    local sep = Instance.new("TextLabel")
    sep.Size = UDim2.new(0, 10, 1, 0)
    sep.Position = UDim2.new(0, 75, 0, 1)
    sep.BackgroundTransparency = 1
    sep.Text = "|"
    sep.TextColor3 = Color3.fromRGB(60, 60, 60)
    sep.TextSize = 14
    sep.Parent = holder

    -- Текст статуса
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -95, 1, 0)
    status.Position = UDim2.new(0, 90, 0, 1)
    status.BackgroundTransparency = 1
    status.Text = "SEX" -- Надпись при загрузке
    status.TextColor3 = Color3.fromRGB(255, 105, 180) -- Розовый цвет для эффекта
    status.TextSize = 13
    status.Font = Enum.Font.Code
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = holder
    
    -- Таймер смены надписи
    task.delay(2.5, function()
        status.Text = "searching threats..."
        status.TextColor3 = Color3.fromRGB(180, 180, 180)
    end)
    
    return status, stroke, uigradient
end

local statusLabel, mainStroke, barGradient = createWatermark()

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
local function isAttacking(char)
    if char == Player.Character then return false end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
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
    
    local character = Player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local shouldBlock = false
    
    for _, enemy in pairs(game:GetService("Players"):GetPlayers()) do
        if enemy ~= Player and enemy.Character then
            local enemyRoot = enemy.Character:FindFirstChild("HumanoidRootPart")
            local enemyHum = enemy.Character:FindFirstChildOfClass("Humanoid")
            
            if enemyRoot and enemyHum and enemyHum.Health > 0 then
                local dist = (root.Position - enemyRoot.Position).Magnitude
                if dist <= SETTINGS.BlockDistance then
                    if isAttacking(enemy.Character) then
                        shouldBlock = true
                        break
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
        -- Возвращаем статус только если прошло время начальной заставки
        if statusLabel.Text ~= "SEX" then
            statusLabel.Text = "status: active"
            statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        TweenService:Create(mainStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(40, 40, 40)}):Play()
        setBlockState(false)
    end
end)

print("--- JJS.SENSE V4 (Animated) Loaded ---")
