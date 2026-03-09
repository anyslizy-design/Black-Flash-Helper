--[[
    Jujutsu Shenanigans Auto Block Script (Optimized)
    Совместимость: Xeno / Executor
    Описание: Версия с ватермаркой (Watermark) и улучшенным детектом атак.
]]

local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Создание Watermark
local function createWatermark()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "JJS_Watermark"
    -- Пытаемся поместить в CoreGui для скрытия от скриншотов, иначе в PlayerGui
    screenGui.Parent = (gethui and gethui()) or CoreGui or Player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 200, 0, 40)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Скругление углов
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Обводка
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(138, 43, 226) -- Фиолетовый цвет (стиль JJS)
    stroke.Thickness = 2
    stroke.Parent = mainFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "JJS | Auto Block: ACTIVE"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Parent = mainFrame
    
    return label
end

local statusLabel = createWatermark()

-- Настройки
local SETTINGS = {
    BlockDistance = 18,
    Enabled = true,
    BlockKey = Enum.KeyCode.F
}

-- Переменные состояния
local isBlocking = false

-- Функция проверки атаки
local function isAttacking(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    
    if animator then
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            local animName = track.Animation.Name:lower()
            -- Расширенный список ключевых слов для JJS
            if animName:find("attack") or animName:find("punch") or animName:find("swing") or 
               animName:find("slash") or animName:find("execute") or animName:find("ability") or
               animName:find("m1") or animName:find("m2") then
                return true
            end
        end
    end
    return false
end

-- Основной цикл обработки
RunService.RenderStepped:Connect(function()
    if not SETTINGS.Enabled then 
        statusLabel.Text = "JJS | Auto Block: OFF"
        statusLabel.TextColor3 = Color3.fromRGB(200, 0, 0)
        return 
    end
    
    local character = Player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local shouldBlock = false
    
    -- Поиск ближайшего атакующего противника
    for _, enemyPlayer in pairs(game:GetService("Players"):GetPlayers()) do
        if enemyPlayer ~= Player and enemyPlayer.Character then
            local enemyRoot = enemyPlayer.Character:FindFirstChild("HumanoidRootPart")
            if enemyRoot then
                local dist = (root.Position - enemyRoot.Position).Magnitude
                if dist <= SETTINGS.BlockDistance then
                    if isAttacking(enemyPlayer.Character) then
                        shouldBlock = true
                        break
                    end
                end
            end
        end
    end
    
    -- Логика нажатия
    if shouldBlock and not isBlocking then
        isBlocking = true
        statusLabel.Text = "JJS | Auto Block: BLOCKING"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        if keypress then keypress(0x46) end -- Клавиша F
        
    elseif not shouldBlock and isBlocking then
        isBlocking = false
        statusLabel.Text = "JJS | Auto Block: ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        if keyrelease then keyrelease(0x46) end -- Отпустить F
    end
end)

print("--- Auto Block JJS Loaded with Watermark ---")
