--[[
    Learning Mode для Jujutsu Shenanigans (Xeno)
    Запоминает анимации, которые проигрываются на других игроках в момент получения урона.
    Сохраняет список в файл jjs_attacks.txt
--]]

local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")

-- Константы
local HISTORY_WINDOW = 0.5      -- интервал времени до урона (сек), в котором ищем анимации
local SAVE_FILE = "jjs_attacks.txt"
local NOTIFICATION_DURATION = 2 -- секунды показа уведомления

-- Множество известных атак (название -> true)
local attackAnimations = {}

-- История анимаций для каждого игрока: history[player] = { [animName] = time }
local history = {}

-- Функция загрузки сохранённого списка
local function loadAttacks()
    local success, data = pcall(readfile, SAVE_FILE)
    if success and data then
        for name in string.gmatch(data, "[^\r\n]+") do
            attackAnimations[name] = true
        end
        print("Загружено анимаций: " .. table.count(attackAnimations))
    end
end

-- Функция сохранения списка в файл
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

-- Уведомление на экране (через PlayerGui)
local function notify(text)
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
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = frame
    
    -- Автоматическое удаление через NOTIFICATION_DURATION секунд
    task.wait(NOTIFICATION_DURATION)
    screenGui:Destroy()
end

-- Подписка на анимации конкретного игрока (врага)
local function watchEnemy(enemy)
    local function onCharacterAdded(char)
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        -- Создаём запись в истории для этого игрока, если её нет
        if not history[enemy] then
            history[enemy] = {}
        end
        
        -- При каждой новой анимации записываем её с текущим временем
        humanoid.AnimationTrackPlayed:Connect(function(animationTrack)
            local now = tick()
            local animName = animationTrack.Name
            history[enemy][animName] = now
            
            -- Очищаем старые записи этого игрока (старше 1 секунды)
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

-- Подписка на получение урона игроком
local function watchDamage()
    local function onCharacterAdded(char)
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        local lastHealth = humanoid.Health
        humanoid.HealthChanged:Connect(function(newHealth)
            if newHealth < lastHealth then
                -- Здоровье уменьшилось → возможно, получен урон
                local now = tick()
                
                -- Собираем анимации со всех врагов, попавшие в интервал [now - HISTORY_WINDOW, now]
                for enemy, anims in pairs(history) do
                    if enemy ~= player then
                        for animName, animTime in pairs(anims) do
                            if animTime >= now - HISTORY_WINDOW and animTime <= now then
                                if not attackAnimations[animName] then
                                    attackAnimations[animName] = true
                                    notify("Зафиксированно: " .. animName)
                                    print("Новая атака: " .. animName)
                                    saveAttacks() -- сохраняем при каждом добавлении
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

-- Инициализация: загружаем старые атаки, подписываемся на всех существующих игроков
loadAttacks()

for _, p in ipairs(game.Players:GetPlayers()) do
    if p ~= player then
        watchEnemy(p)
    end
end

-- Подписываемся на новых игроков
game.Players.PlayerAdded:Connect(watchEnemy)

-- Запускаем прослушку урона
watchDamage()

print("Режим обучения активирован. Наносите урон, чтобы записывать анимации.")
