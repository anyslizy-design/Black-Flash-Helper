--[[
    AutoBlock + AutoLearn — ФИНАЛ
    Основан на твоём рабочем тестовом скрипте.
--]]

local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")

-- ======= НАСТРОЙКИ =======
local BLOCK_RADIUS = 5
local ATTACK_DURATION = 1.2
local HISTORY_WINDOW = 0.5
local SAVE_FILE = "jjs_attacks.txt"
-- =========================

local attackAnimations = {}
local activeAttacks = {}
local isBlocking = false
local history = {}

-- Загрузка списка атак
local function loadAttacks()
    local success, data = pcall(readfile, SAVE_FILE)
    if success and data then
        for name in string.gmatch(data, "[^\r\n]+") do
            attackAnimations[name] = true
        end
        print("Загружено атак: " .. table.count(attackAnimations))
    else
        pcall(writefile, SAVE_FILE, "")
        print("Создан новый файл " .. SAVE_FILE)
    end
end

local function saveAttacks()
    local lines = {}
    for name in pairs(attackAnimations) do
        table.insert(lines, name)
    end
    pcall(writefile, SAVE_FILE, table.concat(lines, "\n"))
    print("Список атак сохранён")
end

local function pressF() keypress(70) end
local function releaseF() keyrelease(70) end

local function isEnemyInRange(enemyChar)
    local myChar = player.Character
    if not myChar then return false end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local enemyRoot = enemyChar and enemyChar:FindFirstChild("HumanoidRootPart")
    if not myRoot or not enemyRoot then return false end
    return (myRoot.Position - enemyRoot.Position).Magnitude <= BLOCK_RADIUS
end

-- Функция показа уведомления
local function showNotification(text, color)
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Notif" .. math.random(1, 9999)
    screenGui.Parent = gui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 50)
    frame.Position = UDim2.new(0.5, -150, 0.3, -25)
    frame.BackgroundColor3 = color or Color3.new(0, 1, 0)
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

    task.wait(1.5)
    screenGui:Destroy()
end

-- Подписка на анимации врага (история)
local function watchEnemy(enemy)
    local function onCharacterAdded(char)
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return end

        if not history[enemy] then history[enemy] = {} end

        humanoid.AnimationTrackPlayed:Connect(function(animationTrack)
            local now = tick()
            local animName = animationTrack.Name
            history[enemy][animName] = now
            -- Очистка старых записей
            for name, t in pairs(history[enemy]) do
                if now - t > 1 then history[enemy][name] = nil end
            end

            -- Блокировка известных атак
            if attackAnimations[animName] and isEnemyInRange(char) then
                table.insert(activeAttacks, now + ATTACK_DURATION)
                print("[Блок] Атака: " .. animName)
            end
        end)
    end

    if enemy.Character then onCharacterAdded(enemy.Character) end
    enemy.CharacterAdded:Connect(onCharacterAdded)
end

-- *** ЭТО ГЛАВНОЕ: ДЕТЕКЦИЯ УРОНА (КОПИЯ ТВОЕГО ТЕСТОВОГО СКРИПТА) ***
local function watchDamage()
    local function onCharacterAdded(char)
        -- Отслеживаем появление новых объектов (звуки, эффекты)
        char.DescendantAdded:Connect(function(inst)
            local name = inst.Name:lower()
            -- Проверяем, содержит ли имя ключевые слова урона
            if name:find("hit") or name:find("hurt") or name:find("damage") or name:find("oof") then
                -- Показываем уведомление (как в тестовом скрипте)
                showNotification("Получен урон! (" .. inst.Name .. ")", Color3.new(1, 1, 0))
                print("[УРОН] Обнаружен! Объект: " .. inst.Name)

                -- Теперь собираем анимации из истории
                local now = tick()
                for enemy, anims in pairs(history) do
                    for animName, animTime in pairs(anims) do
                        if animTime >= now - HISTORY_WINDOW and animTime <= now then
                            if not attackAnimations[animName] then
                                attackAnimations[animName] = true
                                showNotification("ЗАФИКСИРОВАННО: " .. animName, Color3.new(0, 1, 0))
                                print("[НОВАЯ АТАКА] " .. animName)
                                saveAttacks()
                            end
                        end
                    end
                end
            end
        end)
    end

    if player.Character then onCharacterAdded(player.Character) end
    player.CharacterAdded:Connect(onCharacterAdded)
end

-- Цикл блока
local function blockLoop()
    while true do
        local now = tick()
        for i = #activeAttacks, 1, -1 do
            if activeAttacks[i] < now then table.remove(activeAttacks, i) end
        end

        if #activeAttacks > 0 and not isBlocking then
            pressF()
            isBlocking = true
            print("[Блок] F НАЖАТ")
        elseif #activeAttacks == 0 and isBlocking then
            releaseF()
            isBlocking = false
            print("[Блок] F ОТПУЩЕН")
        end
        runService.Heartbeat:Wait()
    end
end

-- Водяной знак (простой и надёжный)
local function createWatermark()
    local gui = player:WaitForChild("PlayerGui")
    local old = gui:FindFirstChild("Watermark")
    if old then old:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Watermark"
    screenGui.Parent = gui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 150, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "AutoBlock + Learn"
    label.TextColor3 = Color3.new(0, 1, 0)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = frame
end

-- ЗАПУСК
player.CharacterAdded:Connect(createWatermark)
if player.Character then createWatermark() end

loadAttacks()

for _, p in ipairs(game.Players:GetPlayers()) do watchEnemy(p) end
game.Players.PlayerAdded:Connect(watchEnemy)

watchDamage()  -- запускаем детекцию урона

coroutine.wrap(blockLoop)()

print("ФИНАЛЬНАЯ ВЕРСИЯ ЗАПУЩЕНА")
showNotification("Скрипт активен", Color3.new(0, 1, 0))
