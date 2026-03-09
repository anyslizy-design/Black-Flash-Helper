--[[
    Learning Mode для Jujutsu Shenanigans (Xeno)
    Запоминает анимации, которые проигрываются на других игроках в момент получения урона.
    Сохраняет список в файл jjs_attacks.txt
    Добавлен постоянный watermark "Learn" в левом верхнем углу.
--]]

local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")

-- Константы
local HISTORY_WINDOW = 0.5
local SAVE_FILE = "jjs_attacks.txt"
local NOTIFICATION_DURATION = 2

-- Множество известных атак
local attackAnimations = {}
local history = {}

-- Функция загрузки
local function loadAttacks()
    local success, data = pcall(readfile, SAVE_FILE)
    if success and data then
        for name in string.gmatch(data, "[^\r\n]+") do
            attackAnimations[name] = true
        end
        print("Загружено анимаций: " .. table.count(attackAnimations))
    end
end

-- Сохранение
local function saveAttacks()
    local lines = {}
    for name in pairs(attackAnimations) do
        table.insert(lines, name)
    end
    local success, err = pcall(writefile, SAVE_FILE, table.concat(lines, "\n"))
    if not success then
        warn("Не удалось сохранить файл: " .. tostring(err))
    else
        print("Список атак сохранён в " .. SAVE_FILE)
    end
end

-- Уведомление о новой анимации (центр экрана)
local function notifyNewAttack(animName)
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LearningNotification"
    screenGui.Parent = gui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 50)
    frame.Position = UDim2.new(0.5, -150, 0.2, -25)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "Зафиксированно: " .. animName
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = frame
    
    task.wait(NOTIFICATION_DURATION)
    screenGui:Destroy()
end

-- Создание постоянного watermark
local function createWatermark()
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then return end
    
    -- Удаляем старый, если есть
    local old = gui:FindFirstChild("LearnWatermark")
    if old then old:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LearnWatermark"
    screenGui.Parent = gui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 80, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, 10) -- левый верхний угол
    frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "Learn"
    label.TextColor3 = Color3.new(0, 1, 0) -- зелёный
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = frame
end

-- Подписка на анимации врага
local function watchEnemy(enemy)
    local function onCharacterAdded(char)
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        if not history[enemy] then
            history[enemy] = {}
        end
        
        humanoid.AnimationTrackPlayed:Connect(function(animationTrack)
            local now = tick()
            local animName = animationTrack.Name
            history[enemy][animName] = now
            for name, t in pairs(history[enemy]) do
                if now - t > 1 then
                    history[enemy][name] = nil
                end
            end
        end)
    end
    
    if enemy.Character then
        onCharacterAdded(enemy.Character)
    end
    enemy.CharacterAdded:Connect(onCharacterAdded)
end

-- Подписка на получение урона
local function watchDamage()
    local function onCharacterAdded(char)
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        local lastHealth = humanoid.Health
        humanoid.HealthChanged:Connect(function(newHealth)
            if newHealth < lastHealth then
                local now = tick()
                for enemy, anims in pairs(history) do
                    if enemy ~= player then
                        for animName, animTime in pairs(anims) do
                            if animTime >= now - HISTORY_WINDOW and animTime <= now then
                                if not attackAnimations[animName] then
                                    attackAnimations[animName] = true
                                    notifyNewAttack(animName)
                                    print("Новая атака: " .. animName)
                                    saveAttacks()
                                end
                            end
                        end
                    end
                end
            end
            lastHealth = newHealth
        end)
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
end

-- Инициализация
loadAttacks()

-- Создаём watermark при загрузке персонажа
local function setupWatermark()
    createWatermark()
    -- Обновляем watermark при смене персонажа (на всякий случай)
    player.CharacterAdded:Connect(createWatermark)
end

if player.Character then
    setupWatermark()
else
    player.CharacterAdded:Connect(setupWatermark)
end

-- Подписка на игроков
for _, p in ipairs(game.Players:GetPlayers()) do
    if p ~= player then
        watchEnemy(p)
    end
end
game.Players.PlayerAdded:Connect(watchEnemy)

-- Запуск прослушки урона
watchDamage()

print("Режим обучения активирован. Watermark 'Learn' в левом верхнем углу.")
