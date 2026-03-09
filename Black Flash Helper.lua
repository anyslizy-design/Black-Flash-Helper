--[[
    AutoBlock + AutoLearn для Jujutsu Shenanigans (Xeno)
    Блокирует известные атаки, автоматически учится новым при получении урона.
    Список атак сохраняется в jjs_attacks.txt (создаётся автоматически).
--]]

local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")

-- ======= НАСТРОЙКИ =======
local BLOCK_RADIUS = 5               -- радиус для блока (студий)
local ATTACK_DURATION = 1.2          -- сколько секунд удерживать F после начала атаки
local HISTORY_WINDOW = 0.5            -- окно для обучения (сек до урона)
local SAVE_FILE = "jjs_attacks.txt"   -- имя файла со списком атак
-- =========================

-- Таблица известных атак (название -> true)
local attackAnimations = {}

-- Активные атаки: список времён окончания (когда нужно отпустить F)
local activeAttacks = {}
local isBlocking = false

-- История анимаций для каждого игрока (для обучения)
local history = {}

-- Функция загрузки списка из файла
local function loadAttacks()
    local success, data = pcall(readfile, SAVE_FILE)
    if success and data then
        for name in string.gmatch(data, "[^\r\n]+") do
            attackAnimations[name] = true
        end
        print("Загружено атак: " .. table.count(attackAnimations))
    else
        -- Файла нет — создаём пустой
        pcall(writefile, SAVE_FILE, "")
        print("Создан новый файл " .. SAVE_FILE)
    end
end

-- Сохранение списка в файл
local function saveAttacks()
    local lines = {}
    for name in pairs(attackAnimations) do
        table.insert(lines, name)
    end
    local success, err = pcall(writefile, SAVE_FILE, table.concat(lines, "\n"))
    if not success then
        warn("Не удалось сохранить файл: " .. tostring(err))
    end
end

-- Эмуляция нажатия F (код 70)
local function pressF()
    keypress(70)
end

local function releaseF()
    keyrelease(70)
end

-- Проверка, находится ли враг в радиусе блока
local function isEnemyInRange(enemyChar)
    local myChar = player.Character
    if not myChar then return false end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local enemyRoot = enemyChar and enemyChar:FindFirstChild("HumanoidRootPart")
    if not myRoot or not enemyRoot then return false end
    return (myRoot.Position - enemyRoot.Position).Magnitude <= BLOCK_RADIUS
end

-- Подписка на анимации конкретного игрока (для истории и блока)
local function watchEnemy(enemy)
    local function onCharacterAdded(char)
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return end

        -- Инициализируем историю для этого игрока
        if not history[enemy] then
            history[enemy] = {}
        end

        humanoid.AnimationTrackPlayed:Connect(function(animationTrack)
            local now = tick()
            local animName = animationTrack.Name

            -- Сохраняем в историю
            history[enemy][animName] = now
            -- Очистка старых записей (старше 1 сек)
            for name, t in pairs(history[enemy]) do
                if now - t > 1 then
                    history[enemy][name] = nil
                end
            end

            -- Если анимация известна и враг в радиусе — добавляем в активные
            if attackAnimations[animName] and isEnemyInRange(char) then
                table.insert(activeAttacks, now + ATTACK_DURATION)
            end
        end)
    end

    if enemy.Character then
        onCharacterAdded(enemy.Character)
    end
    enemy.CharacterAdded:Connect(onCharacterAdded)
end

-- Обработка получения урона (обучение новым анимациям)
local function onDamage()
    local now = tick()

    -- Проходим по всем игрокам в истории (включая себя)
    for enemy, anims in pairs(history) do
        -- Можно исключить себя, раскомментировав следующую строку:
        -- if enemy == player then continue end
        for animName, animTime in pairs(anims) do
            if animTime >= now - HISTORY_WINDOW and animTime <= now then
                if not attackAnimations[animName] then
                    attackAnimations[animName] = true
                    print("Новая атака добавлена: " .. animName)
                    saveAttacks()   -- сразу сохраняем в файл
                end
            end
        end
    end
end

-- Подписка на урон игрока
local function watchDamage()
    local function onCharacterAdded(char)
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return end

        local lastHealth = humanoid.Health
        humanoid.HealthChanged:Connect(function(newHealth)
            if newHealth < lastHealth then
                onDamage()
            end
            lastHealth = newHealth
        end)
    end

    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
end

-- Цикл управления блоком
local function blockLoop()
    while true do
        local now = tick()
        -- Удаляем истёкшие атаки
        for i = #activeAttacks, 1, -1 do
            if activeAttacks[i] < now then
                table.remove(activeAttacks, i)
            end
        end

        -- Управление F
        if #activeAttacks > 0 and not isBlocking then
            pressF()
            isBlocking = true
        elseif #activeAttacks == 0 and isBlocking then
            releaseF()
            isBlocking = false
        end

        runService.Heartbeat:Wait()
    end
end

-- ====== ИНИЦИАЛИЗАЦИЯ ======
loadAttacks()

-- Подписываемся на всех существующих игроков
for _, p in ipairs(game.Players:GetPlayers()) do
    watchEnemy(p)
end

-- Подписываемся на новых игроков
game.Players.PlayerAdded:Connect(watchEnemy)

-- Следим за своим здоровьем
watchDamage()

-- Запускаем цикл блока в фоне
coroutine.wrap(blockLoop)()

print("Автоблок с автоматическим обучением запущен. Радиус: " .. BLOCK_RADIUS .. " студий. Файл: " .. SAVE_FILE)
