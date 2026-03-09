--[[
    Jujutsu Shenanigans Auto Block Script (Advanced Bypass)
    Совместимость: Xeno / Любой современный инжектор
    Описание: Версия с обновленным дизайном ватермарка и обходом защиты.
]]

local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- Создание улучшенного Watermark
local function createWatermark()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "JJS_Premium_Watermark"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = (gethui and gethui()) or CoreGui or Player:WaitForChild("PlayerGui")
    
    -- Основной контейнер
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 240, 0, 40)
    mainFrame.Position = UDim2.new(0, 20, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = mainFrame
    
    -- Градиентная полоска сверху
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(1, 0, 0, 2)
    accentBar.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    accentBar.BorderSizePixel = 0
    accentBar.Parent = mainFrame
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 6)
    barCorner.Parent = accentBar

    -- Тень/Свечение
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(138, 43, 226)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.5
    stroke.Parent = mainFrame

    -- Текст заголовка
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 100, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "JJS.SENSE"
    titleLabel.TextColor3 = Color3.fromRGB(138, 43, 226)
    titleLabel.TextSize = 15
    titleLabel.Font = Enum.Font.Ubuntu
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = mainFrame
    
    -- Разделитель
    local separator = Instance.new("Frame")
    separator.Size = UDim2.new(0, 1, 0, 18)
    separator.Position = UDim2.new(0, 95, 0.5, -9)
    separator.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    separator.BorderSizePixel = 0
    separator.Parent = mainFrame

    -- Текст статуса
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -110, 1, 0)
    statusLabel.Position = UDim2.new(0, 105, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "waiting..."
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextSize = 13
    statusLabel.Font = Enum.Font.Code
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = mainFrame
    
    return statusLabel, stroke
end

local statusLabel, mainStroke = createWatermark()

-- Настройки
local SETTINGS = {
    BlockDistance = 22,
    Enabled = true,
    BlockKey = Enum.KeyCode.F
}

-- Переменные состояния
local isBlocking = false

-- Функция активации блока
local function setBlockState(active)
    local char = Player.Character
    if not char then return end

    char:SetAttribute("Blocking", active)
    
    local CAS = game:GetService("ContextActionService")
    if active then
        if keypress then keypress(0x46) end
        CAS:CallAction("BlockAction", Enum.UserInputState.Begin, nil)
    else
        if keyrelease then keyrelease(0x46) end
        CAS:CallAction("BlockAction", Enum.UserInputState.End, nil)
    end
end

-- Проверка атаки
local function isAttacking(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    
    if animator then
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            local animName = track.Animation.Name:lower()
            if animName:find("attack") or animName:find("punch") or animName:find("swing") or 
               animName:find("slash") or animName:find("execute") or animName:find("ability") or
               animName:find("m1") or animName:find("m2") or animName:find("hit") or 
               animName:find("dash") or animName:find("strong") or animName:find("ultimate") then
                return true
            end
        end
    end
    return false
end

-- Основной цикл
RunService.PostSimulation:Connect(function()
    if not SETTINGS.Enabled then 
        statusLabel.Text = "disabled"
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
        statusLabel.Text = "blocking"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        mainStroke.Transparency = 0
        setBlockState(true)
    elseif not shouldBlock and isBlocking then
        isBlocking = false
        statusLabel.Text = "active"
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        mainStroke.Transparency = 0.5
        setBlockState(false)
    end
end)

print("--- JJS.SENSE Loaded ---")
