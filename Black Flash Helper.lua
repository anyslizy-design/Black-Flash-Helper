--[[
    Jujutsu Shenanigans Auto Block Script (Universal V2)
    Совместимость: Xeno / Electron / Solara / Any Executor
    Описание: Версия с ватермаркой и альтернативными методами нажатия.
]]

local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

-- Создание Watermark
local function createWatermark()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "JJS_Watermark"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = (gethui and gethui()) or CoreGui or Player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 220, 0, 45)
    mainFrame.Position = UDim2.new(0, 15, 0, 15)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(138, 43, 226)
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
    BlockDistance = 20,
    Enabled = true,
    BlockKey = "F", -- Клавиша в строковом формате
    KeyByte = 0x46 -- HEX код для F
}

-- Переменные состояния
local isBlocking = false

-- Функция симуляции нажатия (Альтернативный метод)
local function setBlock(state)
    if state then
        -- Метод 1: Стандартный keypress
        if keypress then keypress(SETTINGS.KeyByte) end
        -- Метод 2: VirtualUser (на случай если keypress заблокирован)
        VirtualUser:ButtonDown(Enum.UserInputType.Keyboard, SETTINGS.BlockKey, workspace)
    else
        -- Отпускаем
        if keyrelease then keyrelease(SETTINGS.KeyByte) end
        VirtualUser:ButtonUp(Enum.UserInputType.Keyboard, SETTINGS.BlockKey, workspace)
    end
end

-- Функция проверки атаки
local function isAttacking(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    
    if animator then
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            local animName = track.Animation.Name:lower()
            -- Расширенный список анимаций атак для JJS
            if animName:find("attack") or animName:find("punch") or animName:find("swing") or 
               animName:find("slash") or animName:find("execute") or animName:find("ability") or
               animName:find("m1") or animName:find("m2") or animName:find("hit") or 
               animName:find("dash_attack") then
                return true
            end
        end
    end
    return false
end

-- Основной цикл обработки
RunService.Heartbeat:Connect(function()
    if not SETTINGS.Enabled then 
        statusLabel.Text = "JJS | Auto Block: OFF"
        statusLabel.TextColor3 = Color3.fromRGB(200, 0, 0)
        return 
    end
    
    local character = Player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local shouldBlock = false
    
    -- Поиск противников
    for _, enemyPlayer in pairs(game:GetService("Players"):GetPlayers()) do
        if enemyPlayer ~= Player and enemyPlayer.Character then
            local enemyRoot = enemyPlayer.Character:FindFirstChild("HumanoidRootPart")
            local enemyHum = enemyPlayer.Character:FindFirstChildOfClass("Humanoid")
            
            if enemyRoot and enemyHum and enemyHum.Health > 0 then
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
    
    -- Управление блоком
    if shouldBlock then
        if not isBlocking then
            isBlocking = true
            statusLabel.Text = "JJS | Auto Block: BLOCKING"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            setBlock(true)
        end
    else
        if isBlocking then
            isBlocking = false
            statusLabel.Text = "JJS | Auto Block: ACTIVE"
            statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            setBlock(false)
        end
    end
end)

print("--- Auto Block JJS V2 Loaded ---")
