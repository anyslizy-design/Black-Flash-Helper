--[[
    AutoBlock для Jujutsu Shenanigans
    Инжектор: Xeno
    Файл анимаций: C:\Users\ТВОЁИМЯ\Desktop\jjs_attacks.txt
    (или просто "jjs_attacks.txt" на рабочем столе)
]]

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ===== НАСТРОЙКИ (можно менять) =====
local BLOCK_DISTANCE = 25      -- дальность реакции
local COOLDOWN = 0.3           -- задержка между блоками
-- ====================================

-- Читаем анимации из файла на рабочем столе
local attackNames = {}
local filePath = os.getenv("USERPROFILE") .. "\\Desktop\\jjs_attacks.txt"
local file = io.open(filePath, "r")
if file then
    for line in file:lines() do
        local name = line:match("^%s*(.-)%s*$") -- обрезка пробелов
        if name and name ~= "" then
            table.insert(attackNames, name)
        end
    end
    file:close()
    print("✅ AutoBlock: загружено атак из файла: " .. #attackNames)
else
    warn("❌ Файл jjs_attacks.txt не найден на рабочем столе. Скрипт остановлен.")
    return
end

-- Определяем способ активации блока (автоматически)
local blockFunction = nil

-- Вариант 1: RemoteEvent (часто используется в игре)
local possibleRemotes = {
    ReplicatedStorage:FindFirstChild("Block"),
    ReplicatedStorage:FindFirstChild("Guard"),
    ReplicatedStorage:FindFirstChild("BlockEvent"),
    ReplicatedStorage:FindFirstChild("ActivateBlock"),
    player:FindFirstChild("Block"),
    player:FindFirstChild("Guard"),
}

for _, remote in ipairs(possibleRemotes) do
    if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
        blockFunction = function()
            remote:FireServer() -- для RemoteEvent
            -- если RemoteFunction, то :InvokeServer() без ожидания ответа
        end
        print("🔌 AutoBlock: используется RemoteEvent - " .. remote.Name)
        break
    end
end

-- Вариант 2: Humanoid State (если RemoteEvent не нашёлся)
if not blockFunction then
    -- Включаем защиту через состояние Humanoid (если игра использует стандартный механизм)
    blockFunction = function()
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false) -- неважно что, главное вызвать защиту
            -- но это костыль, лучше через RemoteEvent
        end
    end
    print("⚠️ AutoBlock: RemoteEvent не найден, используется fallback (может не работать)")
end

-- Проверка дистанции
local function isEnemyClose(char)
    if not player.Character then return false end
    local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
    local enemyRoot = char:FindFirstChild("HumanoidRootPart")
    if myRoot and enemyRoot then
        return (myRoot.Position - enemyRoot.Position).Magnitude < BLOCK_DISTANCE
    end
    return false
end

-- Поиск анимаций атаки у противника
local function hasAttackAnimation(char)
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return false end
    local tracks = humanoid:GetPlayingAnimationTracks()
    for _, track in ipairs(tracks) do
        local animName = track.Animation and track.Animation.Name or track.Name
        for _, attackName in ipairs(attackNames) do
            if animName == attackName then
                return true
            end
        end
    end
    return false
end

-- Основной цикл
local lastBlock = 0
local blocking = false

RunService.Heartbeat:Connect(function()
    if blocking or tick() - lastBlock < COOLDOWN then return end

    local myChar = player.Character
    if not myChar or not myChar:FindFirstChild("Humanoid") or myChar.Humanoid.Health <= 0 then return end

    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player then
            local otherChar = otherPlayer.Character
            if otherChar and otherChar:FindFirstChild("Humanoid") and otherChar.Humanoid.Health > 0 then
                if isEnemyClose(otherChar) and hasAttackAnimation(otherChar) then
                    blocking = true
                    blockFunction()  -- вызываем блок
                    lastBlock = tick()
                    blocking = false
                    break
                end
            end
        end
    end
end)

print("🚀 AutoBlock запущен, жду анимации из списка...")
